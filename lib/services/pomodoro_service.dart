import 'package:shared_preferences/shared_preferences.dart';
import 'dart:collection';
import 'dart:convert';
import '../models/pomodoro_record.dart';
import '../models/focus_time.dart';
import '../utils/date_utils.dart';

class PomodoroService {
  static final PomodoroService _instance = PomodoroService._internal();
  factory PomodoroService() => _instance;
  PomodoroService._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // 초기화
  Future<void> initialize() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      await _migrateOldData(); // 기존 데이터 마이그레이션
    }
  }

  // 기존 데이터를 새로운 형식으로 마이그레이션
  Future<void> _migrateOldData() async {
    final keys = _prefs.getKeys();

    for (String key in keys) {
      if (key.startsWith('pomodoro_') && !key.contains('time')) {
        try {
          final dateString = key.substring(9);
          final date = DateTime.parse(dateString);

          // 기존 형식의 데이터가 있는지 확인
          final count = _prefs.getInt(key);
          final timeKey = 'pomodoro_time_$dateString';
          final timeString = _prefs.getString(timeKey);

          if (count != null && count > 0) {
            // 기존 데이터를 새로운 형식으로 변환
            final times = timeString?.split(',') ?? [];
            final focusTimes = <FocusTime>[];

            // 각 완료 시간을 FocusTime으로 변환 (대략적인 시작/종료 시간 추정)
            for (String timeStr in times) {
              if (timeStr.isNotEmpty) {
                final timeParts = timeStr.split(':');
                if (timeParts.length == 2) {
                  final hour = int.parse(timeParts[0]);
                  final minute = int.parse(timeParts[1]);

                  // 시작 시간 (완료 시간에서 25분 전으로 추정)
                  final startTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    hour,
                    minute,
                  ).subtract(const Duration(minutes: 25));

                  // 종료 시간 (완료 시간)
                  final endTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    hour,
                    minute,
                  );

                  focusTimes.add(
                    FocusTime(startTime: startTime, endTime: endTime),
                  );
                }
              }
            }

            // 새로운 형식으로 저장
            final record = PomodoroRecord(
              date: date,
              count: count,
              totalFocusMinutes: count * 25, // 25분씩 추정
              focusTimes: focusTimes,
            );

            await _prefs.setString(key, jsonEncode(record.toJson()));

            // 기존 시간 데이터 삭제
            await _prefs.remove(timeKey);
          }
        } catch (e) {
          print('데이터 마이그레이션 오류: $key - $e');
        }
      }
    }
  }

  // 뽀모도로 추가 (시작 시간과 종료 시간 포함)
  Future<void> addPomodoro(
    DateTime date,
    DateTime startTime,
    DateTime endTime,
  ) async {
    await initialize();

    final dateKey = 'pomodoro_${DateUtils.formatDate(date)}';
    final record = await getPomodoroRecord(date);

    final focusTime = FocusTime(startTime: startTime, endTime: endTime);
    final updatedRecord = record.addPomodoro(focusTime);

    await _prefs.setString(dateKey, jsonEncode(updatedRecord.toJson()));
  }

  // 특정 날짜의 뽀모도로 기록 가져오기
  Future<PomodoroRecord> getPomodoroRecord(DateTime date) async {
    await initialize();

    final dateKey = 'pomodoro_${DateUtils.formatDate(date)}';
    final jsonString = _prefs.getString(dateKey);

    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        return PomodoroRecord.fromJson(json);
      } catch (e) {
        print('JSON 파싱 오류: $e');
        // 오류 발생 시 기존 데이터 삭제
        await _prefs.remove(dateKey);
      }
    }

    return PomodoroRecord.empty(date);
  }

  // 모든 뽀모도로 기록 가져오기
  Future<LinkedHashMap<DateTime, PomodoroRecord>>
  getAllPomodoroRecords() async {
    await initialize();

    final Map<DateTime, PomodoroRecord> records = {};
    final keys = _prefs.getKeys();

    for (String key in keys) {
      if (key.startsWith('pomodoro_') && !key.contains('time')) {
        try {
          final dateString = key.substring(9);
          final date = DateTime.parse(dateString);
          final record = await getPomodoroRecord(date);
          records[date] = record;
        } catch (e) {
          print('날짜 파싱 오류: $key - $e');
          // 오류 발생 시 해당 키 삭제
          await _prefs.remove(key);
        }
      }
    }

    return LinkedHashMap<DateTime, PomodoroRecord>(
      equals: DateUtils.isSameDay,
      hashCode: (key) => DateUtils.getDateHashCode(key),
    )..addAll(records);
  }

  // 더미 데이터 추가 (테스트용) - 새로운 형식으로 수정
  Future<void> addDummyData() async {
    await initialize();
    print('더미 데이터 추가 시작');

    final now = DateTime.now();
    print('현재 시간: $now');

    // 3일 전
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    print('3일 전 날짜: $threeDaysAgo');
    await _addDummyRecord(threeDaysAgo, [
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day - 3, 9, 0),
        endTime: DateTime(now.year, now.month, now.day - 3, 9, 25),
      ),
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day - 3, 14, 30),
        endTime: DateTime(now.year, now.month, now.day - 3, 14, 55),
      ),
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day - 3, 16, 45),
        endTime: DateTime(now.year, now.month, now.day - 3, 17, 10),
      ),
    ]);

    // 2일 전
    final twoDaysAgo = now.subtract(const Duration(days: 2));
    print('2일 전 날짜: $twoDaysAgo');
    await _addDummyRecord(twoDaysAgo, [
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day - 2, 8, 15),
        endTime: DateTime(now.year, now.month, now.day - 2, 8, 40),
      ),
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day - 2, 10, 30),
        endTime: DateTime(now.year, now.month, now.day - 2, 10, 55),
      ),
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day - 2, 13, 45),
        endTime: DateTime(now.year, now.month, now.day - 2, 14, 10),
      ),
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day - 2, 15, 20),
        endTime: DateTime(now.year, now.month, now.day - 2, 15, 45),
      ),
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day - 2, 17, 0),
        endTime: DateTime(now.year, now.month, now.day - 2, 17, 25),
      ),
    ]);

    // 1일 전
    final oneDayAgo = now.subtract(const Duration(days: 1));
    print('1일 전 날짜: $oneDayAgo');
    await _addDummyRecord(oneDayAgo, [
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day - 1, 11, 0),
        endTime: DateTime(now.year, now.month, now.day - 1, 11, 25),
      ),
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day - 1, 15, 30),
        endTime: DateTime(now.year, now.month, now.day - 1, 15, 55),
      ),
    ]);

    // 오늘
    final today = DateTime(now.year, now.month, now.day);
    print('오늘 날짜: $today');
    await _addDummyRecord(today, [
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day, 8, 0),
        endTime: DateTime(now.year, now.month, now.day, 8, 25),
      ),
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day, 9, 30),
        endTime: DateTime(now.year, now.month, now.day, 9, 55),
      ),
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day, 11, 15),
        endTime: DateTime(now.year, now.month, now.day, 11, 40),
      ),
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day, 13, 0),
        endTime: DateTime(now.year, now.month, now.day, 13, 25),
      ),
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day, 14, 45),
        endTime: DateTime(now.year, now.month, now.day, 15, 10),
      ),
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day, 16, 30),
        endTime: DateTime(now.year, now.month, now.day, 16, 55),
      ),
      FocusTime(
        startTime: DateTime(now.year, now.month, now.day, 18, 0),
        endTime: DateTime(now.year, now.month, now.day, 18, 25),
      ),
    ]);

    print('더미 데이터 추가 완료');

    // 저장된 데이터 확인
    final allRecords = await getAllPomodoroRecords();
    print('저장된 레코드 수: ${allRecords.length}');
    for (var entry in allRecords.entries) {
      print('날짜: ${entry.key}, 개수: ${entry.value.count}');
    }
  }

  // 더미 기록 추가 헬퍼 메서드 (새로운 형식)
  Future<void> _addDummyRecord(
    DateTime date,
    List<FocusTime> focusTimes,
  ) async {
    final dateKey = 'pomodoro_${DateUtils.formatDate(date)}';
    print('더미 기록 추가: $dateKey, 개수: ${focusTimes.length}');

    final record = PomodoroRecord(
      date: date,
      count: focusTimes.length,
      totalFocusMinutes: focusTimes.fold(
        0,
        (sum, ft) => sum + ft.durationInMinutes,
      ),
      focusTimes: focusTimes,
    );

    final jsonString = jsonEncode(record.toJson());
    print('저장할 JSON: $jsonString');

    await _prefs.setString(dateKey, jsonString);
    print('더미 기록 저장 완료: $dateKey');
  }

  // 모든 데이터 삭제 (테스트용)
  Future<void> clearAllData() async {
    await initialize();
    await _prefs.clear();
    print('모든 데이터 삭제 완료');
  }

  // 특정 날짜 데이터 삭제
  Future<void> deletePomodoroRecord(DateTime date) async {
    await initialize();

    final dateKey = 'pomodoro_${DateUtils.formatDate(date)}';
    await _prefs.remove(dateKey);
  }

  // 특정 날짜의 특정 세션 삭제
  Future<void> deletePomodoroSession(DateTime date, int sessionIndex) async {
    await initialize();

    final dateKey = 'pomodoro_${DateUtils.formatDate(date)}';
    final record = await getPomodoroRecord(date);

    if (sessionIndex >= 0 && sessionIndex < record.focusTimes.length) {
      // 해당 세션 제거
      final updatedFocusTimes = List<FocusTime>.from(record.focusTimes);
      final removedSession = updatedFocusTimes.removeAt(sessionIndex);

      // 새로운 기록 생성
      final updatedRecord = PomodoroRecord(
        date: date,
        count: record.count - 1,
        totalFocusMinutes:
            record.totalFocusMinutes - removedSession.durationInMinutes,
        focusTimes: updatedFocusTimes,
      );

      // 업데이트된 기록 저장
      await _prefs.setString(dateKey, jsonEncode(updatedRecord.toJson()));
    } else {
      throw Exception('유효하지 않은 세션 인덱스입니다.');
    }
  }
}

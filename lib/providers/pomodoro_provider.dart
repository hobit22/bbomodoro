import 'package:flutter/foundation.dart';
import 'dart:collection';
import '../models/pomodoro_record.dart';
import '../models/focus_time.dart';
import '../services/pomodoro_service.dart';

class PomodoroProvider extends ChangeNotifier {
  final PomodoroService _pomodoroService = PomodoroService();

  LinkedHashMap<DateTime, PomodoroRecord> _pomodoroRecords = LinkedHashMap();
  bool _isLoading = false;
  String? _error;

  // Getters
  LinkedHashMap<DateTime, PomodoroRecord> get pomodoroRecords =>
      _pomodoroRecords;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 특정 날짜의 뽀모도로 기록 가져오기
  PomodoroRecord? getRecordForDate(DateTime date) {
    return _pomodoroRecords[date];
  }

  // 뽀모도로 추가 (시작 시간과 종료 시간 포함)
  Future<void> addPomodoro(
    DateTime date,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      await _pomodoroService.addPomodoro(date, startTime, endTime);
      await loadPomodoroRecords(); // 데이터 다시 로드
    } catch (e) {
      _error = '뽀모도로 추가 실패: $e';
      notifyListeners();
    }
  }

  // 모든 뽀모도로 기록 로드
  Future<void> loadPomodoroRecords() async {
    print('PomodoroProvider: 데이터 로드 시작');
    _setLoading(true);
    _error = null;

    try {
      final records = await _pomodoroService.getAllPomodoroRecords();
      _pomodoroRecords = records;
      print('PomodoroProvider: 데이터 로드 완료, 레코드 수: ${records.length}');
    } catch (e) {
      print('PomodoroProvider: 데이터 로드 실패: $e');
      _error = '데이터 로드 실패: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 더미 데이터 추가
  Future<void> addDummyData() async {
    print('PomodoroProvider: 더미 데이터 추가 시작');
    _setLoading(true);
    _error = null;

    try {
      await _pomodoroService.addDummyData();
      print('PomodoroProvider: 더미 데이터 서비스 호출 완료');
      await loadPomodoroRecords();
      print('PomodoroProvider: 더미 데이터 로드 완료');
    } catch (e) {
      print('PomodoroProvider: 더미 데이터 추가 실패: $e');
      _error = '더미 데이터 추가 실패: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 특정 날짜의 뽀모도로 기록 삭제
  Future<void> deletePomodoroRecord(DateTime date) async {
    try {
      await _pomodoroService.deletePomodoroRecord(date);
      await loadPomodoroRecords();
    } catch (e) {
      _error = '뽀모도로 기록 삭제 실패: $e';
      notifyListeners();
    }
  }

  // 모든 데이터 삭제
  Future<void> clearAllData() async {
    _setLoading(true);
    _error = null;

    try {
      await _pomodoroService.clearAllData();
      _pomodoroRecords.clear();
    } catch (e) {
      _error = '데이터 삭제 실패: $e';
    } finally {
      _setLoading(false);
    }
  }

  // 로딩 상태 설정
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 특정 날짜의 뽀모도로 개수 가져오기
  int getPomodoroCountForDate(DateTime date) {
    final record = _pomodoroRecords[date];
    return record?.count ?? 0;
  }

  // 특정 날짜의 완료 시간들 가져오기 (기존 호환성 유지)
  List<String> getCompletedTimesForDate(DateTime date) {
    final record = _pomodoroRecords[date];
    return record?.completedTimes ?? [];
  }

  // 특정 날짜의 총 집중 시간 가져오기 (분 단위)
  int getTotalFocusMinutesForDate(DateTime date) {
    final record = _pomodoroRecords[date];
    return record?.totalFocusMinutes ?? 0;
  }

  // 특정 날짜의 평균 집중 시간 가져오기 (분 단위)
  double getAverageFocusMinutesForDate(DateTime date) {
    final record = _pomodoroRecords[date];
    return record?.averageFocusMinutes ?? 0;
  }

  // 특정 날짜의 FocusTime 리스트 가져오기
  List<FocusTime> getFocusTimesForDate(DateTime date) {
    final record = _pomodoroRecords[date];
    return record?.focusTimes ?? [];
  }

  // 특정 날짜의 특정 세션 삭제
  Future<void> deletePomodoroSession(DateTime date, int sessionIndex) async {
    try {
      await _pomodoroService.deletePomodoroSession(date, sessionIndex);
      await loadPomodoroRecords(); // 데이터 다시 로드
    } catch (e) {
      _error = '세션 삭제 실패: $e';
      notifyListeners();
    }
  }
}

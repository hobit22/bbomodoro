import 'focus_time.dart';

class PomodoroRecord {
  final DateTime date;
  final int count;
  final int totalFocusMinutes;
  final List<FocusTime> focusTimes;

  PomodoroRecord({
    required this.date,
    required this.count,
    required this.totalFocusMinutes,
    required this.focusTimes,
  });

  // JSON 직렬화를 위한 팩토리 생성자
  factory PomodoroRecord.fromJson(Map<String, dynamic> json) {
    return PomodoroRecord(
      date: DateTime.parse(json['date']),
      count: json['count'] ?? 0,
      totalFocusMinutes: json['totalFocusMinutes'] ?? 0,
      focusTimes:
          (json['focusTimes'] as List<dynamic>?)
              ?.map((e) => FocusTime.fromJson(e))
              .toList() ??
          [],
    );
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().substring(0, 10),
      'count': count,
      'totalFocusMinutes': totalFocusMinutes,
      'focusTimes': focusTimes.map((e) => e.toJson()).toList(),
    };
  }

  // 새로운 뽀모도로 추가
  PomodoroRecord addPomodoro(FocusTime focusTime) {
    final newFocusTimes = List<FocusTime>.from(focusTimes)..add(focusTime);
    final newTotalMinutes = totalFocusMinutes + focusTime.durationInMinutes;

    return PomodoroRecord(
      date: date,
      count: count + 1,
      totalFocusMinutes: newTotalMinutes,
      focusTimes: newFocusTimes,
    );
  }

  // 총 집중 시간을 시:분 형태로 반환
  String get totalFocusTimeString {
    final hours = totalFocusMinutes ~/ 60;
    final minutes = totalFocusMinutes % 60;

    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }

  // 평균 집중 시간 계산 (분 단위)
  double get averageFocusMinutes {
    if (count == 0) return 0;
    return totalFocusMinutes / count;
  }

  // 평균 집중 시간을 시:분 형태로 반환
  String get averageFocusTimeString {
    final avgMinutes = averageFocusMinutes;
    final hours = (avgMinutes ~/ 60).toInt();
    final minutes = (avgMinutes % 60).toInt();

    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }

  // 완료 시간들을 문자열 리스트로 반환 (기존 호환성 유지)
  List<String> get completedTimes {
    return focusTimes.map((ft) => ft.startTimeString).toList();
  }

  // 빈 기록 생성
  factory PomodoroRecord.empty(DateTime date) {
    return PomodoroRecord(
      date: date,
      count: 0,
      totalFocusMinutes: 0,
      focusTimes: [],
    );
  }

  @override
  String toString() {
    return 'PomodoroRecord(date: $date, count: $count, totalFocus: $totalFocusTimeString, focusTimes: $focusTimes)';
  }
}

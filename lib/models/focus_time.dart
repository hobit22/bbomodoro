class FocusTime {
  final DateTime startTime;
  final DateTime endTime;

  FocusTime({required this.startTime, required this.endTime});

  // 집중 시간 계산 (분 단위)
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  // 집중 시간을 시:분 형태로 반환
  String get durationString {
    final duration = endTime.difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }

  // 시작 시간을 HH:MM 형태로 반환
  String get startTimeString {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  // 종료 시간을 HH:MM 형태로 반환
  String get endTimeString {
    return '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
  }

  // JSON 직렬화를 위한 팩토리 생성자
  factory FocusTime.fromJson(Map<String, dynamic> json) {
    return FocusTime(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
    );
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'FocusTime(start: $startTimeString, end: $endTimeString, duration: $durationString)';
  }
}

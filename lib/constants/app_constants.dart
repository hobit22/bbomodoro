class AppConstants {
  // 앱 정보
  static const String appName = 'Pomodoro Timer';
  static const String appVersion = '1.0.0';

  // 타이머 기본값
  static const int defaultFocusTime = 25; // 분
  static const int defaultShortBreak = 5; // 분
  static const int defaultLongBreak = 15; // 분

  // 색상
  static const int primaryColorValue = 0xFF2196F3; // Blue
  static const int accentColorValue = 0xFFFF5722; // Deep Orange

  // 애니메이션
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration timerTickDuration = Duration(seconds: 1);

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 50.0;

  // 타이머 관련
  static const double timerCircleSize = 200.0;
  static const double timerStrokeWidth = 10.0;

  // 캘린더
  static final DateTime calendarFirstDay = DateTime.utc(2020, 1, 1);
  static final DateTime calendarLastDay = DateTime.utc(2030, 12, 31);

  // 저장소 키
  static const String settingsNotificationsKey = 'notifications_enabled';
  static const String settingsFocusTimeKey = 'focus_time';
  static const String settingsShortBreakKey = 'short_break';
  static const String settingsLongBreakKey = 'long_break';

  // 메시지
  static const String pomodoroCompletedMessage = '뽀모도로 완료!';
  static const String timerPausedMessage = '타이머 일시정지됨';
  static const String timerResumedMessage = '타이머 재개됨';
  static const String timerResetMessage = '타이머 리셋됨';
}

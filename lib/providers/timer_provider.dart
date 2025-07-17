import 'package:flutter/foundation.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../models/pomodoro_record.dart';

enum TimerMode { focus, shortBreak, longBreak }

class TimerProvider extends ChangeNotifier {
  Timer? _timer;
  int _totalSeconds = 0;
  bool _isRunning = false;
  int _pomodoros = 0;
  int _completedSessions = 0;
  TimerMode _currentMode = TimerMode.focus;
  DateTime? _sessionStartTime; // 세션 시작 시간 추가

  // 설정값들
  int _focusTime = AppConstants.defaultFocusTime;
  int _shortBreak = AppConstants.defaultShortBreak;
  int _longBreak = AppConstants.defaultLongBreak;
  bool _autoStartBreak = true; // 자동 휴식 시작 기본값

  // 콜백 함수들
  Function(DateTime, DateTime)? _onPomodoroCompleted; // 시작 시간과 종료 시간을 전달하는 콜백
  Function(String)? _onShowMessage;

  // Getters
  Timer? get timer => _timer;
  int get totalSeconds => _totalSeconds;
  bool get isRunning => _isRunning;
  int get pomodoros => _pomodoros;
  int get completedSessions => _completedSessions;
  TimerMode get currentMode => _currentMode;
  int get focusTime => _focusTime;
  int get shortBreak => _shortBreak;
  int get longBreak => _longBreak;
  bool get autoStartBreak => _autoStartBreak;

  // 설정 업데이트
  void updateSettings({
    required int focusTime,
    required int shortBreak,
    required int longBreak,
    required bool autoStartBreak,
  }) {
    _focusTime = focusTime;
    _shortBreak = shortBreak;
    _longBreak = longBreak;
    _autoStartBreak = autoStartBreak;

    // 현재 모드에 따라 타이머 시간 재설정
    if (!_isRunning) {
      _resetToFocusMode();
    }
    notifyListeners();
  }

  // 초기화
  void initialize() {
    if (_totalSeconds == 0) {
      _resetToFocusMode();
    }
  }

  void _resetToFocusMode() {
    _currentMode = TimerMode.focus;
    _totalSeconds = _focusTime * 60;
    notifyListeners();
  }

  // 타이머 시작
  void startTimer() {
    if (_isRunning) return;

    // 세션 시작 시간 기록
    _sessionStartTime = DateTime.now();

    _timer = Timer.periodic(AppConstants.timerTickDuration, _onTick);
    _isRunning = true;
    notifyListeners();
  }

  // 타이머 일시정지
  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  // 타이머 리셋
  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _sessionStartTime = null; // 세션 시작 시간 초기화
    _resetToFocusMode();
  }

  // 다음으로 건너뛰기
  void skipToNext() {
    _timer?.cancel();
    _handleTimerComplete();
  }

  // 타이머 틱 처리
  void _onTick(Timer timer) {
    if (_totalSeconds == 0) {
      _timer?.cancel();
      _handleTimerComplete();
    } else {
      _totalSeconds--;
      notifyListeners();
    }
  }

  // 타이머 완료 처리
  void _handleTimerComplete() {
    if (_currentMode == TimerMode.focus) {
      // 포커스 타임 완료
      _pomodoros++;
      _completedSessions++;
      _isRunning = false;

      // 세션 종료 시간 계산
      final sessionEndTime = DateTime.now();

      // 통계에 저장 (시작 시간과 종료 시간을 포함하여 콜백 호출)
      if (_onPomodoroCompleted != null && _sessionStartTime != null) {
        _onPomodoroCompleted!(_sessionStartTime!, sessionEndTime);
      }

      // 자동 휴식 시작 설정에 따라 처리
      if (_autoStartBreak) {
        // 자동으로 브레이크 타임 시작
        _startBreakMode();
        startTimer(); // 자동 시작
      } else {
        // 수동 시작을 위해 브레이크 모드로만 전환
        _startBreakMode();
      }

      // 완료 메시지 표시
      if (_onShowMessage != null) {
        _onShowMessage!(getCompletionMessage());
      }
    } else {
      // 브레이크 타임 완료
      _isRunning = false;

      // 자동 휴식 시작 설정에 따라 처리
      if (_autoStartBreak) {
        // 자동으로 포커스 타임 시작
        _startFocusMode();
        startTimer(); // 자동 시작
      } else {
        // 수동 시작을 위해 포커스 모드로만 전환
        _startFocusMode();
      }
    }
    notifyListeners();
  }

  void _startBreakMode() {
    // 4개의 포모도로마다 긴 휴식
    final isLongBreak = _completedSessions % 4 == 0;
    _currentMode = isLongBreak ? TimerMode.longBreak : TimerMode.shortBreak;
    _totalSeconds = isLongBreak ? _longBreak * 60 : _shortBreak * 60;
  }

  void _startFocusMode() {
    _currentMode = TimerMode.focus;
    _totalSeconds = _focusTime * 60;
  }

  // 모드별 제목 가져오기
  String getModeTitle() {
    switch (_currentMode) {
      case TimerMode.focus:
        return '포커스 타임';
      case TimerMode.shortBreak:
        return '짧은 휴식';
      case TimerMode.longBreak:
        return '긴 휴식';
    }
  }

  // 모드별 색상 가져오기
  int getProgressColor() {
    switch (_currentMode) {
      case TimerMode.focus:
        return 0xFFFF5722; // Red
      case TimerMode.shortBreak:
        return 0xFF4CAF50; // Green
      case TimerMode.longBreak:
        return 0xFF2196F3; // Blue
    }
  }

  // 진행률 계산
  double getProgressValue() {
    final totalSeconds = _currentMode == TimerMode.focus
        ? _focusTime * 60
        : _currentMode == TimerMode.shortBreak
        ? _shortBreak * 60
        : _longBreak * 60;

    return _totalSeconds / totalSeconds;
  }

  // 완료 메시지 가져오기
  String getCompletionMessage() {
    if (_currentMode == TimerMode.focus) {
      if (_autoStartBreak) {
        return _currentMode == TimerMode.longBreak
            ? '긴 휴식 시간을 자동으로 시작합니다!'
            : '짧은 휴식 시간을 자동으로 시작합니다!';
      } else {
        return _currentMode == TimerMode.longBreak
            ? '긴 휴식 시간을 시작할 준비가 되었습니다!'
            : '짧은 휴식 시간을 시작할 준비가 되었습니다!';
      }
    } else {
      if (_autoStartBreak) {
        return '집중 시간을 자동으로 시작합니다!';
      } else {
        return '집중 시간을 시작할 준비가 되었습니다!';
      }
    }
  }

  // 뽀모도로 완료 콜백 설정 (시작 시간과 종료 시간을 받는 콜백)
  void setPomodoroCompletedCallback(Function(DateTime, DateTime) callback) {
    _onPomodoroCompleted = callback;
  }

  // 메시지 표시 콜백 설정
  void setMessageCallback(Function(String) callback) {
    _onShowMessage = callback;
  }

  // 뽀모도로 카운트 리셋 (통계용)
  void resetPomodoroCount() {
    _pomodoros = 0;
    _completedSessions = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

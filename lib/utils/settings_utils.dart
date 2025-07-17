import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SettingsUtils {
  static late SharedPreferences _prefs;
  static bool _isInitialized = false;

  // 초기화
  static Future<void> initialize() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  // 알림 설정
  static Future<bool> getNotificationsEnabled() async {
    await initialize();
    return _prefs.getBool(AppConstants.settingsNotificationsKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await initialize();
    await _prefs.setBool(AppConstants.settingsNotificationsKey, enabled);
  }

  // 포커스 시간 설정
  static Future<int> getFocusTime() async {
    await initialize();
    return _prefs.getInt(AppConstants.settingsFocusTimeKey) ??
        AppConstants.defaultFocusTime;
  }

  static Future<void> setFocusTime(int minutes) async {
    await initialize();
    await _prefs.setInt(AppConstants.settingsFocusTimeKey, minutes);
  }

  // 짧은 휴식 시간 설정
  static Future<int> getShortBreak() async {
    await initialize();
    return _prefs.getInt(AppConstants.settingsShortBreakKey) ??
        AppConstants.defaultShortBreak;
  }

  static Future<void> setShortBreak(int minutes) async {
    await initialize();
    await _prefs.setInt(AppConstants.settingsShortBreakKey, minutes);
  }

  // 긴 휴식 시간 설정
  static Future<int> getLongBreak() async {
    await initialize();
    return _prefs.getInt(AppConstants.settingsLongBreakKey) ??
        AppConstants.defaultLongBreak;
  }

  static Future<void> setLongBreak(int minutes) async {
    await initialize();
    await _prefs.setInt(AppConstants.settingsLongBreakKey, minutes);
  }

  // 모든 설정을 한 번에 가져오기
  static Future<Map<String, dynamic>> getAllSettings() async {
    await initialize();
    return {
      'notifications': await getNotificationsEnabled(),
      'focusTime': await getFocusTime(),
      'shortBreak': await getShortBreak(),
      'longBreak': await getLongBreak(),
    };
  }

  // 모든 설정을 한 번에 저장하기
  static Future<void> saveAllSettings({
    required bool notifications,
    required int focusTime,
    required int shortBreak,
    required int longBreak,
  }) async {
    await initialize();
    await Future.wait([
      setNotificationsEnabled(notifications),
      setFocusTime(focusTime),
      setShortBreak(shortBreak),
      setLongBreak(longBreak),
    ]);
  }

  // 설정 초기화 (기본값으로 되돌리기)
  static Future<void> resetToDefaults() async {
    await initialize();
    await saveAllSettings(
      notifications: true,
      focusTime: AppConstants.defaultFocusTime,
      shortBreak: AppConstants.defaultShortBreak,
      longBreak: AppConstants.defaultLongBreak,
    );
  }

  // 설정이 변경되었는지 확인
  static Future<bool> hasCustomSettings() async {
    await initialize();
    final focusTime = await getFocusTime();
    final shortBreak = await getShortBreak();
    final longBreak = await getLongBreak();

    return focusTime != AppConstants.defaultFocusTime ||
        shortBreak != AppConstants.defaultShortBreak ||
        longBreak != AppConstants.defaultLongBreak;
  }
}

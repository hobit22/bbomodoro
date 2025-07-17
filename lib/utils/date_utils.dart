class DateUtils {
  // 날짜를 YYYY-MM-DD 형식으로 포맷
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 시간을 HH:MM 형식으로 포맷
  static String formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // 현재 시간을 HH:MM 형식으로 반환
  static String getCurrentTimeString() {
    final now = DateTime.now();
    return formatTime(now);
  }

  // 날짜가 같은지 확인 (시간 무시)
  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // 날짜 해시코드 생성
  static int getDateHashCode(DateTime date) {
    return date.day * 1000000 + date.month * 10000 + date.year;
  }

  // 초를 MM:SS 형식으로 포맷
  static String formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 오늘 날짜인지 확인
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  // 어제 날짜인지 확인
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  // 날짜를 상대적 표현으로 변환 (오늘, 어제, 날짜)
  static String getRelativeDateString(DateTime date) {
    if (isToday(date)) {
      return '오늘';
    } else if (isYesterday(date)) {
      return '어제';
    } else {
      return formatDate(date);
    }
  }

  // 주의 시작일 (월요일) 가져오기
  static DateTime getWeekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  // 주의 마지막일 (일요일) 가져오기
  static DateTime getWeekEnd(DateTime date) {
    final weekday = date.weekday;
    return date.add(Duration(days: 7 - weekday));
  }
}

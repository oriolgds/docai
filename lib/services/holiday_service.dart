class HolidayService {
  static const int _christmasStartMonth = 12;
  static const int _christmasStartDay = 1;
  static const int _christmasEndMonth = 1;
  static const int _christmasEndDay = 7;

  /// Returns true if the current date is within the Christmas season
  static bool isChristmasSeason() {
    final now = DateTime.now();

    // Check if it's December
    if (now.month == _christmasStartMonth) {
      return now.day >= _christmasStartDay;
    }

    // Check if it's January
    if (now.month == _christmasEndMonth) {
      return now.day <= _christmasEndDay;
    }

    return false;
  }

  /// Returns the path to the appropriate logo based on the current season
  static String getLogoPath() {
    if (isChristmasSeason()) {
      return 'assets/logo/xmas.webp';
    }
    return 'assets/logo/logo compress.webp';
  }

  /// Returns true if snow animation should be enabled
  static bool shouldEnableSnow() {
    return isChristmasSeason();
  }
}

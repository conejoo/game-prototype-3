/// Formats the normalized visual day cycle as a player-facing clock time.
///
/// The cycle starts at 10:00 AM, so its existing Day → Evening → Night → Dawn
/// phases begin at 10 AM, 4 PM, 10 PM, and 4 AM respectively.
abstract final class DayNightClock {
  static const minutesPerDay = 24 * 60;
  static const cycleStartMinutes = 10 * 60;
  static const cycleDurationSeconds = 600.0;

  /// Authored clock position, including fractions of one minute.
  static double minuteOfDayForProgress(double progress) {
    _validateProgress(progress);
    return (cycleStartMinutes + progress * minutesPerDay) % minutesPerDay;
  }

  /// Returns a 12-hour clock label for normalized [progress].
  static String format(double progress) {
    final minutes = minuteOfDayForProgress(progress).floor();
    final hour24 = minutes ~/ 60;
    final minute = minutes % 60;
    final period = hour24 < 12 ? 'AM' : 'PM';
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:${minute.toString().padLeft(2, '0')} $period';
  }

  static void _validateProgress(double progress) {
    if (!progress.isFinite || progress < 0 || progress >= 1) {
      throw ArgumentError.value(
        progress,
        'progress',
        'Progress must be greater than or equal to 0.0 and less than 1.0.',
      );
    }
  }
}

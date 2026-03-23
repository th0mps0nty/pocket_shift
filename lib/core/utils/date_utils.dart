import 'package:intl/intl.dart';

class PocketShiftDateUtils {
  const PocketShiftDateUtils._();

  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static String dateKey(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(startOfDay(dateTime));
  }

  static DateTime parseDateKey(String value) {
    return DateFormat('yyyy-MM-dd').parseStrict(value);
  }

  static bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String formatSessionDate(String value) {
    final parsed = parseDateKey(value);
    return DateFormat('EEE, MMM d').format(parsed);
  }

  static String formatCreatedAt(DateTime value) {
    return DateFormat('MMM d, h:mm a').format(value);
  }
}

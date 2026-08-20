import 'package:intl/intl.dart';

class DateTimeUtils {
  const DateTimeUtils._();

  static String formatDate(DateTime value, {String pattern = 'MMM d, y'}) {
    return DateFormat(pattern).format(value);
  }

  static String formatDateTime(
    DateTime value, {
    String pattern = 'MMM d, y h:mm a',
  }) {
    return DateFormat(pattern).format(value);
  }

  static DateTime startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}

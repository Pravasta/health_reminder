import 'package:intl/intl.dart';

class CustomDateFormat {
  DateTime localDateTime({required DateTime date}) {
    return date.toLocal();
  }

  String timeZoneName({required DateTime date}) {
    var dateLocal = localDateTime(date: date);
    return dateLocal.timeZoneName;
  }

  String formatDate({
    required DateTime date,
    String formatDate = 'dd MMMM yyyy',
    String locale = "id_ID",
  }) {
    var dateLocal = localDateTime(date: date);
    return DateFormat(formatDate, locale).format(dateLocal);
  }

  String getFormattedToday({
    required DateTime date,
    String format = 'yyyy-MM-dd',
  }) {
    return formatDate(date: date, formatDate: format);
  }

  String getFormattedNextday({
    required DateTime date,
    String format = 'yyyy-MM-dd',
  }) {
    var newDate = date.add(Duration(days: 1));
    return formatDate(date: newDate, formatDate: format);
  }

  String getFirstDayMonth({required DateTime date}) {
    var newDate = DateTime(date.year, date.month, 1);
    return formatDate(date: newDate, formatDate: 'yyyy-MM-dd');
  }

  String getLastDayMonth({required DateTime date}) {
    var newDate = DateTime(date.year, date.month + 1, 0);
    return formatDate(date: newDate, formatDate: 'yyyy-MM-dd');
  }

  String toIso8601WithOffset(DateTime dateTime) {
    final offset = dateTime.timeZoneOffset;
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final sign = offset.isNegative ? '-' : '+';

    final formattedOffset = '$sign$hours:$minutes';

    return dateTime.toIso8601String() + formattedOffset;
  }

  // time formated from minutes
  String formatDurationFromMinutes(int minutes) {
    final int hours = minutes ~/ 60;
    final int remainingMinutes = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else {
      return '${remainingMinutes}m';
    }
  }
}

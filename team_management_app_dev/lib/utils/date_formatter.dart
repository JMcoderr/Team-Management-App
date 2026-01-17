import 'package:intl/intl.dart';

// DateFormatter provides date/time formatting utilities
class DateFormatter {
  // formats date with day name and month
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly.year == now.year) {
      return DateFormat('EEE, MMM d').format(date);
    } else {
      return DateFormat('EEE, MMM d, yyyy').format(date);
    }
  }

  // combines date and time in readable format
  static String formatDateWithTime(DateTime date) {
    return '${formatRelativeDate(date)} at ${DateFormat('HH:mm').format(date)}';
  }

  // formats time in 24-hour format
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // checks if date matches current day
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // checks if date falls within current week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // checks if date is in current month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
}

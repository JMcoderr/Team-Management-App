import 'package:intl/intl.dart';

// Date formatting utilities

class DateFormatter {
  // Format date with real dates (no relative terms)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly.year == now.year) {
      // This year - show day name, month and day
      return DateFormat('EEE, MMM d').format(date); // Thu, Jan 16
    } else {
      // Other years - show full date
      return DateFormat('EEE, MMM d, yyyy').format(date); // Thu, Jan 16, 2026
    }
  }
  
  // Format date with time
  static String formatDateWithTime(DateTime date) {
    return '${formatRelativeDate(date)} at ${DateFormat('HH:mm').format(date)}';
  }
  
  // Format just time
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
  
  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  // Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }
  
  // Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
}

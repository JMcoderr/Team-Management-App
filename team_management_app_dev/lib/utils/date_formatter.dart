import 'package:intl/intl.dart';

// Date formatting utilities

class DateFormatter {
  // Format date with relative terms (Today, Tomorrow, Yesterday)
  static String formatRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (dateOnly.isAfter(today) && dateOnly.isBefore(today.add(const Duration(days: 7)))) {
      // This week - show day name
      return DateFormat('EEEE').format(date); // Monday, Tuesday, etc
    } else if (dateOnly.year == today.year) {
      // This year - show month and day
      return DateFormat('MMM d').format(date); // Jan 16
    } else {
      // Other years - show full date
      return DateFormat('MMM d, yyyy').format(date); // Jan 16, 2026
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

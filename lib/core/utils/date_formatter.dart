import 'package:intl/intl.dart';

/// Formats a DateTime to show relative day (Today/Tomorrow/Yesterday) with time
/// Example: "Today at 10:30 AM", "Tomorrow at 2:45 PM"
String formatRelativeDateTime(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final yesterday = today.subtract(const Duration(days: 1));

  final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

  String dayText;
  if (dateToCheck == today) {
    dayText = 'Today';
  } else if (dateToCheck == tomorrow) {
    dayText = 'Tomorrow';
  } else if (dateToCheck == yesterday) {
    dayText = 'Yesterday';
  } else {
    // For dates beyond yesterday/tomorrow, show the actual date
    dayText = DateFormat('MMM d').format(dateTime);
  }

  // Format time as "10:30 AM"
  final timeText = DateFormat('h:mm a').format(dateTime);

  return '$dayText at $timeText';
}

/// Formats just the time portion
/// Example: "10:30 AM"
String formatTime(DateTime dateTime) {
  return DateFormat('h:mm a').format(dateTime);
}

/// Formats just the date portion
/// Example: "Jan 15, 2026"
String formatDate(DateTime dateTime) {
  return DateFormat('MMM d, yyyy').format(dateTime);
}

/// Checks if a given DateTime is today
/// Returns true if the date is the same as the current date (ignores time)
bool isToday(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dateToCheck = DateTime(dateTime.year, dateTime.month, dateTime.day);

  return dateToCheck == today;
}

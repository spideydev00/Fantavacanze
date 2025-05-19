/// Utility functions for formatting dates in a human-readable way
class DateFormatter {
  /// Formats a date into a relative time string (e.g., "2 days ago")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      // Return formatted date for dates older than a month
      return '${date.day}/${date.month}/${date.year} ${_formatHourMinute(date)}';
    } else if (difference.inDays > 0) {
      return "${difference.inDays} ${difference.inDays == 1 ? 'giorno' : 'giorni'} fa";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} ${difference.inHours == 1 ? 'ora' : 'ore'} fa";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minuti'} fa";
    } else {
      return "poco fa";
    }
  }

  /// Formats a date in the standard Italian format "dd/MM/yyyy HH:mm"
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${_formatHourMinute(date)}';
  }

  /// Helper to format hour and minute with leading zeros
  static String _formatHourMinute(DateTime date) {
    return '${date.hour}:${date.minute < 10 ? '0${date.minute}' : date.minute}';
  }
}

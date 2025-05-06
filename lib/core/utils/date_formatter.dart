/// Utility functions for formatting dates in a human-readable way
class DateFormatter {
  /// Formats a date into a relative time string (e.g., "2 days ago")
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return "${difference.inDays} ${difference.inDays == 1 ? 'giorno' : 'giorni'} fa";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} ${difference.inHours == 1 ? 'ora' : 'ore'} fa";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} ${difference.inMinutes == 1 ? 'minuto' : 'minuti'} fa";
    } else {
      return "poco fa";
    }
  }
}

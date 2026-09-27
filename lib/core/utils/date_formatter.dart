import 'package:intl/intl.dart';

class DateFormatter {
  static String formatRelative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Az önce';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} dk önce';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} saat önce';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else {
      return DateFormat('d MMMM yyyy', 'tr_TR').format(dateTime);
    }
  }

  static String formatDate(DateTime dateTime) {
    return DateFormat('d MMMM yyyy', 'tr_TR').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('d MMMM yyyy HH:mm', 'tr_TR').format(dateTime);
  }
}

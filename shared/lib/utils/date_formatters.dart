import 'package:intl/intl.dart';

class DateFormatters {
  const DateFormatters._();

  static final _time = DateFormat('h:mm a');
  static final _dateTime = DateFormat('MMM d, h:mm a');
  static final _date = DateFormat('MMM d, yyyy');

  static String time(DateTime value) => _time.format(value);

  static String date(DateTime value) => _date.format(value);

  static String dateTime(DateTime value) => _dateTime.format(value);

  static String relative(DateTime value) {
    final difference = DateTime.now().difference(value);
    if (difference.inMinutes < 1) {
      return 'now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }
}

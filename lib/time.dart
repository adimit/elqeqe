import 'package:timeago/timeago.dart' as timeago;

abstract class FormatTime {
  String format(DateTime dateTime);
}

class TimeAgoFormatTime extends FormatTime {
  @override
  String format(DateTime dateTime) {
    return timeago.format(dateTime);
  }
}

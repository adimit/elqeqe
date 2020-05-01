import 'package:timeago/timeago.dart' as timeago;
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

abstract class FormatTime {
  final DateFormat _format;
  FormatTime._(this._format);
  FormatTime._implicit() : this._(DateFormat.jm().add_yMMMMd());

  String fuzzyFormat(DateTime dateTime);

  String preciseFormat(DateTime dateTime) => _format.format(dateTime);

  static void getFormatTime(Locale locale) async {
    await initializeDateFormatting(locale.countryCode);
  }
}

class TimeAgoFormatTime extends FormatTime {
  TimeAgoFormatTime() : super._implicit();

  @override
  String fuzzyFormat(DateTime dateTime) {
    return timeago.format(dateTime);
  }
}

import 'package:timeago/timeago.dart' as timeago;
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

extension on Locale {
  String getFullLocaleCode() => "${languageCode}_${countryCode}";
}

abstract class FormatTime {
  final BuildContext _context;
  final DateFormat _format;
  FormatTime._(this._format, this._context);
  FormatTime(BuildContext context)
      : this._(
            DateFormat.MMMMd(
                Localizations.localeOf(context).getFullLocaleCode()),
            context);

  String fuzzyFormat(DateTime dateTime);

  String preciseFormat(DateTime dateTime) =>
      "${preciseDateFormat(dateTime)}, ${preciseTimeFormat(dateTime)}";

  String preciseDateFormat(DateTime dateTime) => _format.format(dateTime);
  String preciseTimeFormat(DateTime dateTime) =>
      TimeOfDay.fromDateTime(dateTime).format(_context);
}

class TimeAgoFormatTime extends FormatTime {
  TimeAgoFormatTime(BuildContext context) : super(context);

  @override
  String fuzzyFormat(DateTime dateTime) => timeago.format(dateTime);
}

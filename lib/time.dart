import 'package:timeago/timeago.dart' as timeago;
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

abstract class FormatTime {
  final DateFormat _format;
  FormatTime._(this._format);
  FormatTime(Locale locale)
      : this._(DateFormat.jm(locale.languageCode).add_yMMMMd());

  String fuzzyFormat(DateTime dateTime);

  String preciseFormat(DateTime dateTime) => _format.format(dateTime);
}

class TimeAgoFormatTime extends FormatTime {
  TimeAgoFormatTime(Locale locale) : super(locale);

  TimeAgoFormatTime.fromContext(BuildContext context)
      : this(Localizations.localeOf(context));

  @override
  String fuzzyFormat(DateTime dateTime) => timeago.format(dateTime);
}

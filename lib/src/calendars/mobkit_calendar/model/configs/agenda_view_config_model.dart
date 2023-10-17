import 'package:flutter/material.dart';

class AgendaViewConfigModel {
  DateTime? startDate;
  DateTime? endDate;
  String? dateFormatPattern;
  TextStyle? titleTextStyle;
  TextStyle? detailTextStyle;
  TextStyle? dateTextStyle;
  AgendaViewConfigModel({
    this.startDate,
    this.endDate,
    this.dateFormatPattern,
    this.titleTextStyle,
    this.detailTextStyle,
    this.dateTextStyle,
  });
}

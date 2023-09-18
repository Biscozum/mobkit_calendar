import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/styles/calendar_cell_style.dart';

class CalendarCellConfigModel {
  CalendarCellStyle? selectedStyle;
  CalendarCellStyle? enabledStyle;
  CalendarCellStyle? disabledStyle;
  CalendarCellStyle? currentStyle;
  CalendarCellStyle? weekendStyle;
  double eventPointRadius;
  double spaceBetweenEventLines;
  double spaceBetweenEventLineToPoint;
  double spaceBetweenEventPoints;
  double eventLineHeight;
  BorderRadius eventLineRadius;
  int maxEventPointCount;
  int maxEventLineCount;

  CalendarCellConfigModel({
    this.selectedStyle,
    this.enabledStyle,
    this.disabledStyle,
    this.currentStyle,
    this.weekendStyle,
    this.eventPointRadius = 4.5,
    this.spaceBetweenEventLines = 0.3,
    this.spaceBetweenEventLineToPoint = 4,
    this.spaceBetweenEventPoints = 2,
    this.eventLineHeight = 2.5,
    this.maxEventPointCount = 4,
    this.maxEventLineCount = 3,
    this.eventLineRadius = const BorderRadius.all(Radius.circular(2.0)),
  });
}

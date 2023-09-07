import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/styles/frame_style.dart';

class CalendarCellStyle extends FrameStyle {
  TextStyle? maxLineCountTextStyle;
  TextStyle? maxPointCountTextStyle;
  CalendarCellStyle({
    this.maxLineCountTextStyle,
    this.maxPointCountTextStyle,
    super.border,
    super.color,
    super.padding,
    super.textStyle,
  });
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:mobkit_calendar/src/mobkit_calendar/model/styles/frame_style.dart';

class DailyItemsConfigModel {
  String? allDayText;
  TextStyle? allDayTextStyle;
  TextStyle? hourTextStyle;
  EdgeInsets? allDayMargin;
  FrameStyle? allDayFrameStyle;
  FrameStyle? itemFrameStyle;
  double? space;
  DailyItemsConfigModel({
    this.allDayText,
    this.allDayTextStyle,
    this.hourTextStyle,
    this.allDayMargin,
    this.allDayFrameStyle,
    this.itemFrameStyle,
    this.space,
  });
}

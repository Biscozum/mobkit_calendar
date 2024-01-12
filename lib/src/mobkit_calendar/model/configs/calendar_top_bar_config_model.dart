// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CalendarTopBarConfigModel {
  bool? isVisibleMonthBar;
  bool? isVisibleYearBar;
  bool? isVisibleWeekDaysBar;
  bool? isVisibleHeaderWidget;
  bool? isVisibleTitleWidget;
  TextStyle monthDaysStyle;
  TextStyle weekDaysStyle;
  CalendarTopBarConfigModel({
    this.isVisibleMonthBar,
    this.isVisibleYearBar,
    this.isVisibleWeekDaysBar,
    this.isVisibleHeaderWidget,
    this.isVisibleTitleWidget,
    this.monthDaysStyle = const TextStyle(fontWeight: FontWeight.normal),
    this.weekDaysStyle = const TextStyle(
        color: Color.fromRGBO(253, 165, 46, 1), fontWeight: FontWeight.bold),
  });
}

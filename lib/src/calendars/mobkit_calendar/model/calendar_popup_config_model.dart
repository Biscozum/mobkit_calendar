import 'package:flutter/material.dart';

class CalendarPopupConfigModel {
  double? popupHeight;
  double? popupWidth;
  BoxDecoration? popUpBoxDecoration;
  bool? popUpOpacity;
  int? animateDuration;
  double? popupSpace;
  double? passiveVerticalPadding;
  double? viewportFraction;
  CalendarPopupConfigModel({
    this.popupHeight,
    this.popupWidth,
    this.popUpBoxDecoration,
    this.popUpOpacity = false,
    this.animateDuration = 500,
    this.popupSpace = 10,
    this.passiveVerticalPadding = 30,
    this.viewportFraction = 1.0,
  });
}

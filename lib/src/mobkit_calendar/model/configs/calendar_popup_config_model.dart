import 'package:flutter/material.dart';

class CalendarPopupConfigModel {
  /// Popup height
  double? popupHeight;

  /// Popup width
  double? popupWidth;

  /// Popup decoration
  BoxDecoration? popUpBoxDecoration;

  /// Popup Opacity
  bool? popUpOpacity;

  /// Popup animation duration
  int? animateDuration;

  /// Popup space
  double? popupSpace;

  /// Padding to be applied to the popups that appear on the sides.
  double? verticalPadding;

  /// Determines the spreading rate of the opened carousel relative to the screen.
  double? viewportFraction;
  CalendarPopupConfigModel({
    this.popupHeight,
    this.popupWidth,
    this.popUpBoxDecoration,
    this.popUpOpacity = false,
    this.animateDuration = 500,
    this.popupSpace = 10,
    this.verticalPadding = 30,
    this.viewportFraction = 1.0,
  });
}

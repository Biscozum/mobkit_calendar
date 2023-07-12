import 'package:flutter/material.dart';

class MobkitCalendarConfigModel {
  /// The title you want to appear at the top of the date picker.
  String? title;

  /// It determines in which locale the date picker will work.
  String? locale;

  /// Whether the date picker will show all days
  bool showAllDays;

  /// Turns off all dates of the date picker
  bool disableOffDays;

  /// Whether to show the bar showing the days of the week above the date picker
  bool disableWeekendsDays;

  /// The date picker closes before the specified date.
  DateTime? disableBefore;

  /// The date picker closes after the specified date.
  DateTime? disableAfter;

  /// Specifies which types the date picker will turn off.
  List<DateTime>? disabledDates;

  /// Space inside the cells of the date picker
  EdgeInsetsGeometry itemSpace;

  /// Animation Duration
  Duration animationDuration;

  /// The color that the active days of the date picker will have
  Color enabledColor;

  /// The color that the inactive days of the date picker will have
  Color disabledColor;

  /// The color that the selected days of the date picker will have
  Color selectedColor;

  /// If you are selecting a range with your date picker, the color of the first and last element of the range
  Color isFirstLastItemColor;

  /// The main theme color of your date picker
  Color primaryColor;

  /// The color of the borders of the active days of the date picker
  Color enabledBorderColor;

  /// The color of the borders of the inactive days of the date picker
  Color disabledBorderColor;

  /// The color of the borders of the selected days of the date picker
  Color selectedBorderColor;

  /// The width of the date picker's borders.
  double borderWidth;

  /// If non-null, the corners of this box are rounded.
  BorderRadiusGeometry borderRadius;

  /// The textstyle that the active days of the date picker will have
  TextStyle enableStyle;

  /// The textstyle that the days of the month will have in the date picker.
  TextStyle monthDaysStyle;

  /// The textstyle that the days of the week will have in the date picker
  TextStyle weekDaysStyle;

  /// The textstyle that the inactive days of the date picker will have
  TextStyle disabledStyle;

  /// The textstyle that today's date will have
  TextStyle currentStyle;

  Color weekDaysBarBorderColor;

  MobkitCalendarViewType mobkitCalendarViewType;

  /// The textstyle that the selected days in the date picker will have.
  TextStyle selectedStyle;
  MobkitCalendarConfigModel({
    this.title,
    this.locale = 'tr_Tr',
    this.showAllDays = true,
    this.disableOffDays = true,
    this.disableWeekendsDays = true,
    this.disableBefore,
    this.disableAfter,
    this.disabledDates,
    this.itemSpace = const EdgeInsets.all(2.0),
    this.animationDuration = const Duration(milliseconds: 300),
    this.enabledColor = Colors.transparent,
    this.disabledColor = const Color.fromARGB(255, 127, 127, 127),
    this.selectedColor = const Color.fromRGBO(253, 165, 46, 1),
    this.isFirstLastItemColor = const Color.fromARGB(255, 236, 10, 10),
    this.primaryColor = const Color.fromRGBO(253, 165, 46, 1),
    this.weekDaysBarBorderColor = const Color.fromRGBO(253, 165, 46, 1),
    this.enabledBorderColor = Colors.transparent,
    this.disabledBorderColor = const Color.fromARGB(255, 127, 127, 127),
    this.selectedBorderColor = Colors.black,
    this.borderWidth = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(4)),
    this.enableStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.monthDaysStyle = const TextStyle(fontWeight: FontWeight.normal),
    this.weekDaysStyle = const TextStyle(color: Color.fromRGBO(253, 165, 46, 1), fontWeight: FontWeight.bold),
    this.disabledStyle = const TextStyle(color: Color.fromARGB(255, 127, 127, 127), fontWeight: FontWeight.bold),
    this.currentStyle = const TextStyle(color: Color.fromRGBO(253, 165, 46, 1), fontWeight: FontWeight.bold),
    this.selectedStyle = const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    this.mobkitCalendarViewType = MobkitCalendarViewType.monthly,
  });
}

enum MobkitCalendarViewType { monthly, weekly, daily }

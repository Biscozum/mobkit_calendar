import 'package:flutter/material.dart';
import '../../../mobkit_calendar.dart';
import '../../model/calendar_type_model.dart';

class CellWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isEnabled;
  final bool isFirstLastSelectedItem;
  final bool isWeekDaysBar;
  final bool isCurrent;
  final CalendarType calendarType;
  late final MobkitCalendarConfigModel configStandardCalendar;
  late final MobkitMonthAndYearCalendarConfigModel configMonthAndYear;
  CellWidget(
    this.text, {
    this.isSelected = false,
    this.isEnabled = true,
    this.isFirstLastSelectedItem = false,
    this.isWeekDaysBar = false,
    this.isCurrent = false,
    this.calendarType = CalendarType.standardCalendar,
    MobkitCalendarConfigModel? standardCalendarConfig,
    MobkitMonthAndYearCalendarConfigModel? monthAndYearConfig,
    Key? key,
  }) : super(key: key) {
    if (standardCalendarConfig == null) {
      configStandardCalendar = MobkitCalendarConfigModel();
    } else {
      configStandardCalendar = standardCalendarConfig;
    }
    if (monthAndYearConfig == null) {
      configMonthAndYear = MobkitMonthAndYearCalendarConfigModel();
    } else {
      configMonthAndYear = monthAndYearConfig;
    }
  }
  @override
  Widget build(BuildContext context) {
    if (calendarType == CalendarType.monthAndYearCalendar) {
      return Padding(
        padding: configMonthAndYear.itemSpace,
        child: SizedBox(
          height: 40,
          width: MediaQuery.of(context).size.width * 0.12,
          child: AnimatedContainer(
            duration: configMonthAndYear.animationDuration,
            decoration: BoxDecoration(
              color: isFirstLastSelectedItem
                  ? configMonthAndYear.isFirstLastItemColor
                  : isSelected
                      ? configMonthAndYear.selectedColor.withOpacity(
                          configMonthAndYear.selectionType == MobkitMonthAndYearCalendarSelectionType.selectionRange
                              ? 0.70
                              : 1.0)
                      : configMonthAndYear.enabledColor,
              border: isWeekDaysBar
                  ? Border.all(width: 1, color: configStandardCalendar.weekDaysBarBorderColor)
                  : Border.all(
                      width: configMonthAndYear.borderWidth,
                      color: isSelected
                          ? configStandardCalendar.cellConfig.selectedStyle?.border?.top.color ?? Colors.transparent
                          : configStandardCalendar.cellConfig.enabledStyle?.border?.top.color ?? Colors.transparent,
                    ),
            ),
            child: Center(
              child: Text(
                text,
                style: isEnabled
                    ? isSelected
                        ? configStandardCalendar.cellConfig.selectedStyle?.textStyle
                        : configStandardCalendar.topBarConfig.monthDaysStyle
                    : configStandardCalendar.cellConfig.disabledStyle?.textStyle,
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: configStandardCalendar.itemSpace,
        child: SizedBox(
          height: 40,
          width: MediaQuery.of(context).size.width * 0.12,
          child: AnimatedContainer(
            duration: configStandardCalendar.animationDuration,
            decoration: BoxDecoration(
              color: isEnabled
                  ? isSelected
                      ? configStandardCalendar.cellConfig.selectedStyle?.color
                      : configStandardCalendar.cellConfig.enabledStyle?.color
                  : configStandardCalendar.cellConfig.disabledStyle?.color,
              border: isWeekDaysBar
                  ? Border.all(width: 1, color: configStandardCalendar.weekDaysBarBorderColor)
                  : isSelected
                      ? configStandardCalendar.cellConfig.selectedStyle?.border
                      : configStandardCalendar.cellConfig.enabledStyle?.border,
              borderRadius: configStandardCalendar.borderRadius,
            ),
            child: Center(
              child: Text(
                text,
                style: isEnabled
                    ? isCurrent
                        ? isSelected
                            ? configStandardCalendar.cellConfig.selectedStyle?.textStyle
                            : configStandardCalendar.cellConfig.currentStyle?.textStyle
                        : isSelected
                            ? configStandardCalendar.cellConfig.selectedStyle?.textStyle
                            : configStandardCalendar.topBarConfig.monthDaysStyle
                    : configStandardCalendar.cellConfig.disabledStyle?.textStyle,
              ),
            ),
          ),
        ),
      );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/calendar_config_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';

class CalendarCellWidget extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isEnabled;
  final bool isWeekDaysBar;
  final bool isCurrent;
  late final MobkitCalendarConfigModel configStandardCalendar;
  final List<MobkitCalendarAppointmentModel>? showedCustomCalendarModelList;
  CalendarCellWidget(
    this.text, {
    this.isSelected = false,
    this.isEnabled = true,
    this.isWeekDaysBar = false,
    this.isCurrent = false,
    MobkitCalendarConfigModel? standardCalendarConfig,
    this.showedCustomCalendarModelList,
    Key? key,
  }) : super(key: key) {
    if (standardCalendarConfig == null) {
      configStandardCalendar = MobkitCalendarConfigModel();
    } else {
      configStandardCalendar = standardCalendarConfig;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: configStandardCalendar.itemSpace,
      child: AnimatedContainer(
        duration: configStandardCalendar.animationDuration,
        decoration: BoxDecoration(
          color: isEnabled
              ? isSelected
                  ? configStandardCalendar.selectedColor.withOpacity(1.0)
                  : configStandardCalendar.enabledColor
              : configStandardCalendar.disabledColor,
          borderRadius: configStandardCalendar.borderRadius,
          border: isWeekDaysBar
              ? Border.all(width: 1, color: configStandardCalendar.weekDaysBarBorderColor)
              : Border.all(
                  width: configStandardCalendar.borderWidth,
                  color: isEnabled
                      ? isSelected
                          ? configStandardCalendar.selectedBorderColor
                          : configStandardCalendar.enabledCellBorderColor
                      : configStandardCalendar.disabledColor),
        ),
        child: isWeekDaysBar
            ? Center(
                child: Text(
                  text,
                  style: configStandardCalendar.weekDaysStyle,
                ),
              )
            : showedCustomCalendarModelList != null
                ? Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: configStandardCalendar.cellTextTopPadding ?? 0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Text(
                              text,
                              textAlign: TextAlign.center,
                              style: isEnabled
                                  ? isCurrent
                                      ? isSelected
                                          ? configStandardCalendar.selectedStyle
                                          : configStandardCalendar.currentStyle
                                      : isSelected
                                          ? configStandardCalendar.selectedStyle
                                          : configStandardCalendar.monthDaysStyle
                                  : configStandardCalendar.disabledStyle,
                            ),
                          ),
                        ),
                      ),
                      (!isEnabled && !(configStandardCalendar.showEventOffDay ?? false))
                          ? Container()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: generateItems(showedCustomCalendarModelList),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: generateAllDayItems(showedCustomCalendarModelList, context),
                                ),
                                showedCustomCalendarModelList!.where((element) => element.isAllDay).length > 3
                                    ? Center(
                                        child: Text(
                                          "+${(showedCustomCalendarModelList!.where((element) => element.isAllDay).length - 3).toString()}",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 9,
                                              color: isSelected ? Colors.white : Colors.black,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : Container(),
                              ],
                            )
                    ],
                  )
                : Container(),
      ),
    );
  }

  List<Widget> generateItems(List<MobkitCalendarAppointmentModel>? showedCustomCalendarModelList) {
    List<Widget> items = [];
    if (showedCustomCalendarModelList != null) {
      List<MobkitCalendarAppointmentModel> listModel =
          showedCustomCalendarModelList.where((element) => !element.isAllDay).toList();
      if (listModel.isNotEmpty) {
        for (int i = 0; i < listModel.length; i++) {
          if ((i) == (configStandardCalendar.maxEventPointCount ?? 3)) {
            items.add(
              Padding(
                padding: const EdgeInsets.all(1),
                child: Text(
                  "+${(listModel.length - (configStandardCalendar.maxEventPointCount ?? 3)).toString()}",
                  style: TextStyle(
                      fontSize: 8, color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            );
            break;
          } else {
            items.add(
              Padding(
                padding: const EdgeInsets.all(1),
                child: CircleAvatar(
                  radius: configStandardCalendar.eventPointRadius ?? 4.5,
                  backgroundColor: listModel[i].color,
                ),
              ),
            );
          }
        }
      }
    }
    return items;
  }

  List<Widget> generateAllDayItems(
      List<MobkitCalendarAppointmentModel>? showedCustomCalendarModelList, BuildContext context) {
    List<Widget> items = [];
    if (showedCustomCalendarModelList != null && showedCustomCalendarModelList.isNotEmpty) {
      List<MobkitCalendarAppointmentModel> listModel =
          showedCustomCalendarModelList.where((element) => element.isAllDay).toList();
      if (listModel.isNotEmpty) {
        for (int i = 0; i < listModel.length; i++) {
          if ((i + 1) == (configStandardCalendar.maxEventLineCount ?? 3)) {
            break;
          } else {
            items.add(
              Container(
                margin: EdgeInsets.only(
                  top: configStandardCalendar.eventLinePadding ?? 0.3,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                  color: listModel[i].color,
                ),
                height: configStandardCalendar.eventLineHeight ?? 2.5,
              ),
            );
          }
        }
      }
    }
    return items;
  }
}

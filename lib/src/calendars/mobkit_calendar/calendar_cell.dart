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
        ),
        child: isWeekDaysBar
            ? Center(
                child: Text(
                  text,
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
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Spacer(),
                          Text(
                            text,
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
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: generateItems(showedCustomCalendarModelList),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  showedCustomCalendarModelList != null
                      ? Stack(
                          children: [
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
                      : Container()
                ],
              ),
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
          if (i == 2 && listModel.length > 3) {
            items.add(
              Padding(
                padding: const EdgeInsets.all(1),
                child: Text(
                  "+${(listModel.length - 2).toString()}",
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
                  radius: 4.5,
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
          if (i == 3 && listModel.length > 3) {
            break;
          } else {
            items.add(
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(2.0)),
                  color: listModel[i].color,
                ),
                height: 2.5,
              ),
            );
          }
        }
      }
    }
    return items;
  }
}

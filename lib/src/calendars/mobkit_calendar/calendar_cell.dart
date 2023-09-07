import 'package:flutter/material.dart';
import '../../../mobkit_calendar.dart';

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
    var style = isEnabled || configStandardCalendar.mobkitCalendarViewType != MobkitCalendarViewType.monthly
        ? isSelected
            ? configStandardCalendar.cellConfig.selectedStyle
            : isCurrent
                ? configStandardCalendar.cellConfig.currentStyle
                : configStandardCalendar.cellConfig.enabledStyle
        : configStandardCalendar.cellConfig.disabledStyle;
    return Padding(
      padding: configStandardCalendar.itemSpace,
      child: AnimatedContainer(
        duration: configStandardCalendar.animationDuration,
        decoration: BoxDecoration(
          color: style?.color,
          borderRadius: configStandardCalendar.borderRadius,
          border: isWeekDaysBar
              ? Border.all(width: 1, color: configStandardCalendar.weekDaysBarBorderColor)
              : style?.border,
        ),
        child: isWeekDaysBar
            ? Center(
                child: Text(
                  text,
                  style: configStandardCalendar.topBarConfig.weekDaysStyle,
                ),
              )
            : showedCustomCalendarModelList != null
                ? Padding(
                    padding: style?.padding ?? EdgeInsets.zero,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: style?.textStyle,
                          ),
                        ),
                        ((!isEnabled && !(configStandardCalendar.showEventOffDay ?? false)) &&
                                configStandardCalendar.mobkitCalendarViewType == MobkitCalendarViewType.monthly)
                            ? Container()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: generateItems(showedCustomCalendarModelList, style),
                                  ),
                                  SizedBox(
                                    height: configStandardCalendar.cellConfig.spaceBetweenEventLineToPoint,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: generateAllDayItems(showedCustomCalendarModelList, context),
                                  ),
                                  showedCustomCalendarModelList!.where((element) => element.isAllDay).length >
                                          configStandardCalendar.cellConfig.maxEventLineCount
                                      ? Center(
                                          child: Text(
                                            "+${(showedCustomCalendarModelList!.where((element) => element.isAllDay).length - (configStandardCalendar.cellConfig.maxEventLineCount - 1)).toString()}",
                                            textAlign: TextAlign.center,
                                            style: style?.maxLineCountTextStyle ??
                                                TextStyle(
                                                    fontSize: 9,
                                                    color: isSelected ? Colors.white : Colors.black,
                                                    fontWeight: FontWeight.bold),
                                          ),
                                        )
                                      : Container(),
                                ],
                              )
                      ],
                    ),
                  )
                : Container(),
      ),
    );
  }

  List<Widget> generateItems(
      List<MobkitCalendarAppointmentModel>? showedCustomCalendarModelList, CalendarCellStyle? style) {
    List<Widget> items = [];
    if (showedCustomCalendarModelList != null) {
      List<MobkitCalendarAppointmentModel> listModel =
          showedCustomCalendarModelList.where((element) => !element.isAllDay).toList();
      if (listModel.isNotEmpty) {
        for (int i = 0; i < listModel.length; i++) {
          if (i + 1 == configStandardCalendar.cellConfig.maxEventPointCount && i < listModel.length - 1) {
            items.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Text(
                  "+${(listModel.length - (configStandardCalendar.cellConfig.maxEventPointCount - 1)).toString()}",
                  style: isSelected
                      ? style?.maxPointCountTextStyle ??
                          const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold)
                      : style?.maxPointCountTextStyle ??
                          const TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            );
            break;
          } else {
            items.add(
              Padding(
                padding: EdgeInsets.only(
                  right: i == listModel.length - 1 ? 0 : configStandardCalendar.cellConfig.spaceBetweenEventPoints,
                ),
                child: CircleAvatar(
                  radius: configStandardCalendar.cellConfig.eventPointRadius,
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
          if ((i + 1) == (configStandardCalendar.cellConfig.maxEventLineCount) && i < listModel.length - 1) {
            break;
          } else {
            items.add(
              Container(
                margin: EdgeInsets.only(
                  bottom: i == (configStandardCalendar.cellConfig.maxEventLineCount) || i == listModel.length - 1
                      ? 0
                      : configStandardCalendar.cellConfig.spaceBetweenEventLines,
                ),
                decoration: BoxDecoration(
                  borderRadius: configStandardCalendar.cellConfig.eventLineRadius,
                  color: listModel[i].color,
                ),
                height: configStandardCalendar.cellConfig.eventLineHeight,
              ),
            );
          }
        }
      }
    }
    return items;
  }
}

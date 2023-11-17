import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/calendar_agenda_bar.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/calendar_date_bar.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/configs/calendar_config_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/utils/date_utils.dart';
import 'package:mobkit_calendar/src/extensions/date_extensions.dart';
import 'calendar_month_selection_bar.dart';
import 'calendar_weekdays_bar.dart';
import 'calendar_year_selection_bar.dart';
import 'enum/mobkit_calendar_view_type_enum.dart';
import 'model/mobkit_calendar_appointment_model.dart';
import 'multiple_listenable_builder_widget.dart';

class MobkitCalendarView extends StatelessWidget {
  const MobkitCalendarView({
    Key? key,
    required this.config,
    required this.appointmentModel,
    required this.calendarDate,
    required this.selectedDate,
    this.onSelectionChange,
    this.eventTap,
    this.onPopupChange,
    this.headerWidget,
    this.titleWidget,
    this.agendaWidget,
    this.onDateChanged,
    this.weeklyViewWidget,
    this.dateRangeChanged,
  }) : super(key: key);
  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> appointmentModel;
  final ValueNotifier<DateTime?> selectedDate;
  final ValueNotifier<DateTime> calendarDate;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange;
  final Function(MobkitCalendarAppointmentModel model)? eventTap;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? onPopupChange;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? headerWidget;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? titleWidget;
  final Widget Function(MobkitCalendarAppointmentModel list, DateTime datetime)? agendaWidget;
  final Function(DateTime datetime)? onDateChanged;
  final Widget Function(Map<DateTime, List<MobkitCalendarAppointmentModel>>)? weeklyViewWidget;
  final Function(DateTime datetime)? dateRangeChanged;

  bool? isIntersect(
    DateTime firstStartDate,
    DateTime firstEndDate,
    DateTime secondStartDate,
    DateTime secondEndDate,
  ) {
    return (secondStartDate.isBetween(firstStartDate, firstEndDate.add(const Duration(minutes: -1))) ?? false) ||
        (secondEndDate
                .add(const Duration(minutes: -1))
                .isBetween(firstStartDate, firstEndDate.add(const Duration(minutes: -1))) ??
            false) ||
        (firstStartDate.isBetween(secondStartDate, secondEndDate.add(const Duration(minutes: -1))) ?? false) ||
        (firstEndDate
                .add(const Duration(minutes: -1))
                .isBetween(secondStartDate, secondEndDate.add(const Duration(minutes: -1))) ??
            false);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int maxGroupCount = 0;
    DateTime? cSelectedDate = selectedDate.value;
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: config?.mobkitCalendarViewType == MobkitCalendarViewType.agenda
          ? [
              Expanded(
                child: CalendarAgendaBar(
                  calendarDate,
                  customCalendarModel: appointmentModel,
                  config: config,
                  titleWidget: titleWidget,
                  agendaWidget: agendaWidget,
                  dateRangeChanged: dateRangeChanged,
                  eventTap: eventTap,
                  onDateChanged: onDateChanged,
                ),
              ),
            ]
          : [
              ValueListenableBuilder(
                  valueListenable: ValuesNotifier([
                    calendarDate,
                    selectedDate,
                  ]),
                  builder: (_, bool date, __) {
                    if (cSelectedDate != selectedDate.value) {
                      return (config?.topBarConfig.isVisibleTitleWidget ?? false)
                          ? titleWidget?.call(
                                findCustomModel(appointmentModel, selectedDate.value!),
                                selectedDate.value!,
                              ) ??
                              Container()
                          : Container();
                    } else {
                      return ((config?.topBarConfig.isVisibleTitleWidget ?? false))
                          ? titleWidget?.call(
                                findCustomModel(appointmentModel, calendarDate.value),
                                calendarDate.value,
                              ) ??
                              Container()
                          : Container();
                    }
                  }),
              config?.topBarConfig.isVisibleMonthBar == true || config?.topBarConfig.isVisibleYearBar == true
                  ? SizedBox(
                      height: 30,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            config?.topBarConfig.isVisibleMonthBar == true
                                ? CalendarMonthSelectionBar(
                                    calendarDate,
                                    onSelectionChange,
                                    config,
                                  )
                                : Container(),
                            config?.topBarConfig.isVisibleMonthBar == true
                                ? const SizedBox(
                                    width: 10,
                                  )
                                : Container(),
                            config?.topBarConfig.isVisibleYearBar == true
                                ? CalendarYearSelectionBar(calendarDate, onSelectionChange, config)
                                : Container(),
                          ],
                        ),
                      ),
                    )
                  : Container(),
              config?.topBarConfig.isVisibleMonthBar == true || config?.topBarConfig.isVisibleYearBar == true
                  ? const SizedBox(
                      height: 15,
                    )
                  : Container(),
              config?.topBarConfig.isVisibleWeekDaysBar == true
                  ? SizedBox(
                      height: 30,
                      child: CalendarWeekDaysBar(
                        config: config,
                        customCalendarModel: appointmentModel,
                      ),
                    )
                  : Container(),
              config?.topBarConfig.isVisibleWeekDaysBar == true
                  ? const SizedBox(
                      height: 10,
                    )
                  : Container(),
              config?.mobkitCalendarViewType == MobkitCalendarViewType.daily
                  ? SizedBox(
                      height: config?.dailyTopWidgetSize,
                      child: CalendarDateSelectionBar(
                        calendarDate,
                        selectedDate,
                        onSelectionChange: onSelectionChange,
                        customCalendarModel: appointmentModel,
                        config: config,
                        onPopupChange: onPopupChange,
                        headerWidget: headerWidget,
                        onDateChanged: onDateChanged,
                        weeklyViewWidget: weeklyViewWidget,
                      ),
                    )
                  : Expanded(
                      child: CalendarDateSelectionBar(
                        calendarDate,
                        selectedDate,
                        onSelectionChange: onSelectionChange,
                        customCalendarModel: appointmentModel,
                        config: config,
                        onPopupChange: onPopupChange,
                        headerWidget: headerWidget,
                        onDateChanged: onDateChanged,
                        weeklyViewWidget: weeklyViewWidget,
                      ),
                    ),
              config?.mobkitCalendarViewType == MobkitCalendarViewType.daily
                  ? ValueListenableBuilder(
                      valueListenable: selectedDate,
                      builder: (_, DateTime? date, __) {
                        if (date != null) {
                          List<MobkitCalendarAppointmentModel> modelList = appointmentModel.where((element) {
                            var item = !element.isAllDay &&
                                ((DateTime(selectedDate.value!.year, selectedDate.value!.month, selectedDate.value!.day)
                                            .isBetween(element.appointmentStartDate, element.appointmentEndDate) ??
                                        false) ||
                                    (DateTime(selectedDate.value!.year, selectedDate.value!.month,
                                            selectedDate.value!.day)
                                        .isSameDay(element.appointmentStartDate)) ||
                                    DateTime(selectedDate.value!.year, selectedDate.value!.month,
                                            selectedDate.value!.day)
                                        .isSameDay(element.appointmentEndDate.add(const Duration(minutes: -1))));
                            return item;
                          }).toList();
                          List<MobkitCalendarAppointmentModel> allDayList = appointmentModel
                              .where((element) =>
                                  ((DateTime(selectedDate.value!.year, selectedDate.value!.month,
                                                  selectedDate.value!.day)
                                              .isBetween(element.appointmentStartDate, element.appointmentEndDate) ??
                                          false) ||
                                      DateTime(selectedDate.value!.year, selectedDate.value!.month,
                                              selectedDate.value!.day)
                                          .isSameDay(element.appointmentStartDate)) &&
                                  element.isAllDay)
                              .toList();
                          modelList.sort((a, b) => a.appointmentStartDate.compareTo(b.appointmentStartDate));
                          if (modelList.isNotEmpty) {
                            for (var item in modelList) {
                              if (modelList.indexOf(item) == 0) {
                                item.index = 0;
                                maxGroupCount = 1;
                              } else {
                                var indexOfData = 0;
                                List<int> groupIndex = [];
                                for (int i = 0; i < modelList.indexOf(item); i++) {
                                  if (isIntersect(item.appointmentStartDate, item.appointmentEndDate,
                                          modelList[i].appointmentStartDate, modelList[i].appointmentEndDate) ??
                                      false) {
                                    groupIndex.add((modelList[i].index ?? 0));
                                    while (groupIndex.contains(indexOfData)) {
                                      ++indexOfData;
                                    }
                                  }
                                }
                                item.index = indexOfData;
                                maxGroupCount = indexOfData + 1 > maxGroupCount ? indexOfData + 1 : maxGroupCount;
                              }
                            }
                          }
                          return Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                allDayList.isNotEmpty
                                    ? Padding(
                                        padding: config?.dailyItemsConfigModel.allDayMargin ??
                                            const EdgeInsets.symmetric(vertical: 6),
                                        child: Row(
                                          children: [
                                            Text(
                                              config?.dailyItemsConfigModel.allDayText ?? "Tüm Gün",
                                              style: config?.dailyItemsConfigModel.allDayTextStyle ??
                                                  const TextStyle(color: Colors.black, fontSize: 14),
                                            ),
                                            SizedBox(
                                              width: config?.dailyItemsConfigModel.space ?? 2,
                                            ),
                                            Expanded(
                                              child: Row(
                                                children: allDayList
                                                    .map(
                                                      (item) => Expanded(
                                                        child: GestureDetector(
                                                          onTap: () => eventTap?.call(item),
                                                          child: Container(
                                                            padding: config
                                                                    ?.dailyItemsConfigModel.allDayFrameStyle?.padding ??
                                                                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                            decoration: BoxDecoration(
                                                              color: item.color ??
                                                                  config?.dailyItemsConfigModel.allDayFrameStyle?.color,
                                                              border: config
                                                                  ?.dailyItemsConfigModel.allDayFrameStyle?.border,
                                                              borderRadius: config?.dailyItemsConfigModel
                                                                  .allDayFrameStyle?.borderRadius,
                                                            ),
                                                            child: Text(
                                                              item.title ?? "",
                                                              overflow: TextOverflow.ellipsis,
                                                              maxLines: 1,
                                                              style: config
                                                                  ?.dailyItemsConfigModel.allDayFrameStyle?.textStyle,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Stack(
                                      children: List<Widget>.generate(
                                        modelList.length,
                                        (i) {
                                          return Positioned(
                                            top: (!modelList[i].appointmentEndDate.isSameDay(selectedDate.value!) &&
                                                    !modelList[i].appointmentStartDate.isSameDay(selectedDate.value!))
                                                ? 0
                                                : (!modelList[i].appointmentStartDate.isSameDay(selectedDate.value!) &&
                                                        modelList[i].appointmentEndDate.isSameDay(selectedDate.value!))
                                                    ? 0
                                                    : (80 *
                                                                    (modelList[i].appointmentStartDate.hour +
                                                                        (modelList[i].appointmentStartDate.minute /
                                                                            60)))
                                                                .toDouble() !=
                                                            0
                                                        ? (80 *
                                                                    (modelList[i].appointmentStartDate.hour +
                                                                        (modelList[i].appointmentStartDate.minute /
                                                                            60)))
                                                                .toDouble() +
                                                            9
                                                        : (80 *
                                                                (modelList[i].appointmentStartDate.hour +
                                                                    (modelList[i].appointmentStartDate.minute / 60)))
                                                            .toDouble(),
                                            left: 58.5 +
                                                ((modelList[i].index ?? 0) > 0
                                                    ? ((width * 0.8) / maxGroupCount) * (modelList[i].index ?? 0)
                                                    : 0),
                                            width: (width * 0.8) / (maxGroupCount),
                                            height: (!modelList[i].appointmentEndDate.isSameDay(selectedDate.value!) &&
                                                    !modelList[i].appointmentStartDate.isSameDay(selectedDate.value!))
                                                ? 24 * 80
                                                : (!modelList[i].appointmentStartDate.isSameDay(selectedDate.value!) &&
                                                        modelList[i].appointmentEndDate.isSameDay(selectedDate.value!))
                                                    ? (80 *
                                                                    (modelList[i].appointmentEndDate.hour +
                                                                        (modelList[i].appointmentEndDate.minute / 60)))
                                                                .toDouble() !=
                                                            0
                                                        ? (80 *
                                                                    (modelList[i].appointmentEndDate.hour +
                                                                        (modelList[i].appointmentEndDate.minute / 60)))
                                                                .toDouble() +
                                                            9
                                                        : (80 *
                                                                (modelList[i].appointmentEndDate.hour +
                                                                    (modelList[i].appointmentEndDate.minute / 60)))
                                                            .toDouble()
                                                    : modelList[i].appointmentEndDate.hour != 0
                                                        ? (((modelList[i]
                                                                    .appointmentEndDate
                                                                    .difference(modelList[i].appointmentStartDate)
                                                                    .inMinutes) /
                                                                60) *
                                                            80)
                                                        : modelList[i]
                                                                .appointmentEndDate
                                                                .difference(modelList[i].appointmentStartDate)
                                                                .inHours *
                                                            80,
                                            child: GestureDetector(
                                              onTap: () => eventTap?.call(modelList[i]),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 1.5),
                                                child: Container(
                                                  padding: config?.dailyItemsConfigModel.itemFrameStyle?.padding,
                                                  decoration: BoxDecoration(
                                                      color: modelList[i].color,
                                                      borderRadius:
                                                          config?.dailyItemsConfigModel.itemFrameStyle?.borderRadius ??
                                                              const BorderRadius.all(Radius.circular(1)),
                                                      border: config?.dailyItemsConfigModel.itemFrameStyle?.border),
                                                  child: Align(
                                                    alignment:
                                                        config?.dailyItemsConfigModel.itemFrameStyle?.alignment ??
                                                            Alignment.topLeft,
                                                    child: Text(
                                                      modelList[i].title ?? "",
                                                      style: config?.dailyItemsConfigModel.itemFrameStyle?.textStyle ??
                                                          const TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )..insert(
                                          0,
                                          Column(
                                            children: List<Widget>.generate(
                                              24,
                                              (index) {
                                                if (index == 0) {
                                                  return const SizedBox(
                                                    height: 80,
                                                  );
                                                } else {
                                                  return Container(
                                                    alignment: Alignment.topCenter,
                                                    height: 80,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 12, right: 12),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            "${(index).toString()}:00",
                                                            style: config?.dailyItemsConfigModel.hourTextStyle ??
                                                                const TextStyle(color: Colors.black, fontSize: 18),
                                                          ),
                                                          Container(
                                                            width: width * 0.8,
                                                            color: Theme.of(context).dividerColor,
                                                            height: 1,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    )
                  : Container(),
            ],
    );
  }
}

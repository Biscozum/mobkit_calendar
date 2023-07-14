import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/calendar_config_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import '../../extensions/date_extensions.dart';
import 'calendar_date_cell.dart';

class CalendarDateSelectionBar extends StatefulWidget {
  final ValueNotifier<DateTime> date;
  final ValueNotifier<DateTime> selectedDate;

  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange;

  const CalendarDateSelectionBar(
    this.date,
    this.selectedDate, {
    Key? key,
    this.config,
    required this.customCalendarModel,
    required this.onSelectionChange,
  }) : super(key: key);

  @override
  State<CalendarDateSelectionBar> createState() => _CalendarDateSelectionBarState();
}

class _CalendarDateSelectionBarState extends State<CalendarDateSelectionBar> {
  changeWeek(ValueNotifier<DateTime> calendarDate, int amount) {
    DateTime firstWeekDay = findFirstDateOfTheWeek(calendarDate.value);
    calendarDate.value = firstWeekDay.add(Duration(days: amount));
  }

  goNextWeek() => changeWeek(widget.date, 7);
  goPreviousWeek() => changeWeek(widget.date, -7);

  changeMonth(ValueNotifier<DateTime> calendarDate, bool isNext) {
    DateTime firstMonthDay = isNext
        ? DateTime(calendarDate.value.year, calendarDate.value.month + 1, 1)
        : findFirstDateOfTheMonth(DateTime(calendarDate.value.year, calendarDate.value.month, 0));
    calendarDate.value = firstMonthDay;
  }

  goNextMonth() => changeMonth(widget.date, true);
  goPreviousMonth() => changeMonth(widget.date, false);

  @override
  Widget build(BuildContext context) {
    String? swipeDirection;
    return ValueListenableBuilder(
        valueListenable: widget.date,
        builder: (_, DateTime date, __) {
          return GestureDetector(
            onPanUpdate: (details) {
              swipeDirection = details.delta.dx < 0 ? 'left' : 'right';
            },
            onPanEnd: (details) {
              if (swipeDirection == 'left') {
                if (widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.daily) {
                  goNextWeek();
                } else if (widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly) {
                  goNextMonth();
                }
              }
              if (swipeDirection == 'right') {
                if (widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.daily) {
                  goPreviousWeek();
                } else if (widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly) {
                  goPreviousMonth();
                }
              }
            },
            child: DateList(
              config: widget.config,
              customCalendarModel: widget.customCalendarModel,
              date: date,
              selectedDate: widget.selectedDate,
              onSelectionChange: widget.onSelectionChange,
            ),
          );
        });
  }
}

class DateList extends StatefulWidget {
  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final DateTime date;
  final ValueNotifier<DateTime> selectedDate;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange;

  const DateList(
      {Key? key,
      required this.date,
      required this.selectedDate,
      this.config,
      required this.customCalendarModel,
      required this.onSelectionChange})
      : super(key: key);

  @override
  State<DateList> createState() => _DateListState();
}

class _DateListState extends State<DateList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly
          ? getDatesMonthly(
              widget.date, widget.selectedDate, widget.onSelectionChange, widget.config, widget.customCalendarModel)
          : getDatesWeekly(
              widget.date, widget.selectedDate, widget.onSelectionChange, widget.config, widget.customCalendarModel),
    );
  }

  int calculateMonth(DateTime today) {
    final DateTime firstDayOfMonth = DateTime(today.year, today.month);
    return calculateWeekCount(firstDayOfMonth);
  }

  int calculateWeekCount(DateTime firstDay) {
    int weekCount = 0;
    final DateTime lastDayOfMonth = DateTime(firstDay.year, firstDay.month + 1, 0);
    DateTime date = firstDay;
    while (date.isBefore(lastDayOfMonth) || date == lastDayOfMonth) {
      weekCount++;
      date = date.next(DateTime.monday);
    }
    return weekCount;
  }

  List<Widget> getDatesMonthly(
    DateTime date,
    ValueNotifier<DateTime> selectedDate,
    Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange,
    final MobkitCalendarConfigModel? config,
    final List<MobkitCalendarAppointmentModel> customCalendarModel,
  ) {
    List<Widget> rowList = [];
    var firstDay = DateTime(date.year, date.month, 1);
    DateTime newDate = firstDay.isFirstDay(DateTime.monday) ? firstDay : firstDay.previous(DateTime.monday);
    for (var i = 0; i < calculateMonth(date); i++) {
      List<Widget> cellList = [];
      for (var x = 1; x <= 7; x++) {
        cellList.add(
          Expanded(
            child: CalendarDateCell(
              newDate,
              selectedDate,
              onSelectionChange,
              customCalendarModel: customCalendarModel,
              config: config,
              enabled: true,
            ),
          ),
        );
        cellList.add(Container(
          width: 1,
          color: config?.enabledBorderColor ?? Colors.transparent,
        ));
        newDate = newDate.add(const Duration(days: 1));
      }
      rowList.add(Expanded(child: Row(children: cellList)));
      rowList.add(Container(
        color: config?.enabledBorderColor ?? Colors.transparent,
        height: 1,
      ));
    }
    return rowList;
  }

  List<Widget> getDatesWeekly(
    DateTime date,
    ValueNotifier<DateTime> selectedDate,
    Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange,
    final MobkitCalendarConfigModel? config,
    final List<MobkitCalendarAppointmentModel> customCalendarModel,
  ) {
    List<Widget> rowList = [];
    var firstDay = date.add(const Duration(days: 1));
    DateTime newDate = firstDay.isFirstDay(DateTime.monday) ? firstDay : firstDay.previous(DateTime.monday);
    for (var i = 0; i < 1; i++) {
      List<Widget> cellList = [];
      for (var x = 1; x <= 7; x++) {
        cellList.add(
          CalendarDateCell(
            newDate,
            selectedDate,
            onSelectionChange,
            customCalendarModel: customCalendarModel,
            config: config,
            enabled: true,
          ),
        );
        newDate = newDate.add(const Duration(days: 1));
      }
      rowList.add(Expanded(child: Row(children: cellList)));
    }
    return rowList;
  }

  bool checkConfigForEnable(DateTime newDate, DateTime date, MobkitCalendarConfigModel? config) {
    if (config == null) return false;
    if (config.disableBefore != null && date.isBefore(config.disableBefore!)) return false;

    if (config.disableAfter != null && date.isAfter(config.disableAfter!)) {
      return false;
    }
    if (config.disabledDates != null && config.disabledDates!.any((element) => element.isSameDay(date))) {
      return false;
    }
    if (newDate.isWeekend() && config.disableWeekendsDays) return false;
    if (newDate.month != date.month && config.disableOffDays) return false;
    return true;
  }
}

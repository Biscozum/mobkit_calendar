import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/calendar_config_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/utils/date_utils.dart';
import '../../extensions/date_extensions.dart';
import 'calendar_date_cell.dart';
import 'enum/mobkit_calendar_view_type_enum.dart';

class CalendarDateSelectionBar extends StatefulWidget {
  final ValueNotifier<DateTime> calendarDate;
  final ValueNotifier<DateTime> selectedDate;

  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange;
  final Widget? Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime) onPopupChange;
  final Widget? Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime) headerWidget;

  const CalendarDateSelectionBar(
    this.calendarDate,
    this.selectedDate, {
    Key? key,
    this.config,
    required this.customCalendarModel,
    required this.onSelectionChange,
    required this.onPopupChange,
    required this.headerWidget,
  }) : super(key: key);

  @override
  State<CalendarDateSelectionBar> createState() => _CalendarDateSelectionBarState();
}

class _CalendarDateSelectionBarState extends State<CalendarDateSelectionBar> {
  late PageController _pageController;
  List<DateTime> showDates = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1, viewportFraction: widget.config?.viewportFraction ?? 1.0);
    showDates = [
      DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month - 1, widget.calendarDate.value.day),
      DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month, widget.calendarDate.value.day),
      DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month + 1, widget.calendarDate.value.day),
    ];
  }

  changeWeek(ValueNotifier<DateTime> calendarDate, int amount) {
    DateTime firstWeekDay = findFirstDateOfTheWeek(calendarDate.value);
    calendarDate.value = firstWeekDay.add(Duration(days: amount));
    widget.onSelectionChange([], calendarDate.value);
  }

  changeMonth(ValueNotifier<DateTime> calendarDate, bool isNext) {
    DateTime firstMonthDay = isNext
        ? DateTime(calendarDate.value.year, calendarDate.value.month + 1, 1)
        : findFirstDateOfTheMonth(DateTime(calendarDate.value.year, calendarDate.value.month, 0));
    calendarDate.value = firstMonthDay;
    widget.onSelectionChange([], calendarDate.value);
  }

  setShowDates(bool isNext) {
    if (isNext) {
      showDates = [
        DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month - 1, widget.calendarDate.value.day),
        DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month, widget.calendarDate.value.day),
        DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month + 1, widget.calendarDate.value.day),
      ];
      _pageController.jumpToPage(
        1,
      );
      widget.onSelectionChange([], widget.calendarDate.value);
    } else {
      showDates = [
        DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month - 1, widget.calendarDate.value.day),
        DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month, widget.calendarDate.value.day),
        DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month + 1, widget.calendarDate.value.day),
      ];
      _pageController.jumpToPage(
        1,
      );
      widget.onSelectionChange([], widget.calendarDate.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? swipeDirection;
    return ValueListenableBuilder(
        valueListenable: widget.calendarDate,
        builder: (_, DateTime date, __) {
          return GestureDetector(
            onPanUpdate: (details) {
              swipeDirection = details.delta.dx < 0 ? 'left' : 'right';
            },
            onPanEnd: (details) {
              if (swipeDirection == 'left') {
                if (widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.daily ||
                    widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.weekly) {
                  changeWeek(widget.calendarDate, 7);
                } else if (widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly) {
                  changeMonth(widget.calendarDate, true);
                }
              }
              if (swipeDirection == 'right') {
                if (widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.daily ||
                    widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.weekly) {
                  changeWeek(widget.calendarDate, -7);
                } else if (widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly) {
                  changeMonth(widget.calendarDate, false);
                }
              }
            },
            child: PageView.builder(
                itemCount: showDates.length,
                pageSnapping: true,
                physics: widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.weekly ||
                        widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.daily
                    ? const NeverScrollableScrollPhysics()
                    : const AlwaysScrollableScrollPhysics(),
                controller: _pageController,
                scrollDirection: Axis.vertical,
                padEnds: false,
                onPageChanged: (page) {
                  widget.calendarDate.value = showDates[page];
                  page == 0 ? setShowDates(false) : null;
                  page == 2 ? setShowDates(true) : null;
                },
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ((widget.config?.isVisibleHeaderWidget ?? false) &&
                              widget.headerWidget(
                                    findCustomModel(widget.customCalendarModel, showDates[index]),
                                    showDates[index],
                                  ) !=
                                  null)
                          ? widget.headerWidget(
                              findCustomModel(widget.customCalendarModel, showDates[index]),
                              showDates[index],
                            )!
                          : Container(),
                      Expanded(
                        child: DateList(
                          config: widget.config,
                          customCalendarModel: widget.customCalendarModel,
                          date: index == 0
                              ? addMonth(date, -1)
                              : index == 1
                                  ? showDates[index]
                                  : addMonth(date, 1),
                          selectedDate: widget.selectedDate,
                          onSelectionChange: widget.onSelectionChange,
                          onPopupChange: widget.onPopupChange,
                          headerWidget: widget.headerWidget,
                        ),
                      ),
                    ],
                  );
                }),
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
  final Widget? Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime) onPopupChange;
  final Widget? Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime) headerWidget;
  const DateList({
    Key? key,
    required this.date,
    required this.selectedDate,
    this.config,
    required this.customCalendarModel,
    required this.onSelectionChange,
    required this.onPopupChange,
    required this.headerWidget,
  }) : super(key: key);

  @override
  State<DateList> createState() => _DateListState();
}

class _DateListState extends State<DateList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly
          ? getDatesMonthly(widget.date, widget.selectedDate, widget.onSelectionChange, widget.config,
              widget.customCalendarModel, widget.onPopupChange)
          : getDatesWeekly(widget.date, widget.selectedDate, widget.onSelectionChange, widget.config,
              widget.customCalendarModel, widget.onPopupChange),
    );
  }

  List<Widget> getDatesMonthly(
    DateTime date,
    ValueNotifier<DateTime> selectedDate,
    Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange,
    final MobkitCalendarConfigModel? config,
    final List<MobkitCalendarAppointmentModel> customCalendarModel,
    final Widget? Function(List<MobkitCalendarAppointmentModel>, DateTime datetime) onPopupChange,
  ) {
    List<Widget> rowList = [];
    var firstDay = DateTime(date.year, date.month, 1);
    DateTime newDate = firstDay.isFirstDay(DateTime.monday) ? firstDay : firstDay.previous(DateTime.monday);
    for (var i = 0; i < calculateMonth(date); i++) {
      List<Widget> cellList = [];
      rowList.add(Container(
        color: config?.gridBorderColor ?? Colors.transparent,
        height: 1,
      ));
      for (var x = 1; x <= 7; x++) {
        cellList.add(
          Expanded(
            child: CalendarDateCell(
              newDate,
              selectedDate,
              onSelectionChange,
              customCalendarModel: customCalendarModel,
              config: config,
              enabled: checkConfigForEnable(newDate, date, config),
              onPopupChange: onPopupChange,
            ),
          ),
        );
        cellList.add(Container(
          width: 1,
          color: config?.gridBorderColor ?? Colors.transparent,
        ));
        newDate = newDate.add(const Duration(days: 1));
      }
      rowList.add(Expanded(child: Row(children: cellList)));
    }
    rowList.add(Container(
      color: config?.gridBorderColor ?? Colors.transparent,
      height: 1,
    ));
    return rowList;
  }

  List<Widget> getDatesWeekly(
    DateTime date,
    ValueNotifier<DateTime> selectedDate,
    Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange,
    final MobkitCalendarConfigModel? config,
    final List<MobkitCalendarAppointmentModel> customCalendarModel,
    final Widget? Function(List<MobkitCalendarAppointmentModel>, DateTime datetime) onPopupChange,
  ) {
    List<Widget> rowList = [];
    var firstDay = date.add(const Duration(days: 1));
    DateTime newDate = firstDay.isFirstDay(DateTime.monday) ? firstDay : firstDay.previous(DateTime.monday);
    for (var i = 0; i < 1; i++) {
      List<Widget> cellList = [];
      rowList.add(Container(
        color: config?.gridBorderColor ?? Colors.transparent,
        height: 1,
      ));
      for (var x = 1; x <= 7; x++) {
        cellList.add(
          Expanded(
            child: CalendarDateCell(
              newDate,
              selectedDate,
              onSelectionChange,
              customCalendarModel: customCalendarModel,
              config: config,
              enabled: checkConfigForEnable(newDate, date, config),
              onPopupChange: onPopupChange,
            ),
          ),
        );
        cellList.add(Container(
          width: 1,
          color: config?.enabledCellBorderColor ?? Colors.transparent,
        ));
        newDate = newDate.add(const Duration(days: 1));
      }
      rowList.add(Expanded(child: Row(children: cellList)));
    }
    rowList.add(Container(
      color: config?.gridBorderColor ?? Colors.transparent,
      height: 1,
    ));
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

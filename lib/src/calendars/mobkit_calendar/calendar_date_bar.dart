import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/utils/date_utils.dart';
import '../../extensions/date_extensions.dart';
import 'calendar_date_cell.dart';
import 'enum/mobkit_calendar_view_type_enum.dart';
import 'model/configs/calendar_config_model.dart';

class CalendarDateSelectionBar extends StatefulWidget {
  final ValueNotifier<DateTime> calendarDate;
  final ValueNotifier<DateTime> selectedDate;

  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange;
  final Function(DateTime datetime) onDateChanged;
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
    required this.onDateChanged,
  }) : super(key: key);

  @override
  State<CalendarDateSelectionBar> createState() => _CalendarDateSelectionBarState();
}

class _CalendarDateSelectionBarState extends State<CalendarDateSelectionBar> {
  late PageController _pageController;
  List<DateTime> showDates = [];
  ScrollActivity? _lastActivity;

  int _currentPage = 1;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1, viewportFraction: widget.config?.viewportFraction ?? 1.0);
    _pageController.addListener(() {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      if (_pageController.position.activity is BallisticScrollActivity && _lastActivity is! DragScrollActivity) {
        Future.delayed(const Duration(milliseconds: 350)).then(
          (value) {
            _currentPage == 0 ? setShowDates(false, showDates[_currentPage]) : null;
            _currentPage == 2 ? setShowDates(true, showDates[_currentPage]) : null;
          },
        );
      }
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      _lastActivity = _pageController.position.activity;
    });
    showDates = [
      DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month - 1, 1),
      DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month, widget.calendarDate.value.day),
      DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month + 1, 1),
      DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month + 2, 1),
    ];
  }

  changeWeek(ValueNotifier<DateTime> calendarDate, int amount) {
    DateTime firstWeekDay = findFirstDateOfTheWeek(calendarDate.value);
    calendarDate.value = firstWeekDay.add(Duration(days: amount));
    showDates = [
      DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month - 1, 1),
      DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month, widget.calendarDate.value.day),
      DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month + 1, 1),
      DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month + 2, 1),
    ];
    _pageController.jumpToPage(
      1,
    );
    widget.onDateChanged(widget.calendarDate.value);
  }

  changeMonth(ValueNotifier<DateTime> calendarDate, bool isNext) {
    DateTime firstMonthDay = isNext
        ? DateTime(calendarDate.value.year, calendarDate.value.month + 1, 1)
        : findFirstDateOfTheMonth(DateTime(calendarDate.value.year, calendarDate.value.month, 0));
    calendarDate.value = firstMonthDay;
    widget.onDateChanged(calendarDate.value);
  }

  setShowDates(bool isNext, DateTime time) {
    if (isNext) {
      showDates = [
        DateTime(time.year, time.month - 1, 1),
        DateTime(time.year, time.month, time.day),
        DateTime(time.year, time.month + 1, 1),
        DateTime(time.year, time.month + 2, 1),
      ];
      _pageController.jumpToPage(
        1,
      );
      widget.onDateChanged(time);
    } else {
      showDates = [
        DateTime(time.year, time.month - 1, 1),
        DateTime(time.year, time.month, time.day),
        DateTime(time.year, time.month + 1, 1),
        DateTime(time.year, time.month + 2, 1),
      ];
      _pageController.jumpToPage(
        1,
      );
    }
    widget.calendarDate.value = time;
    widget.onDateChanged(time);
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
                }
              }
              if (swipeDirection == 'right') {
                if (widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.daily ||
                    widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.weekly) {
                  changeWeek(widget.calendarDate, -7);
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
                  _currentPage = page;
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom: widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly
                            ? widget.config?.monthBetweenPadding ?? 0
                            : 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ((widget.config?.topBarConfig.isVisibleHeaderWidget ?? false) &&
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
                            date: showDates[index],
                            selectedDate: widget.selectedDate,
                            onSelectionChange: widget.onSelectionChange,
                            onPopupChange: widget.onPopupChange,
                            headerWidget: widget.headerWidget,
                          ),
                        ),
                      ],
                    ),
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
    DateTime newDate = firstDay.previous(DateTime.monday);
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

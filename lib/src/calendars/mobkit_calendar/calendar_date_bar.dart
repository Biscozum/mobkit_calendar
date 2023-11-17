import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/utils/date_utils.dart';
import '../../extensions/date_extensions.dart';
import 'calendar_date_cell.dart';
import 'enum/mobkit_calendar_view_type_enum.dart';
import 'model/configs/calendar_config_model.dart';
import 'multiple_listenable_builder_widget.dart';

class CalendarDateSelectionBar extends StatefulWidget {
  final ValueNotifier<DateTime> calendarDate;
  final ValueNotifier<DateTime?> selectedDate;

  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange;
  final Function(DateTime datetime)? onDateChanged;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? onPopupChange;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? headerWidget;
  final Widget Function(Map<DateTime, List<MobkitCalendarAppointmentModel>>)? weeklyViewWidget;

  const CalendarDateSelectionBar(
    this.calendarDate,
    this.selectedDate, {
    Key? key,
    this.config,
    required this.customCalendarModel,
    this.onSelectionChange,
    this.onPopupChange,
    this.headerWidget,
    this.onDateChanged,
    this.weeklyViewWidget,
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
    _pageController = widget.config?.pageController ??
        PageController(initialPage: 1, viewportFraction: widget.config?.viewportFraction ?? 1.0);
    _pageController.addListener(() {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      if (_pageController.position.activity is BallisticScrollActivity && _lastActivity is! DragScrollActivity) {
        Future.delayed(const Duration(milliseconds: 500)).then(
          (value) {
            _currentPage == 0 ? setShowDates(showDates[_currentPage]) : null;
            _currentPage == 2 ? setShowDates(showDates[_currentPage]) : null;
          },
        );
      }
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      else if (_pageController.position.activity is DrivenScrollActivity && _lastActivity is! DrivenScrollActivity) {
        Future.delayed(const Duration(milliseconds: 250)).then(
          (value) {
            _currentPage == 0 ? setShowDates(showDates[_currentPage]) : null;
            _currentPage == 2 ? setShowDates(showDates[_currentPage]) : null;
            _lastActivity = null;
          },
        );
      }
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      _lastActivity = _pageController.position.activity;
    });
    if (widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.daily ||
        widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.weekly) {
      showDates = [
        findFirstDateOfTheWeek(DateTime(
            widget.calendarDate.value.year, widget.calendarDate.value.month, widget.calendarDate.value.day - 7)),
        findFirstDateOfTheWeek(widget.calendarDate.value),
        findFirstDateOfTheWeek(DateTime(
            widget.calendarDate.value.year, widget.calendarDate.value.month, widget.calendarDate.value.day + 7)),
        findFirstDateOfTheWeek(DateTime(
            widget.calendarDate.value.year, widget.calendarDate.value.month, widget.calendarDate.value.day + 14)),
      ];
    } else {
      showDates = [
        DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month - 1, 1),
        DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month, widget.calendarDate.value.day),
        DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month + 1, 1),
        DateTime(widget.calendarDate.value.year, widget.calendarDate.value.month + 2, 1),
      ];
    }
  }

  setShowDates(DateTime time) {
    if (widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.daily ||
        widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.weekly) {
      showDates = [
        findFirstDateOfTheWeek(DateTime(time.year, time.month, time.day - 7)),
        findFirstDateOfTheWeek(time),
        findFirstDateOfTheWeek(DateTime(time.year, time.month, time.day + 7)),
        findFirstDateOfTheWeek(DateTime(time.year, time.month, time.day + 14)),
      ];
    } else {
      showDates = [
        DateTime(time.year, time.month - 1, 1),
        DateTime(time.year, time.month, time.day),
        DateTime(time.year, time.month + 1, 1),
        DateTime(time.year, time.month + 2, 1),
      ];
    }
    _pageController.jumpToPage(
      1,
    );

    widget.calendarDate.value = time;
    widget.onDateChanged?.call(time);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ValuesNotifier([
          widget.calendarDate,
          widget.selectedDate,
        ]),
        builder: (_, bool date, __) {
          return PageView.builder(
              itemCount: showDates.length,
              pageSnapping: true,
              controller: _pageController,
              scrollDirection: widget.config?.mobkitCalendarViewType != MobkitCalendarViewType.monthly
                  ? Axis.horizontal
                  : Axis.vertical,
              padEnds: false,
              onPageChanged: (page) {
                _currentPage = page;
              },
              itemBuilder: (context, index) {
                DateTime firstWeekDay = showDates[index];
                var headerDate =
                    (findFirstDateOfTheWeek(showDates[index]).isBeforeOrEqualTo(widget.calendarDate.value) ?? false) &&
                            (findLastDateOfTheWeek(showDates[index]).isAfterOrEqualTo(widget.calendarDate.value) ??
                                false)
                        ? widget.calendarDate.value
                        : showDates[index];
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly
                          ? widget.config?.monthBetweenPadding ?? 0
                          : 0),
                  key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (widget.config?.mobkitCalendarViewType != MobkitCalendarViewType.weekly) ...[
                        (widget.config?.topBarConfig.isVisibleHeaderWidget ?? false)
                            ? widget.headerWidget?.call(
                                  findCustomModel(widget.customCalendarModel, headerDate),
                                  headerDate,
                                ) ??
                                Container()
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
                      ] else
                        SizedBox(
                          height: widget.config?.weeklyTopWidgetSize,
                          child: Column(
                            children: [
                              (widget.config?.topBarConfig.isVisibleHeaderWidget ?? false)
                                  ? widget.headerWidget?.call(
                                        findCustomModel(widget.customCalendarModel, headerDate),
                                        headerDate,
                                      ) ??
                                      Container()
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
                        ),
                      widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.weekly
                          ? widget.weeklyViewWidget?.call({
                                firstWeekDay: findCustomModel(widget.customCalendarModel, firstWeekDay),
                                firstWeekDay.add(const Duration(days: 1)): findCustomModel(
                                    widget.customCalendarModel, firstWeekDay.add(const Duration(days: 1))),
                                firstWeekDay.add(const Duration(days: 2)): findCustomModel(
                                    widget.customCalendarModel, firstWeekDay.add(const Duration(days: 2))),
                                firstWeekDay.add(const Duration(days: 3)): findCustomModel(
                                    widget.customCalendarModel, firstWeekDay.add(const Duration(days: 3))),
                                firstWeekDay.add(const Duration(days: 4)): findCustomModel(
                                    widget.customCalendarModel, firstWeekDay.add(const Duration(days: 4))),
                                firstWeekDay.add(const Duration(days: 5)): findCustomModel(
                                    widget.customCalendarModel, firstWeekDay.add(const Duration(days: 5))),
                                firstWeekDay.add(const Duration(days: 6)): findCustomModel(
                                    widget.customCalendarModel, firstWeekDay.add(const Duration(days: 6))),
                              }) ??
                              Container()
                          : Container(),
                    ],
                  ),
                );
              });
        });
  }
}

class DateList extends StatefulWidget {
  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final DateTime date;
  final ValueNotifier<DateTime?> selectedDate;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? onPopupChange;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? headerWidget;
  const DateList({
    Key? key,
    required this.date,
    required this.selectedDate,
    this.config,
    required this.customCalendarModel,
    this.onSelectionChange,
    this.onPopupChange,
    this.headerWidget,
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
    ValueNotifier<DateTime?> selectedDate,
    Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange,
    final MobkitCalendarConfigModel? config,
    final List<MobkitCalendarAppointmentModel> customCalendarModel,
    final Widget Function(List<MobkitCalendarAppointmentModel>, DateTime datetime)? onPopupChange,
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
    ValueNotifier<DateTime?> selectedDate,
    Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange,
    final MobkitCalendarConfigModel? config,
    final List<MobkitCalendarAppointmentModel> customCalendarModel,
    final Widget Function(List<MobkitCalendarAppointmentModel>, DateTime datetime)? onPopupChange,
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
    if (config.disableBefore != null && newDate.isBefore(config.disableBefore!)) return false;

    if (config.disableAfter != null && newDate.isAfter(config.disableAfter!)) {
      return false;
    }
    if (config.disabledDates != null && config.disabledDates!.any((element) => element.isSameDay(newDate))) {
      return false;
    }
    if (config.disableWeekDays != null && config.disableWeekDays!.any((element) => element == newDate.weekday)) {
      return false;
    }
    if (newDate.isWeekend() && config.disableWeekendsDays) return false;
    if (newDate.month != date.month && config.disableOffDays) return false;
    return true;
  }
}

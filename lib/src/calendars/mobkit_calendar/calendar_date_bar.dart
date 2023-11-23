import 'dart:async';

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
  final DateTime minDate;

  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange;
  final Function(DateTime datetime)? onDateChanged;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime, bool isSameMonth)? onPopupChange;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? headerWidget;
  final Widget Function(Map<DateTime, List<MobkitCalendarAppointmentModel>>)? weeklyViewWidget;

  const CalendarDateSelectionBar(
    this.calendarDate,
    this.minDate,
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
  Timer? timer;

  late int _currentPage;
  @override
  void initState() {
    super.initState();
    _currentPage = ((widget.calendarDate.value.year * 12) + widget.calendarDate.value.month) -
        ((widget.minDate.year * 12) + widget.minDate.month);
    _pageController = widget.config?.pageController ??
        PageController(
            initialPage: widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly
                ? (((widget.calendarDate.value.year * 12) + widget.calendarDate.value.month) -
                    ((widget.minDate.year * 12) + widget.minDate.month))
                : ((findFirstDateOfTheWeek(widget.calendarDate.value)
                            .difference(findFirstDateOfTheWeek(widget.minDate))
                            .inDays) ~/
                        7)
                    .abs(),
            viewportFraction: widget.config?.viewportFraction ?? 1.0);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _pageController.position.isScrollingNotifier.addListener(() {
        timer?.cancel();
        if (!_pageController.position.isScrollingNotifier.value) {
          timer = Timer(const Duration(milliseconds: 500), () {
            widget.onDateChanged?.call(widget.calendarDate.value);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
              pageSnapping: true,
              controller: _pageController,
              scrollDirection: widget.config?.mobkitCalendarViewType != MobkitCalendarViewType.monthly
                  ? Axis.horizontal
                  : Axis.vertical,
              padEnds: false,
              onPageChanged: (page) {
                if (widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.daily ||
                    widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.weekly) {
                  widget.calendarDate.value = findFirstDateOfTheWeek(
                      widget.calendarDate.value.add(Duration(days: _currentPage < page ? 7 : -7)));
                }
                _currentPage = page;
                if (widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly) {
                  widget.calendarDate.value = addMonth(widget.minDate, _currentPage);
                }
              },
              itemBuilder: (context, index) {
                DateTime currentDate = widget.config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly
                    ? addMonth(widget.minDate, index)
                    : findFirstDateOfTheWeek(widget.minDate).add(Duration(days: index * 7));
                DateTime firstWeekDay = currentDate;
                var headerDate =
                    (findFirstDateOfTheWeek(currentDate).isBeforeOrEqualTo(widget.calendarDate.value) ?? false) &&
                            (findLastDateOfTheWeek(currentDate).isAfterOrEqualTo(widget.calendarDate.value) ?? false)
                        ? widget.calendarDate.value
                        : currentDate;
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
                            minDate: widget.minDate,
                            customCalendarModel: widget.customCalendarModel,
                            date: currentDate,
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
                                  date: currentDate,
                                  minDate: widget.minDate,
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
  final DateTime minDate;
  final ValueNotifier<DateTime?> selectedDate;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime, bool isSameMonth)? onPopupChange;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? headerWidget;
  const DateList({
    Key? key,
    required this.date,
    required this.minDate,
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
          ? getDatesMonthly(widget.date, widget.minDate, widget.selectedDate, widget.onSelectionChange, widget.config,
              widget.customCalendarModel, widget.onPopupChange)
          : getDatesWeekly(widget.date, widget.minDate, widget.selectedDate, widget.onSelectionChange, widget.config,
              widget.customCalendarModel, widget.onPopupChange),
    );
  }

  List<Widget> getDatesMonthly(
    DateTime date,
    DateTime minDate,
    ValueNotifier<DateTime?> selectedDate,
    Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange,
    final MobkitCalendarConfigModel? config,
    final List<MobkitCalendarAppointmentModel> customCalendarModel,
    final Widget Function(List<MobkitCalendarAppointmentModel>, DateTime datetime, bool isSameMonth)? onPopupChange,
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
              minDate,
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
    DateTime minDate,
    ValueNotifier<DateTime?> selectedDate,
    Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange,
    final MobkitCalendarConfigModel? config,
    final List<MobkitCalendarAppointmentModel> customCalendarModel,
    final Widget Function(List<MobkitCalendarAppointmentModel>, DateTime datetime, bool isSameMonth)? onPopupChange,
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
              minDate,
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/controller/mobkit_calendar_controller.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/utils/date_utils.dart';
import '../../extensions/date_extensions.dart';
import 'calendar_date_cell.dart';
import 'enum/mobkit_calendar_view_type_enum.dart';
import 'model/configs/calendar_config_model.dart';

class CalendarDateSelectionBar extends StatefulWidget {
  final DateTime minDate;

  final MobkitCalendarController mobkitCalendarController;
  final MobkitCalendarConfigModel? config;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange;
  final Function(DateTime datetime)? onDateChanged;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? onPopupWidget;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? headerWidget;
  final Widget Function(Map<DateTime, List<MobkitCalendarAppointmentModel>>)? weeklyViewWidget;

  const CalendarDateSelectionBar(
    this.minDate, {
    Key? key,
    this.config,
    required this.mobkitCalendarController,
    this.onSelectionChange,
    this.onPopupWidget,
    this.headerWidget,
    this.onDateChanged,
    this.weeklyViewWidget,
  }) : super(key: key);

  @override
  State<CalendarDateSelectionBar> createState() => _CalendarDateSelectionBarState();
}

class _CalendarDateSelectionBarState extends State<CalendarDateSelectionBar> {
  Timer? timer;

  late int _currentPage;
  @override
  void initState() {
    super.initState();
    _currentPage = widget.mobkitCalendarController.mobkitCalendarViewType == MobkitCalendarViewType.monthly
        ? ((widget.mobkitCalendarController.calendarDate.year * 12) +
                widget.mobkitCalendarController.calendarDate.month) -
            ((widget.minDate.year * 12) + widget.minDate.month)
        : ((findFirstDateOfTheWeek(widget.mobkitCalendarController.calendarDate)
                    .difference(findFirstDateOfTheWeek(widget.minDate))
                    .inDays) ~/
                7)
            .abs();
    widget.mobkitCalendarController.setPageController(widget.minDate, widget.config?.viewportFraction ?? 1);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.mobkitCalendarController.pageController.position.isScrollingNotifier.addListener(() {
        timer?.cancel();
        if (!widget.mobkitCalendarController.pageController.position.isScrollingNotifier.value) {
          timer = Timer(const Duration(milliseconds: 500), () {
            widget.onDateChanged?.call(widget.mobkitCalendarController.calendarDate);
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
    return ListenableBuilder(
        listenable: widget.mobkitCalendarController,
        builder: (context, Widget? builderWidget) {
          return PageView.builder(
              pageSnapping: true,
              controller: widget.mobkitCalendarController.pageController,
              scrollDirection: widget.mobkitCalendarController.mobkitCalendarViewType != MobkitCalendarViewType.monthly
                  ? Axis.horizontal
                  : Axis.vertical,
              padEnds: false,
              onPageChanged: (page) {
                if (widget.mobkitCalendarController.mobkitCalendarViewType == MobkitCalendarViewType.daily ||
                    widget.mobkitCalendarController.mobkitCalendarViewType == MobkitCalendarViewType.weekly) {
                  widget.mobkitCalendarController.calendarDate = (findFirstDateOfTheWeek(
                      widget.mobkitCalendarController.calendarDate.add(Duration(days: _currentPage < page ? 7 : -7))));
                }
                _currentPage = page;
                if (widget.mobkitCalendarController.mobkitCalendarViewType == MobkitCalendarViewType.monthly) {
                  widget.mobkitCalendarController.calendarDate = (addMonth(widget.minDate, _currentPage));
                }
              },
              itemBuilder: (context, index) {
                DateTime currentDate =
                    widget.mobkitCalendarController.mobkitCalendarViewType == MobkitCalendarViewType.monthly
                        ? addMonth(widget.minDate, index)
                        : findFirstDateOfTheWeek(widget.minDate).add(Duration(days: index * 7));
                DateTime firstWeekDay = currentDate;
                var headerDate = (findFirstDateOfTheWeek(currentDate)
                                .isBeforeOrEqualTo(widget.mobkitCalendarController.calendarDate) ??
                            false) &&
                        (findLastDateOfTheWeek(currentDate)
                                .isAfterOrEqualTo(widget.mobkitCalendarController.calendarDate) ??
                            false)
                    ? widget.mobkitCalendarController.calendarDate
                    : currentDate;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: widget.mobkitCalendarController.mobkitCalendarViewType == MobkitCalendarViewType.monthly
                          ? widget.config?.monthBetweenPadding ?? 0
                          : 0),
                  key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      if (widget.mobkitCalendarController.mobkitCalendarViewType != MobkitCalendarViewType.weekly) ...[
                        (widget.config?.topBarConfig.isVisibleHeaderWidget ?? false)
                            ? widget.headerWidget?.call(
                                  findCustomModel(widget.mobkitCalendarController.appoitnments, headerDate),
                                  headerDate,
                                ) ??
                                Container()
                            : Container(),
                        Expanded(
                          child: DateList(
                            config: widget.config,
                            minDate: widget.minDate,
                            date: currentDate,
                            mobkitCalendarController: widget.mobkitCalendarController,
                            onSelectionChange: widget.onSelectionChange,
                            onPopupWidget: widget.onPopupWidget,
                            headerWidget: widget.headerWidget,
                            onDateChanged: widget.onDateChanged,
                          ),
                        ),
                      ] else
                        SizedBox(
                          height: widget.config?.weeklyTopWidgetSize,
                          child: Column(
                            children: [
                              (widget.config?.topBarConfig.isVisibleHeaderWidget ?? false)
                                  ? widget.headerWidget?.call(
                                        findCustomModel(widget.mobkitCalendarController.appoitnments, headerDate),
                                        headerDate,
                                      ) ??
                                      Container()
                                  : Container(),
                              Expanded(
                                child: DateList(
                                  config: widget.config,
                                  date: currentDate,
                                  minDate: widget.minDate,
                                  mobkitCalendarController: widget.mobkitCalendarController,
                                  onSelectionChange: widget.onSelectionChange,
                                  onPopupWidget: widget.onPopupWidget,
                                  headerWidget: widget.headerWidget,
                                  onDateChanged: widget.onDateChanged,
                                ),
                              ),
                            ],
                          ),
                        ),
                      widget.mobkitCalendarController.mobkitCalendarViewType == MobkitCalendarViewType.weekly
                          ? widget.weeklyViewWidget?.call({
                                firstWeekDay:
                                    findCustomModel(widget.mobkitCalendarController.appoitnments, firstWeekDay),
                                firstWeekDay.add(const Duration(days: 1)): findCustomModel(
                                    widget.mobkitCalendarController.appoitnments,
                                    firstWeekDay.add(const Duration(days: 1))),
                                firstWeekDay.add(const Duration(days: 2)): findCustomModel(
                                    widget.mobkitCalendarController.appoitnments,
                                    firstWeekDay.add(const Duration(days: 2))),
                                firstWeekDay.add(const Duration(days: 3)): findCustomModel(
                                    widget.mobkitCalendarController.appoitnments,
                                    firstWeekDay.add(const Duration(days: 3))),
                                firstWeekDay.add(const Duration(days: 4)): findCustomModel(
                                    widget.mobkitCalendarController.appoitnments,
                                    firstWeekDay.add(const Duration(days: 4))),
                                firstWeekDay.add(const Duration(days: 5)): findCustomModel(
                                    widget.mobkitCalendarController.appoitnments,
                                    firstWeekDay.add(const Duration(days: 5))),
                                firstWeekDay.add(const Duration(days: 6)): findCustomModel(
                                    widget.mobkitCalendarController.appoitnments,
                                    firstWeekDay.add(const Duration(days: 6))),
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
  final MobkitCalendarController mobkitCalendarController;
  final DateTime minDate;
  final DateTime date;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? onPopupWidget;
  final List<MobkitCalendarAppointmentModel> Function(DateTime datetime, bool isSameMonth)? onPopupChange;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? headerWidget;
  final Function(DateTime datetime)? onDateChanged;

  const DateList({
    Key? key,
    required this.mobkitCalendarController,
    required this.minDate,
    required this.date,
    this.config,
    this.onSelectionChange,
    this.onPopupWidget,
    this.onPopupChange,
    this.headerWidget,
    this.onDateChanged,
  }) : super(key: key);

  @override
  State<DateList> createState() => _DateListState();
}

class _DateListState extends State<DateList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.mobkitCalendarController.mobkitCalendarViewType == MobkitCalendarViewType.monthly
          ? getDatesMonthly(widget.date, widget.minDate, widget.onSelectionChange, widget.config, widget.onPopupWidget,
              widget.onDateChanged, widget.mobkitCalendarController)
          : getDatesWeekly(widget.date, widget.minDate, widget.onSelectionChange, widget.config, widget.onPopupWidget,
              widget.onDateChanged, widget.mobkitCalendarController),
    );
  }

  List<Widget> getDatesMonthly(
    DateTime date,
    DateTime minDate,
    Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange,
    final MobkitCalendarConfigModel? config,
    final Widget Function(List<MobkitCalendarAppointmentModel>, DateTime datetime)? onPopupWidget,
    final Function(DateTime datetime)? onDateChanged,
    final MobkitCalendarController mobkitCalendarController,
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
              onSelectionChange,
              config: config,
              enabled: checkConfigForEnable(newDate, date, config),
              onPopupWidget: onPopupWidget,
              onDateChanged: onDateChanged,
              mobkitCalendarController: mobkitCalendarController,
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
    Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange,
    final MobkitCalendarConfigModel? config,
    final Widget Function(List<MobkitCalendarAppointmentModel>, DateTime datetime)? onPopupWidget,
    final Function(DateTime datetime)? onDateChanged,
    final MobkitCalendarController mobkitCalendarController,
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
              onSelectionChange,
              config: config,
              enabled: checkConfigForEnable(newDate, date, config),
              mobkitCalendarController: mobkitCalendarController,
              onPopupWidget: onPopupWidget,
              onDateChanged: onDateChanged,
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

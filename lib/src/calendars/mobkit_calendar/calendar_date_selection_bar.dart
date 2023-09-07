import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/calendar_date_cell.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'package:mobkit_calendar/src/extensions/date_extensions.dart';
import 'datecell_renderobject.dart';
import 'model/configs/calendar_config_model.dart';

class DateList extends StatefulWidget {
  final DateTime date;
  final ValueNotifier<DateTime> selectedDate;

  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange;
  final Function(DateTime datetime) onCalendarDateChange;
  final Widget? Function(List<MobkitCalendarAppointmentModel>, DateTime datetime) onPopupChange;

  const DateList(
    this.date,
    this.selectedDate, {
    Key? key,
    this.config,
    required this.customCalendarModel,
    required this.onSelectionChange,
    required this.onCalendarDateChange,
    required this.onPopupChange,
  }) : super(key: key);

  @override
  State<DateList> createState() => _DateListState();
}

class _DateListState extends State<DateList> {
  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: const TableBorder(horizontalInside: BorderSide(color: Colors.black, width: 2)),
      children: getDates(
        widget.date,
        widget.selectedDate,
        widget.config,
        widget.customCalendarModel,
        widget.onSelectionChange,
        widget.onCalendarDateChange,
        widget.onPopupChange,
      ),
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

  List<TableRow> getDates(
      DateTime date,
      ValueNotifier<DateTime> selectedDate,
      final MobkitCalendarConfigModel? config,
      final List<MobkitCalendarAppointmentModel> customCalendarModel,
      Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange,
      final Function(DateTime datetime) onCalendarDateChange,
      final Widget? Function(List<MobkitCalendarAppointmentModel>, DateTime datetime) onPopupChange) {
    List<TableRow> rowList = [];

    var firstDay = DateTime(date.year, date.month, 1);
    DateTime newDate = firstDay.isFirstDay(DateTime.monday) ? firstDay : firstDay.previous(DateTime.monday);
    for (var i = 0; i < calculateMonth(date); i++) {
      List<Widget> cellList = [];
      for (var x = 1; x <= 7; x++) {
        if (config != null) {
          cellList.add(CalendarDateCell(
            newDate,
            selectedDate,
            onSelectionChange,
            config: config,
            customCalendarModel: customCalendarModel,
            enabled: checkConfigForEnable(newDate, date, config),
            onPopupChange: onPopupChange,
          ));
        } else {
          cellList.add(Container());
        }
        newDate = newDate.add(const Duration(days: 1));
      }
      rowList.add(TableRow(children: cellList));
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

class DateSelectionBar extends StatefulWidget {
  final ValueNotifier<DateTime> date;
  final ValueNotifier<DateTime> selectedDate;
  final ValueNotifier<List<DateTime>> selectedDates;
  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange;
  final Function(DateTime, DateTime) onRangeSelectionChange;
  final Function(DateTime datetime) onCalendarDateChange;
  final Widget? Function(List<MobkitCalendarAppointmentModel>, DateTime datetime) onPopupChange;

  const DateSelectionBar(this.date, this.selectedDate, this.selectedDates,
      {Key? key,
      this.config,
      required this.customCalendarModel,
      required this.onSelectionChange,
      required this.onRangeSelectionChange,
      required this.onCalendarDateChange,
      required this.onPopupChange})
      : super(key: key);

  @override
  State<DateSelectionBar> createState() => _DateSelectionBarState();
}

class _DateSelectionBarState extends State<DateSelectionBar> {
  final key2 = GlobalKey();

  final Set<Foo2> _trackTaped = <Foo2>{};

  dateSwipteItem(PointerEvent event) {
    final RenderBox box = key2.currentContext!.findRenderObject() as RenderBox;
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is Foo2 && !_trackTaped.contains(target)) {
          _trackTaped.add(target);
          DateTime date = DateTime(widget.date.value.year, widget.date.value.month, target.index);
          _selectSwipe(date);
        }
        if (target is Foo2 && _trackTaped.contains(target)) {
          _trackTaped.add(target);
          DateTime date = DateTime(widget.date.value.year, widget.date.value.month, target.index);
          _selectSwipe(date);
        }
      }
    }
  }

  dateRangeTapItem(PointerEvent event) {
    final RenderBox box = key2.currentContext!.findRenderObject() as RenderBox;
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        final target = hit.target;
        if (target is Foo2) {
          _trackTaped.add(target);
          DateTime date = DateTime(widget.date.value.year, widget.date.value.month, target.index);
          _selectRange(date);
        }
      }
    }
  }

  List<DateTime> getDaysInBeteween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(DateTime(startDate.year, startDate.month, startDate.day + i));
    }
    return days;
  }

  _selectRange(DateTime index) {
    if (widget.selectedDates.value.isNotEmpty) {
      if (widget.selectedDates.value.contains(index)) {
        widget.selectedDates.value.clear();
        widget.selectedDates.value.add(index);
      } else if (!widget.selectedDates.value.contains(index) && widget.selectedDates.value.length > 1) {
        widget.selectedDates.value.clear();
        widget.selectedDates.value.add(index);
      } else {
        if (widget.selectedDates.value.first.isBefore(index)) {
          widget.selectedDates.value.addAll(getDaysInBeteween(widget.selectedDates.value.first, index));
          widget.onRangeSelectionChange(getDaysInBeteween(widget.selectedDates.value.first, index).first,
              getDaysInBeteween(widget.selectedDates.value.first, index).last);
        } else if (widget.selectedDates.value.first.isAfter(index)) {
          widget.selectedDates.value.addAll(getDaysInBeteween(
            index,
            widget.selectedDates.value.first,
          ));
          widget.onRangeSelectionChange(
              getDaysInBeteween(
                index,
                widget.selectedDates.value.first,
              ).first,
              getDaysInBeteween(
                index,
                widget.selectedDates.value.first,
              ).last);
        }
      }
    } else {
      widget.selectedDates.value.add(index);
    }
    setState(() {});
  }

  _selectSwipe(DateTime index) {
    if (widget.selectedDates.value.isNotEmpty) {
      if (widget.selectedDates.value.contains(index)) {
        DateTime firstIndex = widget.selectedDates.value.first;
        widget.selectedDates.value.clear();
        widget.selectedDates.value.add(firstIndex);
      } else {
        if (widget.selectedDates.value.first.day - 1 > index.day) {
          widget.selectedDates.value.addAll(getDaysInBeteween(
              DateTime(widget.date.value.year, widget.date.value.month, widget.selectedDates.value.first.day),
              DateTime(widget.date.value.year, widget.date.value.month, index.day)));
        } else if (widget.selectedDates.value.last.day + 1 < index.day) {
          widget.selectedDates.value.addAll(getDaysInBeteween(
              DateTime(widget.date.value.year, widget.date.value.month, widget.selectedDates.value.last.day),
              DateTime(widget.date.value.year, widget.date.value.month, index.day)));
        } else {
          widget.selectedDates.value.add(index);
        }
      }
    } else {
      widget.selectedDates.value.add(index);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ValueListenableBuilder(
          valueListenable: widget.date,
          builder: (_, DateTime date, __) {
            return DateList(
              date,
              widget.selectedDate,
              config: widget.config,
              customCalendarModel: widget.customCalendarModel,
              key: key2,
              onSelectionChange: widget.onSelectionChange,
              onCalendarDateChange: widget.onCalendarDateChange,
              onPopupChange: widget.onPopupChange,
            );
          }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobkit_calendar/src/extensions/date_extensions.dart';
import 'package:mobkit_calendar/src/pickers/widgets/month_cell.dart';

import '../calendars/mobkit_calendar/datecell_renderobject.dart';
import 'model/month_and_year_config_model.dart';

class MonthList extends StatefulWidget {
  final DateTime date;
  final ValueNotifier<DateTime> selectedDate;
  final ValueNotifier<List<DateTime>> selectedDates;
  final MobkitMonthAndYearCalendarConfigModel? config;
  final ValueChanged<DateTime> onSelectionChange;
  final Function(DateTime, DateTime) onRangeSelectionChange;
  const MonthList(this.date, this.selectedDate, this.selectedDates,
      {Key? key, this.config, required this.onSelectionChange, required this.onRangeSelectionChange})
      : super(key: key);

  @override
  State<MonthList> createState() => _MonthListState();
}

class _MonthListState extends State<MonthList> {
  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: generateMonths(widget.date, widget.selectedDate, widget.config, widget.selectedDates,
          widget.onSelectionChange, widget.onRangeSelectionChange),
    );
  }

  List<TableRow> generateMonths(
      DateTime date,
      ValueNotifier<DateTime> selectedDate,
      final MobkitMonthAndYearCalendarConfigModel? config,
      ValueNotifier<List<DateTime>> selectedDates,
      ValueChanged<DateTime> onSelectionChange,
      Function(DateTime, DateTime) onRangeSelectionChange) {
    List<TableRow> rowList = [];
    widget.selectedDates.value.sort((a, b) => a.compareTo(b));
    DateTime newDate = DateTime(date.year, 1, 1);
    for (var i = 1; i <= 4; i++) {
      List<Widget> months = [];
      for (int x = 1; x <= 3; x++) {
        DateTime dateTime = DateTime(newDate.year, newDate.month, 1);
        months.add(
          Move(
            index: dateTime.month,
            child: MonthCell(
                dateTime,
                selectedDates.value.contains(dateTime),
                selectedDates.value.isNotEmpty
                    ? selectedDates.value.first.month == dateTime.month ||
                            selectedDates.value.last.month == dateTime.month
                        ? true
                        : false
                    : false,
                selectedDate,
                selectedDates,
                config: widget.config,
                onRangeSelectionChange,
                onSelectionChange),
          ),
        );
        newDate = DateTime(newDate.year, newDate.month + 1, 1);
      }
      rowList.length < 4 ? rowList.add(TableRow(children: months)) : null;
    }
    return rowList;
  }

  bool checkConfigForEnable(DateTime newDate, DateTime date, MobkitMonthAndYearCalendarConfigModel? config) {
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

class MonthAndYearBarSelection extends StatefulWidget {
  final ValueNotifier<DateTime> calendarDate;
  final ValueNotifier<DateTime> selectedDate;
  final ValueNotifier<List<DateTime>> selectedDates;
  final MobkitMonthAndYearCalendarConfigModel? config;
  final ValueChanged<DateTime> onSelectionChange;
  final Function(DateTime, DateTime) onRangeSelectionChange;
  const MonthAndYearBarSelection(
      this.calendarDate, this.selectedDate, this.selectedDates, this.onSelectionChange, this.onRangeSelectionChange,
      {Key? key, this.config})
      : super(key: key);

  @override
  State<MonthAndYearBarSelection> createState() => _MonthAndYearBarSelectionState();
}

class _MonthAndYearBarSelectionState extends State<MonthAndYearBarSelection> {
  final key2 = GlobalKey();

  final Set<Foo2> _trackTaped = <Foo2>{};

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.selectedDate.value = DateTime(DateTime.now().year, DateTime.now().month, 1);
    });
    super.initState();
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
          DateTime date = DateTime(widget.calendarDate.value.year, target.index, widget.calendarDate.value.day);
          _selectRange(date);
        }
      }
    }
  }

  List<DateTime> getMonthsInBeteween(DateTime startDate, DateTime endDate) {
    List<DateTime> months = [];
    while (startDate.isBefore(endDate)) {
      months.add(DateTime(startDate.year, startDate.month));
      startDate = DateTime(startDate.year, startDate.month + 1);
    }
    return months;
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
          widget.selectedDates.value.addAll(getMonthsInBeteween(widget.selectedDates.value.first, index));
          widget.onRangeSelectionChange(getMonthsInBeteween(widget.selectedDates.value.first, index).first,
              getMonthsInBeteween(widget.selectedDates.value.first, index).last);
        } else if (widget.selectedDates.value.first.isAfter(index)) {
          widget.selectedDates.value.addAll(getMonthsInBeteween(
            index,
            widget.selectedDates.value.first,
          ));
          widget.onRangeSelectionChange(
              getMonthsInBeteween(
                index,
                widget.selectedDates.value.first,
              ).first,
              getMonthsInBeteween(
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

  @override
  Widget build(BuildContext context) {
    if (widget.config != null) {
      if (widget.config!.selectionType == MobkitMonthAndYearCalendarSelectionType.selectionRange) {
        return SizedBox(
          child: ValueListenableBuilder(
              valueListenable: widget.calendarDate,
              builder: (_, DateTime calendarDate, __) {
                return ValueListenableBuilder(
                    valueListenable: widget.selectedDates,
                    builder: (_, List<DateTime> dates, __) {
                      return Listener(
                        onPointerHover: dateRangeTapItem,
                        child: MonthList(
                          calendarDate,
                          widget.selectedDate,
                          widget.selectedDates,
                          config: widget.config,
                          key: key2,
                          onRangeSelectionChange: widget.onRangeSelectionChange,
                          onSelectionChange: widget.onSelectionChange,
                        ),
                      );
                    });
              }),
        );
      } else {
        return SizedBox(
          child: ValueListenableBuilder(
              valueListenable: widget.calendarDate,
              builder: (_, DateTime calendarDate, __) {
                return MonthList(
                  calendarDate,
                  widget.selectedDate,
                  widget.selectedDates,
                  config: widget.config,
                  key: key2,
                  onRangeSelectionChange: widget.onRangeSelectionChange,
                  onSelectionChange: widget.onSelectionChange,
                );
              }),
        );
      }
    } else {
      return SizedBox(
        child: ValueListenableBuilder(
            valueListenable: widget.calendarDate,
            builder: (_, DateTime calendarDate, __) {
              return MonthList(
                calendarDate,
                widget.selectedDate,
                widget.selectedDates,
                config: widget.config,
                key: key2,
                onRangeSelectionChange: widget.onRangeSelectionChange,
                onSelectionChange: widget.onSelectionChange,
              );
            }),
      );
    }
  }
}

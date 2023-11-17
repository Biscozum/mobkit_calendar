import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/src/extensions/date_extensions.dart';
import '../../model/calendar_type_model.dart';
import '../model/month_and_year_config_model.dart';
import 'picker_cell.dart';

class MonthCell extends StatelessWidget {
  final DateTime date;
  final bool enabled;
  final ValueNotifier<DateTime?> selectedDate;
  final ValueNotifier<List<DateTime>> selectedDates;
  final MobkitMonthAndYearCalendarConfigModel? config;
  final bool isSelectedNew;
  final bool isFirstLastSelectedItem;
  final ValueChanged<DateTime> onSelectionChange;
  final Function(DateTime, DateTime) onRangeSelectionChange;
  const MonthCell(this.date, this.isSelectedNew, this.isFirstLastSelectedItem, this.selectedDate, this.selectedDates,
      this.onRangeSelectionChange, this.onSelectionChange,
      {Key? key, this.config, this.enabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isEnabled = true;
    return ValueListenableBuilder(
        valueListenable: selectedDate,
        builder: (context, DateTime? selectedDate, widget) {
          return config != null
              ? config!.selectionType == MobkitMonthAndYearCalendarSelectionType.selectionRange
                  ? CellWidget(
                      DateFormat('MMMM', config!.locale).format(DateTime(0, date.month, 1)),
                      isSelected: isSelectedNew,
                      isFirstLastSelectedItem: isFirstLastSelectedItem,
                      isCurrent: DateFormat.yMd().format(DateTime.now()) == DateFormat.yMd().format(date),
                      isEnabled: isEnabled,
                      monthAndYearConfig: config,
                      calendarType: CalendarType.monthAndYearCalendar,
                    )
                  : GestureDetector(
                      onTap: () {
                        this.selectedDate.value = date;
                        onSelectionChange(date);
                      },
                      child: CellWidget(
                        DateFormat('MMMM', config!.locale).format(DateTime(0, date.month)),
                        isSelected: selectedDate != null && selectedDate.isSameDay(date),
                        isCurrent: DateFormat.yMd().format(DateTime.now()) == DateFormat.yMd().format(date),
                        monthAndYearConfig: config,
                        calendarType: CalendarType.monthAndYearCalendar,
                      ),
                    )
              : GestureDetector(
                  onTap: () {
                    this.selectedDate.value = date;
                    onSelectionChange(date);
                  },
                  child: CellWidget(
                    DateFormat('MMMM', config!.locale).format(DateTime(0, date.month)),
                    isSelected: selectedDate != null && selectedDate.isSameDay(date),
                    isCurrent: DateFormat.yMd().format(DateTime.now()) == DateFormat.yMd().format(date),
                  ),
                );
        });
  }
}

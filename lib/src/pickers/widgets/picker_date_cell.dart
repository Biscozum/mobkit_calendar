import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/src/extensions/date_extensions.dart';
import 'package:mobkit_calendar/src/model/calendar_type_model.dart';
import 'picker_cell.dart';
import '../standard_picker/model/picker_config_model.dart';

class PickerDateCell extends StatelessWidget {
  final DateTime date;
  final bool enabled;
  final ValueNotifier<DateTime> selectedDate;
  final MobkitPickerConfigModel? config;
  final bool isSelectedNew;
  final bool isFirstLastSelectedItem;
  final ValueChanged<DateTime> onSelectionChange;
  final Function(DateTime, DateTime) onRangeSelectionChange;
  const PickerDateCell(this.date, this.isSelectedNew, this.isFirstLastSelectedItem, this.selectedDate,
      this.onSelectionChange, this.onRangeSelectionChange,
      {Key? key, this.config, this.enabled = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isEnabled = enabled && checkIsEnableDate(date);
    return ValueListenableBuilder(
        valueListenable: selectedDate,
        builder: (context, DateTime selectedDate, widget) {
          return config != null
              ? config!.selectionType == MobkitCalendarSelectionType.rangeTap
                  ? CellWidget(
                      date.day.toString(),
                      isSelected: isSelectedNew,
                      isFirstLastSelectedItem: isFirstLastSelectedItem,
                      isEnabled: isEnabled,
                      standardCalendarConfig: config,
                      calendarType: CalendarType.standardCalendar,
                      isCurrent: DateFormat.yMd().format(DateTime.now()) == DateFormat.yMd().format(date),
                    )
                  : GestureDetector(
                      onTap: () {
                        if (isEnabled) {
                          this.selectedDate.value = date;
                          onSelectionChange(date);
                        }
                      },
                      child: CellWidget(
                        date.day.toString(),
                        isSelected: selectedDate.isSameDay(date),
                        isEnabled: isEnabled,
                        standardCalendarConfig: config,
                        calendarType: CalendarType.standardCalendar,
                        isCurrent: DateFormat.yMd().format(DateTime.now()) == DateFormat.yMd().format(date),
                      ),
                    )
              : GestureDetector(
                  onTap: () {
                    if (isEnabled) {
                      this.selectedDate.value = date;
                      onSelectionChange(date);
                    }
                  },
                  child: CellWidget(
                    date.day.toString(),
                    isSelected: selectedDate.isSameDay(date),
                    isEnabled: isEnabled,
                    standardCalendarConfig: config,
                    isCurrent: DateFormat.yMd().format(DateTime.now()) == DateFormat.yMd().format(date),
                    calendarType: CalendarType.standardCalendar,
                  ),
                );
        });
  }

  bool checkIsEnableDate(DateTime date) {
    if (config != null) {
      if (config?.disableBefore != null && date.isBefore(config!.disableBefore!)) return false;

      if (config?.disableAfter != null && date.isAfter(config!.disableAfter!)) {
        return false;
      }
      if (config?.disabledDates != null && config!.disabledDates!.any((element) => element.isSameDay(date))) {
        return false;
      }
    }
    return true;
  }
}

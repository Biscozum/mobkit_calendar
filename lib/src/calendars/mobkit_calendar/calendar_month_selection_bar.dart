import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/calendar_config_model.dart';
import 'calendar_buttons.dart';

class CalendarMonthSelectionBar extends StatelessWidget {
  final double _itemSpace = 14;
  final ValueNotifier<DateTime> calendarDate;
  final MobkitCalendarConfigModel? config;
  final Function(DateTime datetime) onCalendarDateChange;

  const CalendarMonthSelectionBar(this.calendarDate, this.onCalendarDateChange, this.config, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly
            ? CalendarBackButton(goPreviousMonth)
            : Container(),
        SizedBox(
          width: _itemSpace,
        ),
        ValueListenableBuilder(
          valueListenable: calendarDate,
          builder: (_, DateTime date, __) {
            return Text(
              _parseDateStr(calendarDate.value),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        SizedBox(
          width: _itemSpace,
        ),
        config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly
            ? CalendarForwardButton(goNextMonth)
            : Container(),
      ],
    );
  }

  changeMonth(ValueNotifier<DateTime> calendarDate, int amount) {
    var newMonth = calendarDate.value.month + amount;
    calendarDate.value = DateTime(calendarDate.value.year, newMonth, calendarDate.value.day);
    onCalendarDateChange(calendarDate.value);
  }

  goNextMonth() => changeMonth(calendarDate, 1);
  goPreviousMonth() => changeMonth(calendarDate, -1);
  String _parseDateStr(DateTime date) {
    return DateFormat('MMMM', config?.locale).format(date);
  }
}

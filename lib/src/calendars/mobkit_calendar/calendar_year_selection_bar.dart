import 'package:flutter/material.dart';
import '../../../mobkit_calendar.dart';
import 'calendar_buttons.dart';

class CalendarYearSelectionBar extends StatelessWidget {
  final ValueNotifier<DateTime> calendarDate;
  final double _itemSpace = 14;
  final MobkitCalendarConfigModel? config;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange;

  const CalendarYearSelectionBar(this.calendarDate, this.onSelectionChange, this.config, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly
            ? CalendarBackButton(goPreviousYear)
            : Container(),
        SizedBox(
          width: _itemSpace,
        ),
        ValueListenableBuilder(
            valueListenable: calendarDate,
            builder: (_, DateTime date, __) {
              return Text(
                date.year.toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              );
            }),
        SizedBox(
          width: _itemSpace,
        ),
        config?.mobkitCalendarViewType == MobkitCalendarViewType.monthly
            ? CalendarForwardButton(goNextYear)
            : Container(),
      ],
    );
  }

  changeYear(ValueNotifier<DateTime> calendarDate, int amount) {
    var newYear = calendarDate.value.year + amount;
    calendarDate.value = DateTime(newYear, calendarDate.value.month, calendarDate.value.day);
    onSelectionChange([], calendarDate.value);
  }

  goNextYear() => changeYear(calendarDate, 1);

  goPreviousYear() => changeYear(calendarDate, -1);
}

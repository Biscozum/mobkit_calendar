import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../mobkit_calendar.dart';

class CalendarMonthSelectionBar extends StatelessWidget {
  final ValueNotifier<DateTime> calendarDate;
  final MobkitCalendarConfigModel? config;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange;

  const CalendarMonthSelectionBar(this.calendarDate, this.onSelectionChange, this.config, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
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
    );
  }

  String _parseDateStr(DateTime date) {
    return DateFormat('MMMM', config?.locale).format(date);
  }
}

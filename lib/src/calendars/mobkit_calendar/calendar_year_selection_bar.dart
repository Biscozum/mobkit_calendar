import 'package:flutter/material.dart';
import '../../../mobkit_calendar.dart';

class CalendarYearSelectionBar extends StatelessWidget {
  final ValueNotifier<DateTime> calendarDate;
  final MobkitCalendarConfigModel? config;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange;

  const CalendarYearSelectionBar(this.calendarDate, this.onSelectionChange, this.config, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder(
            valueListenable: calendarDate,
            builder: (_, DateTime date, __) {
              return Text(
                date.year.toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              );
            }),
      ],
    );
  }
}

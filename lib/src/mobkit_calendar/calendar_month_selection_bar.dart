import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../mobkit_calendar.dart';

/// Creates the month information view available in various views of  [MobkitCalendarWidget].
class CalendarMonthSelectionBar extends StatelessWidget {
  final MobkitCalendarConfigModel? config;
  final MobkitCalendarController mobkitCalendarController;
  final Function(
          List<MobkitCalendarAppointmentModel> models, DateTime datetime)?
      onSelectionChange;

  const CalendarMonthSelectionBar(
      this.mobkitCalendarController, this.onSelectionChange, this.config,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: mobkitCalendarController,
      builder: (context, widget) {
        return Text(
          _parseDateStr(mobkitCalendarController.calendarDate),
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

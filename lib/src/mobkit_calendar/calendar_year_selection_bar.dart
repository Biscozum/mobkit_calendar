import 'package:flutter/material.dart';
import '../../mobkit_calendar.dart';

/// Creates the year information view available in various views of  [MobkitCalendarWidget].
class CalendarYearSelectionBar extends StatelessWidget {
  final MobkitCalendarController mobkitCalendarController;
  final MobkitCalendarConfigModel? config;
  final Function(
          List<MobkitCalendarAppointmentModel> models, DateTime datetime)?
      onSelectionChange;

  const CalendarYearSelectionBar(
      this.mobkitCalendarController, this.onSelectionChange, this.config,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListenableBuilder(
            listenable: mobkitCalendarController,
            builder: (context, builderwidget) {
              return Text(
                mobkitCalendarController.calendarDate.year.toString(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              );
            }),
      ],
    );
  }
}

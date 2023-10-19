import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';
import 'package:provider/provider.dart';

import 'controller/calendar_controller.dart';
import 'main.dart';

class MobkitCalendarDailyView extends StatelessWidget {
  const MobkitCalendarDailyView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<CalendarController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobkit Calendar Daily View'),
      ),
      body: MobkitCalendarWidget(
        calendarDate: DateTime.now(),
        config: controller.configModel,
        weeklyViewWidget: (val) => null,
        dateRangeChanged: (datetime) => null,
        headerWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => null,
        titleWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(children: [
            Text(
              DateFormat(
                "yyyy MMMM",
              ).format(datetime),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ]),
        ),
        onSelectionChange: (List<MobkitCalendarAppointmentModel> model, DateTime date) =>
            controller.setCalendarDate(model, date),
        appointmentModel: eventList,
        eventTap: (model) => null,
        onPopupChange: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => null,
        onDateChanged: (DateTime datetime) => null,
      ),
    );
  }
}

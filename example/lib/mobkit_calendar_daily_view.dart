import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';
import 'package:provider/provider.dart';
import 'controller/calendar_controller.dart';

class MobkitCalendarDailyView extends StatelessWidget {
  const MobkitCalendarDailyView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<CalendarController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobkit Calendar Daily View'),
      ),
      body: FutureBuilder<dynamic>(
          future: controller.getCalendarData(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return MobkitCalendarWidget(
                minDate: DateTime(1800),
                config: controller.configModel,
                titleWidget: (List<MobkitCalendarAppointmentModel> models,
                        DateTime datetime) =>
                    Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(children: [
                    Text(
                      DateFormat("yyyy MMMM", controller.configModel.locale)
                          .format(datetime),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ]),
                ),
                onSelectionChange: (List<MobkitCalendarAppointmentModel> model,
                        DateTime date) =>
                    controller.setCalendarDate(model, date),
                mobkitCalendarController: controller.mobkitCalendarController,
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}

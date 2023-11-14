import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';
import 'package:provider/provider.dart';

import 'controller/calendar_controller.dart';
import 'main.dart';

class MobkitCalendarWeeklyView extends StatefulWidget {
  const MobkitCalendarWeeklyView({super.key});

  @override
  State<MobkitCalendarWeeklyView> createState() => _MobkitCalendarWeeklyViewState();
}

class _MobkitCalendarWeeklyViewState extends State<MobkitCalendarWeeklyView> {
  DateTime calendarDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<CalendarController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobkit Calendar Weekly View'),
      ),
      body: MobkitCalendarWidget(
        calendarDate: DateTime.now(),
        config: controller.configModel,
        weeklyViewWidget: (val) => Expanded(
          child: ListView(
            children: [
              const SizedBox(
                height: 24,
              ),
              ValueListenableBuilder(
                valueListenable: controller.eventDate,
                builder: (context, DateTime? date, widget) {
                  return controller.eventDate.value != null
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            DateFormat("EEE, MMMM d", controller.configModel.locale)
                                .format(controller.eventDate.value!),
                            style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Text(
                            DateFormat("EEE, MMMM d", controller.configModel.locale)
                                .format(controller.calendarDate ?? DateTime.now()),
                            style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        );
                },
              ),
              const SizedBox(
                height: 12,
              ),
              ValueListenableBuilder(
                valueListenable: controller.showEvents,
                builder: (context, List<MobkitCalendarAppointmentModel> showEvents, widget) {
                  return SizedBox(
                    height: controller.showEvents.value.length * 45,
                    child: ListView.builder(
                      itemCount: controller.showEvents.value.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          child: Row(children: [
                            Container(
                              height: 40,
                              color: controller.showEvents.value[index].color,
                              width: 3,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Flexible(
                              child: Text(
                                controller.showEvents.value[index].title ?? "",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ]),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        dateRangeChanged: (datetime) => null,
        titleWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(children: [
            Text(
              DateFormat("yyyy MMMM", controller.configModel.locale).format(datetime),
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
        onDateChanged: (DateTime datetime) {},
      ),
    );
  }
}

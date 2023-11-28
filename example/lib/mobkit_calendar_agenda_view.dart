import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';
import 'package:provider/provider.dart';
import 'controller/calendar_controller.dart';

class MobkitCalendarAgendaView extends StatelessWidget {
  const MobkitCalendarAgendaView({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<CalendarController>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobkit Calendar Agenda View'),
      ),
      body: MobkitCalendarWidget(
        minDate: DateTime(1800),
        config: controller.configModel,
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
        eventTap: (model) => null,
        onPopupWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
          child: models.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        DateFormat("EEE, MMMM d", controller.configModel.locale).format(datetime),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: models.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              child: Row(children: [
                                Container(
                                  height: 40,
                                  color: models[index].color,
                                  width: 3,
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Flexible(
                                  child: Text(
                                    models[index].title ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        DateFormat("EEE, MMMM d", controller.configModel.locale).format(datetime),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ],
                ),
        ),
        onDateChanged: (DateTime datetime) => null,
        mobkitCalendarController: controller.mobkitCalendarController,
      ),
    );
  }
}

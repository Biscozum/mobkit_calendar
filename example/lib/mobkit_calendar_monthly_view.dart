import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';
import 'package:mobkit_calendar_example/controller/calendar_controller.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class MobkitCalendarMonthlyView extends StatefulWidget {
  const MobkitCalendarMonthlyView({super.key});

  @override
  State<MobkitCalendarMonthlyView> createState() => _MobkitCalendarMonthlyViewState();
}

class _MobkitCalendarMonthlyViewState extends State<MobkitCalendarMonthlyView> {
  @override
  Widget build(BuildContext context) {
    var controller = Provider.of<CalendarController>(context, listen: false);

    return Consumer<CalendarController>(
      builder: (context, state, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Mobkit Calendar Monthly View'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => controller.setIsFullScreen(),
            child: Icon(controller.isFullScreen ? Icons.close_fullscreen : Icons.open_in_full),
          ),
          body: MobkitCalendarWidget(
            calendarDate: DateTime.now(),
            key: UniqueKey(),
            config: controller.configModel,
            dateRangeChanged: (datetime) => null,
            headerWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(children: [
                Text(
                  DateFormat("MMMM", controller.configModel.locale).format(datetime),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ]),
            ),
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
            eventTap: (model) => null,
            onPopupChange: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => Padding(
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
          ),
        );
      },
    );
  }
}

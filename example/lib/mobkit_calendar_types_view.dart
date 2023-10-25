import 'package:flutter/material.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';
import 'package:mobkit_calendar_example/controller/calendar_controller.dart';
import 'package:provider/provider.dart';

import 'mobkit_calendar_agenda_view.dart';
import 'mobkit_calendar_daily_view.dart';
import 'mobkit_calendar_monthly_view.dart';
import 'mobkit_calendar_weekly_view.dart';

class MobkitCalendarTypesView extends StatelessWidget {
  const MobkitCalendarTypesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mobkit Calendar Example App'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                                create: (_) => CalendarController(MobkitCalendarViewType.monthly),
                                child: const MobkitCalendarMonthlyView(),
                              )),
                    );
                  },
                  child: const Text("Monthly View")),
            ),
            Center(
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                                create: (_) => CalendarController(MobkitCalendarViewType.weekly),
                                child: const MobkitCalendarWeeklyView(),
                              )),
                    );
                  },
                  child: const Text("Weekly View")),
            ),
            Center(
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                                create: (_) => CalendarController(MobkitCalendarViewType.daily),
                                child: const MobkitCalendarDailyView(),
                              )),
                    );
                  },
                  child: const Text("Daily View")),
            ),
            Center(
              child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                                create: (_) => CalendarController(MobkitCalendarViewType.agenda),
                                child: const MobkitCalendarAgendaView(),
                              )),
                    );
                  },
                  child: const Text("Agenda View")),
            )
          ],
        ));
  }
}

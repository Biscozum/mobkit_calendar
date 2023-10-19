import 'package:flutter/material.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';
import 'mobkit_calendar_types_view.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

double pageHeight = MediaQuery.of(navigatorKey.currentContext!).size.height;
double pageWidht = MediaQuery.of(navigatorKey.currentContext!).size.width;
List<MobkitCalendarAppointmentModel> eventList = [
  MobkitCalendarAppointmentModel(
    title: "Recurring event every 2 days (10 repetitions)",
    appointmentStartDate: DateTime.now().add(const Duration(days: -1)),
    appointmentEndDate: DateTime.now(),
    isAllDay: true,
    color: Colors.red,
    detail: "Recurring event every 2 days (10 repetitions)",
    recurrenceModel: RecurrenceModel(
        endDate: DateTime.now().add(const Duration(days: 500)), frequency: DailyFrequency(), interval: 10, repeatOf: 2),
  ),
  MobkitCalendarAppointmentModel(
    title: "Every 2nd Monday of the month (10 reps)",
    appointmentStartDate: DateTime.now().add(const Duration(days: -1)),
    appointmentEndDate: DateTime.now(),
    isAllDay: true,
    color: Colors.blue,
    detail: "Every 2nd Monday of the month (10 reps)",
    recurrenceModel: RecurrenceModel(
        endDate: DateTime.now().add(const Duration(days: 500)),
        frequency: MonthlyFrequency(
            monthlyFrequencyType: DayOfWeekAndRepetitionModel(dayOfMonthAndRepetition: const MapEntry(1, 2))),
        interval: 10,
        repeatOf: 1),
  ),
  MobkitCalendarAppointmentModel(
    title: "The event will take place between 4 and 6 p.m.",
    appointmentStartDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 16),
    appointmentEndDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
    isAllDay: false,
    color: Colors.green,
    detail: "The event will take place between 4 and 6 p.m.",
    recurrenceModel: null,
  ),
  MobkitCalendarAppointmentModel(
    title: "Every 2 weeks on Tuesdays and Sundays of the week (10 repetitions)",
    appointmentStartDate: DateTime.now().add(const Duration(days: -1)),
    appointmentEndDate: DateTime.now(),
    isAllDay: true,
    color: Colors.orange,
    detail: "Every 2 weeks on Tuesdays and Sundays of the week (10 repetitions)",
    recurrenceModel: RecurrenceModel(
        endDate: DateTime.now().add(const Duration(days: 500)),
        frequency: WeeklyFrequency(daysOfWeek: [2, 7]),
        interval: 10,
        repeatOf: 2),
  ),
];

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: const MobkitCalendarTypesView(),
    );
  }
}

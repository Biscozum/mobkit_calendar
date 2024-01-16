import 'package:flutter/material.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';
import '../main.dart';

class CalendarController extends ChangeNotifier {
  List<MobkitCalendarAppointmentModel> eventList = [
    MobkitCalendarAppointmentModel(
      title: "Recurring event every 2 days (10 repetitions)",
      appointmentStartDate: DateTime.now().add(const Duration(days: -1)),
      appointmentEndDate: DateTime.now(),
      isAllDay: true,
      color: Colors.red,
      detail: "Recurring event every 2 days (10 repetitions)",
      recurrenceModel: RecurrenceModel(
          endDate: DateTime.now().add(const Duration(days: 500)),
          frequency: DailyFrequency(),
          interval: 10,
          repeatOf: 2),
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
              monthlyFrequencyType: DayOfWeekAndRepetitionModel(
                  dayOfMonthAndRepetition: const MapEntry(1, 2))),
          interval: 10,
          repeatOf: 1),
    ),
    MobkitCalendarAppointmentModel(
      title: "The event will take place between 4 and 6 p.m.",
      appointmentStartDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 16),
      appointmentEndDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
      isAllDay: false,
      color: Colors.green,
      detail: "The event will take place between 4 and 6 p.m.",
      recurrenceModel: null,
    ),
    MobkitCalendarAppointmentModel(
      title:
          "Every 2 weeks on Tuesdays and Sundays of the week (10 repetitions)",
      appointmentStartDate: DateTime.now().add(const Duration(days: -1)),
      appointmentEndDate: DateTime.now(),
      isAllDay: true,
      color: Colors.orange,
      detail:
          "Every 2 weeks on Tuesdays and Sundays of the week (10 repetitions)",
      recurrenceModel: RecurrenceModel(
          endDate: DateTime.now().add(const Duration(days: 500)),
          frequency: WeeklyFrequency(daysOfWeek: [2, 7]),
          interval: 10,
          repeatOf: 2),
    ),
  ];
  MobkitCalendarController mobkitCalendarController =
      MobkitCalendarController();
  CalendarController(MobkitCalendarViewType mobkitCalendarViewType) {
    mobkitCalendarController.mobkitCalendarViewType = mobkitCalendarViewType;
    mobkitCalendarController.appointments = eventList;
    configModel = MobkitCalendarConfigModel(
      cellConfig: CalendarCellConfigModel(
        disabledStyle: CalendarCellStyle(
          textStyle:
              TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.5)),
          color: Colors.transparent,
        ),
        enabledStyle: CalendarCellStyle(
          textStyle: const TextStyle(fontSize: 14, color: Colors.black),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
        selectedStyle: CalendarCellStyle(
          color: Colors.orange,
          textStyle: const TextStyle(fontSize: 14, color: Colors.white),
          border: Border.all(color: Colors.black, width: 1),
        ),
        currentStyle: CalendarCellStyle(
          textStyle: const TextStyle(color: Colors.lightBlue),
        ),
      ),
      calendarPopupConfigModel: CalendarPopupConfigModel(
        popUpBoxDecoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(25))),
        popUpOpacity: true,
        animateDuration: 500,
        verticalPadding: 30,
        popupSpace: 10,
        popupHeight:
            MediaQuery.of(navigatorKey.currentContext!).size.height * 0.6,
        popupWidth: MediaQuery.of(navigatorKey.currentContext!).size.width,
        viewportFraction: 0.9,
      ),
      topBarConfig: CalendarTopBarConfigModel(
        isVisibleHeaderWidget:
            mobkitCalendarViewType == MobkitCalendarViewType.monthly ||
                mobkitCalendarViewType == MobkitCalendarViewType.agenda,
        isVisibleTitleWidget: true,
        isVisibleMonthBar: false,
        isVisibleYearBar: false,
        isVisibleWeekDaysBar: true,
        weekDaysStyle: const TextStyle(fontSize: 14, color: Colors.black),
      ),
      weekDaysBarBorderColor: Colors.transparent,
      locale: "en",
      disableOffDays: true,
      disableWeekendsDays: false,
      monthBetweenPadding: 20,
      primaryColor: Colors.lightBlue,
      popupEnable: mobkitCalendarViewType == MobkitCalendarViewType.monthly
          ? true
          : false,
      viewportFraction: mobkitCalendarViewType == MobkitCalendarViewType.monthly
          ? isFullScreen
              ? 1
              : 0.8
          : 1,
    );
  }
  late MobkitCalendarConfigModel configModel;
  bool isFullScreen = false;
  ValueNotifier<DateTime?> eventDate = ValueNotifier<DateTime?>(null);
  ValueNotifier<List<MobkitCalendarAppointmentModel>> showEvents =
      ValueNotifier<List<MobkitCalendarAppointmentModel>>([]);
  DateTime? calendarDate;

  setCalendarDate(List<MobkitCalendarAppointmentModel> models, DateTime date,
      {bool isFirst = false}) {
    showEvents.value = [];
    eventDate.value = date;
    if (models.isNotEmpty) {
      showEvents.value.addAll(models);
    }
    calendarDate = date;
    isFirst ? null : showEvents.notifyListeners();
    isFirst ? null : eventDate.notifyListeners();
  }

  setIsFullScreen() {
    isFullScreen = !isFullScreen;
    if (isFullScreen) {
      configModel.viewportFraction = 1;
    } else {
      configModel.viewportFraction = 0.8;
    }
    notifyListeners();
  }
}

import 'package:mobkit_calendar/mobkit_calendar.dart';

int calculateMonth(DateTime today) {
  final DateTime firstDayOfMonth = DateTime(today.year, today.month);
  return calculateWeekCount(firstDayOfMonth);
}

int calculateWeekCount(DateTime firstDay) {
  int weekCount = 0;
  final DateTime lastDayOfMonth = DateTime(firstDay.year, firstDay.month + 1, 0);
  DateTime date = firstDay;
  while (date.isBefore(lastDayOfMonth) || date == lastDayOfMonth) {
    weekCount++;
    date = date.next(DateTime.monday);
  }
  return weekCount;
}

List<MobkitCalendarAppointmentModel> findCustomModel(
    List<MobkitCalendarAppointmentModel> customCalendarModelList, DateTime today) {
  List<MobkitCalendarAppointmentModel> showCustomCalendarModelList = [];
  showCustomCalendarModelList = customCalendarModelList
      .where((element) =>
          !today.isSameDay(element.appointmentEndDate) &&
              (today.isBetween(element.appointmentStartDate, element.appointmentEndDate) ?? false) ||
          today.isSameDay(element.appointmentStartDate) ||
          (today.isSameDay(element.appointmentStartDate) ||
              today.isSameDay(element.appointmentEndDate.add(const Duration(minutes: -1)))))
      .toList();
  return showCustomCalendarModelList;
}

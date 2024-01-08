import 'package:mobkit_calendar/mobkit_calendar.dart';

import '../../extensions/model/week_dates_model.dart';

/// Returns the number of weeks in the relevant month.
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

/// Returns the number of weeks in the relevant month.
List<MobkitCalendarAppointmentModel> findCustomModel(
    List<MobkitCalendarAppointmentModel> customCalendarModelList, DateTime today) {
  List<MobkitCalendarAppointmentModel> showCustomCalendarModelList = [];
  showCustomCalendarModelList = customCalendarModelList
      .where((element) =>
          !today.isSameDay(element.appointmentEndDate) &&
              (today.isBetween(element.appointmentStartDate, element.appointmentEndDate) ?? false) ||
          today.isSameDay(element.appointmentStartDate) ||
          (today.isSameDay(element.appointmentStartDate) ||
              (!element.appointmentStartDate.isSameDay(element.appointmentEndDate) &&
                  today.isSameDay(element.appointmentEndDate.add(const Duration(minutes: -1))))))
      .toList();
  return showCustomCalendarModelList;
}

/// Adds the specified number of months to the relevant date and returns it.
DateTime addMonth(DateTime date, int amount) {
  var newMonth = date.month + amount;
  date = DateTime(date.year, newMonth, date.day);
  return date;
}

/// Returns the current date one week later.
DateTime getNextWeekDay(int weekDay, {DateTime? from}) {
  DateTime now = DateTime.now();
  if (from != null) {
    now = from;
  }
  int remainDays = weekDay - now.weekday + 7;
  return now.add(Duration(days: remainDays));
}

/// Returns the dates that fall between two related dates.
List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
  List<DateTime> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(startDate.add(Duration(days: i)));
  }
  return days;
}

/// Returns the start and end dates of the specified year and week.
WeekDates getDatesFromWeekNumber(int year, int weekNumber) {
  final DateTime firstDayOfYear = DateTime.utc(year, 1, 1);

  final int firstDayOfWeek = firstDayOfYear.weekday;

  final int daysToFirstWeek = (8 - firstDayOfWeek) % 7;

  final DateTime firstDayOfGivenWeek = firstDayOfYear.add(Duration(days: daysToFirstWeek + (weekNumber - 1) * 7));

  final DateTime lastDayOfGivenWeek = firstDayOfGivenWeek.add(const Duration(days: 6));

  return WeekDates(from: firstDayOfGivenWeek, to: lastDayOfGivenWeek);
}

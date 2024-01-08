import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  DateTime next(int day) {
    if (day == weekday) {
      return add(const Duration(days: 7));
    } else {
      return add(
        Duration(
          days: (day - weekday) % DateTime.daysPerWeek,
        ),
      );
    }
  }

  bool? isAfterOrEqualTo(DateTime dateTime) {
    final date = this;
    final isAtSameMomentAs = dateTime.isAtSameMomentAs(date);
    return isAtSameMomentAs | date.isAfter(dateTime);
  }

  bool? isBeforeOrEqualTo(DateTime dateTime) {
    final date = this;
    final isAtSameMomentAs = dateTime.isAtSameMomentAs(date);
    return isAtSameMomentAs | date.isBefore(dateTime);
  }

  bool? isBetween(
    DateTime fromDateTime,
    DateTime toDateTime,
  ) {
    final date = this;
    final isAfter = date.isAfterOrEqualTo(fromDateTime) ?? false;
    final isBefore = date.isBeforeOrEqualTo(toDateTime) ?? false;
    return isAfter && isBefore;
  }

  DateTime previous(int day) {
    if (day == weekday) {
      return subtract(const Duration(days: 7));
    } else {
      return subtract(
        Duration(
          days: (weekday - day) % DateTime.daysPerWeek,
        ),
      );
    }
  }

  bool isFirstDay(int weekday) {
    return DateTime(year, month, 1).weekday == weekday;
  }

  bool isFirstDayMonday() {
    return DateTime(year, month, 1).weekday == DateTime.monday;
  }

  bool isWeekend() {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  bool isSameDay(DateTime other) {
    var item = year == other.year && month == other.month && day == other.day;
    return item;
  }

  bool isSameMonth(DateTime other) {
    var item = year == other.year && month == other.month;
    return item;
  }

  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  int weekNumber() {
    int dayOfYear = int.parse(DateFormat("D").format(this));
    int woy = ((dayOfYear - weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(year - 1);
    } else if (woy > numOfWeeks(year)) {
      woy = 1;
    }
    return woy;
  }

  DateTime findFirstDateOfTheYear() {
    return DateTime(year, 1, 1);
  }

  DateTime findLastDateOfTheYear() {
    return DateTime(year, 12, 31);
  }

  DateTime findFirstDateOfTheMonth() {
    return DateTime(year, month, 1);
  }

  DateTime findLastDateOfTheMonth() {
    return DateTime(year, month + 1, 0);
  }

  DateTime findLastDateOfTheWeek() {
    return add(Duration(days: DateTime.daysPerWeek - weekday));
  }

  DateTime findFirstDateOfTheWeek() {
    return subtract(Duration(days: weekday - 1));
  }
}

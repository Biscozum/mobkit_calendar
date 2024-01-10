import 'package:intl/intl.dart';

/// Extension that collects functions produced with DateTime
extension DateTimeExtension on DateTime {
  /// Returns the relevant date to the next specified date.
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

  /// Returns a check if it is equal to or later than the relevant date.
  bool? isAfterOrEqualTo(DateTime dateTime) {
    final date = this;
    final isAtSameMomentAs = dateTime.isAtSameMomentAs(date);
    return isAtSameMomentAs | date.isAfter(dateTime);
  }

  /// Returns the check if it is equal to or earlier than the relevant date.
  bool? isBeforeOrEqualTo(DateTime dateTime) {
    final date = this;
    final isAtSameMomentAs = dateTime.isAtSameMomentAs(date);
    return isAtSameMomentAs | date.isBefore(dateTime);
  }

  /// Returns whether the relevant date is between two given dates.
  bool? isBetween(
    DateTime fromDateTime,
    DateTime toDateTime,
  ) {
    final date = this;
    final isAfter = date.isAfterOrEqualTo(fromDateTime) ?? false;
    final isBefore = date.isBeforeOrEqualTo(toDateTime) ?? false;
    return isAfter && isBefore;
  }

  /// Returns the relevant date to the previous specified date.
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

  /// Returns the check if the relevant date is the first day of the week.
  bool isFirstDay(int weekday) {
    return DateTime(year, month, 1).weekday == weekday;
  }

  /// Returns the check if the relevant date is the first day of the month.
  bool isFirstDayMonday() {
    return DateTime(year, month, 1).weekday == DateTime.monday;
  }

  /// Returns the check if the relevant date falls on a weekend.
  bool isWeekend() {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  /// Returns the check whether the relevant date and the specified date are the same day.
  bool isSameDay(DateTime other) {
    var item = year == other.year && month == other.month && day == other.day;
    return item;
  }

  /// Returns the check whether the relevant date and the specified date are the same month.
  bool isSameMonth(DateTime other) {
    var item = year == other.year && month == other.month;
    return item;
  }

  /// Returns the number of weeks in the year of the relevant date.
  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  /// Returns the week of the year in which the relevant date is.
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

  /// Returns the first day of the year of the relevant date.
  DateTime findFirstDateOfTheYear() {
    return DateTime(year, 1, 1);
  }

  /// Returns the last day of the year of the relevant date.
  DateTime findLastDateOfTheYear() {
    return DateTime(year, 12, 31);
  }

  /// Returns the first day of the month of the relevant date.
  DateTime findFirstDateOfTheMonth() {
    return DateTime(year, month, 1);
  }

  /// Returns the last day of the month of the relevant date.
  DateTime findLastDateOfTheMonth() {
    return DateTime(year, month + 1, 0);
  }

  /// Returns the first day of the week of the relevant date.
  DateTime findLastDateOfTheWeek() {
    return add(Duration(days: DateTime.daysPerWeek - weekday));
  }

  /// Returns the last day of the week of the relevant date.
  DateTime findFirstDateOfTheWeek() {
    return subtract(Duration(days: weekday - 1));
  }
}

import 'package:intl/intl.dart';

import 'model/week_dates_model.dart';

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
    return year == other.year && month == other.month && day == other.day;
  }

  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  int weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(date.year - 1);
    } else if (woy > numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }
}

WeekDates getDatesFromWeekNumber(int year, int weekNumber) {
  final DateTime firstDayOfYear = DateTime.utc(year, 1, 1);

  final int firstDayOfWeek = firstDayOfYear.weekday;

  final int daysToFirstWeek = (8 - firstDayOfWeek) % 7;

  final DateTime firstDayOfGivenWeek = firstDayOfYear.add(Duration(days: daysToFirstWeek + (weekNumber - 1) * 7));

  final DateTime lastDayOfGivenWeek = firstDayOfGivenWeek.add(const Duration(days: 6));

  return WeekDates(from: firstDayOfGivenWeek, to: lastDayOfGivenWeek);
}

List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
  List<DateTime> days = [];
  for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
    days.add(startDate.add(Duration(days: i)));
  }
  return days;
}

DateTime addMonth(DateTime date, int amount) {
  var newMonth = date.month + amount;
  date = DateTime(date.year, newMonth, date.day);
  return date;
}

DateTime findFirstDateOfTheYear(DateTime dateTime) {
  return DateTime(dateTime.year, 1, 1);
}

DateTime findLastDateOfTheYear(DateTime dateTime) {
  return DateTime(dateTime.year, 12, 31);
}

DateTime findFirstDateOfTheMonth(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, 1);
}

DateTime findLastDateOfTheMonth(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month + 1, 0);
}

DateTime findLastDateOfTheWeek(DateTime dateTime) {
  return dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
}

DateTime findFirstDateOfTheWeek(DateTime dateTime) {
  return dateTime.subtract(Duration(days: dateTime.weekday - 1));
}

DateTime getNextWeekDay(int weekDay, {DateTime? from}) {
  DateTime now = DateTime.now();
  if (from != null) {
    now = from;
  }
  int remainDays = weekDay - now.weekday + 7;
  return now.add(Duration(days: remainDays));
}

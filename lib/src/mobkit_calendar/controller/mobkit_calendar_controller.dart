import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';
import '../../extensions/model/week_dates_model.dart';

/// Controller that allows you to use [MobkitCalendar] with all its functions
class MobkitCalendarController extends ChangeNotifier {
  DateTime _calendarDate = DateTime.now();
  DateTime? _selectedDate;
  List<MobkitCalendarAppointmentModel> _appointments = [];
  late PageController _pageController;
  MobkitCalendarViewType _mobkitCalendarViewType =
      MobkitCalendarViewType.monthly;
  bool isLoadData = false;

  List<MobkitCalendarAppointmentModel> get appointments {
    return _appointments;
  }

  set appointments(List<MobkitCalendarAppointmentModel> newList) {
    parseAppointmentModel(newList);
    notifyListeners();
  }

  set selectedDate(DateTime? selectedDate) {
    _selectedDate = selectedDate;
    notifyListeners();
  }

  DateTime? get selectedDate {
    return _selectedDate;
  }

  DateTime get calendarDate {
    return _calendarDate;
  }

  set calendarDate(DateTime calendarDate) {
    _calendarDate = calendarDate;
    notifyListeners();
  }

  PageController get pageController {
    return _pageController;
  }

  setPageController(DateTime minDate, double viewportFraction) {
    _pageController = PageController(
        initialPage: mobkitCalendarViewType == MobkitCalendarViewType.monthly
            ? (((calendarDate.year * 12) + calendarDate.month) -
                ((minDate.year * 12) + minDate.month))
            : (((selectedDate ?? calendarDate)
                        .findFirstDateOfTheWeek()
                        .difference(minDate.findFirstDateOfTheWeek())
                        .inDays) ~/
                    7)
                .abs(),
        viewportFraction: viewportFraction);
  }

  set mobkitCalendarViewType(MobkitCalendarViewType mobkitCalendarViewType) {
    _mobkitCalendarViewType = mobkitCalendarViewType;

    notifyListeners();
  }

  MobkitCalendarViewType get mobkitCalendarViewType {
    return _mobkitCalendarViewType;
  }

  MobkitCalendarController({
    DateTime? calendarDateTime,
    DateTime? selectedDateTime,
    List<MobkitCalendarAppointmentModel>? appointmentList,
    MobkitCalendarViewType? viewType,
  }) {
    calendarDate = calendarDateTime ?? DateTime.now();
    selectedDate = selectedDateTime;
    appointments = appointmentList ?? [];
    mobkitCalendarViewType = viewType ?? MobkitCalendarViewType.monthly;
  }

  void nextPage({required Duration duration, required Curve curve}) {
    pageController.nextPage(duration: duration, curve: curve);
  }

  void previousPage({required Duration duration, required Curve curve}) {
    pageController.previousPage(duration: duration, curve: curve);
  }

  void popupChanged(DateTime minDate, int page) {
    if (selectedDate!.month != minDate.add(Duration(days: page)).month) {
      if (selectedDate!.isBefore((minDate.add(Duration(days: page))))) {
        pageController.nextPage(
            duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
      } else if (selectedDate!.isAfter((minDate.add(Duration(days: page))))) {
        pageController.previousPage(
            duration: const Duration(milliseconds: 250), curve: Curves.easeIn);
      }
      selectedDate = (minDate.add(Duration(days: page)));
    } else {
      selectedDate = (minDate.add(Duration(days: page)));
    }
  }

  parseAppointmentModel(List<MobkitCalendarAppointmentModel> newAppointments) {
    _appointments = [];
    if (newAppointments.isNotEmpty) {
      List<MobkitCalendarAppointmentModel> withRecurrencyAppointments = [];
      List<MobkitCalendarAppointmentModel> addNewAppointments = [];
      List<MobkitCalendarAppointmentModel> deletedAppointments = [];
      for (var appointment in newAppointments.where((element) =>
          element.appointmentStartDate.isAfter(element.appointmentEndDate))) {
        deletedAppointments.add(appointment);
        if (newAppointments.isEmpty) {
          break;
        }
      }
      for (var d = 0; d < deletedAppointments.length; d++) {
        if (kDebugMode) {
          log("Due to incorrect values ​​on the MobkitCalendarAppointmentModel, the relevant model has been deleted from the list.");
        }
        newAppointments.remove(deletedAppointments[d]);
      }
      if (newAppointments.isNotEmpty) {
        withRecurrencyAppointments = newAppointments
            .where((element) => element.recurrenceModel != null)
            .toList();
        _appointments.addAll(newAppointments
            .where((element) => element.recurrenceModel == null)
            .toList());
        for (int i = 0; i < withRecurrencyAppointments.length; i++) {
          addNewAppointments = [];
          if (withRecurrencyAppointments[i].recurrenceModel!.frequency
                  is DailyFrequency
              ? withRecurrencyAppointments[i].recurrenceModel!.repeatOf >
                  (withRecurrencyAppointments[i]
                      .appointmentStartDate
                      .difference(
                          withRecurrencyAppointments[i].appointmentEndDate)
                      .inDays
                      .abs())
              : true) {
            if (withRecurrencyAppointments[i].recurrenceModel != null) {
//region :Daily Repeat
              if (withRecurrencyAppointments[i].recurrenceModel!.frequency
                  is DailyFrequency) {
                for (int y = 1;
                    y <
                        withRecurrencyAppointments[i]
                                .recurrenceModel!
                                .interval +
                            1;
                    y++) {
                  MobkitCalendarAppointmentModel addAppointmentModel =
                      MobkitCalendarAppointmentModel(
                          title: withRecurrencyAppointments[i].title,
                          appointmentStartDate: withRecurrencyAppointments[i]
                              .appointmentStartDate
                              .add(Duration(
                                  days: y *
                                      withRecurrencyAppointments[i]
                                          .recurrenceModel!
                                          .repeatOf)),
                          appointmentEndDate: withRecurrencyAppointments[i]
                              .appointmentEndDate
                              .add(Duration(
                                  days: y *
                                      withRecurrencyAppointments[i]
                                          .recurrenceModel!
                                          .repeatOf)),
                          color: withRecurrencyAppointments[i].color,
                          isAllDay: withRecurrencyAppointments[i].isAllDay,
                          detail: withRecurrencyAppointments[i].detail,
                          recurrenceModel: null);
                  addNewAppointments.add(addAppointmentModel);
                }
              }
//endregion
//region : Weekly Repeat
              if (withRecurrencyAppointments[i].recurrenceModel!.frequency
                  is WeeklyFrequency) {
                List<int> dayOfWeekList = (withRecurrencyAppointments[i]
                        .recurrenceModel!
                        .frequency as WeeklyFrequency)
                    .daysOfWeek;
                int interval =
                    withRecurrencyAppointments[i].recurrenceModel!.interval;
                WeekDates weekDates = getDatesFromWeekNumber(
                    withRecurrencyAppointments[i].appointmentStartDate.year,
                    withRecurrencyAppointments[i]
                        .appointmentEndDate
                        .weekNumber());
                for (int y = 1; y < interval + 1; y++) {
                  int endDateDay = withRecurrencyAppointments[i]
                      .appointmentStartDate
                      .difference(
                          withRecurrencyAppointments[i].appointmentEndDate)
                      .inDays
                      .abs();
                  List<DateTime> betweenDays = getDaysInBetween(
                      weekDates.from.add(Duration(
                          days: (withRecurrencyAppointments[i]
                                  .recurrenceModel!
                                  .repeatOf *
                              (y * 7)))),
                      weekDates.to.add(Duration(
                          days: (withRecurrencyAppointments[i]
                                  .recurrenceModel!
                                  .repeatOf *
                              (y * 7)))));
                  if (withRecurrencyAppointments[i]
                      .recurrenceModel!
                      .endDate
                      .isAfter(weekDates.from.add(Duration(days: y * 7)))) {
                    for (int d = 0; d < dayOfWeekList.length; d++) {
                      for (int k = 0; k < betweenDays.length; k++) {
                        if (betweenDays[k].weekday == dayOfWeekList[d]) {
                          MobkitCalendarAppointmentModel addAppointmentModel =
                              MobkitCalendarAppointmentModel(
                                  title: withRecurrencyAppointments[i].title,
                                  appointmentStartDate: DateTime(
                                    betweenDays[k].year,
                                    betweenDays[k].month,
                                    betweenDays[k].day,
                                    withRecurrencyAppointments[i]
                                        .appointmentStartDate
                                        .hour,
                                    withRecurrencyAppointments[i]
                                        .appointmentStartDate
                                        .minute,
                                    withRecurrencyAppointments[i]
                                        .appointmentStartDate
                                        .second,
                                  ),
                                  appointmentEndDate: DateTime(
                                    betweenDays[k].year,
                                    betweenDays[k].month,
                                    betweenDays[k].day + endDateDay,
                                    withRecurrencyAppointments[i]
                                        .appointmentEndDate
                                        .hour,
                                    withRecurrencyAppointments[i]
                                        .appointmentEndDate
                                        .minute,
                                    withRecurrencyAppointments[i]
                                        .appointmentEndDate
                                        .second,
                                  ),
                                  color: withRecurrencyAppointments[i].color,
                                  isAllDay:
                                      withRecurrencyAppointments[i].isAllDay,
                                  detail: withRecurrencyAppointments[i].detail,
                                  recurrenceModel: null);
                          addNewAppointments.add(addAppointmentModel);
                        }
                      }
                    }
                  }
                }
              }
//endregion
//region : Monthly Repeat
              if (withRecurrencyAppointments[i].recurrenceModel!.frequency
                  is MonthlyFrequency) {
                for (int y = 1;
                    y <
                        withRecurrencyAppointments[i]
                                .recurrenceModel!
                                .interval +
                            1;
                    y++) {
                  int endDateDay = withRecurrencyAppointments[i]
                      .appointmentStartDate
                      .difference(
                          withRecurrencyAppointments[i].appointmentEndDate)
                      .inDays
                      .abs();
                  if (((withRecurrencyAppointments[i].recurrenceModel!.frequency
                          as MonthlyFrequency)
                      .monthlyFrequencyType) is DaysOfMonthModel) {
                    List<int> daysOfMonthList = (((withRecurrencyAppointments[i]
                                .recurrenceModel!
                                .frequency as MonthlyFrequency)
                            .monthlyFrequencyType) as DaysOfMonthModel)
                        .daysOfMonth;
                    DateTime changedDate = addMonth(
                        withRecurrencyAppointments[i].appointmentStartDate,
                        y +
                            (withRecurrencyAppointments[i]
                                    .recurrenceModel!
                                    .repeatOf -
                                1));
                    if (withRecurrencyAppointments[i]
                        .recurrenceModel!
                        .endDate
                        .isAfter(changedDate)) {
                      for (int k = 0; k < daysOfMonthList.length; k++) {
                        MobkitCalendarAppointmentModel addAppointmentModel =
                            MobkitCalendarAppointmentModel(
                                title: withRecurrencyAppointments[i].title,
                                appointmentStartDate: DateTime(
                                    changedDate.year,
                                    changedDate.month,
                                    daysOfMonthList[k],
                                    withRecurrencyAppointments[i]
                                        .appointmentStartDate
                                        .hour,
                                    withRecurrencyAppointments[i]
                                        .appointmentStartDate
                                        .minute,
                                    withRecurrencyAppointments[i]
                                        .appointmentStartDate
                                        .second),
                                appointmentEndDate: DateTime(
                                    changedDate.year,
                                    changedDate.month,
                                    daysOfMonthList[k] + endDateDay,
                                    withRecurrencyAppointments[i]
                                        .appointmentEndDate
                                        .hour,
                                    withRecurrencyAppointments[i]
                                        .appointmentEndDate
                                        .minute,
                                    withRecurrencyAppointments[i]
                                        .appointmentEndDate
                                        .second),
                                color: withRecurrencyAppointments[i].color,
                                isAllDay:
                                    withRecurrencyAppointments[i].isAllDay,
                                detail: withRecurrencyAppointments[i].detail,
                                recurrenceModel: null);
                        addNewAppointments.add(addAppointmentModel);
                      }
                    }
                  } else if (((withRecurrencyAppointments[i]
                          .recurrenceModel!
                          .frequency as MonthlyFrequency)
                      .monthlyFrequencyType) is DayOfWeekAndRepetitionModel) {
                    MapEntry<int, int> dayOfMonthAndRepetition =
                        (((withRecurrencyAppointments[i]
                                        .recurrenceModel!
                                        .frequency as MonthlyFrequency)
                                    .monthlyFrequencyType)
                                as DayOfWeekAndRepetitionModel)
                            .dayOfMonthAndRepetition;
                    DateTime changedDate = addMonth(
                        withRecurrencyAppointments[i].appointmentStartDate,
                        y +
                            (withRecurrencyAppointments[i]
                                    .recurrenceModel!
                                    .repeatOf -
                                1));
                    if (withRecurrencyAppointments[i]
                        .recurrenceModel!
                        .endDate
                        .isAfter(changedDate)) {
                      int monthDays = DateUtils.getDaysInMonth(
                          changedDate.year, changedDate.month);
                      int repetition = 0;
                      for (int d = 1; d < monthDays; d++) {
                        if (dayOfMonthAndRepetition.key ==
                            DateTime(changedDate.year, changedDate.month, d)
                                .weekday) {
                          repetition++;
                          if (repetition == dayOfMonthAndRepetition.value) {
                            addNewAppointments.add(
                                MobkitCalendarAppointmentModel(
                                    title: withRecurrencyAppointments[i].title,
                                    appointmentStartDate: DateTime(
                                        changedDate.year,
                                        changedDate.month,
                                        d,
                                        withRecurrencyAppointments[i]
                                            .appointmentStartDate
                                            .hour,
                                        withRecurrencyAppointments[i]
                                            .appointmentStartDate
                                            .minute,
                                        withRecurrencyAppointments[i]
                                            .appointmentStartDate
                                            .second),
                                    appointmentEndDate: DateTime(
                                        changedDate.year,
                                        changedDate.month,
                                        d + endDateDay,
                                        withRecurrencyAppointments[i]
                                            .appointmentEndDate
                                            .hour,
                                        withRecurrencyAppointments[i]
                                            .appointmentEndDate
                                            .minute,
                                        withRecurrencyAppointments[i]
                                            .appointmentEndDate
                                            .second),
                                    color: withRecurrencyAppointments[i].color,
                                    isAllDay:
                                        withRecurrencyAppointments[i].isAllDay,
                                    detail:
                                        withRecurrencyAppointments[i].detail,
                                    recurrenceModel: null));
                          }
                        }
                      }
                    }
                  }
                }
              }
//endregion
              _appointments.addAll(addNewAppointments);
            } else {
              continue;
            }
          }
        }
      }
      isLoadData = true;
      notifyListeners();
    } else {
      isLoadData = true;
      notifyListeners();
    }
  }
}

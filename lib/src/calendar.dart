import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/extensions/date_extensions.dart';
import 'mobkit_calendar/controller/mobkit_calendar_controller.dart';
import 'mobkit_calendar/mobkit_calendar_widget.dart';
import 'mobkit_calendar/model/configs/calendar_config_model.dart';
import 'mobkit_calendar/model/daily_frequency.dart';
import 'mobkit_calendar/model/day_of_month_model.dart';
import 'mobkit_calendar/model/day_of_week_and_repetition_model.dart';
import 'mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'mobkit_calendar/model/monthly_frequency.dart';
import 'mobkit_calendar/model/weekly_frequency.dart';
import 'extensions/model/week_dates_model.dart';

class MobkitCalendarWidget extends StatefulWidget {
  final DateTime? minDate;
  final MobkitCalendarConfigModel? config;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange;
  final Function(MobkitCalendarAppointmentModel model)? eventTap;
  final Function(DateTime datetime)? onDateChanged;
  final MobkitCalendarController? mobkitCalendarController;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? onPopupWidget;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? headerWidget;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? titleWidget;
  final Widget Function(MobkitCalendarAppointmentModel list, DateTime datetime)? agendaWidget;
  final Widget Function(Map<DateTime, List<MobkitCalendarAppointmentModel>>)? weeklyViewWidget;
  final Function(DateTime datetime)? dateRangeChanged;

  const MobkitCalendarWidget({
    super.key,
    this.config,
    required this.onSelectionChange,
    this.eventTap,
    this.minDate,
    this.onPopupWidget,
    this.headerWidget,
    this.titleWidget,
    this.agendaWidget,
    this.onDateChanged,
    this.weeklyViewWidget,
    this.dateRangeChanged,
    required this.mobkitCalendarController,
  });

  @override
  State<MobkitCalendarWidget> createState() => _MobkitCalendarWidgetState();
}

class _MobkitCalendarWidgetState extends State<MobkitCalendarWidget> {
  late MobkitCalendarController mobkitCalendarController;

  @override
  void initState() {
    mobkitCalendarController = widget.mobkitCalendarController ?? MobkitCalendarController();
    super.initState();
    assert((widget.minDate ?? DateTime.utc(0, 0, 0)).isBefore(mobkitCalendarController.calendarDate),
        "Minimum Date cannot be greater than Calendar Date.");
  }

  late final ValueNotifier<List<DateTime>> selectedDates = ValueNotifier<List<DateTime>>(List<DateTime>.from([]));
  List<MobkitCalendarAppointmentModel> lastAppointments = [];
  bool isLoadData = false;

  parseAppointmentModel() {
    lastAppointments = [];
    if (mobkitCalendarController.appoitnments.isNotEmpty) {
      List<MobkitCalendarAppointmentModel> withRecurrencyAppointments = [];
      List<MobkitCalendarAppointmentModel> addNewAppointments = [];
      for (var appointment in mobkitCalendarController.appoitnments
          .where((element) => element.appointmentStartDate.isAfter(element.appointmentEndDate))) {
        int index = mobkitCalendarController.appoitnments.indexOf(appointment);
        mobkitCalendarController.appoitnments.removeAt(index);
        if (mobkitCalendarController.appoitnments.isEmpty) {
          break;
        }
      }
      if (mobkitCalendarController.appoitnments.isNotEmpty) {
        if (mobkitCalendarController.appoitnments.where((element) => element.recurrenceModel != null).isNotEmpty) {
          withRecurrencyAppointments =
              mobkitCalendarController.appoitnments.where((element) => element.recurrenceModel != null).toList();
          for (int i = 0; i < withRecurrencyAppointments.length; i++) {
            addNewAppointments = [];
            if (withRecurrencyAppointments[i].recurrenceModel!.frequency is DailyFrequency
                ? withRecurrencyAppointments[i].recurrenceModel!.repeatOf >
                    (withRecurrencyAppointments[i]
                        .appointmentStartDate
                        .difference(withRecurrencyAppointments[i].appointmentEndDate)
                        .inDays
                        .abs())
                : true) {
              if (withRecurrencyAppointments[i].recurrenceModel != null) {
                //Günlük tekrar döngüsü
                if (withRecurrencyAppointments[i].recurrenceModel!.frequency is DailyFrequency) {
                  for (int y = 1; y < withRecurrencyAppointments[i].recurrenceModel!.interval + 1; y++) {
                    MobkitCalendarAppointmentModel addAppointmentModel = MobkitCalendarAppointmentModel(
                        title: withRecurrencyAppointments[i].title,
                        appointmentStartDate: withRecurrencyAppointments[i]
                            .appointmentStartDate
                            .add(Duration(days: y * withRecurrencyAppointments[i].recurrenceModel!.repeatOf)),
                        appointmentEndDate: withRecurrencyAppointments[i]
                            .appointmentEndDate
                            .add(Duration(days: y * withRecurrencyAppointments[i].recurrenceModel!.repeatOf)),
                        color: withRecurrencyAppointments[i].color,
                        isAllDay: withRecurrencyAppointments[i].isAllDay,
                        detail: withRecurrencyAppointments[i].detail,
                        recurrenceModel: null);
                    addNewAppointments.add(addAppointmentModel);
                  }
                }
                //Haftalik tekrar döngüsü
                if (withRecurrencyAppointments[i].recurrenceModel!.frequency is WeeklyFrequency) {
                  List<int> dayOfWeekList =
                      (withRecurrencyAppointments[i].recurrenceModel!.frequency as WeeklyFrequency).daysOfWeek;
                  int interval = withRecurrencyAppointments[i].recurrenceModel!.interval;
                  WeekDates weekDates = getDatesFromWeekNumber(withRecurrencyAppointments[i].appointmentStartDate.year,
                      withRecurrencyAppointments[i].appointmentEndDate.weekNumber());
                  for (int y = 1; y < interval + 1; y++) {
                    int endDateDay = withRecurrencyAppointments[i]
                        .appointmentStartDate
                        .difference(withRecurrencyAppointments[i].appointmentEndDate)
                        .inDays
                        .abs();
                    List<DateTime> betweenDays = getDaysInBetween(
                        weekDates.from
                            .add(Duration(days: (withRecurrencyAppointments[i].recurrenceModel!.repeatOf * (y * 7)))),
                        weekDates.to
                            .add(Duration(days: (withRecurrencyAppointments[i].recurrenceModel!.repeatOf * (y * 7)))));
                    if (withRecurrencyAppointments[i]
                        .recurrenceModel!
                        .endDate
                        .isAfter(weekDates.from.add(Duration(days: y * 7)))) {
                      for (int d = 0; d < dayOfWeekList.length; d++) {
                        for (int k = 0; k < betweenDays.length; k++) {
                          if (betweenDays[k].weekday == dayOfWeekList[d]) {
                            MobkitCalendarAppointmentModel addAppointmentModel = MobkitCalendarAppointmentModel(
                                title: withRecurrencyAppointments[i].title,
                                appointmentStartDate: DateTime(
                                  betweenDays[k].year,
                                  betweenDays[k].month,
                                  betweenDays[k].day,
                                  withRecurrencyAppointments[i].appointmentStartDate.hour,
                                  withRecurrencyAppointments[i].appointmentStartDate.minute,
                                  withRecurrencyAppointments[i].appointmentStartDate.second,
                                ),
                                appointmentEndDate: DateTime(
                                  betweenDays[k].year,
                                  betweenDays[k].month,
                                  betweenDays[k].day + endDateDay,
                                  withRecurrencyAppointments[i].appointmentEndDate.hour,
                                  withRecurrencyAppointments[i].appointmentEndDate.minute,
                                  withRecurrencyAppointments[i].appointmentEndDate.second,
                                ),
                                color: withRecurrencyAppointments[i].color,
                                isAllDay: withRecurrencyAppointments[i].isAllDay,
                                detail: withRecurrencyAppointments[i].detail,
                                recurrenceModel: null);
                            addNewAppointments.add(addAppointmentModel);
                          }
                        }
                      }
                    }
                  }
                }
                //Aylik tekrar döngüsü
                if (withRecurrencyAppointments[i].recurrenceModel!.frequency is MonthlyFrequency) {
                  for (int y = 1; y < withRecurrencyAppointments[i].recurrenceModel!.interval + 1; y++) {
                    int endDateDay = withRecurrencyAppointments[i]
                        .appointmentStartDate
                        .difference(withRecurrencyAppointments[i].appointmentEndDate)
                        .inDays
                        .abs();
                    if (((withRecurrencyAppointments[i].recurrenceModel!.frequency as MonthlyFrequency)
                        .monthlyFrequencyType) is DaysOfMonthModel) {
                      List<int> daysOfMonthList =
                          (((withRecurrencyAppointments[i].recurrenceModel!.frequency as MonthlyFrequency)
                                  .monthlyFrequencyType) as DaysOfMonthModel)
                              .daysOfMonth;
                      DateTime changedDate = addMonth(withRecurrencyAppointments[i].appointmentStartDate,
                          y + (withRecurrencyAppointments[i].recurrenceModel!.repeatOf - 1));
                      if (withRecurrencyAppointments[i].recurrenceModel!.endDate.isAfter(changedDate)) {
                        for (int k = 0; k < daysOfMonthList.length; k++) {
                          MobkitCalendarAppointmentModel addAppointmentModel = MobkitCalendarAppointmentModel(
                              title: withRecurrencyAppointments[i].title,
                              appointmentStartDate: DateTime(
                                  changedDate.year,
                                  changedDate.month,
                                  daysOfMonthList[k],
                                  withRecurrencyAppointments[i].appointmentStartDate.hour,
                                  withRecurrencyAppointments[i].appointmentStartDate.minute,
                                  withRecurrencyAppointments[i].appointmentStartDate.second),
                              appointmentEndDate: DateTime(
                                  changedDate.year,
                                  changedDate.month,
                                  daysOfMonthList[k] + endDateDay,
                                  withRecurrencyAppointments[i].appointmentEndDate.hour,
                                  withRecurrencyAppointments[i].appointmentEndDate.minute,
                                  withRecurrencyAppointments[i].appointmentEndDate.second),
                              color: withRecurrencyAppointments[i].color,
                              isAllDay: withRecurrencyAppointments[i].isAllDay,
                              detail: withRecurrencyAppointments[i].detail,
                              recurrenceModel: null);
                          addNewAppointments.add(addAppointmentModel);
                        }
                      }
                    } else if (((withRecurrencyAppointments[i].recurrenceModel!.frequency as MonthlyFrequency)
                        .monthlyFrequencyType) is DayOfWeekAndRepetitionModel) {
                      MapEntry<int, int> dayOfMonthAndRepetition =
                          (((withRecurrencyAppointments[i].recurrenceModel!.frequency as MonthlyFrequency)
                                  .monthlyFrequencyType) as DayOfWeekAndRepetitionModel)
                              .dayOfMonthAndRepetition;
                      DateTime changedDate = addMonth(withRecurrencyAppointments[i].appointmentStartDate,
                          y + (withRecurrencyAppointments[i].recurrenceModel!.repeatOf - 1));
                      if (withRecurrencyAppointments[i].recurrenceModel!.endDate.isAfter(changedDate)) {
                        int monthDays = DateUtils.getDaysInMonth(changedDate.year, changedDate.month);
                        int repetition = 0;
                        for (int d = 1; d < monthDays; d++) {
                          if (dayOfMonthAndRepetition.key == DateTime(changedDate.year, changedDate.month, d).weekday) {
                            repetition++;
                            if (repetition == dayOfMonthAndRepetition.value) {
                              addNewAppointments.add(MobkitCalendarAppointmentModel(
                                  title: withRecurrencyAppointments[i].title,
                                  appointmentStartDate: DateTime(
                                      changedDate.year,
                                      changedDate.month,
                                      d,
                                      withRecurrencyAppointments[i].appointmentStartDate.hour,
                                      withRecurrencyAppointments[i].appointmentStartDate.minute,
                                      withRecurrencyAppointments[i].appointmentStartDate.second),
                                  appointmentEndDate: DateTime(
                                      changedDate.year,
                                      changedDate.month,
                                      d + endDateDay,
                                      withRecurrencyAppointments[i].appointmentEndDate.hour,
                                      withRecurrencyAppointments[i].appointmentEndDate.minute,
                                      withRecurrencyAppointments[i].appointmentEndDate.second),
                                  color: withRecurrencyAppointments[i].color,
                                  isAllDay: withRecurrencyAppointments[i].isAllDay,
                                  detail: withRecurrencyAppointments[i].detail,
                                  recurrenceModel: null));
                            }
                          }
                        }
                      }
                    }
                  }
                }
                lastAppointments.addAll(addNewAppointments);
              } else {
                continue;
              }
            }
          }
        }
      }
      lastAppointments.addAll(mobkitCalendarController.appoitnments);
      setState(() {
        isLoadData = true;
      });
    } else {
      lastAppointments.addAll(mobkitCalendarController.appoitnments);
      setState(() {
        isLoadData = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    parseAppointmentModel();
    return isLoadData
        ? MobkitCalendarView(
            config: widget.config,
            mobkitCalendarController: mobkitCalendarController,
            minDate: widget.minDate,
            onSelectionChange: widget.onSelectionChange,
            eventTap: widget.eventTap,
            onPopupWidget: widget.onPopupWidget,
            headerWidget: widget.headerWidget,
            titleWidget: widget.titleWidget,
            agendaWidget: widget.agendaWidget,
            onDateChanged: widget.onDateChanged,
            weeklyViewWidget: widget.weeklyViewWidget,
            dateRangeChanged: widget.dateRangeChanged,
          )
        : const Center(child: CircularProgressIndicator());
  }
}

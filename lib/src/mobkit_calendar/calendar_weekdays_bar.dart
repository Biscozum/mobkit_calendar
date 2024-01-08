import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';
import 'calendar_cell.dart';

class CalendarWeekDaysBar extends StatelessWidget {
  const CalendarWeekDaysBar(
      {Key? key, this.config, required this.customCalendarModel, required this.mobkitCalendarController})
      : super(key: key);
  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final MobkitCalendarController mobkitCalendarController;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _getWeekDays(DateTime.monday)
          .map((e) => SizedBox(
                width: MediaQuery.of(context).size.width * 0.12,
                child: CalendarCellWidget(
                  e,
                  mobkitCalendarController: mobkitCalendarController,
                  isWeekDaysBar: true,
                  standardCalendarConfig: config,
                ),
              ))
          .toList(),
    );
  }

  List<String> _getWeekDays(int weekStart) {
    List<String> weekdays = [];
    for (var i = 0; i < 7; i++) {
      weekdays.add(DateFormat.d(config?.locale).dateSymbols.SHORTWEEKDAYS[(i + weekStart) % 7]);
    }
    return weekdays;
  }
}

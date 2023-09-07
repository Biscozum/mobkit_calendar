import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'calendar_cell.dart';
import 'model/configs/calendar_config_model.dart';

class CalendarWeekDaysBar extends StatelessWidget {
  const CalendarWeekDaysBar({Key? key, this.config, required this.customCalendarModel}) : super(key: key);
  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _getWeekDays(DateTime.monday)
          .map((e) => SizedBox(
                width: MediaQuery.of(context).size.width * 0.12,
                child: CalendarCellWidget(
                  e,
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
      weekdays.add(DateFormat.d(config?.locale ?? 'tr').dateSymbols.SHORTWEEKDAYS[(i + weekStart) % 7]);
    }
    return weekdays;
  }
}

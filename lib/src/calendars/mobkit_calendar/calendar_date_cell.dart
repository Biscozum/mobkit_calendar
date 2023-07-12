import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/calendar_config_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'package:mobkit_calendar/src/extensions/date_extensions.dart';
import 'calendar_cell.dart';

class CalendarDateCell extends StatelessWidget {
  final DateTime date;
  final bool enabled;
  final ValueNotifier<DateTime> selectedDate;
  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange;

  const CalendarDateCell(
    this.date,
    this.selectedDate,
    this.onSelectionChange, {
    Key? key,
    this.config,
    required this.customCalendarModel,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isEnabled = enabled && checkIsEnableDate(date);
    return ValueListenableBuilder(
        valueListenable: selectedDate,
        builder: (context, DateTime selectedDate, widget) {
          return GestureDetector(
            onTap: () {
              this.selectedDate.value = date;
              onSelectionChange(findCustomModel(customCalendarModel, date), date);
            },
            child: CalendarCellWidget(
              date.day.toString(),
              isSelected: selectedDate.isSameDay(date),
              showedCustomCalendarModelList: findCustomModel(customCalendarModel, date),
              isEnabled: isEnabled,
              standardCalendarConfig: config,
              isCurrent: DateFormat.yMd().format(DateTime.now()) == DateFormat.yMd().format(date),
            ),
          );
        });
  }

  List<MobkitCalendarAppointmentModel> findCustomModel(
      List<MobkitCalendarAppointmentModel> customCalendarModelList, DateTime today) {
    List<MobkitCalendarAppointmentModel> showCustomCalendarModelList = [];
    showCustomCalendarModelList = customCalendarModelList
        .where((element) =>
            (today.isBetween(element.appointmentStartDate, element.appointmentEndDate) ?? false) ||
            today.isSameDay(element.appointmentStartDate) ||
            (today.isSameDay(element.appointmentStartDate) && today.isSameDay(element.appointmentEndDate)))
        .toList();
    return showCustomCalendarModelList;
  }

  bool checkIsEnableDate(DateTime date) {
    if (config != null) {
      if (config?.disableBefore != null && date.isBefore(config!.disableBefore!)) return false;

      if (config?.disableAfter != null && date.isAfter(config!.disableAfter!)) {
        return false;
      }
      if (config?.disabledDates != null && config!.disabledDates!.any((element) => element.isSameDay(date))) {
        return false;
      }
    }
    return true;
  }
}

import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/recurrence_model.dart';

class MobkitCalendarAppointmentModel {
  String? nativeEventId;
  int? index;
  String? title;
  DateTime appointmentStartDate;
  DateTime appointmentEndDate;
  Color? color;
  bool isAllDay;
  String detail;
  RecurrenceModel? recurrenceModel;
  MobkitCalendarAppointmentModel({
    this.nativeEventId,
    required this.title,
    required this.appointmentStartDate,
    required this.appointmentEndDate,
    this.color,
    required this.isAllDay,
    required this.detail,
    required this.recurrenceModel,
  });
}

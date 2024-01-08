import 'package:flutter/material.dart';
import 'package:mobkit_calendar/src/mobkit_calendar/model/recurrence_model.dart';

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
  Object? eventData;
  MobkitCalendarAppointmentModel({
    this.nativeEventId,
    required this.title,
    required this.appointmentStartDate,
    required this.appointmentEndDate,
    this.color,
    required this.isAllDay,
    required this.detail,
    required this.recurrenceModel,
    this.eventData,
  });
}

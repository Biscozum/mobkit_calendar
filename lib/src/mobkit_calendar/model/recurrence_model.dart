import 'frequency_model.dart';
import './mobkit_calendar_appointment_model.dart';

/// Recurrence Model to be used in [MobkitCalendarAppointmentModel]
class RecurrenceModel {
  Frequency frequency;
  DateTime endDate;
  int interval;
  int repeatOf;
  RecurrenceModel({
    required this.frequency,
    required this.endDate,
    required this.interval,
    required this.repeatOf,
  });
}

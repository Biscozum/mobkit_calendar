import 'frequency_model.dart';

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

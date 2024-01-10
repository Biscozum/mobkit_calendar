import 'frequency_model.dart';

/// //Which days of the week in weekly repetition.
class WeeklyFrequency extends Frequency {
  List<int> daysOfWeek;
  WeeklyFrequency({
    required this.daysOfWeek,
  });
}

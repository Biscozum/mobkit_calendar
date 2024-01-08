import 'frequency_model.dart';

class WeeklyFrequency extends Frequency {
  // Haftalık tekrarda haftanın hangi günleri
  List<int> daysOfWeek;
  WeeklyFrequency({
    required this.daysOfWeek,
  });
}

import '../../calendar.dart';

/// By taking the start and end date of the week,
/// it provides a search for week information used in many parts of [MobkitCalendarWidget].
class WeekDates {
  WeekDates({
    required this.from,
    required this.to,
  });

  final DateTime from;

  final DateTime to;

  @override
  String toString() {
    return '${from.toIso8601String()} - ${to.toIso8601String()}';
  }
}

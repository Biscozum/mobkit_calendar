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

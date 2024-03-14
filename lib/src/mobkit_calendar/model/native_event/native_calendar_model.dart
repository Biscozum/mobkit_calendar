/// Class that holds each event's info.
class NativeCalendar {
  String calendarName;
  String? calendarColor;
  String localAccountName;

  NativeCalendar({
    required this.calendarName,
    this.calendarColor,
    required this.localAccountName,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> params = {
      'calendarName': calendarName,
      'calendarColor': calendarColor,
      'localAccountName': localAccountName,
    };
    return params;
  }
}

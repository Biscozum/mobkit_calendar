/// Class that holds each event's info.
class NativeEvent {
  String calendarId;
  String title;
  String? description;
  String? location;
  String? timeZone;
  DateTime startDate;
  DateTime endDate;
  bool allDay;

  NativeEvent({
    required this.calendarId,
    required this.title,
    this.description,
    this.location,
    required this.startDate,
    required this.endDate,
    this.timeZone,
    this.allDay = false,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> params = {
      'calendarId': calendarId,
      'title': title,
      'desc': description,
      'location': location,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'timeZone': timeZone,
      'allDay': allDay,
    };
    return params;
  }
}

class AndroidParams {
  final List<String>? emailInvites;

  const AndroidParams({this.emailInvites});
}

class IOSParams {
  //In iOS, you can set alert notification with duration. Ex. Duration(minutes:30) -> After30 min.
  final Duration? reminder;
  final String? url;

  const IOSParams({this.reminder, this.url});
}

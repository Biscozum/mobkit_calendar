import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

double pageHeight = MediaQuery.of(navigatorKey.currentContext!).size.height;
double pageWidht = MediaQuery.of(navigatorKey.currentContext!).size.width;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late TabController _tabController;

  MobkitCalendarConfigModel getConfig(MobkitCalendarViewType mobkitCalendarViewType) {
    return MobkitCalendarConfigModel(
      cellConfig: CalendarCellConfigModel(
        disabledStyle: CalendarCellStyle(
          textStyle: TextStyle(fontSize: 14, color: Colors.grey.withOpacity(0.5)),
          color: Colors.transparent,
        ),
        enabledStyle: CalendarCellStyle(
          textStyle: const TextStyle(fontSize: 14, color: Colors.black),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
        selectedStyle: CalendarCellStyle(
          color: Colors.orange,
          textStyle: const TextStyle(fontSize: 14, color: Colors.white),
          border: Border.all(color: Colors.black, width: 1),
        ),
        currentStyle: CalendarCellStyle(
          textStyle: const TextStyle(color: Colors.lightBlue),
        ),
      ),
      calendarPopupConfigModel: CalendarPopupConfigModel(
        popUpBoxDecoration:
            const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(25))),
        popUpOpacity: true,
        animateDuration: 500,
        verticalPadding: 30,
        popupSpace: 10,
        popupHeight: MediaQuery.of(context).size.height * 0.6,
        popupWidth: MediaQuery.of(context).size.width,
        viewportFraction: 0.9,
      ),
      topBarConfig: CalendarTopBarConfigModel(
        isVisibleHeaderWidget: mobkitCalendarViewType == MobkitCalendarViewType.monthly ||
            mobkitCalendarViewType == MobkitCalendarViewType.agenda,
        isVisibleTitleWidget: true,
        isVisibleMonthBar: false,
        isVisibleYearBar: false,
        isVisibleWeekDaysBar: true,
        weekDaysStyle: const TextStyle(fontSize: 14, color: Colors.black),
      ),
      weekDaysBarBorderColor: Colors.transparent,
      locale: "en",
      disableOffDays: true,
      disableWeekendsDays: false,
      monthBetweenPadding: 20,
      primaryColor: Colors.lightBlue,
      popupEnable: mobkitCalendarViewType == MobkitCalendarViewType.monthly ? true : false,
    );
  }

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);

    super.initState();
  }

  List<MobkitCalendarAppointmentModel> eventList = [
    MobkitCalendarAppointmentModel(
      title: "Recurring event every 2 days (10 repetitions)",
      appointmentStartDate: DateTime.now().add(const Duration(days: -1)),
      appointmentEndDate: DateTime.now(),
      isAllDay: true,
      color: Colors.red,
      detail: "Recurring event every 2 days (10 repetitions)",
      recurrenceModel: RecurrenceModel(
          endDate: DateTime.now().add(const Duration(days: 500)),
          frequency: DailyFrequency(),
          interval: 10,
          repeatOf: 2),
    ),
    MobkitCalendarAppointmentModel(
      title: "Every 2nd Monday of the month (10 reps)",
      appointmentStartDate: DateTime.now().add(const Duration(days: -1)),
      appointmentEndDate: DateTime.now(),
      isAllDay: true,
      color: Colors.blue,
      detail: "Every 2nd Monday of the month (10 reps)",
      recurrenceModel: RecurrenceModel(
          endDate: DateTime.now().add(const Duration(days: 500)),
          frequency: MonthlyFrequency(
              monthlyFrequencyType: DayOfWeekAndRepetitionModel(dayOfMonthAndRepetition: const MapEntry(1, 2))),
          interval: 10,
          repeatOf: 1),
    ),
    MobkitCalendarAppointmentModel(
      title: "The event will take place between 4 and 6 p.m.",
      appointmentStartDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 16),
      appointmentEndDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
      isAllDay: false,
      color: Colors.green,
      detail: "The event will take place between 4 and 6 p.m.",
      recurrenceModel: null,
    ),
    MobkitCalendarAppointmentModel(
      title: "Every 2 weeks on Tuesdays and Sundays of the week (10 repetitions)",
      appointmentStartDate: DateTime.now().add(const Duration(days: -1)),
      appointmentEndDate: DateTime.now(),
      isAllDay: true,
      color: Colors.orange,
      detail: "Every 2 weeks on Tuesdays and Sundays of the week (10 repetitions)",
      recurrenceModel: RecurrenceModel(
          endDate: DateTime.now().add(const Duration(days: 500)),
          frequency: WeeklyFrequency(daysOfWeek: [2, 7]),
          interval: 10,
          repeatOf: 2),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text("Mobkit Calendar"),
          bottom: TabBar(
            controller: _tabController,
            padding: EdgeInsets.zero,
            tabs: const <Widget>[
              Tab(
                text: "Monthly",
              ),
              Tab(
                text: "Weekly",
              ),
              Tab(
                text: "Daily",
              ),
              Tab(
                text: "Agenda",
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Column(
              children: [
                TextButton(
                  onPressed: () async {
                    await MobkitCalendar().addCalendar(NativeCalendar(
                        calendarName: "Mobkit Calendar",
                        calendarColor: "0xFFBB4438",
                        localAccountName: 'MobkitCalendar'));
                  },
                  child: const Text("Native Calendar"),
                ),
                const SizedBox(
                  height: 12,
                ),
                TextButton(
                  onPressed: () async {
                    List<AccountGroupModel> accounts = await MobkitCalendar().getAccountList();
                    MobkitCalendar().addNativeEvent(NativeEvent(
                      title: 'Test event',
                      calendarId: accounts.isNotEmpty ? accounts.first.accountModels?.first.accountId ?? "" : "",
                      description: 'example',
                      location: 'Flutter app',
                      startDate: DateTime.now(),
                      endDate: DateTime.now().add(const Duration(minutes: 30)),
                      allDay: false,
                    ));
                  },
                  child: Text("Native Event"),
                ),
                SizedBox(
                  height: 300,
                  child: MobkitCalendarWidget(
                    minDate: DateTime(1800),
                    key: UniqueKey(),
                    config: getConfig(MobkitCalendarViewType.monthly),
                    dateRangeChanged: (datetime) => null,
                    headerWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => HeaderWidget(
                      datetime: datetime,
                      models: models,
                    ),
                    titleWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => TitleWidget(
                      datetime: datetime,
                      models: models,
                    ),
                    onSelectionChange: (List<MobkitCalendarAppointmentModel> models, DateTime date) => null,
                    eventTap: (model) => null,
                    onPopupWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => OnPopupWidget(
                      datetime: datetime,
                      models: models,
                    ),
                    onDateChanged: (DateTime datetime) => null,
                    mobkitCalendarController: MobkitCalendarController(
                      viewType: MobkitCalendarViewType.monthly,
                      appointmentList: eventList,
                    ),
                  ),
                ),
              ],
            ),
            MobkitCalendarWidget(
              minDate: DateTime(1800),
              key: UniqueKey(),
              config: getConfig(MobkitCalendarViewType.weekly),
              dateRangeChanged: (datetime) => null,
              headerWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => HeaderWidget(
                datetime: datetime,
                models: models,
              ),
              weeklyViewWidget: (Map<DateTime, List<MobkitCalendarAppointmentModel>> val) => Expanded(
                child: ListView.builder(
                  itemCount: val.length,
                  itemBuilder: (BuildContext context, int index) {
                    DateTime dateTime = val.keys.elementAt(index);
                    return val[dateTime] != null
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                DateFormat("dd MMMM").format(dateTime),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              val[dateTime]!.isNotEmpty
                                  ? SizedBox(
                                      height: val[dateTime]!.length * 45,
                                      child: ListView.builder(
                                        itemCount: val[dateTime]!.length,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: (BuildContext context, int index) {
                                          return GestureDetector(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      height: 40,
                                                      color: val[dateTime]![index].color,
                                                      width: 3,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Flexible(
                                                      child: Text(
                                                        val[dateTime]![index].title ?? "",
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 4,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : Container(),
                            ]),
                          )
                        : Container();
                  },
                ),
              ),
              titleWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => TitleWidget(
                datetime: datetime,
                models: models,
              ),
              onSelectionChange: (List<MobkitCalendarAppointmentModel> models, DateTime date) => null,
              eventTap: (model) => null,
              onPopupWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => OnPopupWidget(
                datetime: datetime,
                models: models,
              ),
              onDateChanged: (DateTime datetime) => null,
              mobkitCalendarController: MobkitCalendarController(
                viewType: MobkitCalendarViewType.weekly,
                appointmentList: eventList,
              ),
            ),
            MobkitCalendarWidget(
              minDate: DateTime(1800),
              key: UniqueKey(),
              config: getConfig(MobkitCalendarViewType.daily),
              dateRangeChanged: (datetime) => null,
              headerWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => HeaderWidget(
                datetime: datetime,
                models: models,
              ),
              titleWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => TitleWidget(
                datetime: datetime,
                models: models,
              ),
              onSelectionChange: (List<MobkitCalendarAppointmentModel> models, DateTime date) => null,
              eventTap: (model) => null,
              onPopupWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => OnPopupWidget(
                datetime: datetime,
                models: models,
              ),
              onDateChanged: (DateTime datetime) => null,
              mobkitCalendarController: MobkitCalendarController(
                viewType: MobkitCalendarViewType.daily,
                appointmentList: eventList,
              ),
            ),
            MobkitCalendarWidget(
              minDate: DateTime(1800),
              key: UniqueKey(),
              config: getConfig(MobkitCalendarViewType.agenda),
              dateRangeChanged: (datetime) => null,
              headerWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => HeaderWidget(
                datetime: datetime,
                models: models,
              ),
              titleWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => TitleWidget(
                datetime: datetime,
                models: models,
              ),
              onSelectionChange: (List<MobkitCalendarAppointmentModel> models, DateTime date) => null,
              eventTap: (model) => null,
              onPopupWidget: (List<MobkitCalendarAppointmentModel> models, DateTime datetime) => OnPopupWidget(
                datetime: datetime,
                models: models,
              ),
              onDateChanged: (DateTime datetime) => null,
              mobkitCalendarController: MobkitCalendarController(
                viewType: MobkitCalendarViewType.agenda,
                appointmentList: eventList,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class OnPopupWidget extends StatelessWidget {
  const OnPopupWidget({
    super.key,
    required this.datetime,
    required this.models,
  });

  final DateTime datetime;
  final List<MobkitCalendarAppointmentModel> models;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      child: models.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    DateFormat("EEE, MMMM d").format(datetime),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: models.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          child: Row(children: [
                            Container(
                              height: 40,
                              color: models[index].color,
                              width: 3,
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Flexible(
                              child: Text(
                                models[index].title ?? "",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    DateFormat("EEE, MMMM d").format(datetime),
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
              ],
            ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({
    super.key,
    required this.datetime,
    required this.models,
  });

  final DateTime datetime;
  final List<MobkitCalendarAppointmentModel> models;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(children: [
        Text(
          DateFormat("yyyy MMMM").format(datetime),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ]),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({
    super.key,
    required this.datetime,
    required this.models,
  });

  final DateTime datetime;
  final List<MobkitCalendarAppointmentModel> models;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(children: [
        Text(
          DateFormat("MMMM").format(datetime),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
      ]),
    );
  }
}

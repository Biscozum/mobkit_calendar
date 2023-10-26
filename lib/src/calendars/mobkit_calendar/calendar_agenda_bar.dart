import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/utils/date_utils.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'infinite_listview.dart';
import 'model/configs/calendar_config_model.dart';

class CalendarAgendaBar extends StatefulWidget {
  final ValueNotifier<DateTime> calendarDate;
  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final Function(DateTime datetime) dateRangeChanged;
  final Widget? Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime) titleWidget;
  final Widget? Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime) agendaWidget;
  final Function(MobkitCalendarAppointmentModel model) eventTap;

  const CalendarAgendaBar(
    this.calendarDate, {
    Key? key,
    this.config,
    required this.customCalendarModel,
    required this.titleWidget,
    required this.agendaWidget,
    required this.dateRangeChanged,
    required this.eventTap,
  }) : super(key: key);

  @override
  State<CalendarAgendaBar> createState() => _CalendarAgendaBarState();
}

class _CalendarAgendaBarState extends State<CalendarAgendaBar> {
  final InfiniteScrollController _infiniteScrollController = InfiniteScrollController();
  ValueNotifier<DateTime?> lastDate = ValueNotifier<DateTime?>(null);

  @override
  void initState() {
    super.initState();
    widget.customCalendarModel.sort((a, b) {
      return a.appointmentStartDate.compareTo(b.appointmentStartDate);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _infiniteScrollController.position.isScrollingNotifier.addListener(() {
        if (!_infiniteScrollController.position.isScrollingNotifier.value) {
          if (widget.config?.agendaViewConfigModel != null && lastDate.value != null) {
            if (widget.config!.agendaViewConfigModel!.endDate != null &&
                lastDate.value!.isAfter(widget.config!.agendaViewConfigModel!.endDate!)) {
              widget.dateRangeChanged(lastDate.value!);
            } else if (widget.config!.agendaViewConfigModel!.startDate != null &&
                lastDate.value!.isBefore(widget.config!.agendaViewConfigModel!.startDate!)) {
              widget.dateRangeChanged(lastDate.value!);
            }
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _infiniteScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: lastDate,
          builder: (_, DateTime? date, __) {
            return ((widget.config?.topBarConfig.isVisibleHeaderWidget ?? false) &&
                    widget.titleWidget(
                          findCustomModel(widget.customCalendarModel, lastDate.value ?? DateTime.now()),
                          lastDate.value ?? DateTime.now(),
                        ) !=
                        null)
                ? widget.titleWidget(
                    findCustomModel(widget.customCalendarModel, lastDate.value ?? DateTime.now()),
                    lastDate.value ?? DateTime.now(),
                  )!
                : Container();
          },
        ),
        Expanded(
          child: InfiniteListView.builder(
            key: const PageStorageKey("keyy"),
            controller: _infiniteScrollController,
            itemBuilder: (BuildContext context, int index) {
              DateTime currentDate = DateUtils.dateOnly(DateTime.now().add(Duration(days: index)));
              List<MobkitCalendarAppointmentModel> listData = findCustomModel(widget.customCalendarModel, currentDate);
              return VisibilityDetector(
                key: ValueKey("$currentDate"),
                onVisibilityChanged: (visibilityInfo) {
                  if (visibilityInfo.key is ValueKey) {
                    lastDate.value = DateUtils.dateOnly(
                        DateFormat("yyyy-MM-dd", widget.config?.locale).parse((visibilityInfo.key as ValueKey).value));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                  child: Column(
                    children: [
                      Text(
                        DateFormat(widget.config?.agendaViewConfigModel?.dateFormatPattern ?? "EEE, MMMM d",
                                widget.config?.locale)
                            .format(currentDate),
                        style: widget.config?.agendaViewConfigModel?.dateTextStyle ??
                            const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      listData.isNotEmpty
                          ? ListView.builder(
                              itemCount: listData.length,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: GestureDetector(
                                    onTap: () => widget.eventTap(listData[index]),
                                    child: widget.agendaWidget(widget.customCalendarModel, currentDate) ??
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4),
                                                child: Text(
                                                  "${listData[index].title}",
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: widget.config?.agendaViewConfigModel?.titleTextStyle ??
                                                      const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(6),
                                                  color: listData[index].color,
                                                ),
                                                height: 60,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                                  child: Text(
                                                    listData[index].detail,
                                                    style: widget.config?.agendaViewConfigModel?.detailTextStyle ??
                                                        const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  ),
                                );
                              },
                            )
                          : Container(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

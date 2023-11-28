import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/controller/mobkit_calendar_controller.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/utils/date_utils.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'infinite_listview.dart';
import 'model/configs/calendar_config_model.dart';

class CalendarAgendaBar extends StatefulWidget {
  final MobkitCalendarController mobkitCalendarController;
  final MobkitCalendarConfigModel? config;
  final Function(DateTime datetime)? dateRangeChanged;
  final Function(DateTime datetime)? onDateChanged;
  final Widget Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime)? titleWidget;
  final Widget Function(MobkitCalendarAppointmentModel list, DateTime datetime)? agendaWidget;
  final Function(MobkitCalendarAppointmentModel model)? eventTap;

  const CalendarAgendaBar({
    Key? key,
    required this.mobkitCalendarController,
    this.config,
    this.titleWidget,
    this.agendaWidget,
    this.dateRangeChanged,
    this.onDateChanged,
    this.eventTap,
  }) : super(key: key);

  @override
  State<CalendarAgendaBar> createState() => _CalendarAgendaBarState();
}

class _CalendarAgendaBarState extends State<CalendarAgendaBar> {
  final InfiniteScrollController _infiniteScrollController = InfiniteScrollController();
  ValueNotifier<DateTime?> lastDate = ValueNotifier<DateTime?>(null);
  late DateTime initialDate;
  @override
  void initState() {
    super.initState();
    initialDate = widget.mobkitCalendarController.calendarDate;
    widget.mobkitCalendarController.appoitnments.sort((a, b) {
      return a.appointmentStartDate.compareTo(b.appointmentStartDate);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _infiniteScrollController.position.isScrollingNotifier.addListener(() {
        if (!_infiniteScrollController.position.isScrollingNotifier.value) {
          if (widget.config?.agendaViewConfigModel != null && lastDate.value != null) {
            if (widget.config!.agendaViewConfigModel!.endDate != null &&
                lastDate.value!.isAfter(widget.config!.agendaViewConfigModel!.endDate!)) {
              widget.dateRangeChanged?.call(lastDate.value!);
            } else if (widget.config!.agendaViewConfigModel!.startDate != null &&
                lastDate.value!.isBefore(widget.config!.agendaViewConfigModel!.startDate!)) {
              widget.dateRangeChanged?.call(lastDate.value!);
            }
          } else if (widget.config?.agendaViewConfigModel == null ||
              widget.config?.agendaViewConfigModel?.endDate == null ||
              widget.config?.agendaViewConfigModel?.startDate == null) {
            widget.onDateChanged?.call(lastDate.value!);
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
            return ((widget.config?.topBarConfig.isVisibleHeaderWidget ?? false) && widget.titleWidget != null)
                ? widget.titleWidget!.call(
                    findCustomModel(widget.mobkitCalendarController.appoitnments, lastDate.value ?? DateTime.now()),
                    lastDate.value ?? DateTime.now(),
                  )
                : Container();
          },
        ),
        Expanded(
          child: InfiniteListView.builder(
            controller: _infiniteScrollController,
            itemBuilder: (BuildContext context, int index) {
              DateTime currentDate = DateUtils.dateOnly(initialDate.add(Duration(days: index)));
              List<MobkitCalendarAppointmentModel> listData =
                  findCustomModel(widget.mobkitCalendarController.appoitnments, currentDate);
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                    onTap: () => widget.eventTap?.call(listData[index]),
                                    child: widget.agendaWidget?.call(listData[index], currentDate) ??
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

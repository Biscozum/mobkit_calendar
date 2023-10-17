import 'package:flutter/material.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/utils/date_utils.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'model/configs/calendar_config_model.dart';

class CalendarAgendaBar extends StatefulWidget {
  final ValueNotifier<DateTime> calendarDate;
  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final Function(DateTime datetime) dateRangeChanged;
  final Widget? Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime) headerWidget;

  const CalendarAgendaBar(
    this.calendarDate, {
    Key? key,
    this.config,
    required this.customCalendarModel,
    required this.headerWidget,
    required this.dateRangeChanged,
  }) : super(key: key);

  @override
  State<CalendarAgendaBar> createState() => _CalendarAgendaBarState();
}

class _CalendarAgendaBarState extends State<CalendarAgendaBar> {
  final InfiniteScrollController _infiniteScrollController = InfiniteScrollController();
  DateTime? lastDate;

  @override
  void initState() {
    super.initState();
    widget.customCalendarModel.sort((a, b) {
      return a.appointmentStartDate.compareTo(b.appointmentStartDate);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _infiniteScrollController.position.isScrollingNotifier.addListener(() {
        if (!_infiniteScrollController.position.isScrollingNotifier.value) {
          if (widget.config?.agendaViewConfigModel != null && lastDate != null) {
            if (widget.config!.agendaViewConfigModel!.endDate != null &&
                lastDate!.isAfter(widget.config!.agendaViewConfigModel!.endDate!)) {
              widget.dateRangeChanged(lastDate!);
            } else if (widget.config!.agendaViewConfigModel!.startDate != null &&
                lastDate!.isBefore(widget.config!.agendaViewConfigModel!.startDate!)) {
              widget.dateRangeChanged(lastDate!);
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
        ((widget.config?.topBarConfig.isVisibleHeaderWidget ?? false) &&
                widget.headerWidget(
                      findCustomModel(widget.customCalendarModel, lastDate ?? DateTime.now()),
                      lastDate ?? DateTime.now(),
                    ) !=
                    null)
            ? widget.headerWidget(
                findCustomModel(widget.customCalendarModel, lastDate ?? DateTime.now()),
                lastDate ?? DateTime.now(),
              )!
            : Container(),
        Expanded(
          child: InfiniteListView.builder(
            key: const PageStorageKey("keyy"),
            controller: _infiniteScrollController,
            itemBuilder: (BuildContext context, int index) {
              DateTime currentDate = DateUtils.dateOnly(DateTime.now().add(Duration(days: index)));
              return VisibilityDetector(
                key: ValueKey("$currentDate"),
                onVisibilityChanged: (visibilityInfo) {
                  if (visibilityInfo.key is ValueKey) {
                    lastDate =
                        DateUtils.dateOnly(DateFormat("yyyy-MM-dd").parse((visibilityInfo.key as ValueKey).value));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                  child: AgendaItemWidget(
                    appoitnments: findCustomModel(widget.customCalendarModel, currentDate),
                    currentDate: currentDate,
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

class AgendaItemWidget extends StatefulWidget {
  const AgendaItemWidget({super.key, required this.currentDate, required this.appoitnments});
  final DateTime currentDate;
  final List<MobkitCalendarAppointmentModel> appoitnments;

  @override
  State<AgendaItemWidget> createState() => _AgendaItemWidgetState();
}

class _AgendaItemWidgetState extends State<AgendaItemWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat("EEE, MMMM d", "tr").format(widget.currentDate),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        widget.appoitnments.isNotEmpty
            ? ListView.builder(
                itemCount: widget.appoitnments.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              "${widget.appoitnments[index].title}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
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
                              color: widget.appoitnments[index].color,
                            ),
                            height: 60,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: Text(
                                widget.appoitnments[index].detail,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Container(),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/utils/date_utils.dart';
import '../../extensions/date_extensions.dart';
import 'model/configs/calendar_config_model.dart';

class CalendarAgendaBar extends StatefulWidget {
  final ValueNotifier<DateTime> calendarDate;
  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final Function(DateTime datetime) onDateChanged;
  final Widget? Function(List<MobkitCalendarAppointmentModel> list, DateTime datetime) headerWidget;

  const CalendarAgendaBar(
    this.calendarDate, {
    Key? key,
    this.config,
    required this.customCalendarModel,
    required this.headerWidget,
    required this.onDateChanged,
  }) : super(key: key);

  @override
  State<CalendarAgendaBar> createState() => _CalendarAgendaBarState();
}

class _CalendarAgendaBarState extends State<CalendarAgendaBar> {
  List<DateTime> reverseDates = [];
  List<DateTime> centerDates = [];
  List<DateTime> forwardDates = [];

  final ScrollController _controller = ScrollController();
  ScrollActivity? _lastActivity;

  @override
  void initState() {
    super.initState();

    setShowDates(widget.calendarDate.value, isFirst: true);

    _controller.addListener(() {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      if (_controller.position.activity is BallisticScrollActivity && _lastActivity is! DragScrollActivity) {
        Future.delayed(const Duration(milliseconds: 350)).then(
          (value) {
            if (_controller.position.pixels == _controller.position.maxScrollExtent) {
              setShowDates(addMonth(widget.calendarDate.value, 2));
              _controller.jumpTo(1);
              setState(() {});
            } else if (_controller.position.pixels == _controller.position.minScrollExtent) {
              setShowDates(addMonth(widget.calendarDate.value, -2));
              _controller.jumpTo(1);
              setState(() {});
            }
          },
        );
      }
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      _lastActivity = _controller.position.activity;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  setShowDates(DateTime time, {bool isFirst = false}) {
    centerDates = getDaysInBetween(findFirstDateOfTheMonth(time), findLastDateOfTheMonth(time));

    reverseDates = getDaysInBetween(findFirstDateOfTheMonth(DateTime(time.year, time.month - 1, 1)),
        findLastDateOfTheMonth(DateTime(time.year, time.month - 1, 1)))
      ..sort((b, a) {
        return a.compareTo(b);
      });

    forwardDates = getDaysInBetween(findFirstDateOfTheMonth(DateTime(time.year, time.month + 1, 1)),
        findLastDateOfTheMonth(DateTime(time.year, time.month + 1, 1)));

    widget.calendarDate.value = time;
    if (!isFirst) {
      widget.onDateChanged(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    Key centerListKey = UniqueKey();
    Widget centerList = SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            child: AgendaItemWidget(
              key: ValueKey(DateUtils.dateOnly(centerDates[index])),
              appoitnments: findCustomModel(widget.customCalendarModel, centerDates[index]),
              currentDate: centerDates[index],
            ),
          );
        },
        childCount: centerDates.length,
      ),
      key: centerListKey,
    );

    Widget reverseList = SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            child: AgendaItemWidget(
              key: ValueKey(DateUtils.dateOnly(reverseDates[index])),
              appoitnments: findCustomModel(widget.customCalendarModel, reverseDates[index]),
              currentDate: reverseDates[index],
            ),
          );
        },
        childCount: reverseDates.length,
      ),
    );
    Widget forwardList = SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
            child: AgendaItemWidget(
              key: ValueKey(DateUtils.dateOnly(forwardDates[index])),
              appoitnments: findCustomModel(widget.customCalendarModel, forwardDates[index]),
              currentDate: forwardDates[index],
            ),
          );
        },
        childCount: forwardDates.length,
      ),
    );

    return Column(
      children: [
        Expanded(
          child: Scrollable(
            controller: _controller,
            viewportBuilder: (BuildContext context, ViewportOffset offset) {
              return Viewport(offset: offset, center: centerListKey, slivers: [
                reverseList,
                centerList,
                forwardList,
              ]);
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

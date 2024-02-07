import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'mobkit_calendar/controller/mobkit_calendar_controller.dart';
import 'mobkit_calendar/mobkit_calendar_widget.dart';
import 'mobkit_calendar/model/configs/calendar_config_model.dart';
import 'mobkit_calendar/model/mobkit_calendar_appointment_model.dart';

/// It allows you to use MobkitCalendar on your screen with a few parameters.
class MobkitCalendarWidget extends StatefulWidget {
  final DateTime? minDate;
  final MobkitCalendarConfigModel? config;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)
      onSelectionChange;
  final Function(MobkitCalendarAppointmentModel model)? eventTap;
  final Function(DateTime datetime)? onDateChanged;
  final MobkitCalendarController? mobkitCalendarController;
  final Widget Function(
          List<MobkitCalendarAppointmentModel> list, DateTime datetime)?
      onPopupWidget;
  final Widget Function(
          List<MobkitCalendarAppointmentModel> list, DateTime datetime)?
      headerWidget;
  final Widget Function(
          List<MobkitCalendarAppointmentModel> list, DateTime datetime)?
      titleWidget;
  final Widget Function(MobkitCalendarAppointmentModel list, DateTime datetime)?
      agendaWidget;
  final Widget Function(Map<DateTime, List<MobkitCalendarAppointmentModel>>)?
      weeklyViewWidget;
  final Function(DateTime datetime)? dateRangeChanged;

  const MobkitCalendarWidget({
    super.key,
    this.config,
    required this.onSelectionChange,
    this.eventTap,
    this.minDate,
    this.onPopupWidget,
    this.headerWidget,
    this.titleWidget,
    this.agendaWidget,
    this.onDateChanged,
    this.weeklyViewWidget,
    this.dateRangeChanged,
    required this.mobkitCalendarController,
  });

  @override
  State<MobkitCalendarWidget> createState() => _MobkitCalendarWidgetState();
}

class _MobkitCalendarWidgetState extends State<MobkitCalendarWidget> {
  late MobkitCalendarController mobkitCalendarController;

  @override
  void initState() {
    mobkitCalendarController =
        widget.mobkitCalendarController ?? MobkitCalendarController();
    initializeDateFormatting();
    super.initState();
    assert(
        (widget.minDate ?? DateTime.utc(0, 0, 0))
            .isBefore(mobkitCalendarController.calendarDate),
        "Minimum Date cannot be greater than Calendar Date.");
  }

  late final ValueNotifier<List<DateTime>> selectedDates =
      ValueNotifier<List<DateTime>>(List<DateTime>.from([]));

  @override
  Widget build(BuildContext context) {
    return mobkitCalendarController.isLoadData
        ? MobkitCalendarView(
            config: widget.config,
            mobkitCalendarController: mobkitCalendarController,
            minDate: widget.minDate,
            onSelectionChange: widget.onSelectionChange,
            eventTap: widget.eventTap,
            onPopupWidget: widget.onPopupWidget,
            headerWidget: widget.headerWidget,
            titleWidget: widget.titleWidget,
            agendaWidget: widget.agendaWidget,
            onDateChanged: widget.onDateChanged,
            weeklyViewWidget: widget.weeklyViewWidget,
            dateRangeChanged: widget.dateRangeChanged,
          )
        : const Center(child: CircularProgressIndicator());
  }
}

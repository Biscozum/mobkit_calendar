import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/src/mobkit_calendar/calendar_native_carousel.dart';
import 'package:mobkit_calendar/src/mobkit_calendar/controller/mobkit_calendar_controller.dart';
import 'package:mobkit_calendar/src/mobkit_calendar/enum/mobkit_calendar_view_type_enum.dart';
import 'package:mobkit_calendar/src/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'package:mobkit_calendar/src/mobkit_calendar/utils/date_utils.dart';
import 'package:mobkit_calendar/src/extensions/date_extensions.dart';
import 'calendar_cell.dart';
import 'model/configs/calendar_config_model.dart';

class CalendarDateCell extends StatelessWidget {
  final DateTime date;
  final DateTime minDate;
  final bool enabled;
  final MobkitCalendarConfigModel? config;
  final MobkitCalendarController mobkitCalendarController;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime)? onSelectionChange;
  final Widget Function(List<MobkitCalendarAppointmentModel>, DateTime datetime)? onPopupWidget;
  final Function(DateTime datetime)? onDateChanged;

  const CalendarDateCell(
    this.date,
    this.minDate,
    this.onSelectionChange, {
    Key? key,
    this.config,
    required this.mobkitCalendarController,
    this.enabled = true,
    this.onPopupWidget,
    this.onDateChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: mobkitCalendarController,
        builder: (context, widget) {
          return GestureDetector(
            onTap: () async {
              if (enabled || mobkitCalendarController.mobkitCalendarViewType != MobkitCalendarViewType.monthly) {
                mobkitCalendarController.selectedDate = (date);
                onSelectionChange?.call(findCustomModel(mobkitCalendarController.appointments, date), date);
                if (config != null && config!.popupEnable) {
                  await showDialog(
                    context: context,
                    useRootNavigator: true,
                    builder: (_) => ListenableBuilder(
                        listenable: mobkitCalendarController,
                        builder: (context, widget) {
                          return CarouselEvent(
                            minDate: minDate,
                            onPopupWidget: onPopupWidget,
                            onSelectionChange: onSelectionChange,
                            mobkitCalendarController: mobkitCalendarController,
                            config: config,
                            onDateChanged: onDateChanged,
                          );
                        }),
                  );
                }
              }
            },
            key: Key("${DateUtils.dateOnly(date)}"),
            child: CalendarCellWidget(
              date.day.toString(),
              mobkitCalendarController: mobkitCalendarController,
              key: Key("CalendarCell-${DateFormat("dd-MM-yyyy").format(date)}"),
              isSelected: mobkitCalendarController.selectedDate != null &&
                  mobkitCalendarController.selectedDate!.isSameDay(date),
              showedCustomCalendarModelList: findCustomModel(mobkitCalendarController.appointments, date),
              isEnabled: enabled,
              isWeekend: date.isWeekend(),
              standardCalendarConfig: config,
              isCurrent:
                  DateFormat.yMd(config?.locale).format(DateTime.now()) == DateFormat.yMd(config?.locale).format(date),
            ),
          );
        });
  }
}

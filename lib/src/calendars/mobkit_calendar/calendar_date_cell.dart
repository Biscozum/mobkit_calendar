import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/calendar_native_carousel.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/enum/mobkit_calendar_view_type_enum.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
import 'package:mobkit_calendar/src/calendars/mobkit_calendar/utils/date_utils.dart';
import 'package:mobkit_calendar/src/extensions/date_extensions.dart';
import 'calendar_cell.dart';
import 'model/configs/calendar_config_model.dart';

class CalendarDateCell extends StatelessWidget {
  final DateTime calendarDate;
  final bool enabled;
  final ValueNotifier<DateTime> selectedDate;
  final MobkitCalendarConfigModel? config;
  final List<MobkitCalendarAppointmentModel> customCalendarModel;
  final Function(List<MobkitCalendarAppointmentModel> models, DateTime datetime) onSelectionChange;
  final Widget? Function(List<MobkitCalendarAppointmentModel>, DateTime datetime) onPopupChange;

  const CalendarDateCell(
    this.calendarDate,
    this.selectedDate,
    this.onSelectionChange, {
    Key? key,
    this.config,
    required this.customCalendarModel,
    this.enabled = true,
    required this.onPopupChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: selectedDate,
        builder: (context, DateTime selectedDate, widget) {
          return GestureDetector(
            onTap: () async {
              if (enabled || config?.mobkitCalendarViewType != MobkitCalendarViewType.monthly) {
                this.selectedDate.value = calendarDate;
                onSelectionChange(findCustomModel(customCalendarModel, calendarDate), calendarDate);
                if (config != null && config!.isNativePopup) {
                  await showDialog(
                    context: context,
                    useRootNavigator: true,
                    builder: (_) => ValueListenableBuilder(
                        valueListenable: this.selectedDate,
                        builder: (_, DateTime date, __) {
                          return NativeCarousel(
                            date: this.selectedDate,
                            listAppointmentModel: customCalendarModel,
                            onPopupChange: onPopupChange,
                            onSelectionChange: onSelectionChange,
                            customCalendarModel: customCalendarModel,
                            config: config,
                          );
                        }),
                  );
                }
              }
            },
            child: CalendarCellWidget(
              calendarDate.day.toString(),
              isSelected: selectedDate.isSameDay(calendarDate),
              showedCustomCalendarModelList: findCustomModel(customCalendarModel, calendarDate),
              isEnabled: enabled,
              isWeekend: calendarDate.isWeekend(),
              standardCalendarConfig: config,
              isCurrent: DateFormat.yMd().format(DateTime.now()) == DateFormat.yMd().format(calendarDate),
            ),
          );
        });
  }
}

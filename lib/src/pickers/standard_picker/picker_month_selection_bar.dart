import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/src/pickers/standard_picker/model/picker_config_model.dart';
import '../widgets/picker_buttons.dart';

class MonthSelectionBar extends StatelessWidget {
  final double _itemSpace = 14;
  final ValueNotifier<DateTime> calendarDate;
  final MobkitPickerConfigModel? config;
  const MonthSelectionBar(this.calendarDate, this.config, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        BackButtonWidget(goPreviousMonth),
        SizedBox(
          width: _itemSpace,
        ),
        ValueListenableBuilder(
          valueListenable: calendarDate,
          builder: (_, DateTime date, __) {
            return Text(
              _parseDateStr(calendarDate.value),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        SizedBox(
          width: _itemSpace,
        ),
        ForwardButtonWidget(goNextMonth),
      ],
    );
  }

  changeMonth(ValueNotifier<DateTime> calendarDate, int amount) {
    var newMonth = calendarDate.value.month + amount;
    calendarDate.value = DateTime(calendarDate.value.year, newMonth, calendarDate.value.day);
  }

  goNextMonth() => changeMonth(calendarDate, 1);
  goPreviousMonth() => changeMonth(calendarDate, -1);

  String _parseDateStr(DateTime date) {
    return DateFormat('MMMM', config?.locale).format(date);
  }
}

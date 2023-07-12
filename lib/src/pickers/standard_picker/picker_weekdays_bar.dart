import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/picker_cell.dart';
import 'model/picker_config_model.dart';

class WeekDaysBar extends StatelessWidget {
  const WeekDaysBar({Key? key, this.config}) : super(key: key);
  final MobkitPickerConfigModel? config;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _getWeekDays(DateTime.monday)
          .map((e) => CellWidget(
                e,
                isWeekDaysBar: true,
                standardCalendarConfig: config,
              ))
          .toList(),
    );
  }

  List<String> _getWeekDays(int weekStart) {
    List<String> weekdays = [];
    for (var i = 0; i < 7; i++) {
      weekdays.add(DateFormat.d(config?.locale ?? 'tr').dateSymbols.SHORTWEEKDAYS[(i + weekStart) % 7]);
    }
    return weekdays;
  }
}

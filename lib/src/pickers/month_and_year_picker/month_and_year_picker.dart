import 'package:flutter/material.dart';
import '../standard_picker/picker_year_selection_bar.dart';
import '../widgets/picker_header.dart';
import 'month_and_year_bar_selection.dart';
import 'month_and_year_scroll_selection.dart';
import 'model/month_and_year_config_model.dart';

class MonthAndYearPicker extends StatelessWidget {
  late final MobkitMonthAndYearCalendarConfigModel config;
  final MobkitMonthAndYearCalendarConfigModel? monthAndYearConfigModel;
  final ValueNotifier<DateTime> calendarDate;
  final ValueNotifier<DateTime> selectedDate;
  final ValueNotifier<List<DateTime>> selectedDates;
  final ValueChanged<DateTime> onSelectionChange;
  final Function(DateTime, DateTime) onRangeSelectionChange;
  MonthAndYearPicker({
    Key? key,
    required this.monthAndYearConfigModel,
    required this.calendarDate,
    required this.selectedDate,
    required this.selectedDates,
    required this.onSelectionChange,
    required this.onRangeSelectionChange,
  }) : super(key: key) {
    if (monthAndYearConfigModel == null) {
      config = MobkitMonthAndYearCalendarConfigModel();
    } else {
      config = monthAndYearConfigModel!;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (config.selectionType == MobkitMonthAndYearCalendarSelectionType.selectionScroll) {
      return MonthAndYearScrollSelection(calendarDate, config, onSelectionChange);
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (config.title != null) Header(config.title!),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              YearSelectionBar(calendarDate),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          Expanded(
              child: MonthAndYearBarSelection(
            calendarDate,
            selectedDate,
            selectedDates,
            config: config,
            onSelectionChange,
            onRangeSelectionChange,
          )),
        ],
      );
    }
  }
}

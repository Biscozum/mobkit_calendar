import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/src/pickers/month_and_year_picker/model/month_and_year_config_model.dart';

class MonthAndYearScrollSelection extends StatefulWidget {
  final ValueNotifier<DateTime> calendarDate;
  final MobkitMonthAndYearCalendarConfigModel? monthAndYearConfigModel;
  final ValueChanged<DateTime> onSelectionChange;

  const MonthAndYearScrollSelection(this.calendarDate, this.monthAndYearConfigModel, this.onSelectionChange, {Key? key})
      : super(key: key);

  @override
  State<MonthAndYearScrollSelection> createState() => _MonthAndYearScrollSelectionState();
}

class _MonthAndYearScrollSelectionState extends State<MonthAndYearScrollSelection> {
  late final MobkitMonthAndYearCalendarConfigModel config;

  int selectedMonthIndex = 0;
  int selectedYearIndex = 0;
  FixedExtentScrollController fixedMonthController = FixedExtentScrollController();
  FixedExtentScrollController fixedYearController = FixedExtentScrollController();
  List<DateTime> yearsList = [];
  List<DateTime> monthsList = [];

  List<Widget> generateYear(DateTime min, DateTime max) {
    DateTime sDate = min;
    final difference = sDate.difference(max);
    int differenceInYears = (difference.inDays / 365).floor().abs();
    List<Widget> years = [];
    for (int i = 0; i <= differenceInYears; i++) {
      DateTime incrementDate = DateTime(sDate.year + i, sDate.month, sDate.day);
      yearsList.add(incrementDate);
      years.add(
        Text(
          DateFormat('yyyy', config.locale).format(incrementDate),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return years;
  }

  List<Widget> generateMonths() {
    List<Widget> months = [];
    for (int i = 1; i <= 12; i++) {
      DateTime dateTime = DateTime(DateTime.now().year, i, 1);
      monthsList.add(dateTime);
      months.add(
        Text(
          DateFormat('MMM', config.locale).format(dateTime),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return months;
  }

  late DateTime sDate;
  late Duration difference;
  late int differenceInYears;

  @override
  void initState() {
    if (widget.monthAndYearConfigModel == null) {
      config = MobkitMonthAndYearCalendarConfigModel();
    } else {
      config = widget.monthAndYearConfigModel!;
    }
    generateMonths();
    generateYear(config.minDate ?? DateTime(1950, 1, 1), config.maxDate ?? DateTime(2050, 1, 1));
    sDate = config.minDate ?? DateTime(1950, 1, 1);
    difference = sDate.difference(config.maxDate ?? DateTime(2050, 1, 1));
    differenceInYears = (difference.inDays / 365).floor().abs();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      int selectedMonthIndex = monthsList.indexOf(DateTime(DateTime.now().year, DateTime.now().month, 1));
      if (selectedMonthIndex != -1) {
        fixedMonthController.jumpToItem(selectedMonthIndex);
      }
      int selectedYearIndex = yearsList.indexOf(DateTime(DateTime.now().year, 1, 1));
      if (selectedYearIndex != -1) {
        fixedYearController.jumpToItem(selectedYearIndex);
      }
    });
    super.initState();
  }

  bool isScroll = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CupertinoPicker.builder(
            scrollController: fixedMonthController,
            selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
              background: config.selectedColor.withOpacity(0.5),
            ),
            itemExtent: config.itemExtent,
            onSelectedItemChanged: (value) {
              widget.calendarDate.value = DateTime(widget.calendarDate.value.year, monthsList[value].month, 1);
              widget.onSelectionChange(DateTime(widget.calendarDate.value.year, monthsList[value].month, 1));
            },
            childCount: 12,
            itemBuilder: (context, index) {
              DateTime dateTime = DateTime(widget.calendarDate.value.year, index + 1, 1);
              return Text(
                DateFormat('MMM', config.locale).format(dateTime),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 2,
          child: CupertinoPicker.builder(
            scrollController: fixedYearController,
            selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
              background: config.selectedColor.withOpacity(0.5),
            ),
            itemExtent: config.itemExtent,
            onSelectedItemChanged: (value) {
              widget.calendarDate.value =
                  DateTime(yearsList[value].year, widget.calendarDate.value.month, widget.calendarDate.value.day);
              widget.onSelectionChange(
                  DateTime(yearsList[value].year, widget.calendarDate.value.month, widget.calendarDate.value.day));
            },
            childCount: differenceInYears,
            itemBuilder: (context, index) {
              index + 1;
              DateTime incrementDate = DateTime(sDate.year + index, 1, 1);
              return Text(
                DateFormat('yyyy', config.locale).format(incrementDate),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  changeYearListWheel(ValueNotifier<DateTime> calendarDate, DateTime changedDate) {
    calendarDate.value = DateTime(changedDate.year, calendarDate.value.year, calendarDate.value.day);
  }

  changeMonthListWheel(ValueNotifier<DateTime> calendarDate, DateTime changedDate) {
    calendarDate.value = DateTime(calendarDate.value.year, changedDate.month, calendarDate.value.day);
  }
}

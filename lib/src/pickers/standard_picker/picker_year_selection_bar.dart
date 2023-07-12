import 'package:flutter/material.dart';

import '../widgets/picker_buttons.dart';

class YearSelectionBar extends StatelessWidget {
  final ValueNotifier<DateTime> calendarDate;
  final double _itemSpace = 14;
  const YearSelectionBar(this.calendarDate, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        BackButtonWidget(goPreviousYear),
        SizedBox(
          width: _itemSpace,
        ),
        ValueListenableBuilder(
            valueListenable: calendarDate,
            builder: (_, DateTime date, __) {
              return Text(
                date.year.toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              );
            }),
        SizedBox(
          width: _itemSpace,
        ),
        ForwardButtonWidget(goNextYear),
      ],
    );
  }

  changeYear(ValueNotifier<DateTime> calendarDate, int amount) {
    var newYear = calendarDate.value.year + amount;
    calendarDate.value = DateTime(newYear, calendarDate.value.month, calendarDate.value.day);
  }

  goNextYear() => changeYear(calendarDate, 1);

  goPreviousYear() => changeYear(calendarDate, -1);
}

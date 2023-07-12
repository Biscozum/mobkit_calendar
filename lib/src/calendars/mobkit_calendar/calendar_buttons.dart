import 'package:flutter/material.dart';

import 'calendar_arrow_button.dart';

class CalendarBackButton extends StatelessWidget {
  final Function()? onPressed;
  const CalendarBackButton(this.onPressed, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CalendarArrowButton(
      Icons.arrow_back_ios,
      onPressed: onPressed,
    );
  }
}

class CalendarForwardButton extends StatelessWidget {
  final Function()? onPressed;
  const CalendarForwardButton(this.onPressed, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CalendarArrowButton(
      Icons.arrow_forward_ios,
      onPressed: onPressed,
    );
  }
}

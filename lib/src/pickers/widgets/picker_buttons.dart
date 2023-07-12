import 'package:flutter/material.dart';

import 'picker_arrow_button.dart';

class BackButtonWidget extends StatelessWidget {
  final Function()? onPressed;
  const BackButtonWidget(this.onPressed, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CalendarArrowButton(
      Icons.arrow_back_ios,
      onPressed: onPressed,
    );
  }
}

class ForwardButtonWidget extends StatelessWidget {
  final Function()? onPressed;
  const ForwardButtonWidget(this.onPressed, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CalendarArrowButton(
      Icons.arrow_forward_ios,
      onPressed: onPressed,
    );
  }
}

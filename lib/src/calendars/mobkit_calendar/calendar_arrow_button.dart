import 'package:flutter/material.dart';

class CalendarArrowButton extends StatelessWidget {
  const CalendarArrowButton(
    this.icon, {
    this.alignment = Alignment.center,
    this.onPressed,
    Key? key,
  }) : super(key: key);
  final IconData icon;
  final AlignmentGeometry alignment;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      width: 25,
      child: IconButton(
        iconSize: 12,
        alignment: alignment,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(
          icon,
        ),
      ),
    );
  }
}

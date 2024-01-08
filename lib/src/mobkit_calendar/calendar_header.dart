import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title;
  const Header(
    this.title, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.close,
          ),
          constraints: const BoxConstraints(maxWidth: 25, minWidth: 25),
        ),
      ],
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'mobkit_calendar_types_view.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

double pageHeight = MediaQuery.of(navigatorKey.currentContext!).size.height;
double pageWidht = MediaQuery.of(navigatorKey.currentContext!).size.width;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      home: const MobkitCalendarTypesView(),
    );
  }
}

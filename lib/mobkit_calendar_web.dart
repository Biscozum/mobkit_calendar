// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter

import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'mobkit_calendar_platform_interface.dart';

/// A web implementation of the MobkitCalendarPlatform of the MobkitCalendar plugin.
class MobkitCalendarWeb extends MobkitCalendarPlatform {
  /// Constructs a MobkitCalendarWeb
  MobkitCalendarWeb();

  static void registerWith(Registrar registrar) {
    MobkitCalendarPlatform.instance = MobkitCalendarWeb();
  }
}

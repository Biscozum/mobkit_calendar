import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mobkit_calendar_platform_interface.dart';

/// An implementation of [MobkitCalendarPlatform] that uses method channels.
class MethodChannelMobkitCalendar extends MobkitCalendarPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mobkit_calendar');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<Map?> getAccountList() async {
    final accountList = await methodChannel.invokeMethod<Map>('getAccountList');
    return accountList;
  }

  @override
  Future<Map?> getEventList(Map arguments) async {
    final eventList = await methodChannel.invokeMethod<Map>('getEventList', arguments);
    return eventList;
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';
import 'package:mobkit_calendar/mobkit_calendar_platform_interface.dart';
import 'package:mobkit_calendar/mobkit_calendar_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMobkitCalendarPlatform
    with MockPlatformInterfaceMixin
    implements MobkitCalendarPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final MobkitCalendarPlatform initialPlatform = MobkitCalendarPlatform.instance;

  test('$MethodChannelMobkitCalendar is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMobkitCalendar>());
  });

  test('getPlatformVersion', () async {
    MobkitCalendar mobkitCalendarPlugin = MobkitCalendar();
    MockMobkitCalendarPlatform fakePlatform = MockMobkitCalendarPlatform();
    MobkitCalendarPlatform.instance = fakePlatform;

    expect(await mobkitCalendarPlugin.getPlatformVersion(), '42');
  });
}

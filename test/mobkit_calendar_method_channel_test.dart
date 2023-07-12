import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobkit_calendar/mobkit_calendar_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelMobkitCalendar platform = MethodChannelMobkitCalendar();
  const MethodChannel channel = MethodChannel('mobkit_calendar');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}

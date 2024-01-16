import 'package:flutter_test/flutter_test.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';
import 'package:mobkit_calendar/mobkit_calendar_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMobkitCalendarPlatform with MockPlatformInterfaceMixin implements MobkitCalendarPlatform {
  @override
  Future<List<AccountGroupModel>> getAccountList() {
    throw UnimplementedError();
  }

  @override
  Future<List<MobkitCalendarAppointmentModel>> getEventList(Map arguments) {
    throw UnimplementedError();
  }

  @override
  Future openEventDetail(Map arguments) {
    throw UnimplementedError();
  }

  @override
  Future requestCalendarAccess() {
    throw UnimplementedError();
  }
}

void main() {}

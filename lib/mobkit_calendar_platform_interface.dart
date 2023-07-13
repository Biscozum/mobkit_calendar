import 'package:mobkit_calendar/src/calendars/mobkit_calendar/model/calendar_account_group_model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mobkit_calendar.dart';
import 'mobkit_calendar_method_channel.dart';

abstract class MobkitCalendarPlatform extends PlatformInterface {
  /// Constructs a MobkitCalendarPlatform.
  MobkitCalendarPlatform() : super(token: _token);

  static final Object _token = Object();

  static MobkitCalendarPlatform _instance = MethodChannelMobkitCalendar();

  /// The default instance of [MobkitCalendarPlatform] to use.
  ///
  /// Defaults to [MethodChannelMobkitCalendar].
  static MobkitCalendarPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MobkitCalendarPlatform] when
  /// they register themselves.
  static set instance(MobkitCalendarPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<List<AccountGroupModel>> getAccountList() {
    throw UnimplementedError('accountList() has not been implemented.');
  }

  Future<List<MobkitCalendarAppointmentModel>> getEventList(Map arguments) {
    throw UnimplementedError('eventList() has not been implemented.');
  }

  Future requestCalendarAccess() {
    throw UnimplementedError('reqestCalendarAccess() has not been implemented.');
  }
}

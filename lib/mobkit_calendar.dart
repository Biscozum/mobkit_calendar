export './src/calendar.dart';
export 'src/mobkit_calendar/model/mobkit_calendar_appointment_model.dart';
export 'src/mobkit_calendar/model/configs/calendar_popup_config_model.dart';
export 'src/mobkit_calendar/model/configs/calendar_config_model.dart';
export 'src/mobkit_calendar/model/configs/agenda_view_config_model.dart';
export 'src/mobkit_calendar/model/configs/calendar_cell_config_model.dart';
export 'src/mobkit_calendar/model/configs/daily_items_config_model.dart';
export 'src/mobkit_calendar/model/configs/calendar_top_bar_config_model.dart';
export 'src/mobkit_calendar/model/styles/calendar_cell_style.dart';
export 'src/mobkit_calendar/model/styles/frame_style.dart';
export 'src/mobkit_calendar/enum/mobkit_calendar_view_type_enum.dart';
export 'src/mobkit_calendar/model/recurrence_model.dart';
export 'src/mobkit_calendar/model/calendar_account_group_model.dart';
export 'src/mobkit_calendar/model/calendar_account_model.dart';
export 'src/mobkit_calendar/model/daily_frequency.dart';
export 'src/mobkit_calendar/model/weekly_frequency.dart';
export 'src/mobkit_calendar/model/monthly_frequency.dart';
export 'src/mobkit_calendar/model/yearly_frequency.dart';
export 'src/mobkit_calendar/model/day_of_month_model.dart';
export 'src/mobkit_calendar/model/day_of_week_and_repetition_model.dart';
export 'src/extensions/date_extensions.dart';
export 'src/mobkit_calendar/controller/mobkit_calendar_controller.dart';
import 'mobkit_calendar.dart';
import 'mobkit_calendar_platform_interface.dart';

class MobkitCalendar {
  Future<String?> getPlatformVersion() {
    return MobkitCalendarPlatform.instance.getPlatformVersion();
  }

  Future<List<AccountGroupModel>> getAccountList() {
    return MobkitCalendarPlatform.instance.getAccountList();
  }

  Future<List<MobkitCalendarAppointmentModel>> getEventList(Map arguments) {
    return MobkitCalendarPlatform.instance.getEventList(arguments);
  }

  Future requestCalendarAccess() {
    return MobkitCalendarPlatform.instance.requestCalendarAccess();
  }

  Future openEventDetail(Map arguments) {
    return MobkitCalendarPlatform.instance.openEventDetail(arguments);
  }
}

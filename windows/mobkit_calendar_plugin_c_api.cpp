#include "include/mobkit_calendar/mobkit_calendar_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "mobkit_calendar_plugin.h"

void MobkitCalendarPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  mobkit_calendar::MobkitCalendarPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

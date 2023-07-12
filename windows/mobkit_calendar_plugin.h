#ifndef FLUTTER_PLUGIN_MOBKIT_CALENDAR_PLUGIN_H_
#define FLUTTER_PLUGIN_MOBKIT_CALENDAR_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace mobkit_calendar {

class MobkitCalendarPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  MobkitCalendarPlugin();

  virtual ~MobkitCalendarPlugin();

  // Disallow copy and assign.
  MobkitCalendarPlugin(const MobkitCalendarPlugin&) = delete;
  MobkitCalendarPlugin& operator=(const MobkitCalendarPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace mobkit_calendar

#endif  // FLUTTER_PLUGIN_MOBKIT_CALENDAR_PLUGIN_H_

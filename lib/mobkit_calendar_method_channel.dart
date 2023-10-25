import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_calendar/mobkit_calendar.dart';
import 'mobkit_calendar_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';

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
  Future<List<AccountGroupModel>> getAccountList() async {
    PermissionStatus result = await Permission.calendarReadOnly.request();
    List<AccountGroupModel> accounts = [];
    if (result.isGranted) {
      String? accountList = await methodChannel.invokeMethod<String?>('getAccountList');
      Map accountMap = json.decode(accountList ?? "");
      if (accountMap["accounts"] is List<Object?>) {
        for (var account in accountMap["accounts"]) {
          if (account is Map) {
            if (accounts.any((element) => element.groupName == account["groupName"])) {
              AccountModel accountModel = AccountModel(
                  accountName: account["accountName"],
                  isChecked: account["isChecked"],
                  accountId: account["accountId"]);
              accounts
                  .where((element) => element.groupName == account["groupName"])
                  .first
                  .accountModels!
                  .add(accountModel);
            } else {
              AccountGroupModel accountGroupModel =
                  AccountGroupModel(groupName: account["groupName"], accountModels: []);
              AccountModel accountModel = AccountModel(
                  accountName: account["accountName"],
                  isChecked: account["isChecked"],
                  accountId: account["accountId"]);
              accountGroupModel.accountModels!.add(accountModel);
              accounts.add(accountGroupModel);
            }
          }
        }
      }
    }

    return accounts;
  }

  @override
  Future<List<MobkitCalendarAppointmentModel>> getEventList(Map arguments) async {
    PermissionStatus result = await Permission.calendarReadOnly.request();
    List<MobkitCalendarAppointmentModel> events = [];
    if (result.isGranted) {
      String? eventList = await methodChannel.invokeMethod<String?>('getEventList', arguments);
      Map eventMap = json.decode(eventList ?? "");
      if (eventMap["events"] is List<Object?>) {
        for (var event in eventMap["events"]) {
          if (event is Map) {
            MobkitCalendarAppointmentModel mobkitCalendarAppointmentModel = MobkitCalendarAppointmentModel(
              nativeEventId: event["nativeEventId"].toString(),
              title: event["fullName"],
              appointmentStartDate: DateFormat('dd/MM/yyyy HH:mm:ss').parse(event["startDate"]),
              appointmentEndDate: DateFormat('dd/MM/yyyy HH:mm:ss').parse(event["endDate"]),
              isAllDay: event["isFullDayEvent"],
              detail: event["description"] ?? "",
              color: const Color(0xff7209b7),
              recurrenceModel: null,
            );
            events.add(mobkitCalendarAppointmentModel);
          }
        }
      }
    }
    return events;
  }

  @override
  Future requestCalendarAccess() async {
    PermissionStatus result = await Permission.calendarFullAccess.request();
    return result.isGranted;
  }
}

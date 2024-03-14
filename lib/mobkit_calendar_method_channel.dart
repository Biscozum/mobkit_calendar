import 'dart:convert';
import 'dart:io';
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
  Future openEventDetail(Map arguments) async {
    final success = await methodChannel.invokeMethod<bool>('openEventDetail', arguments);
    return success;
  }

  @override
  Future<List<AccountGroupModel>> getAccountList() async {
    // ignore: deprecated_member_use
    PermissionStatus result = await Permission.calendar.request();
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
    // ignore: deprecated_member_use
    PermissionStatus result = await Permission.calendar.request();
    List<MobkitCalendarAppointmentModel> events = [];
    if ((arguments["idlist"] is List<String>) && result.isGranted && (arguments["idlist"] as List<String>).isNotEmpty) {
      String? eventList = await methodChannel.invokeMethod<String?>('getEventList', arguments);
      Map eventMap = json.decode(eventList ?? "");
      if (eventMap["events"] is List<Object?>) {
        for (var event in eventMap["events"]) {
          if (event is Map) {
            late MobkitCalendarAppointmentModel mobkitCalendarAppointmentModel;
            if (Platform.isAndroid) {
              mobkitCalendarAppointmentModel = MobkitCalendarAppointmentModel(
                nativeEventId: event["nativeEventId"].toString(),
                title: event["fullName"],
                appointmentStartDate:
                    DateTime.fromMillisecondsSinceEpoch(event["startDate"], isUtc: event["isFullDayEvent"]),
                appointmentEndDate:
                    DateTime.fromMillisecondsSinceEpoch(event["endDate"], isUtc: event["isFullDayEvent"]),
                isAllDay: event["isFullDayEvent"],
                detail: event["description"] ?? "",
                color: const Color(0xff7209b7),
                recurrenceModel: null,
              );
            } else {
              mobkitCalendarAppointmentModel = MobkitCalendarAppointmentModel(
                nativeEventId: event["nativeEventId"].toString(),
                title: event["fullName"],
                appointmentStartDate: DateFormat('dd/MM/yyyy HH:mm:ss').parse(event["startDate"]),
                appointmentEndDate: DateFormat('dd/MM/yyyy HH:mm:ss').parse(event["endDate"]),
                isAllDay: event["isFullDayEvent"],
                detail: event["description"] ?? "",
                color: const Color(0xff7209b7),
                recurrenceModel: null,
              );
            }
            events.add(mobkitCalendarAppointmentModel);
          }
        }
      }
    }
    return events;
  }

  @override
  Future requestCalendarAccess() async {
    // ignore: deprecated_member_use
    // PermissionStatus result = await Permission.calendar.request();
    // return result.isGranted;
    final success = await methodChannel.invokeMethod<bool>('requestPermissions');
    return success ?? false;
  }

  @override
  Future<bool> addNativeEvent(NativeEvent nativeEvent) async {
    final success = await methodChannel.invokeMethod<bool>('addNativeEvent', nativeEvent.toJson());
    return success ?? false;
  }

  @override
  Future<bool> addCalendar(NativeCalendar nativeCalendar) async {
    final success = await methodChannel.invokeMethod<bool>('addCalendar', nativeCalendar.toJson());
    return success ?? false;
  }
}

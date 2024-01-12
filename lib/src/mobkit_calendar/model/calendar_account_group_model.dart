import 'calendar_account_model.dart';

/// Groups for accounts on the device.
class AccountGroupModel {
  String groupName;
  List<AccountModel>? accountModels;
  AccountGroupModel({
    required this.groupName,
    required this.accountModels,
  });

  factory AccountGroupModel.fromJson(Map<String, dynamic> json) =>
      AccountGroupModel(
        groupName: json["groupName"],
        accountModels: (json['accountModels'] as List<dynamic>?)
            ?.map((e) => AccountModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        "groupName": groupName,
        "accountModels": accountModels,
      };
}

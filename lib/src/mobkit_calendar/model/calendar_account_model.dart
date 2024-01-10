/// Accounts on the device.
class AccountModel {
  String accountName;
  bool isChecked;
  String accountId;
  AccountModel({
    required this.accountName,
    required this.isChecked,
    required this.accountId,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        accountName: json["accountName"],
        isChecked: json["isChecked"],
        accountId: json["accountId"],
      );

  Map<String, dynamic> toJson() => {
        "accountName": accountName,
        "isChecked": isChecked,
        "accountId": accountId,
      };
}

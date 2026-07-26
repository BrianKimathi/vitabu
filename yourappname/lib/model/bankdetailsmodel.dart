// To parse this JSON data, do
//
//     final bankDetailsModel = bankDetailsModelFromJson(jsonString);

import 'dart:convert';

BankDetailsModel bankDetailsModelFromJson(String str) =>
    BankDetailsModel.fromJson(json.decode(str));

String bankDetailsModelToJson(BankDetailsModel data) =>
    json.encode(data.toJson());

class BankDetailsModel {
  int? status;
  String? message;
  List<Result>? result;

  BankDetailsModel({
    this.status,
    this.message,
    this.result,
  });

  factory BankDetailsModel.fromJson(Map<String, dynamic> json) =>
      BankDetailsModel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

class Result {
  int? id;
  int? userId;
  String? bankName;
  String? accountNo;
  String? ifscCode;
  String? bankHolderName;
  int? status;
  String? image;
  String? createdAt;
  String? updatedAt;

  Result({
    this.id,
    this.userId,
    this.bankName,
    this.accountNo,
    this.ifscCode,
    this.bankHolderName,
    this.status,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        userId: json["user_id"],
        bankName: json["bank_name"],
        accountNo: json["account_no"],
        ifscCode: json["ifsc_code"],
        bankHolderName: json["bank_holder_name"],
        status: _parseInt(json["status"]),
        image: json["image"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "bank_name": bankName,
        "account_no": accountNo,
        "ifsc_code": ifscCode,
        "bank_holder_name": bankHolderName,
        "status": status,
        "image": image,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

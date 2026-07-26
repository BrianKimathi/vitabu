// To parse this JSON data, do
//
//     final voucherListModel = voucherListModelFromJson(jsonString);

import 'dart:convert';

VoucherListModel voucherListModelFromJson(String str) =>
    VoucherListModel.fromJson(json.decode(str));

String voucherListModelToJson(VoucherListModel data) =>
    json.encode(data.toJson());

class VoucherListModel {
  int? status;
  String? message;
  List<Result>? result;

  VoucherListModel({
    this.status,
    this.message,
    this.result,
  });

  factory VoucherListModel.fromJson(Map<String, dynamic> json) =>
      VoucherListModel(
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
  String? title;
  String? points;
  DateTime? expiryDate;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? fullName;
  int? voucherBalance;

  Result({
    this.id,
    this.userId,
    this.title,
    this.points,
    this.expiryDate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.fullName,
    this.voucherBalance,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        userId: json["user_id"],
        title: json["title"],
        points: json["points"],
        expiryDate: DateTime.parse(json["expiry_date"]),
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        fullName: json["full_name"],
        voucherBalance: json["voucher_balance"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "title": title,
        "points": points,
        "expiry_date":
            "${expiryDate?.year.toString().padLeft(4, '0')}-${expiryDate?.month.toString().padLeft(2, '0')}-${expiryDate?.day.toString().padLeft(2, '0')}",
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "full_name": fullName,
        "voucher_balance": voucherBalance,
      };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

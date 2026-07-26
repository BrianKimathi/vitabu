// To parse this JSON data, do
//
//     final followListModel = followListModelFromJson(jsonString);

import 'dart:convert';

FollowListModel followListModelFromJson(String str) =>
    FollowListModel.fromJson(json.decode(str));

String followListModelToJson(FollowListModel data) =>
    json.encode(data.toJson());

class FollowListModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  FollowListModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory FollowListModel.fromJson(Map<String, dynamic> json) =>
      FollowListModel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
        totalRows: _parseInt(json["total_rows"]),
        totalPage: _parseInt(json["total_page"]),
        currentPage: _parseInt(json["current_page"]),
        morePage: json["more_page"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
        "total_rows": totalRows,
        "total_page": totalPage,
        "current_page": currentPage,
        "more_page": morePage,
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
  int? toUserId;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? userName;
  String? fullName;
  String? email;
  String? mobileNumber;
  String? image;
  int? isFollow;

  Result({
    this.id,
    this.userId,
    this.toUserId,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.fullName,
    this.email,
    this.mobileNumber,
    this.image,
    this.isFollow,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        userId: json["user_id"],
        toUserId: json["to_user_id"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        userName: json["user_name"],
        fullName: json["full_name"],
        email: json["email"],
        mobileNumber: json["mobile_number"],
        image: json["image"],
        isFollow: json["is_follow"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "to_user_id": toUserId,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "user_name": userName,
        "full_name": fullName,
        "email": email,
        "mobile_number": mobileNumber,
        "image": image,
        "is_follow": isFollow,
      };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

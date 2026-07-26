// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

NotificationModel notificationModelFromJson(String str) => NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) => json.encode(data.toJson());

class NotificationModel {
    int? status;
    String? message;
    List<Result>? result;
    int? totalRows;
    int? totalPage;
    int? currentPage;
    bool? morePage;

    NotificationModel({
        this.status,
        this.message,
        this.result,
        this.totalRows,
        this.totalPage,
        this.currentPage,
        this.morePage,
    });

    factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: json["result"] == null ? [] : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
        totalRows: _parseInt(json["total_rows"]),
        totalPage: _parseInt(json["total_page"]),
        currentPage: _parseInt(json["current_page"]),
        morePage: json["more_page"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
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
    int? type;
    int? userId;
    int? autherId;
    int? contentType;
    int? contentId;
    int? subContentId;
    String? title;
    String? message;
    String? image;
    int? status;
    String? createdAt;
    String? updatedAt;

    Result({
        this.id,
        this.type,
        this.userId,
        this.autherId,
        this.contentType,
        this.contentId,
        this.subContentId,
        this.title,
        this.message,
        this.image,
        this.status,
        this.createdAt,
        this.updatedAt,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        type: _parseInt(json["type"]),
        userId: json["user_id"],
        autherId: json["auther_id"],
        contentType: json["content_type"],
        contentId: json["content_id"],
        subContentId: json["sub_content_id"],
        title: json["title"],
        message: json["message"],
        image: json["image"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "user_id": userId,
        "auther_id": autherId,
        "content_type": contentType,
        "content_id": contentId,
        "sub_content_id": subContentId,
        "title": title,
        "message": message,
        "image": image,
        "status": status,
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

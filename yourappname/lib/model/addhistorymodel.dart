// To parse this JSON data, do
//
//     final addhistorymodel = addhistorymodelFromJson(jsonString);

import 'dart:convert';

Addhistorymodel addhistorymodelFromJson(String str) => Addhistorymodel.fromJson(json.decode(str));

String addhistorymodelToJson(Addhistorymodel data) => json.encode(data.toJson());

class Addhistorymodel {
    int? status;
    String? message;
    List<Result>? result;

    Addhistorymodel({
        this.status,
        this.message,
        this.result,
    });

    factory Addhistorymodel.fromJson(Map<String, dynamic> json) => Addhistorymodel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: json["result"] == null ? [] : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
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
    int? userId;
    int? authorId;
    int? contentType;
    int? contentId;
    int? subContentId;
    int? isSubscription;
    int? lastPosition;
    int? timeSpend;
    int? status;
    String? updatedAt;
    String? createdAt;
    int? id;

    Result({
        this.userId,
        this.authorId,
        this.contentType,
        this.contentId,
        this.subContentId,
        this.isSubscription,
        this.lastPosition,
        this.timeSpend,
        this.status,
        this.updatedAt,
        this.createdAt,
        this.id,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        userId: json["user_id"],
        authorId: _parseInt(json["author_id"]),
        contentType: json["content_type"],
        contentId: json["content_id"],
        subContentId: json["sub_content_id"],
        isSubscription: _parseInt(json["is_subscription"]),
        lastPosition: json["last_position"],
        timeSpend: json["time_spend"],
        status: _parseInt(json["status"]),
        updatedAt: json["updated_at"],
        createdAt: json["created_at"],
        id: _parseInt(json["id"]),
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "author_id": authorId,
        "content_type": contentType,
        "content_id": contentId,
        "sub_content_id": subContentId,
        "is_subscription": isSubscription,
        "last_position": lastPosition,
        "time_spend": timeSpend,
        "status": status,
        "updated_at": updatedAt,
        "created_at": createdAt,
        "id": id,
    };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

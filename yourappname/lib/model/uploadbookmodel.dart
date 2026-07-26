// To parse this JSON data, do
//
//     final upoadBookModel = upoadBookModelFromJson(jsonString);

import 'dart:convert';

UploadBookModel uploadBookModelFromJson(String str) =>
    UploadBookModel.fromJson(json.decode(str));

String uploadBookModelToJson(UploadBookModel data) =>
    json.encode(data.toJson());

class UploadBookModel {
  int? status;
  String? message;
  List<Result>? result;

  UploadBookModel({
    this.status,
    this.message,
    this.result,
  });

  factory UploadBookModel.fromJson(Map<String, dynamic> json) =>
      UploadBookModel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: json["result"] == null
            ? null
            : List<Result>.from(
                json["result"].map((x) => Result.fromJson(x)) ?? []),
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
  int? categoryId;
  String? title;
  int? price;
  int? isPaid;
  String? description;
  String? image;
  String? sampleUrl;
  String? url;
  int? readCount;
  int? download;
  int? status;
  String? createdAt;
  String? updatedAt;

  Result({
    this.id,
    this.userId,
    this.categoryId,
    this.title,
    this.price,
    this.isPaid,
    this.description,
    this.image,
    this.sampleUrl,
    this.url,
    this.readCount,
    this.download,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        userId: json["user_id"],
        categoryId: _parseInt(json["category_id"]),
        title: json["title"],
        price: _parseInt(json["price"]),
        isPaid: json["is_paid"],
        description: json["description"],
        image: json["image"],
        sampleUrl: json["sample_url"],
        url: json["url"],
        readCount: json["read_count"],
        download: json["download"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "category_id": categoryId,
        "title": title,
        "price": price,
        "is_paid": isPaid,
        "description": description,
        "image": image,
        "sample_url": sampleUrl,
        "url": url,
        "read_count": readCount,
        "download": download,
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

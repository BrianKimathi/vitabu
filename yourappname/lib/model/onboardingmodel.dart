// To parse this JSON data, do
//
//     final onBoardingModel = onBoardingModelFromJson(jsonString);

import 'dart:convert';

OnBoardingModel onBoardingModelFromJson(String str) =>
    OnBoardingModel.fromJson(json.decode(str));

String onBoardingModelToJson(OnBoardingModel data) =>
    json.encode(data.toJson());

class OnBoardingModel {
  int? status;
  String? message;
  List<Result>? result;

  OnBoardingModel({
    this.status,
    this.message,
    this.result,
  });

  factory OnBoardingModel.fromJson(Map<String, dynamic> json) =>
      OnBoardingModel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result!.map((x) => x.toJson())),
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
  String? title;
  String? image;
  String? description;
  int? status;
  String? createdAt;
  String? updatedAt;

  Result({
    this.id,
    this.title,
    this.image,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        title: json["title"],
        image: json["image"],
        description: json["description"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image": image,
        "description": description,
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

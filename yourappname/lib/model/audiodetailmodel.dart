// To parse this JSON data, do
//
//     final audioDetailModel = audioDetailModelFromJson(jsonString);

import 'dart:convert';

AudioDetailModel audioDetailModelFromJson(String str) =>
    AudioDetailModel.fromJson(json.decode(str));

String audioDetailModelToJson(AudioDetailModel data) =>
    json.encode(data.toJson());

class AudioDetailModel {
  int? status;
  String? message;
  Result? result;

  AudioDetailModel({
    this.status,
    this.message,
    this.result,
  });

  factory AudioDetailModel.fromJson(Map<String, dynamic> json) =>
      AudioDetailModel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: json["result"] == null ? null : Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result?.toJson(),
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
  int? authorId;
  int? categoryId;
  int? languageId;
  String? title;
  String? portraitImg;
  String? landscapeImg;
  int? accessType;
  int? price;
  String? description;
  String? fullAudio;
  int? totalPlayed;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? authorName;
  String? authorImage;
  String? categoryName;
  String? languageName;
  int? totalEpisodes;
  int? totalReviews;
  dynamic avgReviews;
  int? isBookmark;
  int? isBuy;
  int? isSubscription;
  int? lastPosition;
  String? authorSubaccount;
  String? bsnb;
  String? customAuthorName;

  Result({
    this.id,
    this.authorId,
    this.categoryId,
    this.languageId,
    this.title,
    this.portraitImg,
    this.landscapeImg,
    this.accessType,
    this.price,
    this.description,
    this.fullAudio,
    this.totalPlayed,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.authorName,
    this.authorImage,
    this.categoryName,
    this.languageName,
    this.totalEpisodes,
    this.totalReviews,
    this.avgReviews,
    this.isBookmark,
    this.isBuy,
    this.isSubscription,
    this.lastPosition,
    this.authorSubaccount,
    this.bsnb,
    this.customAuthorName,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        authorId: _parseInt(json["author_id"]),
        categoryId: _parseInt(json["category_id"]),
        languageId: json["language_id"],
        title: json["title"],
        portraitImg: json["portrait_img"],
        landscapeImg: json["landscape_img"],
        accessType: _parseInt(json["access_type"]),
        price: _parseInt(json["price"]),
        description: json["description"],
        fullAudio: json["full_audio"],
        totalPlayed: json["total_played"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        authorName: json["author_name"],
        authorImage: json["author_image"],
        categoryName: json["category_name"],
        languageName: json["language_name"],
        totalEpisodes: json["total_episodes"],
        totalReviews: _parseInt(json["total_reviews"]),
        avgReviews: _parseInt(json["avg_reviews"]),
        isBookmark: _parseInt(json["is_bookmark"]),
        isBuy: _parseInt(json["is_buy"]),
        isSubscription: _parseInt(json["is_subscription"]),
        lastPosition: json["last_position"],
        authorSubaccount: json["author_subaccount"],
        bsnb: json["bsnb"],
        customAuthorName: json["custom_author_name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "author_id": authorId,
        "category_id": categoryId,
        "language_id": languageId,
        "title": title,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "is_paid": accessType,
        "price": price,
        "description": description,
        "full_audio": fullAudio,
        "total_played": totalPlayed,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "author_name": authorName,
        "author_image": authorImage,
        "category_name": categoryName,
        "language_name": languageName,
        "total_episodes": totalEpisodes,
        "total_reviews": totalReviews,
        "avg_reviews": avgReviews,
        "is_bookmark": isBookmark,
        "is_buy": isBuy,
        "is_subscription": isSubscription,
        "last_position": lastPosition,
        "author_subaccount": authorSubaccount,
        "bsnb": bsnb,
        "custom_author_name": customAuthorName,
      };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

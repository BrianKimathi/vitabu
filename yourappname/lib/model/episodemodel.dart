// To parse this JSON data, do
//
//     final episodeModel = episodeModelFromJson(jsonString);

import 'dart:convert';

EpisodeModel episodeModelFromJson(String str) =>
    EpisodeModel.fromJson(json.decode(str));

String episodeModelToJson(EpisodeModel data) => json.encode(data.toJson());

class EpisodeModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  EpisodeModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) => EpisodeModel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
        totalRows: _parseInt(json["total_rows"]),
        totalPage: _parseInt(json["total_page"]),
        currentPage: _parseInt(json["current_page"]),
        morePage: json["more_page"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result!.map((x) => x.toJson())),
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
  int? audioBookId;
  String? title;
  String? description;
  String? image;
  int? audioType;
  String? audio;
  int? isEpisodePaid;
  int? price;
  int? totalPlayed;
  int? sortOrder;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? isBuy;
  int? authorId;

  Result(
      {this.id,
      this.audioBookId,
      this.title,
      this.description,
      this.image,
      this.audioType,
      this.audio,
      this.isEpisodePaid,
      this.price,
      this.totalPlayed,
      this.sortOrder,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.isBuy,
      this.authorId});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        audioBookId: json["audio_book_id"],
        title: json["title"],
        description: json["description"],
        image: json["image"],
        audioType: json["audio_type"],
        audio: json["audio"],
        isEpisodePaid: json["is_episode_paid"],
        price: _parseInt(json["price"]),
        totalPlayed: json["total_played"],
        sortOrder: json["sort_order"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isBuy: _parseInt(json["is_buy"]),
        authorId: _parseInt(json["author_id"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "audio_book_id": audioBookId,
        "title": title,
        "description": description,
        "image": image,
        "audio_type": audioType,
        "audio": audio,
        "is_episode_paid": isEpisodePaid,
        "price": price,
        "total_played": totalPlayed,
        "sort_order": sortOrder,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "is_buy": isBuy,
        "author_id": authorId,
      };
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "audio_book_id": audioBookId,
      "title": title,
      "description": description,
      "image": image,
      "audio_type": audioType,
      "audio": audio,
      "is_episode_paid": isEpisodePaid,
      "price": price,
      "total_played": totalPlayed,
      "sort_order": sortOrder,
      "status": status,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "is_buy": isBuy,
      "author_id": authorId,
    };
  }
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

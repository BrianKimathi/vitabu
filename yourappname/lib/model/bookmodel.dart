// To parse this JSON data, do
//
//     final bookModel = bookModelFromJson(jsonString);

import 'dart:convert';

BookModel bookModelFromJson(String str) => BookModel.fromJson(json.decode(str));

String bookModelToJson(BookModel data) => json.encode(data.toJson());

class BookModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  BookModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
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
  int? authorId;
  int? categoryId;
  int? languageId;
  String? title;
  String? portraitImg;
  String? landscapeImg;
  int? accessType;
  int? price;
  String? description;
  String? fullNovel;
  int? totalRead;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? authorName;
  String? categoryName;
  String? languageName;
  int? totalChapters;
  int? totalReviews;
  dynamic avgReviews;
  int? isBookmark;
  int? isBuy;

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
    this.fullNovel,
    this.totalRead,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.authorName,
    this.categoryName,
    this.languageName,
    this.totalChapters,
    this.totalReviews,
    this.avgReviews,
    this.isBookmark,
    this.isBuy,
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
        fullNovel: json["full_novel"],
        totalRead: json["total_read"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        authorName: json["author_name"],
        categoryName: json["category_name"],
        languageName: json["language_name"],
        totalChapters: json["total_chapters"],
        totalReviews: _parseInt(json["total_reviews"]),
        avgReviews: _parseInt(json["avg_reviews"]),
        isBookmark: _parseInt(json["is_bookmark"]),
        isBuy: _parseInt(json["is_buy"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "author_id": authorId,
        "category_id": categoryId,
        "language_id": languageId,
        "title": title,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "access_type": accessType,
        "price": price,
        "description": description,
        "full_novel": fullNovel,
        "total_read": totalRead,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "author_name": authorName,
        "category_name": categoryName,
        "language_name": languageName,
        "total_chapters": totalChapters,
        "total_reviews": totalReviews,
        "avg_reviews": avgReviews,
        "is_bookmark": isBookmark,
        "is_buy": isBuy,
      };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

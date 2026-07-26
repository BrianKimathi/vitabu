// To parse this JSON data, do
//
//     final getBookMarkBookModel = getBookMarkBookModelFromJson(jsonString);

import 'dart:convert';

BookMarkModel getBookMarkBookModelFromJson(String str) =>
    BookMarkModel.fromJson(json.decode(str));

String getBookMarkBookModelToJson(BookMarkModel data) =>
    json.encode(data.toJson());

class BookMarkModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  BookMarkModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory BookMarkModel.fromJson(Map<String, dynamic> json) => BookMarkModel(
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
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
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
  String? categoryName;
  String? authorName;
  int? totalComment;
  String? avgRating;
  int? isBookmark;
  int? isDownload;
  int? isBuy;

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
    this.categoryName,
    this.authorName,
    this.totalComment,
    this.avgRating,
    this.isBookmark,
    this.isDownload,
    this.isBuy,
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
        categoryName: json["category_name"],
        authorName: json["author_name"],
        totalComment: json["total_comment"],
        avgRating: json["avg_rating"],
        isBookmark: _parseInt(json["is_bookmark"]),
        isDownload: json["is_download"],
        isBuy: _parseInt(json["is_buy"]),
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
        "category_name": categoryName,
        "author_name": authorName,
        "total_comment": totalComment,
        "avg_rating": avgRating,
        "is_bookmark": isBookmark,
        "is_download": isDownload,
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

// To parse this JSON data, do
//
//     final chapterModel = chapterModelFromJson(jsonString);

import 'dart:convert';

ChapterModel chapterModelFromJson(String str) => ChapterModel.fromJson(json.decode(str));

String chapterModelToJson(ChapterModel data) => json.encode(data.toJson());

class ChapterModel {
    int? status;
    String? message;
    List<Result>? result;
    int? totalRows;
    int? totalPage;
    int? currentPage;
    bool? morePage;

    ChapterModel({
        this.status,
        this.message,
        this.result,
        this.totalRows,
        this.totalPage,
        this.currentPage,
        this.morePage,
    });

    factory ChapterModel.fromJson(Map<String, dynamic> json) => ChapterModel(
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
    int? novelId;
    String? title;
    String? description;
    String? image;
    int? chapterType;
    String? chapter;
    int? isChapterPaid;
    int? price;
    int? totalRead;
    int? sortOrder;
    int? status;
    String? createdAt;
    String? updatedAt;
    int? isBuy;

    Result({
        this.id,
        this.novelId,
        this.title,
        this.description,
        this.image,
        this.chapterType,
        this.chapter,
        this.isChapterPaid,
        this.price,
        this.totalRead,
        this.sortOrder,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.isBuy,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        novelId: json["novel_id"],
        title: json["title"],
        description: json["description"],
        image: json["image"],
        chapterType: json["chapter_type"],
        chapter: json["chapter"],
        isChapterPaid: json["is_chapter_paid"],
        price: _parseInt(json["price"]),
        totalRead: json["total_read"],
        sortOrder: json["sort_order"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isBuy: _parseInt(json["is_buy"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "novel_id": novelId,
        "title": title,
        "description": description,
        "image": image,
        "chapter_type": chapterType,
        "chapter": chapter,
        "is_chapter_paid": isChapterPaid,
        "price": price,
        "total_read": totalRead,
        "sort_order": sortOrder,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
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

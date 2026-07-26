// To parse this JSON data, do
//
//     final commentModel = commentModelFromJson(jsonString);

import 'dart:convert';

CommentModel commentModelFromJson(String str) =>
    CommentModel.fromJson(json.decode(str));

String commentModelToJson(CommentModel data) => json.encode(data.toJson());

class CommentModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  CommentModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(
                json["result"].map((x) => Result.fromJson(x)) ?? []),
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
  int? bookId;
  int? magazineId;
  int? chapterId;
  String? comment;
  int? rating;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? fullName;
  String? userName;
  String? userImage;

  Result({
    this.id,
    this.userId,
    this.bookId,
    this.magazineId,
    this.chapterId,
    this.comment,
    this.rating,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.fullName,
    this.userName,
    this.userImage,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        userId: json["user_id"],
        bookId: json["book_id"],
        magazineId: json["magazine_id"],
        chapterId: json["chapter_id"],
        comment: json["comment"],
        rating: json["rating"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        fullName: json["full_name"],
        userName: json["user_name"],
        userImage: json["user_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "book_id": bookId,
        "magazine_id": magazineId,
        "chapter_id": chapterId,
        "comment": comment,
        "rating": rating,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "full_name": fullName,
        "user_name": userName,
        "user_image": userImage,
      };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

// To parse this JSON data, do
//
//     final transactionHistoryModel = transactionHistoryModelFromJson(jsonString);

import 'dart:convert';

TransactionHistoryModel transactionHistoryModelFromJson(String str) =>
    TransactionHistoryModel.fromJson(json.decode(str));

String transactionHistoryModelToJson(TransactionHistoryModel data) =>
    json.encode(data.toJson());

class TransactionHistoryModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  TransactionHistoryModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) =>
      TransactionHistoryModel(
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
  int? userId;
  int? authorId;
  int? contentType;
  int? contentId;
  int? subContentId;
  int? price;
  int? commission;
  int? authorEarning;
  String? transactionId;
  String? paymentMethod;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? authorName;
  String? contentName;
  String? contentImage;
  String? subContentName;
  String? subContentImage;
  int? categoryId;

  Result({
    this.id,
    this.userId,
    this.authorId,
    this.contentType,
    this.contentId,
    this.subContentId,
    this.price,
    this.commission,
    this.authorEarning,
    this.transactionId,
    this.paymentMethod,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.authorName,
    this.contentName,
    this.contentImage,
    this.subContentName,
    this.subContentImage,
    this.categoryId,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: int.tryParse(json["id"]?.toString() ?? ""),
        userId: int.tryParse(json["user_id"]?.toString() ?? ""),
        authorId: int.tryParse(json["author_id"]?.toString() ?? ""),
        contentType: int.tryParse(json["content_type"]?.toString() ?? ""),
        contentId: int.tryParse(json["content_id"]?.toString() ?? ""),
        subContentId: int.tryParse(json["sub_content_id"]?.toString() ?? ""),
        price: int.tryParse(json["price"]?.toString() ?? ""),
        commission: int.tryParse(json["commission"]?.toString() ?? ""),
        authorEarning: int.tryParse(json["author_earning"]?.toString() ?? ""),
        status: int.tryParse(json["status"]?.toString() ?? ""),
        categoryId: int.tryParse(json["category_id"]?.toString() ?? ""),
        transactionId: json["transaction_id"]?.toString(),
        paymentMethod: json["payment_method"]?.toString(),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
        authorName: json["author_name"]?.toString(),
        contentName: json["content_name"]?.toString(),
        contentImage: json["content_image"]?.toString(),
        subContentName: json["sub_content_name"]?.toString(),
        subContentImage: json["sub_content_image"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "author_id": authorId,
        "content_type": contentType,
        "content_id": contentId,
        "sub_content_id": subContentId,
        "price": price,
        "commission": commission,
        "author_earning": authorEarning,
        "transaction_id": transactionId,
        "payment_method": paymentMethod,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "author_name": authorName,
        "content_name": contentName,
        "content_image": contentImage,
        "sub_content_name": subContentName,
        "sub_content_image": subContentImage,
        "category_id": categoryId,
      };
}

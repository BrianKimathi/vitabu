// To parse this JSON data, do
//
//     final sectionModel = sectionModelFromJson(jsonString);

import 'dart:convert';

SectionModel sectionModelFromJson(String str) =>
    SectionModel.fromJson(json.decode(str));

String sectionModelToJson(SectionModel data) => json.encode(data.toJson());

class SectionModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  SectionModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) => SectionModel(
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
  int? sectionType;
  int? contentType;
  String? title;
  String? shortTitle;
  String? screenLayout;
  int? authorId;
  int? categoryId;
  int? languageId;
  int? accessType;
  int? orderByView;
  int? orderByUpload;
  int? noOfContent;
  int? viewAll;
  int? sortOrder;
  int? status;
  String? createdAt;
  String? updatedAt;
  List<Datum>? data;

  Result({
    this.id,
    this.sectionType,
    this.contentType,
    this.title,
    this.shortTitle,
    this.screenLayout,
    this.authorId,
    this.categoryId,
    this.languageId,
    this.accessType,
    this.orderByView,
    this.orderByUpload,
    this.noOfContent,
    this.viewAll,
    this.sortOrder,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.data,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        sectionType: json["section_type"],
        contentType: json["content_type"],
        title: json["title"],
        shortTitle: json["short_title"],
        screenLayout: json["screen_layout"],
        authorId: _parseInt(json["author_id"]),
        categoryId: _parseInt(json["category_id"]),
        languageId: json["language_id"],
        accessType: _parseInt(json["access_type"]),
        orderByView: json["order_by_view"],
        orderByUpload: json["order_by_upload"],
        noOfContent: json["no_of_content"],
        viewAll: json["view_all"],
        sortOrder: json["sort_order"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "section_type": sectionType,
        "content_type": contentType,
        "title": title,
        "short_title": shortTitle,
        "screen_layout": screenLayout,
        "author_id": authorId,
        "category_id": categoryId,
        "language_id": languageId,
        "access_type": accessType,
        "order_by_view": orderByView,
        "order_by_upload": orderByUpload,
        "no_of_content": noOfContent,
        "view_all": viewAll,
        "sort_order": sortOrder,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

class Datum {
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
  String? categoryName;
  String? languageName;
  int? totalEpisodes;
  int? totalReviews;
  dynamic avgReviews;
  int? isBookmark;
  int? isBuy;
  String? name;
  String? image;
  int? sortOrder;
  String? fullMagazine;
  int? totalRead;
  int? isAuthor;
  String? categoryIds;
  String? userName;
  String? firstName;
  String? lastName;
  String? email;
  String? mobileNumber;
  int? type;
  String? address;
  int? walletAmount;
  int? deviceType;
  String? deviceToken;
  String? fullNovel;
  int? totalChapters;

  Datum({
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
    this.categoryName,
    this.languageName,
    this.totalEpisodes,
    this.totalReviews,
    this.avgReviews,
    this.isBookmark,
    this.isBuy,
    this.name,
    this.image,
    this.sortOrder,
    this.fullMagazine,
    this.totalRead,
    this.isAuthor,
    this.categoryIds,
    this.userName,
    this.firstName,
    this.lastName,
    this.email,
    this.mobileNumber,
    this.type,
    this.address,
    this.walletAmount,
    this.deviceType,
    this.deviceToken,
    this.fullNovel,
    this.totalChapters,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
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
        categoryName: json["category_name"],
        languageName: json["language_name"],
        totalEpisodes: json["total_episodes"],
        totalReviews: _parseInt(json["total_reviews"]),
        avgReviews: _parseInt(json["avg_reviews"]),
        isBookmark: _parseInt(json["is_bookmark"]),
        isBuy: _parseInt(json["is_buy"]),
        name: json["name"],
        image: json["image"],
        sortOrder: json["sort_order"],
        fullMagazine: json["full_magazine"],
        totalRead: json["total_read"],
        isAuthor: _parseInt(json["is_author"]),
        categoryIds: json["category_ids"],
        userName: json["user_name"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        mobileNumber: json["mobile_number"],
        type: _parseInt(json["type"]),
        address: json["address"],
        walletAmount: _parseInt(json["wallet_amount"]),
        deviceType: _parseInt(json["device_type"]),
        deviceToken: json["device_token"],
        fullNovel: json["full_novel"],
        totalChapters: json["total_chapters"],
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
        "full_audio": fullAudio,
        "total_played": totalPlayed,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "author_name": authorName,
        "category_name": categoryName,
        "language_name": languageName,
        "total_episodes": totalEpisodes,
        "total_reviews": totalReviews,
        "avg_reviews": avgReviews,
        "is_bookmark": isBookmark,
        "is_buy": isBuy,
        "name": name,
        "image": image,
        "sort_order": sortOrder,
        "full_magazine": fullMagazine,
        "total_read": totalRead,
        "is_author": isAuthor,
        "category_ids": categoryIds,
        "user_name": userName,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "mobile_number": mobileNumber,
        "type": type,
        "address": address,
        "wallet_amount": walletAmount,
        "device_type": deviceType,
        "device_token": deviceToken,
        "full_novel": fullNovel,
        "total_chapters": totalChapters,
      };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

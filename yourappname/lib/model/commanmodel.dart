import 'dart:convert';

CommonModel commonModelFromJson(String str) =>
    CommonModel.fromJson(json.decode(str));
String commonModelToJson(CommonModel data) => json.encode(data.toJson());

class CommonModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  CommonModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory CommonModel.fromJson(Map<String, dynamic> json) => CommonModel(
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
  String? fullAudio; // for AudioBook
  String? fullNovel; // for Book
  String? fullMagazine; // for Magazine
  int? totalPlayed; // AudioBook
  int? totalRead; // Book/Magazine
  int? totalEpisodes; // AudioBook
  int? totalChapters; // Book
  int? totalReviews;
  dynamic avgReviews;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? authorName;
  String? categoryName;
  String? languageName;
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
    this.fullAudio,
    this.fullNovel,
    this.fullMagazine,
    this.totalPlayed,
    this.totalRead,
    this.totalEpisodes,
    this.totalChapters,
    this.totalReviews,
    this.avgReviews,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.authorName,
    this.categoryName,
    this.languageName,
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
        fullAudio: json["full_audio"],
        fullNovel: json["full_novel"],
        fullMagazine: json["full_magazine"],
        totalPlayed: json["total_played"],
        totalRead: json["total_read"],
        totalEpisodes: json["total_episodes"],
        totalChapters: json["total_chapters"],
        totalReviews: _parseInt(json["total_reviews"]),
        avgReviews: _parseInt(json["avg_reviews"]),
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        authorName: json["author_name"],
        categoryName: json["category_name"],
        languageName: json["language_name"],
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
        "full_audio": fullAudio,
        "full_novel": fullNovel,
        "full_magazine": fullMagazine,
        "total_played": totalPlayed,
        "total_read": totalRead,
        "total_episodes": totalEpisodes,
        "total_chapters": totalChapters,
        "total_reviews": totalReviews,
        "avg_reviews": avgReviews,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "author_name": authorName,
        "category_name": categoryName,
        "language_name": languageName,
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

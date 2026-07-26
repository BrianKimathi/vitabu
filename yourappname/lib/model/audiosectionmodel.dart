// To parse this JSON data, do
//
//     final audioSectionModel = audioSectionModelFromJson(jsonString);

import 'dart:convert';

AudioSectionModel audioSectionModelFromJson(String str) => AudioSectionModel.fromJson(json.decode(str));

String audioSectionModelToJson(AudioSectionModel data) => json.encode(data.toJson());

class AudioSectionModel {
    int? status;
    String? message;
    List<Result>? result;
    int? totalRows;
    int? totalPage;
    int? currentPage;
    bool? morePage;

    AudioSectionModel({
        this.status,
        this.message,
        this.result,
        this.totalRows,
        this.totalPage,
        this.currentPage,
        this.morePage,
    });

    factory AudioSectionModel.fromJson(Map<String, dynamic> json) => AudioSectionModel(
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
    int? sectionType;
    int? contentType;
    String? title;
    String? shortTitle;
    int? categoryId;
    int? languageId;
    int? authorId;
    int? orderByView;
    int? orderByUpload;
    String? screenLayout;
    int? noOfContent;
    int? viewAll;
    int? sortable;
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
        this.categoryId,
        this.languageId,
        this.authorId,
        this.orderByView,
        this.orderByUpload,
        this.screenLayout,
        this.noOfContent,
        this.viewAll,
        this.sortable,
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
        categoryId: _parseInt(json["category_id"]),
        languageId: json["language_id"],
        authorId: _parseInt(json["author_id"]),
        orderByView: json["order_by_view"],
        orderByUpload: json["order_by_upload"],
        screenLayout: json["screen_layout"],
        noOfContent: json["no_of_content"],
        viewAll: json["view_all"],
        sortable: json["sortable"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "section_type": sectionType,
        "content_type": contentType,
        "title": title,
        "short_title": shortTitle,
        "category_id": categoryId,
        "language_id": languageId,
        "author_id": authorId,
        "order_by_view": orderByView,
        "order_by_upload": orderByUpload,
        "screen_layout": screenLayout,
        "no_of_content": noOfContent,
        "view_all": viewAll,
        "sortable": sortable,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
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
    String? title;
    int? userId;
    int? categoryId;
    int? languageId;
    int? isPaid;
    int? price;
    String? description;
    String? portraitImg;
    String? landscapeImg;
    int? readCount;
    String? download;
    int? status;
    String? createdAt;
    String? updatedAt;
    String? categoryName;
    String? languageName;
    String? authorName;
    int? totalEpisode;
    String? name;
    String? image;
    String? firebaseId;
    String? userName;
    String? fullName;
    String? email;
    String? mobileNumber;
    String? address;
    int? walletCoin;
    int? voucherBalance;
    String? facebookUrl;
    String? instragramUrl;
    int? deviceType;
    String? deviceToken;
    int? isAuthor;
    int? type;

    Datum({
        this.id,
        this.title,
        this.userId,
        this.categoryId,
        this.languageId,
        this.isPaid,
        this.price,
        this.description,
        this.portraitImg,
        this.landscapeImg,
        this.readCount,
        this.download,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.categoryName,
        this.languageName,
        this.authorName,
        this.totalEpisode,
        this.name,
        this.image,
        this.firebaseId,
        this.userName,
        this.fullName,
        this.email,
        this.mobileNumber,
        this.address,
        this.walletCoin,
        this.voucherBalance,
        this.facebookUrl,
        this.instragramUrl,
        this.deviceType,
        this.deviceToken,
        this.isAuthor,
        this.type,
    });

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: _parseInt(json["id"]),
        title: json["title"],
        userId: json["user_id"],
        categoryId: _parseInt(json["category_id"]),
        languageId: json["language_id"],
        isPaid: json["is_paid"],
        price: _parseInt(json["price"]),
        description: json["description"],
        portraitImg: json["portrait_img"],
        landscapeImg: json["landscape_img"],
        readCount: json["read_count"],
        download: json["download"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        categoryName: json["category_name"],
        languageName: json["language_name"],
        authorName: json["author_name"],
        totalEpisode: _parseInt(json["total_episode"]),
        name: json["name"],
        image: json["image"],
        firebaseId: json["firebase_id"],
        userName: json["user_name"],
        fullName: json["full_name"],
        email: json["email"],
        mobileNumber: json["mobile_number"],
        address: json["address"],
        walletCoin: json["wallet_coin"],
        voucherBalance: json["voucher_balance"],
        facebookUrl: json["facebook_url"],
        instragramUrl: json["instragram_url"],
        deviceType: _parseInt(json["device_type"]),
        deviceToken: json["device_token"],
        isAuthor: _parseInt(json["is_author"]),
        type: _parseInt(json["type"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "user_id": userId,
        "category_id": categoryId,
        "language_id": languageId,
        "is_paid": isPaid,
        "price": price,
        "description": description,
        "portrait_img": portraitImg,
        "landscape_img": landscapeImg,
        "read_count": readCount,
        "download": download,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "category_name": categoryName,
        "language_name": languageName,
        "author_name": authorName,
        "total_episode": totalEpisode,
        "name": name,
        "image": image,
        "firebase_id": firebaseId,
        "user_name": userName,
        "full_name": fullName,
        "email": email,
        "mobile_number": mobileNumber,
        "address": address,
        "wallet_coin": walletCoin,
        "voucher_balance": voucherBalance,
        "facebook_url": facebookUrl,
        "instragram_url": instragramUrl,
        "device_type": deviceType,
        "device_token": deviceToken,
        "is_author": isAuthor,
        "type": type,
    };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

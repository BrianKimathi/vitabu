// To parse this JSON data, do
//
//     final atherProfileModel = atherProfileModelFromJson(jsonString);

import 'dart:convert';

AtherProfileModel atherProfileModelFromJson(String str) =>
    AtherProfileModel.fromJson(json.decode(str));

String atherProfileModelToJson(AtherProfileModel data) =>
    json.encode(data.toJson());

class AtherProfileModel {
  int? status;
  String? message;
  List<Result>? result;

  AtherProfileModel({
    this.status,
    this.message,
    this.result,
  });

  factory AtherProfileModel.fromJson(Map<String, dynamic> json) =>
      AtherProfileModel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(
                json["result"].map((x) => Result.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
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
  String? firebaseId;
  String? userName;
  String? fullName;
  String? email;
  String? mobileNumber;
  String? address;
  String? description;
  String? image;
  int? walletCoin;
  int? voucherBalance;
  String? facebookUrl;
  String? instragramUrl;
  int? deviceType;
  String? deviceToken;
  int? isAuthor;
  int? type;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? avgRating;
  int? isFollow;
  int? following;
  int? followers;
  Book? book;
  Magazine? magazine;

  Result({
    this.id,
    this.firebaseId,
    this.userName,
    this.fullName,
    this.email,
    this.mobileNumber,
    this.address,
    this.description,
    this.image,
    this.walletCoin,
    this.voucherBalance,
    this.facebookUrl,
    this.instragramUrl,
    this.deviceType,
    this.deviceToken,
    this.isAuthor,
    this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.avgRating,
    this.isFollow,
    this.following,
    this.followers,
    this.book,
    this.magazine,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        firebaseId: json["firebase_id"],
        userName: json["user_name"],
        fullName: json["full_name"],
        email: json["email"],
        mobileNumber: json["mobile_number"],
        address: json["address"],
        description: json["description"],
        image: json["image"],
        walletCoin: json["wallet_coin"],
        voucherBalance: json["voucher_balance"],
        facebookUrl: json["facebook_url"],
        instragramUrl: json["instragram_url"],
        deviceType: _parseInt(json["device_type"]),
        deviceToken: json["device_token"],
        isAuthor: _parseInt(json["is_author"]),
        type: _parseInt(json["type"]),
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        avgRating: json["avg_rating"],
        isFollow: json["is_follow"],
        following: json["following"],
        followers: json["followers"],
        book: Book.fromJson(json["book"]),
        magazine: Magazine.fromJson(json["magazine"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firebase_id": firebaseId,
        "user_name": userName,
        "full_name": fullName,
        "email": email,
        "mobile_number": mobileNumber,
        "address": address,
        "description": description,
        "image": image,
        "wallet_coin": walletCoin,
        "voucher_balance": voucherBalance,
        "facebook_url": facebookUrl,
        "instragram_url": instragramUrl,
        "device_type": deviceType,
        "device_token": deviceToken,
        "is_author": isAuthor,
        "type": type,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "avg_rating": avgRating,
        "is_follow": isFollow,
        "following": following,
        "followers": followers,
        "book": book?.toJson(),
        "magazine": magazine?.toJson(),
      };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

class Book {
  int? readCount;
  int? download;
  int? totalBook;

  Book({
    this.readCount,
    this.download,
    this.totalBook,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        readCount: json["read_count"],
        download: json["download"],
        totalBook: json["total_book"],
      );

  Map<String, dynamic> toJson() => {
        "read_count": readCount,
        "download": download,
        "total_book": totalBook,
      };
}

class Magazine {
  int? readCount;
  int? download;
  int? totalMagazine;

  Magazine({
    this.readCount,
    this.download,
    this.totalMagazine,
  });

  factory Magazine.fromJson(Map<String, dynamic> json) => Magazine(
        readCount: json["read_count"],
        download: json["download"],
        totalMagazine: json["total_magazine"],
      );

  Map<String, dynamic> toJson() => {
        "read_count": readCount,
        "download": download,
        "total_magazine": totalMagazine,
      };
}

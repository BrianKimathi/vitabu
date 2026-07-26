// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
    int? status;
    String? message;
    List<Result>? result;

    UserModel({
        this.status,
        this.message,
        this.result,
    });

    factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: json["result"] == null ? [] : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
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
    int? isAuthor;
    String? categoryIds;
    String? userName;
    String? firstName;
    String? lastName;
    String? email;
    String? mobileNumber;
    String? image;
    int? type;
    String? address;
    String? description;
    String? walletAmount;
    int? deviceType;
    String? deviceToken;
    int? status;
    String? createdAt;
    String? updatedAt;
    String? categoryName;
    int? totalAudioBooks;
    int? totalNovels;
    int? totalMagazines;
    String? bankName;
    String? bankHolderName;
    String? accountNo;
    String? ifscCode;
    int? isSubscription;
    String? planName;
    int? planPrice;
    String? planImage;

    Result({
        this.id,
        this.isAuthor,
        this.categoryIds,
        this.userName,
        this.firstName,
        this.lastName,
        this.email,
        this.mobileNumber,
        this.image,
        this.type,
        this.address,
        this.description,
        this.walletAmount,
        this.deviceType,
        this.deviceToken,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.categoryName,
        this.totalAudioBooks,
        this.totalNovels,
        this.totalMagazines,
        this.bankName,
        this.bankHolderName,
        this.accountNo,
        this.ifscCode,
        this.isSubscription,
        this.planName,
        this.planPrice,
        this.planImage,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        isAuthor: _parseInt(json["is_author"]),
        categoryIds: json["category_ids"],
        userName: json["user_name"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        email: json["email"],
        mobileNumber: json["mobile_number"],
        image: json["image"],
        type: _parseInt(json["type"]),
        address: json["address"],
        description: json["description"],
        walletAmount: json["wallet_amount"]?.toString(),
        deviceType: _parseInt(json["device_type"]),
        deviceToken: json["device_token"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        categoryName: json["category_name"],
        totalAudioBooks: json["total_audio_books"],
        totalNovels: json["total_novels"],
        totalMagazines: json["total_magazines"],
        bankName: json["bank_name"],
        bankHolderName: json["bank_holder_name"],
        accountNo: json["account_no"],
        ifscCode: json["ifsc_code"],
        isSubscription: _parseInt(json["is_subscription"]),
        planName: json["plan_name"],
        planPrice: json["plan_price"],
        planImage: json["plan_image"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "is_author": isAuthor,
        "category_ids": categoryIds,
        "user_name": userName,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "mobile_number": mobileNumber,
        "image": image,
        "type": type,
        "address": address,
        "description": description,
        "wallet_amount": walletAmount,
        "device_type": deviceType,
        "device_token": deviceToken,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "category_name": categoryName,
        "total_audio_books": totalAudioBooks,
        "total_novels": totalNovels,
        "total_magazines": totalMagazines,
        "bank_name": bankName,
        "bank_holder_name": bankHolderName,
        "account_no": accountNo,
        "ifsc_code": ifscCode,
        "is_subscription": isSubscription,
        "plan_name": planName,
        "plan_price": planPrice,
        "plan_image": planImage,
    };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

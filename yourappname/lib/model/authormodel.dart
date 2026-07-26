// To parse this JSON data, do
//
//     final authorModel = authorModelFromJson(jsonString);

import 'dart:convert';

AuthorModel authorModelFromJson(String str) => AuthorModel.fromJson(json.decode(str));

String authorModelToJson(AuthorModel data) => json.encode(data.toJson());

class AuthorModel {
    int? status;
    String? message;
    List<Result>? result;
    int? totalRows;
    int? totalPage;
    int? currentPage;
    bool? morePage;

    AuthorModel({
        this.status,
        this.message,
        this.result,
        this.totalRows,
        this.totalPage,
        this.currentPage,
        this.morePage,
    });

    factory AuthorModel.fromJson(Map<String, dynamic> json) => AuthorModel(
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
    int? walletAmount;
    int? deviceType;
    String? deviceToken;
    int? status;
    String? createdAt;
    String? updatedAt;

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
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        isAuthor: _parseInt(json["is_author"]),
        categoryIds: json["category_ids"]?.toString(),
        userName: json["user_name"]?.toString(),
        firstName: json["first_name"]?.toString(),
        lastName: json["last_name"]?.toString(),
        email: json["email"]?.toString(),
        mobileNumber: json["mobile_number"]?.toString(),
        image: json["image"]?.toString(),
        type: _parseInt(json["type"]),
        address: json["address"]?.toString(),
        description: json["description"]?.toString(),
        walletAmount: _parseInt(json["wallet_amount"]),
        deviceType: _parseInt(json["device_type"]),
        deviceToken: json["device_token"]?.toString(),
        status: _parseInt(json["status"]),
        createdAt: json["created_at"]?.toString(),
        updatedAt: json["updated_at"]?.toString(),
    );

    static int? _parseInt(dynamic value) {
        if (value == null) return null;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) return int.tryParse(value);
        return null;
    }

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
    };
}

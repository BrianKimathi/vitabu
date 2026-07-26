// To parse this JSON data, do
//
//     final packageModel = packageModelFromJson(jsonString);

import 'dart:convert';

PackageModel packageModelFromJson(String str) => PackageModel.fromJson(json.decode(str));

String packageModelToJson(PackageModel data) => json.encode(data.toJson());

class PackageModel {
    int? status;
    String? message;
    List<Result>? result;
    int? totalRows;
    int? totalPage;
    int? currentPage;
    bool? morePage;

    PackageModel({
        this.status,
        this.message,
        this.result,
        this.totalRows,
        this.totalPage,
        this.currentPage,
        this.morePage,
    });

    factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
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
    String? name;
    String? type;
    int? time;
    int? price;
    String? accessType;
    int? cancelAnytime;
    int? autoRenew;
    String? image;
    int? status;
    String? createdAt;
    String? updatedAt;
    int? isBuy;

    Result({
        this.id,
        this.name,
        this.type,
        this.time,
        this.price,
        this.accessType,
        this.cancelAnytime,
        this.autoRenew,
        this.image,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.isBuy,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        name: json["name"],
        type: json["type"]?.toString(),
        time: json["time"],
        price: _parseInt(json["price"]),
        accessType: json["access_type"]?.toString(),
        cancelAnytime: json["cancel_anytime"],
        autoRenew: json["auto_renew"],
        image: json["image"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        isBuy: _parseInt(json["is_buy"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "time": time,
        "price": price,
        "access_type": accessType,
        "cancel_anytime": cancelAnytime,
        "auto_renew": autoRenew,
        "image": image,
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

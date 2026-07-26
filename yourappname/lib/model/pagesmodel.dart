// To parse this JSON data, do
//
//     final pagesModel = pagesModelFromJson(jsonString);

import 'dart:convert';

PagesModel pagesModelFromJson(String str) => PagesModel.fromJson(json.decode(str));

String pagesModelToJson(PagesModel data) => json.encode(data.toJson());

class PagesModel {
    int? status;
    String? message;
    List<Result>? result;

    PagesModel({
        this.status,
        this.message,
        this.result,
    });

    factory PagesModel.fromJson(Map<String, dynamic> json) => PagesModel(
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
    String? title;
    String? url;
    String? icon;

    Result({
        this.title,
        this.url,
        this.icon,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        title: json["title"],
        url: json["url"],
        icon: json["icon"],
    );

    Map<String, dynamic> toJson() => {
        "title": title,
        "url": url,
        "icon": icon,
    };
}

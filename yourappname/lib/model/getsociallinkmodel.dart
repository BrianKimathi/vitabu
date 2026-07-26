// To parse this JSON data, do
//
//     final getsociallinkmodel = getsociallinkmodelFromJson(jsonString);

import 'dart:convert';

Getsociallinkmodel getsociallinkmodelFromJson(String str) => Getsociallinkmodel.fromJson(json.decode(str));

String getsociallinkmodelToJson(Getsociallinkmodel data) => json.encode(data.toJson());

class Getsociallinkmodel {
    int? status;
    String? message;
    List<Result>? result;

    Getsociallinkmodel({
        this.status,
        this.message,
        this.result,
    });

    factory Getsociallinkmodel.fromJson(Map<String, dynamic> json) => Getsociallinkmodel(
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
    String? name;
    String? image;
    String? url;
    int? status;
    String? createdAt;
    String? updatedAt;

    Result({
        this.id,
        this.name,
        this.image,
        this.url,
        this.status,
        this.createdAt,
        this.updatedAt,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        name: json["name"],
        image: json["image"],
        url: json["url"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "url": url,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

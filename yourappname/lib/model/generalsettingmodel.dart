import 'dart:convert';

class Generalsettingmodel {
  int? status;
  String? message;
  List<Result>? result;

  Generalsettingmodel({
    this.status,
    this.message,
    this.result,
  });

  factory Generalsettingmodel.fromRawJson(String str) =>
      Generalsettingmodel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Generalsettingmodel.fromJson(Map<String, dynamic> json) =>
      Generalsettingmodel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(
                json["result"]?.map((x) => Result.fromJson(x)) ?? []),
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
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  Result({
    this.id,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromRawJson(String str) => Result.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        key: json["key"],
        value: json["value"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "value": value,
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
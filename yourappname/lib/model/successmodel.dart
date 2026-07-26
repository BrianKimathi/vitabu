// To parse this JSON data, do
//
//     final successModel = successModelFromJson(jsonString);

import 'dart:convert';

SuccessModel successModelFromJson(String str) =>
    SuccessModel.fromJson(json.decode(str));

String successModelToJson(SuccessModel data) => json.encode(data.toJson());

class SuccessModel {
  int? status;
  String? message;
  dynamic result; // ✅ changed from List<dynamic>? to dynamic

  SuccessModel({
    this.status,
    this.message,
    this.result,
  });

  factory SuccessModel.fromJson(Map<String, dynamic> json) {
    final res = json["result"];

    return SuccessModel(
      status: _parseInt(json["status"]),
      message: json["message"],
      result: (res is List)
          ? List<dynamic>.from(res.map((x) => x))
          : res, // Keep it as int, string, or map directly
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        // ✅ Handle null or list safely
        "result": (result is List)
            ? List<dynamic>.from(result.map((x) => x))
            : result,
      };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

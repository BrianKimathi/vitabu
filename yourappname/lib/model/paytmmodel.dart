// To parse this JSON data, do
// final payTmModel = payTmModelFromJson(jsonString);

import 'dart:convert';

PayTmModel payTmModelFromJson(String str) =>
    PayTmModel.fromJson(json.decode(str));

String payTmModelToJson(PayTmModel data) => json.encode(data.toJson());

class PayTmModel {
  PayTmModel({
    this.status,
    this.message,
    this.result,
  });

  int? status;
  String? message;
  Result? result;

  factory PayTmModel.fromJson(Map<String, dynamic> json) => PayTmModel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result?.toJson() ?? {},
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
  Result({
    required this.paytmChecksum,
    required this.verifySignature,
  });

  String? paytmChecksum;
  bool? verifySignature;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        paytmChecksum: json["paytmChecksum"],
        verifySignature: json["verifySignature"],
      );

  Map<String, dynamic> toJson() => {
        "paytmChecksum": paytmChecksum,
        "verifySignature": verifySignature,
      };
}

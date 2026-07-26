// To parse this JSON data, do
//
//     final addtransectionModel = addtransectionModelFromJson(jsonString);

import 'dart:convert';

AddtransectionModel addtransectionModelFromJson(String str) =>
    AddtransectionModel.fromJson(json.decode(str));

String addtransectionModelToJson(AddtransectionModel data) =>
    json.encode(data.toJson());

class AddtransectionModel {
  int? status;
  String? message;
  List<dynamic>? result;

  AddtransectionModel({
    this.status,
    this.message,
    this.result,
  });

  factory AddtransectionModel.fromJson(Map<String, dynamic> json) =>
      AddtransectionModel(
        status: _parseInt(json["status"]),
        message: json["message"],
        result: List<dynamic>.from(json["result"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result!.map((x) => x)),
      };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

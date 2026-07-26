// To parse this JSON data, do
//
//     final userplanhistorymodel = userplanhistorymodelFromJson(jsonString);

import 'dart:convert';

Userplanhistorymodel userplanhistorymodelFromJson(String str) => Userplanhistorymodel.fromJson(json.decode(str));

String userplanhistorymodelToJson(Userplanhistorymodel data) => json.encode(data.toJson());

class Userplanhistorymodel {
    int? status;
    String? message;
    List<Result>? result;
    int? totalRows;
    int? totalPage;
    int? currentPage;
    bool? morePage;

    Userplanhistorymodel({
        this.status,
        this.message,
        this.result,
        this.totalRows,
        this.totalPage,
        this.currentPage,
        this.morePage,
    });

    factory Userplanhistorymodel.fromJson(Map<String, dynamic> json) => Userplanhistorymodel(
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
    String? couponCode;
    int? userId;
    int? planId;
    String? transactionId;
    int? price;
    int? totalTax;
    String? tax;
    String? paymentMethod;
    String? startsAt;
    String? expiryDate;
    int? status;
    String? createdAt;
    String? updatedAt;
    String? planName;
    String? planDuration;
    String? buyDate;

    Result({
        this.id,
        this.couponCode,
        this.userId,
        this.planId,
        this.transactionId,
        this.price,
        this.totalTax,
        this.tax,
        this.paymentMethod,
        this.startsAt,
        this.expiryDate,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.planName,
        this.planDuration,
        this.buyDate,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: _parseInt(json["id"]),
        couponCode: json["coupon_code"],
        userId: json["user_id"],
        planId: json["plan_id"],
        transactionId: json["transaction_id"],
        price: _parseInt(json["price"]),
        totalTax: json["total_tax"],
        tax: json["tax"],
        paymentMethod: json["payment_method"],
        startsAt: json["starts_at"],
        expiryDate: json["expiry_date"],
        status: _parseInt(json["status"]),
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        planName: json["plan_name"],
        planDuration: json["plan_duration"],
        buyDate: json["buy_date"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "coupon_code": couponCode,
        "user_id": userId,
        "plan_id": planId,
        "transaction_id": transactionId,
        "price": price,
        "total_tax": totalTax,
        "tax": tax,
        "payment_method": paymentMethod,
        "starts_at": startsAt,
        "expiry_date": expiryDate,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "plan_name": planName,
        "plan_duration": planDuration,
        "buy_date": buyDate,
    };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

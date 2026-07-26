// To parse this JSON data, do
//
//     final usersubscriptionmodel = usersubscriptionmodelFromJson(jsonString);

import 'dart:convert';

Usersubscriptionmodel usersubscriptionmodelFromJson(String str) => Usersubscriptionmodel.fromJson(json.decode(str));

String usersubscriptionmodelToJson(Usersubscriptionmodel data) => json.encode(data.toJson());

class Usersubscriptionmodel {
    int? status;
    String? message;
    List<Result>? result;

    Usersubscriptionmodel({
        this.status,
        this.message,
        this.result,
    });

    factory Usersubscriptionmodel.fromJson(Map<String, dynamic> json) => Usersubscriptionmodel(
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
    Plan? activePlan;
    Plan? upcomingPlan;

    Result({
        this.activePlan,
        this.upcomingPlan,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        activePlan: json["active_plan"] == null ? null : Plan.fromJson(json["active_plan"]),
        upcomingPlan: json["upcoming_plan"] == null ? null : Plan.fromJson(json["upcoming_plan"]),
    );

    Map<String, dynamic> toJson() => {
        "active_plan": activePlan?.toJson(),
        "upcoming_plan": upcomingPlan?.toJson(),
    };
}

class Plan {
    int? id;
    String? couponCode;
    int? userId;
    int? planId;
    int? autoRenew;
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
    String? buyDate;
    String? planName;
    String? planImage;
    String? planType;
    int? planTime;
    int? planPrice;
    int? cancelAnytime;

    Plan({
        this.id,
        this.couponCode,
        this.userId,
        this.planId,
        this.autoRenew,
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
        this.buyDate,
        this.planName,
        this.planImage,
        this.planType,
        this.planTime,
        this.planPrice,
        this.cancelAnytime,
    });

    factory Plan.fromJson(Map<String, dynamic> json) => Plan(
        id: _parseInt(json["id"]),
        couponCode: json["coupon_code"],
        userId: json["user_id"],
        planId: json["plan_id"],
        autoRenew: json["auto_renew"],
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
        buyDate: json["buy_date"],
        planName: json["plan_name"],
        planImage: json["plan_image"],
        planType: json["plan_type"],
        planTime: json["plan_time"],
        planPrice: json["plan_price"],
        cancelAnytime: json["cancel_anytime"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "coupon_code": couponCode,
        "user_id": userId,
        "plan_id": planId,
        "auto_renew": autoRenew,
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
        "buy_date": buyDate,
        "plan_name": planName,
        "plan_image": planImage,
        "plan_type": planType,
        "plan_time": planTime,
        "plan_price": planPrice,
        "cancel_anytime": cancelAnytime,
    };
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

}

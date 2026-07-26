import 'package:yourappname/model/couponmodel.dart';
import 'package:yourappname/model/paytmmodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/model/paymentoptionmodel.dart';
import 'package:yourappname/webservice/apiservice.dart';

class PaymentOptionProvider extends ChangeNotifier {
  PaymentOptionModel paymentOptionModel = PaymentOptionModel();
  SuccessModel successModel = SuccessModel();
  PayTmModel payTmModel = PayTmModel();
  CouponModel couponModel = CouponModel();

  bool loading = false,
      payLoading = false,
      couponLoading = false,
      paymentloading = false;
  String? currentPayment = "", finalAmount = "";

  Future<void> getPayment() async {
    paymentloading = true;
    paymentOptionModel = await ApiService().paymentResponse();
    paymentloading = false;
    notifyListeners();
  }

  Future<void> changestatus(String transactionId, int status) async {
    successModel =
        await ApiService().addchangestransactionstatus(transactionId, status);
    printLog("CHANGE STATUS RESPONSE ===> ${successModel.toJson()}");
    notifyListeners();
  }

  Future<void> addTransaction(
    authorId,
    contentType,
    contentId,
    price,
    subContentId,
    transactionId, {
    String? paymentMethod,
    String? couponCode,
  }) async {
    successModel = await ApiService().addTransactionResponse(
      authorId,
      contentType,
      contentId,
      price,
      subContentId,
      transactionId,
      paymentMethod: paymentMethod,
      couponCode: couponCode,
    );
    printLog("TRANSACTION RESPONSE ===> ${successModel.toJson()}");

    notifyListeners();
  }

  setFinalAmount(String? amount) {
    finalAmount = amount;
    debugPrint("setFinalAmount finalAmount :==> $finalAmount");
    notifyListeners();
  }

  Future<void> getPaytmToken(merchantID, orderId, custmoreID, channelID,
      txnAmount, website, callbackURL, industryTypeID) async {
    loading = true;
    payTmModel = await ApiService().getPaytmToken(merchantID, orderId,
        custmoreID, channelID, txnAmount, website, callbackURL, industryTypeID);
    loading = false;
    notifyListeners();
  }

  Future<void> buyTransactionForPackage(
    planid,
    price,
    couponcode,
    totaltax,
    tax,
    transactionid,
    paymentmethod,
  ) async {
    loading = true;
    successModel = await ApiService().buyplanapi(
      planid: planid,
      price: price,
      couponcode: couponcode,
      totaltax: totaltax,
      tax: tax,
      transactionid: transactionid,
      paymentmethod: paymentmethod,
    );
    loading = false;
    notifyListeners();
  }

  Future<void> addTransactionForChapter(autherid, amount, bookChapterId) async {
    loading = true;
    successModel = await ApiService()
        .addChapterTransection(autherid, amount, bookChapterId);
    loading = false;
    notifyListeners();
  }

  Future<void> addTransactionForBook(autherid, amount, bookid) async {
    loading = true;
    successModel =
        await ApiService().addBookTransection(autherid, amount, bookid);
    loading = false;
    notifyListeners();
  }

  Future<void> addTransactionForMagazine(autherid, amount, magazineid) async {
    loading = true;
    successModel =
        await ApiService().addMagazineTransection(autherid, amount, magazineid);
    loading = false;
    notifyListeners();
  }

  Future<void> addAmountToWallet(amount, transactionId, description) async {
    loading = true;
    successModel =
        await ApiService().addAmountWallet(amount, transactionId, description);
    loading = false;
    notifyListeners();
  }

  Future<void> applyPackageCouponCode(couponCode, packageId) async {
    couponLoading = true;
    couponModel = await ApiService().applyPackageCoupon(couponCode, packageId);
    couponLoading = false;
    notifyListeners();
  }

  setCurrentPayment(String? payment) {
    currentPayment = payment;
    notifyListeners();
  }

  clearProvider() {
    currentPayment = "";
    finalAmount = "";
    paymentOptionModel = PaymentOptionModel();
    successModel = SuccessModel();
  }
}

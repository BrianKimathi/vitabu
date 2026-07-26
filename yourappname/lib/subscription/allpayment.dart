// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:confetti/confetti.dart';
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/loadingoverlay.dart';
import 'package:yourappname/webpages/webhome.dart';
import 'package:yourappname/webwidget/footerweb.dart';
import 'package:yourappname/webwidget/webappbar.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:yourappname/provider/paymentoptionprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:flutterwave_standard_smart/core/flutterwave.dart';
import 'package:flutterwave_standard_smart/models/requests/customer.dart';
import 'package:flutterwave_standard_smart/models/requests/customizations.dart';
import 'package:flutterwave_standard_smart/models/responses/charge_response.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';


import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:intl/intl.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart' as paystack_sdk;
import 'package:provider/provider.dart';
import 'paystack_interop.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:uuid/uuid.dart';
const _indigo = Color(0xFF4E45B8);

final bool _kAutoConsume = Platform.isIOS || true;

class AllPayment extends StatefulWidget {
  final int issubscription;
  final String? itemId,
      price,
      itemTitle,
      autherid,
      contentType,
      subContentId,
      renewdate,
      subaccount;
  const AllPayment(
      {super.key,
      required this.itemId,
      required this.price,
      required this.itemTitle,
      this.subContentId,
      this.contentType,
      this.autherid,
      required this.issubscription,
      this.renewdate,
      this.subaccount});

  @override
  State<AllPayment> createState() => AllPaymentState();
}

class AllPaymentState extends State<AllPayment> {
  final couponController = TextEditingController();

  late PaymentOptionProvider paymentProvider;
  SharedPref sharedPref = SharedPref();
  String? userId, userName, userEmail, userMobileNo, paymentId;
  String? strCouponCode = "";
  bool isPaymentDone = false;

  late ConfettiController _confettiController;

  /* InApp Purchase */
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  late List<String> _kProductIds;
  final List<PurchaseDetails> _purchases = <PurchaseDetails>[];

  /* Razorpay */
  late Razorpay razorpay;

  /* Paytm */
  String paytmResult = "";

  /* Flutterwave */
  String selectedCurrency = "";
  bool isTestMode = true;

  /* Stripe */
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    printLog(
        "ContentIds => ${widget.itemId} : SubConetntIds => ${widget.subContentId}");
    paymentProvider =
        Provider.of<PaymentOptionProvider>(context, listen: false);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });

    if (!kIsWeb) {
      /* InApp Purchase */
      _kProductIds = <String>[widget.price ?? ""];
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _inAppPurchase.purchaseStream;
      _subscription =
          purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription?.cancel();
      }, onError: (Object error) {
        // handle error here.
        printLog("onError ============> ${error.toString()}");
        LoadingOverlay().hide(); // Stop Loading...
      });
      initStoreInfo();
    }

    /* Razorpay */
    // razorpay = Razorpay();
    super.initState();
  }

  String formatDate(DateTime date) {
    return DateFormat("MMMM dd, yyyy").format(date);
  }

  _getData() async {
    paymentProvider.getPayment();
    paymentProvider.setFinalAmount(widget.price ?? "");

    /* PaymentID */
    paymentId = Utils.generateRandomOrderID();
    printLog('paymentId =====================> $paymentId');

    userId = await sharedPref.read("userid");
    userName = await sharedPref.read("username");
    userEmail = await sharedPref.read("useremail");
    userMobileNo = await sharedPref.read("usermobile");
    printLog('getUserData userId ==> $userId');
    printLog('getUserData userName ==> $userName');
    printLog('getUserData userEmail ==> $userEmail');
    printLog('getUserData userMobileNo ==> $userMobileNo');
  }

  bool checkKeysAndContinue({
    required String isLive,
    required bool isBothKeyReq,
    required String liveKey1,
    required String liveKey2,
    required String testKey1,
    required String testKey2,
  }) {
    if (isLive == "1") {
      if (isBothKeyReq) {
        if (liveKey1 == "" || liveKey2 == "") {
          Utils.showSnackbar(context, "payment_not_processed", true);
          return false;
        }
      } else {
        if (liveKey1 == "") {
          Utils.showSnackbar(context, "payment_not_processed", true);
          return false;
        }
      }
      return true;
    } else {
      if (isBothKeyReq) {
        if (testKey1 == "" || testKey2 == "") {
          Utils.showSnackbar(context, "payment_not_processed", true);
          return false;
        }
      } else {
        if (testKey1 == "") {
          Utils.showSnackbar(context, "payment_not_processed", true);
          return false;
        }
      }
      return true;
    }
  }

  @override
  void dispose() {
    paymentProvider.clearProvider();
    _confettiController.dispose();

    if (!kIsWeb) {
      if (Platform.isIOS) {
        final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
            _inAppPurchase
                .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        iosPlatformAddition.setDelegate(null);
      }
      _subscription?.cancel();
    }
    couponController.dispose();
    super.dispose();
  }

  /* add_transaction && buy plan  API */

  Future<void> buyPlan() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    try {
      Utils.showProgress(context);

      if (widget.itemId == null || widget.price == null) {
        Utils.hideProgress(context);
        Utils.showSnackbar(context, "chooseplan", false);
        return;
      }

      await paymentProvider.buyTransactionForPackage(
        widget.itemId ?? "",
        widget.price ?? "",
        paymentId ?? "",
        '',
        '',
        paymentId,
        paymentProvider.currentPayment ?? "",
      );

      Utils.hideProgress(context);

      if (paymentProvider.successModel.status == 200) {
        final transactionId = paymentProvider.successModel.result?.toString();

        printLog("Buy Plan Transaction ID =====>>> $transactionId");

        isPaymentDone = true;
        await profileProvider.getProfile(Constant.userID);
        showSubscriptionSuccessDialog(context,
            planName: widget.itemTitle ?? "",
            renewDate: widget.renewdate ?? "");
      } else {
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
          context,
          paymentProvider.successModel.message ?? "payment_failed",
          false,
        );
      }
    } catch (e, s) {
      Utils.hideProgress(context);
      printLog("buyPlan error =====>>> $e");
      printLog("Stack =====>>> $s");

      if (!mounted) return;
      Utils.showSnackbar(context, "something_went_wrong", false);
    }
  }

  Future<void> addTransaction() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    try {
      Utils.showProgress(context);
      await paymentProvider.addTransaction(
        widget.autherid,
        widget.contentType ?? "",
        widget.itemId,
        paymentProvider.finalAmount,
        widget.subContentId,
        paymentId,
        paymentMethod: paymentProvider.currentPayment,
        couponCode: strCouponCode,
      );
      Utils.hideProgress(context);
      if (paymentProvider.successModel.status == 200) {
        final transactionId = paymentProvider.successModel.result?.toString();
        printLog("Transaction ID============>>>>: $transactionId");

        if (transactionId != null && transactionId.isNotEmpty) {
          await changeTransactionStatus(transactionId, 1);
        }
        Utils.showSnackbar(context, "payment_success", true);
        isPaymentDone = true;
        await profileProvider.getProfile(Constant.userID);
        Navigator.pop(context, true);
      } else {
        isPaymentDone = false;
        if (!mounted) return;
        Utils.showSnackbar(
          context,
          paymentProvider.successModel.message ?? "payment_failed",
          false,
        );
      }
    } catch (e, s) {
      Utils.hideProgress(context);
      printLog("addTransaction error============>>>>: $e");
      printLog("Stack: $s");
      if (!mounted) return;
      Utils.showSnackbar(context, "something_went_wrong", false);
    }
  }

  Future<void> changeTransactionStatus(String transactionId, int status) async {
    try {
      Utils.showProgress(context);

      await paymentProvider.changestatus(transactionId, status);

      Utils.hideProgress(context);

      if (paymentProvider.successModel.status == 200) {
        printLog(
            "Transaction status changed to ============>>>>: $status ============>>>>: successfully");
      } else {
        printLog(
            "Failed to update transaction============>>>>: ${paymentProvider.successModel.message}");
      }
    } catch (e) {
      Utils.hideProgress(context);
      printLog("changeTransactionStatus error============>>>>: $e");
    }
  }

  openPayment({required String pgName}) async {
    // if (kIsWeb) {
    //   Utils.showSnackbar(
    //     context,
    //     "This payment gateway is available on mobile app only",
    //     false,
    //   );
    //   return;
    // }

    printLog("finalAmount =============> ${paymentProvider.finalAmount}");

    if (paymentProvider.finalAmount != "0") {
      if (pgName == "demo") {
        if (widget.issubscription == 1) {
          await buyPlan();
        } else {
          await addTransaction();
        }
      } else if (pgName == "inapp") {
        _initInAppPurchase();
      } else if (pgName == "razorpay") {
        _initializeRazorpay();
      } else if (pgName == "Paytm") {
        _paytmInit();
      } else if (pgName == "flutterwave") {
        _flutterwaveInit();
      } else if (pgName == "stripe") {
        _stripeInit();
      } else if (pgName == "paystack") {
        _paystackInit();
      } else if (pgName == "cash") {
        Utils.showSnackbar(context, "cash_payment_msg", true);
      } else {
        if (widget.issubscription == 1) {
          await buyPlan();
        } else {
          Utils.showSnackbar(context, 'Oopsss.... Something went wrong', false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await onBackPressed(didPop);
      },
      child: kIsWeb ? _buildwebPage() : _buildPage(),
    );
  }

  Widget _buildPage() {
    return Scaffold(
      appBar: Utils.cusstomAppBar(
          context: context, name: "payment_details", multilanguage: true),
      body: _buildResponsivePage(),
    );
  }

  Widget _buildResponsivePage() {
    return Consumer<PaymentOptionProvider>(
      builder: (context, paymentProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Order Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [colorPrimary, colorPrimaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorPrimary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.issubscription == 1 ? "Subscription Plan" : "Book / Magazine Order",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "SECURE CHECKOUT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.itemTitle ?? "Vitabu Content",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${Constant.currencySymbol} ${paymentProvider.finalAmount}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Text(
                "Payment Method",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Pay securely with M-Pesa, Airtel Money, or Card via Paystack",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 20),

              /* Payment Options list */
              _buildPayments(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPayments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Consumer<PaymentOptionProvider>(
          builder: (context, paymentProvider, child) {
            if (paymentProvider.paymentloading) {
              return paymentShimmer();
            } else {
              if (paymentProvider.paymentOptionModel.status == 200 &&
                  (paymentProvider.paymentOptionModel.result != null)) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    children: [
                      if (Constant.isDemoMode)
                        _buildPGButton("demo", onTap: () async {
                          await paymentProvider.setCurrentPayment("demo");
                          openPayment(pgName: "demo");
                        }),

                      /* In-App purchase */
                      paymentProvider
                                  .paymentOptionModel.result?.inapppurchage !=
                              null
                          ? paymentProvider.paymentOptionModel.result
                                      ?.inapppurchage?.visibility ==
                                  "1"
                              ? _buildPGButton(
                                  'inapp',
                                  onTap: () async {
                                    await paymentProvider
                                        .setCurrentPayment("inapp");
                                    openPayment(pgName: "inapp");
                                  },
                                )
                              : const SizedBox.shrink()
                          : const SizedBox.shrink(),
                      const SizedBox(height: 5),

                      /* Paypal */
                      paymentProvider.paymentOptionModel.result?.paypal != null
                          ? paymentProvider.paymentOptionModel.result?.paypal
                                      ?.visibility ==
                                  "1"
                              ? _buildPGButton(
                                  "Paypal",
                                  onTap: () async {
                                    await paymentProvider
                                        .setCurrentPayment("paypal");
                                    openPayment(pgName: "paypal");
                                  },
                                )
                              : const SizedBox.shrink()
                          : const SizedBox.shrink(),
                      const SizedBox(height: 5),

                      /* Razorpay */
                      paymentProvider.paymentOptionModel.result?.razorpay !=
                              null
                          ? paymentProvider.paymentOptionModel.result?.razorpay
                                      ?.visibility ==
                                  "1"
                              ? _buildPGButton(
                                  "Razorpay",
                                  onTap: () async {
                                    await paymentProvider
                                        .setCurrentPayment("razorpay");
                                    openPayment(pgName: "razorpay");
                                  },
                                )
                              : const SizedBox.shrink()
                          : const SizedBox.shrink(),
                      const SizedBox(height: 5),

                      /* Paytm */
                      paymentProvider.paymentOptionModel.result?.paytm != null
                          ? paymentProvider.paymentOptionModel.result?.paytm
                                      ?.visibility ==
                                  "1"
                              ? _buildPGButton(
                                  "Paytm",
                                  onTap: () async {
                                    await paymentProvider
                                        .setCurrentPayment("paytm");
                                    openPayment(pgName: "paytm");
                                  },
                                )
                              : const SizedBox.shrink()
                          : const SizedBox.shrink(),
                      const SizedBox(height: 5),

                      /* Flutterwave */
                      paymentProvider.paymentOptionModel.result?.flutterwave !=
                              null
                          ? paymentProvider.paymentOptionModel.result
                                      ?.flutterwave?.visibility ==
                                  "1"
                              ? _buildPGButton(
                                  "Flutterwave",
                                  onTap: () async {
                                    await paymentProvider
                                        .setCurrentPayment("flutterwave");
                                    openPayment(pgName: "flutterwave");
                                  },
                                )
                              : const SizedBox.shrink()
                          : const SizedBox.shrink(),
                      const SizedBox(height: 5),

                      /* Stripe */
                      paymentProvider.paymentOptionModel.result?.stripe != null
                          ? paymentProvider.paymentOptionModel.result?.stripe
                                      ?.visibility ==
                                  "1"
                              ? _buildPGButton(
                                  "Stripe",
                                  onTap: () async {
                                    await paymentProvider
                                        .setCurrentPayment("stripe");
                                    openPayment(pgName: "stripe");
                                  },
                                )
                              : const SizedBox.shrink()
                          : const SizedBox.shrink(),
                      const SizedBox(height: 5),

                      /* Paystack */
                      paymentProvider.paymentOptionModel.result?.paystack != null
                          ? paymentProvider.paymentOptionModel.result?.paystack
                                      ?.visibility ==
                                  "1"
                              ? _buildPGButton(
                                  "Mpesa | Airtel Money | Paystack",
                                  onTap: () async {
                                    await paymentProvider
                                        .setCurrentPayment("paystack");
                                    openPayment(pgName: "paystack");
                                  },
                                )
                              : const SizedBox.shrink()
                          : const SizedBox.shrink(),
                      const SizedBox(height: 5),

                      /* PayUMoney */
                      paymentProvider.paymentOptionModel.result?.payumoney !=
                              null
                          ? paymentProvider.paymentOptionModel.result?.payumoney
                                      ?.visibility ==
                                  "1"
                              ? _buildPGButton(
                                  "PayU Money",
                                  onTap: () async {
                                    await paymentProvider
                                        .setCurrentPayment("payumoney");

                                    openPayment(pgName: "payumoney");
                                  },
                                )
                              : const SizedBox.shrink()
                          : const SizedBox.shrink(),
                    ],
                  ),
                );
              } else {
                return const NoData();
              }
            }
          },
        ),
        /* /* Payments */ */

        /* Cash */
        // paymentProvider.paymentoptionModel.result?.cash != null
        //     ? paymentProvider.paymentoptionModel.result?.cash?.visibility ==
        //             "1"
        //         ? Card(
        //             semanticContainer: true,
        //             clipBehavior: Clip.antiAliasWithSaveLayer,
        //             elevation: 5,
        //             color: lightBlack,
        //             shape: RoundedRectangleBorder(
        //               borderRadius: BorderRadius.circular(8),
        //             ),
        //             child: InkWell(
        //               borderRadius: BorderRadius.circular(8),
        //               onTap: () async {
        //                 await paymentProvider.setCurrentPayment("cash");
        //                 openPayment(pgName: "cash");
        //               },
        //               child: _buildPGButton("pg_cash.png", "Cash", 50, 50),
        //             ),
        //           )
        //         : const SizedBox.shrink()
        //     : const SizedBox.shrink(),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget paymentShimmer() {
    return ListView.builder(
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 30,
                    width: MediaQuery.of(context).size.width * 0.45,
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Container(
                    height: 20,
                    width: 70,
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Container(
                    height: 28,
                    width: 28,
                    decoration: const BoxDecoration(
                      color: white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showSubscriptionSuccessDialog(BuildContext context,
      {required String planName, required String renewDate}) {
    _confettiController.play();

    showDialog(
      barrierColor: Constant.isDarkMode ? appbarcolor : white,
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Constant.isDarkMode ? black : white,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 80),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color:
                    Constant.isDarkMode ? black : white.withOpacity( 0.7),
              )),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
            child: Container(
              decoration: BoxDecoration(
                color: Constant.isDarkMode ? graycolor : white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Constant.isDarkMode
                      ? transparent
                      : gray.withOpacity( 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: black.withOpacity( 0.7),
                    blurRadius: 25,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        color: Constant.isDarkMode ? _indigo : black,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 30,
                    child: MyImage(
                      imagePath: 'star.png',
                      height: 14,
                      width: 14,
                    ),
                  ),
                  Positioned(
                    top: 60,
                    right: 30,
                    child: MyImage(
                      imagePath: 'star.png',
                      height: 14,
                      width: 14,
                    ),
                  ),
                  ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    emissionFrequency: 0,
                    numberOfParticles: 200,
                    gravity: 0.2,
                    maxBlastForce: 30,
                    minBlastForce: 20,
                    shouldLoop: false,
                    colors: [
                      green.withOpacity( 0.6), // soft green
                      _indigo.withOpacity( 0.6), // mint / teal
                      yello.withOpacity( 0.6), // soft yellow
                      _indigo.withOpacity( 0.6), // coral / pinkish
                      _indigo.withOpacity( 0.6), // bluish gray
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MyImage(
                                imagePath: 'successfully.png',
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),

                              const SizedBox(height: 16),

                              MyText(
                                text: "subscription_activated",
                                fontsize: Dimens.text30Size,
                                fontwaight: FontWeight.w600,
                                multilanguage: true,
                                textalign: TextAlign.center,
                                fontstyle: FontStyle.normal,
                                isfont: 3,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                color: Constant.isDarkMode ? white : black,
                              ),

                              const SizedBox(height: 6),

                              MyText(
                                text: "subscription_activated_desc",
                                fontsize: Dimens.medium16TextSize,
                                fontwaight: FontWeight.w400,
                                multilanguage: true,
                                textalign: TextAlign.center,
                                color: Constant.isDarkMode ? white : black,
                                maxline: 2,
                              ),

                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: gray.withOpacity( 0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          text: "plan_type",
                                          fontsize: Dimens.smallTextSize,
                                          multilanguage: true,
                                          color: gray,
                                        ),
                                        MyText(
                                          text: planName,
                                          fontsize: Dimens.medium14TextSize,
                                          fontwaight: FontWeight.w600,
                                          multilanguage: false,
                                          color: Constant.isDarkMode
                                              ? white
                                              : black,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        MyText(
                                          text: "renews_on",
                                          fontsize: Dimens.smallTextSize,
                                          multilanguage: true,
                                          color: gray,
                                        ),
                                        MyText(
                                          text: renewDate,
                                          fontsize: Dimens.medium14TextSize,
                                          fontwaight: FontWeight.w600,
                                          multilanguage: false,
                                          color: Constant.isDarkMode
                                              ? white
                                              : black,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              /// START READING (SAME)
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _indigo,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    if (kIsWeb) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const WebHome()),
                                        (route) => false,
                                      );
                                    } else {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const Bottombar()),
                                        (route) => false,
                                      );
                                    }
                                  },
                                  child: Row(
                                    spacing: 5,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Iconify(
                                        Ic.round_menu_book,
                                        color: white,
                                        size: 20,
                                      ),
                                      MyText(
                                        fontstyle: FontStyle.normal,
                                        isfont: 2,
                                        textalign: TextAlign.center,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        text: "start_reading",
                                        fontsize: Dimens.medium15TextSize,
                                        fontwaight: FontWeight.w600,
                                        multilanguage: true,
                                        color: white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Constant.isDarkMode ? graycolor : white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      side: BorderSide(
                                        color: Constant.isDarkMode
                                            ? graycolor
                                            : gray.withOpacity( 0.5),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    _confettiController.stop();
                                    if (kIsWeb) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const WebHome()),
                                        (route) => false,
                                      );
                                    } else {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => const Bottombar()),
                                        (route) => false,
                                      );
                                    }
                                  },
                                  child: Row(
                                    spacing: 3,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Iconify(
                                        Ri.home_4_line,
                                        color: Constant.isDarkMode
                                            ? _indigo
                                            : black,
                                        size: 22,
                                      ),
                                      MyText(
                                        text: "go_home",
                                        fontstyle: FontStyle.normal,
                                        isfont: 3,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textalign: TextAlign.center,
                                        fontsize: Dimens.medium15TextSize,
                                        fontwaight: FontWeight.w600,
                                        multilanguage: true,
                                        color: Constant.isDarkMode
                                            ? _indigo
                                            : black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /* WEB */

  Widget _buildwebPage() {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final contentWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 20;

    return Material(
      child: WebAppBar(
        widget: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: contentWidth,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth <= 1000 ? 10 : 0),
                child: Column(
                  children: [
                    Utils.buildWebDetailsAppBar(
                        context: context,
                        title1: "payment_details",
                        isHome: false),
                    SizedBox(
                      height: 10,
                    ),
                    _buildResponsivePage(),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              FooterWeb(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebPayments() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
      margin: (MediaQuery.of(context).size.width > 800)
          ? const EdgeInsets.fromLTRB(100, 20, 100, 0)
          : const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyText(
            text: "payment_methods",
            fontsize: Dimens.medium16TextSize,
            fontsizeWeb: 17,
            maxline: 1,
            multilanguage: true,
            fontwaight: FontWeight.w600,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 5),
          MyText(
            text: "choose_a_payment_methods_to_pay",
            multilanguage: true,
            fontsize: Dimens.medium14TextSize,
            fontsizeWeb: 15,
            maxline: 2,
            fontwaight: FontWeight.w500,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 15),
          MyText(
            color: _indigo,
            text: "pay_with",
            multilanguage: true,
            fontsize: Dimens.medium16TextSize,
            fontsizeWeb: 16,
            maxline: 1,
            fontwaight: FontWeight.w700,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
          const SizedBox(height: 20),
          if (paymentProvider.paymentloading)
            const Card(
              color: white,
              elevation: 10,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CustomWidget.roundcorner(
                  height: 50,
                  width: double.infinity,
                ),
              ),
            )
          else if (paymentProvider.paymentOptionModel.status == 200 &&
              (paymentProvider.paymentOptionModel.result != null))
            Column(
              children: [
                /* Razorpay */
                paymentProvider.paymentOptionModel.result?.razorpay?.visibility ==
                        "1"
                    ? _buildPGButton(
                        "Razorpay",
                        onTap: () async {
                          await paymentProvider.setCurrentPayment("razorpay");
                          openPayment(pgName: "razorpay");
                        },
                      )
                    : const SizedBox.shrink(),
                const SizedBox(height: 5),
                /* Paystack */
                paymentProvider.paymentOptionModel.result?.paystack?.visibility ==
                        "1"
                    ? _buildPGButton(
                        "Mpesa | Airtel Money | Paystack",
                        onTap: () async {
                          await paymentProvider.setCurrentPayment("paystack");
                          openPayment(pgName: "paystack");
                        },
                      )
                    : const SizedBox.shrink(),
              ],
            )
          else
            const NoData(),
          if (Constant.isDemoMode)
            _buildPGButton("demo", onTap: () async {
              await paymentProvider.setCurrentPayment("demo");
              openPayment(pgName: "demo");
            }),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildPGButton(String pgName, {required Function() onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPaystack = pgName.toLowerCase().contains("paystack") || pgName.toLowerCase().contains("mpesa");

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isPaystack
                ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4))
                : (isDark ? const Color(0xFF1E1E2E) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPaystack
                  ? colorAccent
                  : (isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB)),
              width: isPaystack ? 1.8 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isPaystack
                    ? colorAccent.withOpacity(0.15)
                    : (isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04)),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isPaystack ? colorAccent : colorPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPaystack ? Icons.phone_android_rounded : Icons.payment_rounded,
                  color: isPaystack ? Colors.white : colorPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            isPaystack ? "M-Pesa / Mobile Money / Card" : pgName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        if (isPaystack) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorAccent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "RECOMMENDED",
                                maxLines: 1,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isPaystack ? "Instant payment via Paystack" : "Tap to complete transaction",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isPaystack ? colorAccent : (isDark ? Colors.grey[500] : Colors.grey[400]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ********* InApp purchase START ********* */
  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {});
      return;
    }
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }
    final ProductDetailsResponse productDetailResponse =
        await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    if (productDetailResponse.error != null ||
        productDetailResponse.productDetails.isEmpty) {
      setState(() {});
      return;
    }
  }

  _initInAppPurchase() async {
    LoadingOverlay().show(context); // Start Loading...
    printLog(
        "_initInAppPurchase _kProductIds ============> ${_kProductIds[0].toString()}");
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kProductIds.toSet());
    if (response.notFoundIDs.isNotEmpty) {
      LoadingOverlay().hide(); // Stop Loading...
      Utils.showSnackbar(context, "Please check SKU", false);
      return;
    }
    printLog("productID ============> ${response.productDetails[0].id}");
    late PurchaseParam purchaseParam;
    if (Platform.isAndroid) {
      purchaseParam =
          GooglePlayPurchaseParam(productDetails: response.productDetails[0]);
    } else {
      purchaseParam = PurchaseParam(productDetails: response.productDetails[0]);
    }
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    printLog(
        "_listenToPurchaseUpdated purchaseDetailsList ===> ${purchaseDetailsList.length}");
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      printLog(
          "_listenToPurchaseUpdated purchaseDetails status ===> ${purchaseDetails.status}");
      if (purchaseDetails.status == PurchaseStatus.pending) {
        showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          printLog(
              "_listenToPurchaseUpdated purchaseDetails ============> ${purchaseDetails.error.toString()}");
          handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          LoadingOverlay().hide(); // Stop Loading...
          if (!mounted) return;
          Utils.showSnackbar(context, "payment_cancel", true);
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume && purchaseDetails.productID == _kProductIds[0]) {
            final InAppPurchaseAndroidPlatformAddition androidAddition =
                _inAppPurchase.getPlatformAddition<
                    InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          printLog(
              "_listenToPurchaseUpdated pendingCompletePurchase ===> ${purchaseDetails.pendingCompletePurchase}");
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    printLog("deliverProduct productID ===> ${purchaseDetails.productID}");
    LoadingOverlay().hide(); // Stop Loading...
    if (purchaseDetails.productID == _kProductIds[0]) {
      if (widget.issubscription == 1) {
        await buyPlan(); // 🔥 MUST await
      } else {
        await addTransaction();
      }

      setState(() {});
    } else {
      printLog("deliverProduct consumables else ===> $purchaseDetails");
      setState(() {
        _purchases.add(purchaseDetails);
      });
    }
  }

  void showPendingUI() {
    LoadingOverlay().hide(); // Stop Loading...
    setState(() {});
  }

  void handleError(IAPError error) {
    LoadingOverlay().hide(); // Stop Loading...
    setState(() {});
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    LoadingOverlay().hide(); // Stop Loading...
    printLog("invalid Purchase ===> $purchaseDetails");
  }
  /* ********* InApp purchase END ********* */

  /* ********* Razorpay START ********* */
  void _initializeRazorpay() {
    if (paymentProvider.paymentOptionModel.result?.razorpay != null) {
      /* Check Keys */
      printLog(
          "Razorpay Check key pass is ${paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? ""}");

      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.razorpay?.isLive ?? ""),
        isBothKeyReq: false,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? ""),
        liveKey2: "",
        testKey1:
            (paymentProvider.paymentOptionModel.result?.razorpay?.key1 ?? ""),
        testKey2: "",
      );
      if (!isContinue) return;
      /* Check Keys */
      Razorpay razorpay = Razorpay();
      var options = {
        'key':
            // "rzp_test_E7TfP2p9bA9q75",
            (paymentProvider.paymentOptionModel.result?.razorpay?.isLive == "1")
                ? (paymentProvider.paymentOptionModel.result?.razorpay?.key1 ??
                    "")
                : (paymentProvider.paymentOptionModel.result?.razorpay?.key1 ??
                    ""),
        'currency': Constant.currency,
        'amount': (double.parse(paymentProvider.finalAmount ?? "") * 100),
        'name': widget.itemTitle,
        'description': widget.itemTitle,
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'prefill': {'contact': userMobileNo, 'email': userEmail},
        'external': {
          'wallets': ['paytm']
        }
      };
      printLog("Razorpay Payment Key is $options");
      razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
      razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
      razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
      try {
        razorpay.open(options);
      } catch (e) {
        printLog('Razorpay Error :=========> $e');
      }
    } else {
      printLog('Razorpay Error :=========> ');
      Utils.showSnackbar(context, "payment_not_processed", true);
    }
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) async {
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */

    Utils.showSnackbar(context, "payment_fail", true);
    await paymentProvider.setCurrentPayment("");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */
    paymentId = response.paymentId.toString();
    printLog("paymentId ========> $paymentId");
    Utils.showSnackbar(context, "payment_success", true);

    if (widget.issubscription == 1) {
      await buyPlan(); // 🔥 MUST await
    } else {
      await addTransaction();
    }

    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => const BottomMenu(),
    //     ));
    printLog("Success==============");
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    printLog("============ External Wallet Selected ============");
  }

  /* ********* Razorpay END ********* */

  /* ********* Paytm START ********* */
  Future<void> _paytmInit() async {
    // if (paymentProvider.paymentOptionModel.result?.paytm != null) {
    //   /* Check Keys */
    //   bool isContinue = checkKeysAndContinue(
    //     isLive:
    //         (paymentProvider.paymentOptionModel.result?.paytm?.isLive ?? ""),
    //     isBothKeyReq: true,
    //     liveKey1:
    //         (paymentProvider.paymentOptionModel.result?.paytm?.key1 ?? ""),
    //     liveKey2:
    //         (paymentProvider.paymentOptionModel.result?.paytm?.key2 ?? ""),
    //     testKey1: '',
    //     testKey2: '',
    //   );
    //   if (!isContinue) return;
    //   /* Check Keys */

    //   bool payTmIsStaging;
    //   String payTmMerchantID,
    //       payTmOrderId,
    //       payTmCustmoreID,
    //       payTmChannelID,
    //       payTmTxnAmount,
    //       payTmWebsite,
    //       payTmCallbackURL,
    //       payTmIndustryTypeID;

    //   payTmOrderId = paymentId ?? "";
    //   payTmMerchantID =
    //       paymentProvider.paymentOptionModel.result?.paytm?.key1 ?? "";
    //   payTmCustmoreID = "${Constant.userID}_$paymentId";
    //   payTmChannelID = "WAP";
    //   payTmTxnAmount = "${(paymentProvider.finalAmount ?? "")}.00";
    //   payTmIndustryTypeID = "Retail";

    //   if (paymentProvider.paymentOptionModel.result?.paytm?.isLive == "1") {
    //     payTmIsStaging = false;
    //     payTmWebsite = "DEFAULT";
    //     payTmCallbackURL =
    //         "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=$payTmOrderId";
    //   } else {
    //     payTmIsStaging = true;
    //     payTmWebsite = "WEBSTAGING";
    //     payTmCallbackURL =
    //         "https://securegw.paytm.in/theia/paytmCallback?ORDER_ID=$payTmOrderId";
    //   }
    //   var sendMap = <String, dynamic>{
    //     "mid": payTmMerchantID,
    //     "orderId": payTmOrderId,
    //     "amount": payTmTxnAmount,
    //     "txnToken": paymentProvider.payTmModel.result?.paytmChecksum ?? "",
    //     "callbackUrl": payTmCallbackURL,
    //     "isStaging": payTmIsStaging,
    //     "restrictAppInvoke": true,
    //     "enableAssist": true,
    //   };
    //   printLog("sendMap ===> $sendMap");

    //   /* Generate CheckSum from Backend */
    //   await paymentProvider.getPaytmToken(
    //     payTmMerchantID,
    //     payTmOrderId,
    //     payTmCustmoreID,
    //     payTmChannelID,
    //     payTmTxnAmount,
    //     payTmWebsite,
    //     payTmCallbackURL,
    //     payTmIndustryTypeID,
    //   );

    //   if (!paymentProvider.loading) {
    //     if (paymentProvider.payTmModel.result != null) {
    //       if (paymentProvider.payTmModel.result?.paytmChecksum != null) {
    //         try {
    //           var response = AllInOneSdk.startTransaction(
    //             payTmMerchantID,
    //             payTmOrderId,
    //             payTmTxnAmount,
    //             paymentProvider.payTmModel.result?.paytmChecksum ?? "",
    //             payTmCallbackURL,
    //             payTmIsStaging,
    //             true,
    //             true,
    //           );
    //           response.then((value) {
    //             printLog("value ====> $value");
    //             setState(() {
    //               paytmResult = value.toString();
    //             });
    //           }).catchError((onError) {
    //             if (onError is PlatformException) {
    //               setState(() {
    //                 paytmResult = "${onError.message} \n  ${onError.details}";
    //               });
    //             } else {
    //               setState(() {
    //                 paytmResult = onError.toString();
    //               });
    //             }
    //           });
    //         } catch (err) {
    //           paytmResult = err.toString();
    //         }
    //       } else {
    //         if (!mounted) return;
    //         Utils.showSnackbar(context, "", "payment_not_processed", true);
    //       }
    //     } else {
    //       if (!mounted) return;
    //       Utils.showSnackbar(context, "", "payment_not_processed", true);
    //     }
    //   }
    // } else {
    //   Utils.showSnackbar(context, "", "payment_not_processed", true);
    // }
  }
  // /* ********* Paytm END ********* */

  // /* ********* Paypal START ********* */
  // Future<void> _paypalInit() async {
  //   if (kIsWeb) {
  //     Utils.showSnackbar(context,
  //         "PayPal payment is supported only on mobile app", false);
  //     return;
  //   }
  //   if (paymentProvider.paymentOptionModel.result?.paypal != null) {
  //     /* Check Keys */
  //     bool isContinue = checkKeysAndContinue(
  //       isLive:
  //           (paymentProvider.paymentOptionModel.result?.paypal?.isLive ?? ""),
  //       isBothKeyReq: true,
  //       liveKey1:
  //           (paymentProvider.paymentOptionModel.result?.paypal?.key1 ?? ""),
  //       liveKey2:
  //           (paymentProvider.paymentOptionModel.result?.paypal?.key2 ?? ""),
  //       testKey1:
  //           (paymentProvider.paymentOptionModel.result?.paypal?.key1 ?? ""),
  //       testKey2:
  //           (paymentProvider.paymentOptionModel.result?.paypal?.key2 ?? ""),
  //     );
  //     if (!isContinue) return;
  //     /* Check Keys */
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (BuildContext context) => UsePaypal(
  //             sandboxMode:
  //                 (paymentProvider.paymentOptionModel.result?.paypal?.isLive ??
  //                             "") ==
  //                         "1"
  //                     ? false
  //                     : true,
  //             clientId: paymentProvider
  //                         .paymentOptionModel.result?.paypal?.isLive ==
  //                     "1"
  //                 ? paymentProvider.paymentOptionModel.result?.paypal?.key1 ??
  //                     ""
  //                 : paymentProvider.paymentOptionModel.result?.paypal?.key1 ??
  //                     "",
  //             secretKey: paymentProvider
  //                         .paymentOptionModel.result?.paypal?.isLive ==
  //                     "1"
  //                 ? paymentProvider.paymentOptionModel.result?.paypal?.key2 ??
  //                     ""
  //                 : paymentProvider.paymentOptionModel.result?.paypal?.key2 ??
  //                     "",
  //             returnURL: "return.divinetechs.com",
  //             cancelURL: "cancel.divinetechs.com",
  //             transactions: [
  //               {
  //                 "amount": {
  //                   "total": '${paymentProvider.finalAmount}',
  //                   "currency": Constant.currency,
  //                   "details": {
  //                     "subtotal": '${paymentProvider.finalAmount}',
  //                     "shipping": '0',
  //                     "shipping_discount": 0
  //                   }
  //                 },
  //                 "description": "The payment transaction description.",
  //                 "item_list": {
  //                   "items": [
  //                     {
  //                       "name": "${widget.itemTitle}",
  //                       "quantity": 1,
  //                       "price": '${paymentProvider.finalAmount}',
  //                       "currency": Constant.currency
  //                     }
  //                   ],
  //                 }
  //               }
  //             ],
  //             note: "Contact us for any questions on your order.",
  //             onSuccess: (params) async {
  //               debugPrint("onSuccess: ${params["paymentId"]}");

  //               addTransaction();
  //             },
  //             onError: (params) {
  //               printLog("onError: ${params["message"]}");
  //               Utils.showSnackbar(
  //                   context,  params["message"].toString(), false);
  //             },
  //             onCancel: (params) {
  //               printLog('cancelled: $params');
  //               Utils.showSnackbar(context,  params.toString(), false);
  //             }),
  //       ),
  //     );
  //   } else {
  //     Utils.showSnackbar(context,  "payment_not_processed", true);
  //   }
  // }
  // /* ********* Paypal END ********* */

  /* ********* Stripe START ********* */
  Future createCustomer() async {
    try {
      var body = {
        "email": userEmail,
        "name": userName,
        "phone": userMobileNo,
      };

      //final response  = await http.post(Uri.parse("https://api.stripe.com/v1/customers"),
      final response = await http.post(
        Uri.parse("https://api.stripe.com/v1/customers"),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Authorization":
              "Bearer ${paymentProvider.paymentOptionModel.result?.stripe?.key2}",
        },
        body: body,
      );
      printLog('createCustomer jsonDecode :=> ${jsonDecode(response.body)}');
      return jsonDecode(response.body);
    } catch (err) {
      printLog('createCustomer Error :=> ${err.toString()}');
      return null;
    }
  }

  Future<void> _stripeInit() async {
    if (paymentProvider.paymentOptionModel.result?.stripe != null) {
      /* Check Keys */
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.stripe?.isLive ?? ""),
        isBothKeyReq: true,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.stripe?.key1 ?? ""),
        liveKey2:
            (paymentProvider.paymentOptionModel.result?.stripe?.key2 ?? ""),
        testKey1: "",
        testKey2: '',
      );
      if (!isContinue) return;
      /* Check Keys */
      stripe.Stripe.publishableKey =
          paymentProvider.paymentOptionModel.result?.stripe?.key1 ?? "";
      try {
        //STEP 1: Create Payment Intent
        paymentIntent = await createPaymentIntent(
            paymentProvider.finalAmount ?? "", Constant.currency ?? "");

        //STEP 2: Initialize Payment Sheet

        await stripe.Stripe.instance
            .initPaymentSheet(
                paymentSheetParameters: stripe.SetupPaymentSheetParameters(
              merchantDisplayName: Constant.appName,
              paymentIntentClientSecret: paymentIntent?['client_secret'],
              style: ThemeMode.light,
            ))
            .then((value) {});
        //STEP 3: Display Payment sheet
        displayPaymentSheet();
      } catch (err) {
        throw Exception(err);
      }
    } else {
      Utils.showSnackbar(context, "payment_not_processed", true);
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'description': widget.itemTitle,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization':
              'Bearer ${paymentProvider.paymentOptionModel.result?.stripe?.key2 ?? ""}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (double.parse(amount)) * 100;
    return calculatedAmout.toString();
  }

  displayPaymentSheet() async {
    try {
      await stripe.Stripe.instance.presentPaymentSheet().then((value) {
        if (!mounted) return;
        Utils.showSnackbar(context, "payment_success", true);
        if (widget.issubscription == 1) {
          buyPlan();
        } else {
          addTransaction();
        }

        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on stripe.StripeException catch (e) {
      printLog('Error is:---> $e');
      if (!mounted) return;
      Utils.showSnackbar(context, "payment_fail", true);
    } catch (e) {
      printLog('$e');
    }
  }
  /* ********* Stripe END ********* */

  _flutterwaveInit() async {
    if (paymentProvider.paymentOptionModel.result?.flutterwave != null) {
      /* Check Keys */
      printLog(
          "Flutter wave Check key pass is ${paymentProvider.paymentOptionModel.result?.flutterwave?.key1 ?? ""}");
      bool isContinue = checkKeysAndContinue(
        isLive:
            (paymentProvider.paymentOptionModel.result?.flutterwave?.isLive ??
                ""),
        isBothKeyReq: false,
        liveKey1:
            (paymentProvider.paymentOptionModel.result?.flutterwave?.key1 ??
                ""),
        liveKey2: "",
        testKey1:
            (paymentProvider.paymentOptionModel.result?.flutterwave?.key1 ??
                ""),
        testKey2: "",
      );
      if (!isContinue) return;
      /* Check Keys */

      final Customer customer = Customer(
          email: userEmail ?? "",
          name: userName ?? "",
          phoneNumber: userMobileNo ?? "");

      final Flutterwave flutterwave = Flutterwave(
        context: context,
        publicKey:
            // "FLWPUBK_TEST-e791024b3585ae0839d3c79506d953d1-X",
            (paymentProvider.paymentOptionModel.result?.flutterwave?.isLive ==
                    "1")
                ? (paymentProvider
                        .paymentOptionModel.result?.flutterwave?.key1 ??
                    "")
                : (paymentProvider
                        .paymentOptionModel.result?.flutterwave?.key1 ??
                    ""),
        currency: Constant.currency ?? "",
        redirectUrl: 'https://www.divinetechs.com',
        txRef: const Uuid().v1(),
        amount: widget.price.toString().trim(),
        customer: customer,
        paymentOptions: "card, payattitude, barter, bank transfer, ussd",
        customization: Customization(title: widget.itemTitle),
        isTestMode:
            paymentProvider.paymentOptionModel.result?.flutterwave?.isLive !=
                "1",
      );
      ChargeResponse? response = await flutterwave.charge();
      printLog("Flutterwave response =====> ${response.toJson()}");
      if ((response.status == "success" ||
              response.status == "successful" ||
              (response.status ?? "").contains("success")) &&
          response.success == true) {
        paymentId = response.transactionId.toString();
        printLog("paymentId ========> $paymentId");

        if (!mounted) return;
        Utils.showSnackbar(context, "payment_success", true);
        if (widget.issubscription == 1) {
          await buyPlan(); // 🔥 MUST await
        } else {
          await addTransaction();
        }
      } else if (response.status == "cancel" &&
          response.status == "cancelled") {
        if (!mounted) return;
        Utils.showSnackbar(context, "payment_cancel", true);
      } else {
        if (!mounted) return;

        Utils.showSnackbar(context, "payment_fail", true);
      }
    } else {
      if (!mounted) return;

      Utils.showSnackbar(context, "payment_fail", true);
      printLog("Error Flutter wave");
    }
  }

  // /* ********* FlutterWave End ******* */

  /* ********* Paystack START ********* */
  _paystackInit() async {
    if (paymentProvider.paymentOptionModel.result?.paystack == null) {
      if (!mounted) return;
      Utils.showSnackbar(context, "payment_not_processed", true);
      return;
    }

    final paystack = paymentProvider.paymentOptionModel.result!.paystack!;
    // Admin now stores PK in key_1 and SK in key_2.
    // This SDK uses `secretKey`, so prefer key_2.
    final selectedKey = (paystack.key2 ?? "").isNotEmpty
        ? (paystack.key2 ?? "")
        : (paystack.key1 ?? "");
    final effectiveEmail = (userEmail ?? "").isNotEmpty
        ? (userEmail ?? "")
        : (Constant.email ?? "");
    if (selectedKey.isEmpty || effectiveEmail.isEmpty) {
      if (!mounted) return;
      Utils.showSnackbar(context, "payment_not_processed", true);
      return;
    }

    final amountValue = (double.tryParse(paymentProvider.finalAmount.toString()) ??
            double.tryParse(widget.price ?? "0") ??
            0) *
        100;
    final amountInKobo = amountValue.round();
    if (amountInKobo <= 0) {
      if (!mounted) return;
      Utils.showSnackbar(context, "payment_not_processed", true);
      return;
    }
    final currencyCode = "KES"; // Force KES for Paystack to avoid 400 bad request with "KENYAN SHILLING"

    paymentId = DateTime.now().microsecondsSinceEpoch.toString();

    if (kIsWeb) {
      final publicKey = (paystack.key1 ?? "").isNotEmpty
          ? (paystack.key1 ?? "")
          : (paystack.key2 ?? "");

      openPaystackIframe(
        context: context,
        publicKey: publicKey,
        email: effectiveEmail,
        amountInKobo: amountInKobo,
        currency: currencyCode,
        reference: paymentId ?? "",
        subaccount: (widget.subaccount ?? "").isNotEmpty ? widget.subaccount : null,
        onSuccess: () async {
          if (!mounted) return;
          Utils.showSnackbar(context, "payment_success", true);
          if (widget.issubscription == 1) {
            await buyPlan();
          } else {
            await addTransaction();
          }
        },
        onCancel: () {
          if (!mounted) return;
          Utils.showSnackbar(context, "payment_cancel", true);
        },
      );
      return;
    }

    // SDK expects amount in major currency (e.g. 500 for KES 500)
    final amountInMajor = (double.tryParse(paymentProvider.finalAmount.toString()) ??
        double.tryParse(widget.price ?? "0") ??
        0);
    if (amountInMajor <= 0) {
      if (!mounted) return;
      Utils.showSnackbar(context, "payment_not_processed", true);
      return;
    }

    paystack_sdk.PayWithPayStack().now(
      context: context,
      customerEmail: effectiveEmail,
      reference: paymentId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      currency: currencyCode,
      amount: amountInMajor,
      secretKey: selectedKey,
      subaccount: (widget.subaccount ?? "").isNotEmpty ? widget.subaccount : null,
      transactionCompleted: (paymentData) async {
        paymentId = paymentData.reference;
        if (!mounted) return;
        Utils.showSnackbar(context, "payment_success", true);
        if (widget.issubscription == 1) {
          await buyPlan();
        } else {
          await addTransaction();
        }
      },
      transactionNotCompleted: (message) {
        if (!mounted) return;
        Utils.showSnackbar(context, "payment_fail", true);
      },
      callbackUrl: Constant.website ?? "https://console.vitabu.online",
    );
  }
  /* ********* Paystack END ********* */

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context, isPaymentDone);
    }
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}

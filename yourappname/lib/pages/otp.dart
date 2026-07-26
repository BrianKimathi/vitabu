import 'dart:io';
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/pages/genresprefrences.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/webservice/apiservice.dart';

class OTP extends StatefulWidget {
  final String? mobileNumber, countryCode, countryName, serverOtp;
  const OTP({
    super.key,
    required this.mobileNumber,
    required this.countryCode,
    required this.countryName,
    this.serverOtp,
  });

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  SharedPref sharedPre = SharedPref();
  final pinPutController = TextEditingController();
  int? forceResendingToken;
  String? verificationId;
  dynamic strDeviceToken;
  String? platformType;
  bool codeResended = false;
  late GeneralProvider generalProvider;

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      codeSend(false);
    });
    super.initState();
    _getDeviceToken();
  }

  _getDeviceToken() async {
    if (Platform.isAndroid) {
      platformType = "1";
      strDeviceToken = await FirebaseMessaging.instance.getToken();
    } else {
      platformType = "2";
      strDeviceToken = OneSignal.User.pushSubscription.id.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF8F9FD),
      body: Consumer<GeneralProvider>(
        builder: (context, generalProvider, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Hero gradient header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    bottom: 48,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [colorPrimary, colorPrimaryDark],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const MyImage(
                        height: 80,
                        imagePath: "appicon.png",
                        fit: BoxFit.contain,
                        isAppicon: true,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Verify Phone",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Enter the code sent to your phone",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // OTP card
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const MyText(
                          text: "verifyphonenumber",
                          multilanguage: true,
                          fontsize: Dimens.appbarTextSize,
                          maxline: 1,
                          textalign: TextAlign.center,
                          fontwaight: FontWeight.w600,
                        ),
                        const SizedBox(height: 6),
                        MyText(
                          text: "wehavesentcodetoyournumber",
                          fontsize: Dimens.medium16TextSize,
                          multilanguage: true,
                          maxline: 2,
                          textalign: TextAlign.center,
                          fontwaight: FontWeight.w400,
                          color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Enter OTP",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Pinput(
                          length: 6,
                          keyboardType: TextInputType.number,
                          controller: pinPutController,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          defaultPinTheme: PinTheme(
                            width: 50,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF252536) : Colors.white,
                              border: Border.all(
                                color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                                width: 1.2,
                              ),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : black,
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 50,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF252536) : Colors.white,
                              border: Border.all(
                                color: colorPrimary,
                                width: 1.8,
                              ),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Confirm button
                        InkWell(
                          onTap: () {
                            if (pinPutController.text.isEmpty) {
                              Utils.showSnackbar(context, "pleaseenterotp", true);
                            } else {
                              Utils.showProgress(context);
                              _checkOTPAndLogin();
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [colorPrimary, colorPrimaryDark],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: colorPrimary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              "Confirm",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Resend
                        TextButton(
                          onPressed: () {
                            if (!codeResended) {
                              codeSend(true);
                            }
                          },
                          child: Text(
                            "Resend Code",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: codeResended
                                  ? (isDark ? Colors.grey[600] : Colors.grey[400])
                                  : colorPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  codeSend(bool isResend) async {
    printLog("codeSend mobileNumber ===> ${widget.mobileNumber.toString()}");
    codeResended = isResend;

    if (widget.serverOtp != null && widget.serverOtp!.isNotEmpty) {
      if (isResend) {
        Utils.showProgress(context);
        final fullNumber =
            '${(widget.countryCode ?? "").replaceAll('+', '')}${widget.mobileNumber}';
        try {
          final smsResp = await ApiService().sendOtpSms(mobileNumber: fullNumber);
          if (!mounted) return;
          Utils.hideProgress(context);
          if ((smsResp.status ?? 0) == 200) {
            Utils.showSnackbar(context, "otpsent", true);
          } else {
            Utils.showSnackbar(
                context, (smsResp.message ?? 'Failed to send OTP SMS'), false);
          }
        } catch (_) {
          if (!mounted) return;
          Utils.hideProgress(context);
          Utils.showSnackbar(context, "Something went wrong", false);
        }
      }
      return;
    }

    await phoneSignIn(phoneNumber: widget.mobileNumber.toString());
    if (!mounted) return;
    Utils.hideProgress(context);
  }

  Future<void> phoneSignIn({required String phoneNumber}) async {
    await auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 60),
      phoneNumber: "${widget.countryCode} $phoneNumber",
      forceResendingToken: forceResendingToken,
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _onCodeTimeout,
    );
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    printLog("verification completed ======> ${authCredential.smsCode}");
    setState(() {
      pinPutController.text = authCredential.smsCode ?? "";
    });
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (!mounted) return;
    Utils.hideProgress(context);
    if (exception.code == 'invalid-phone-number') {
      printLog("The phone number entered is invalid!");
      Utils.showSnackbar(context, "invalidphonenumber", true);
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    this.forceResendingToken = forceResendingToken;
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {
        Utils.hideProgress(context);
      });
    });
    printLog("verificationId =======> $verificationId");
    printLog("resendingToken =======> ${forceResendingToken.toString()}");
    printLog("code sent");
  }

  _onCodeTimeout(String verificationId) {
    printLog("_onCodeTimeout verificationId =======> $verificationId");
    this.verificationId = verificationId;
    if (!mounted) return;

    Utils.hideProgress(context);
    codeResended = false;
    return null;
  }

  _checkOTPAndLogin() async {
    bool error = false;
    UserCredential? userCredential;

    if (widget.serverOtp != null && widget.serverOtp!.isNotEmpty) {
      if (pinPutController.text.toString() == widget.serverOtp) {
        printLog("Server OTP matched successfully");
        loginApi(widget.mobileNumber.toString(), pinPutController.text.toString());
      } else {
        Utils.hideProgress(context);
        Utils.showSnackbar(context, "otpinvalid", true);
      }
      return;
    }

    printLog("_checkOTPAndLogin verificationId =====> $verificationId");
    PhoneAuthCredential? phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: verificationId ?? "",
      smsCode: pinPutController.text.toString(),
    );

    printLog(
        "phoneAuthCredential.smsCode   =====> ${phoneAuthCredential.smsCode}");
    printLog(
        "phoneAuthCredential.verificationId =====> ${phoneAuthCredential.verificationId}");
    try {
      userCredential = await auth.signInWithCredential(phoneAuthCredential);
      printLog(
          "_checkOTPAndLogin userCredential =====> ${userCredential.user?.phoneNumber ?? ""}");
      printLog(
          "_checkOTPAndLogin userCredential =====> ${userCredential.user?.uid ?? ""}");
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Utils.hideProgress(context);
      printLog("_checkOTPAndLogin error Code =====> ${e.code}");
      if (e.code == 'invalid-verification-code' ||
          e.code == 'invalid-verification-id') {
        if (!mounted) return;
        Utils.showSnackbar(context, "otpinvalid", true);
        return;
      } else if (e.code == 'session-expired') {
        if (!mounted) return;
        Utils.showSnackbar(context, "otpsessionexpired", true);
        return;
      } else {
        error = true;
      }
    }
    printLog(
        "Firebase Verification Complated & phoneNumber => ${userCredential?.user?.phoneNumber} and isError => $error");
    if (!error && userCredential != null) {
      loginApi(widget.mobileNumber.toString(), pinPutController.text.toString());
    } else {
      if (!mounted) return;
      Utils.hideProgress(context);
      Utils.showSnackbar(context, "otploginfail", true);
    }
  }

  loginApi(String number, String otp) async {
    Utils.showProgress(context);
    try {
      await generalProvider.getOTPAPI(
          "1", number, strDeviceToken, platformType.toString());

      if (!generalProvider.loading) {
        if (generalProvider.userModel.status == 200) {
          Utils.saveUserCreds(
              userID: generalProvider.userModel.result?[0].id.toString() ?? "",
              categoryId:
                  generalProvider.userModel.result?[0].categoryIds.toString() ?? "",
              firstName:
                  generalProvider.userModel.result?[0].firstName.toString() ?? "",
              lastName: generalProvider.userModel.result?[0].lastName.toString() ??
                  "",
              userName: generalProvider.userModel.result?[0].userName.toString() ??
                  "",
              userImage:
                  generalProvider.userModel.result?[0].image.toString() ?? "",
              userEmail:
                  generalProvider.userModel.result?[0].email.toString() ?? "",
              mobileNumber:
                  generalProvider.userModel.result?[0].mobileNumber.toString() ??
                      "",
              walletCoin:
                  generalProvider.userModel.result?[0].walletAmount.toString() ??
                      "",
              address:
                  generalProvider.userModel.result?[0].address.toString() ?? "",
              isAuthor:
                  generalProvider.userModel.result?[0].isAuthor.toString() ?? "",
              deviceType: generalProvider.userModel.result?[0].deviceType
                      .toString() ??
                  "",
              deviceToken: generalProvider.userModel.result?[0].deviceToken
                      .toString() ??
                  "",
              description: generalProvider.userModel.result?[0].description
                      .toString() ??
                  "");

          if (!mounted) return;
          Utils.hideProgress(context);
          if ((generalProvider.userModel.result?[0].categoryIds.toString() ??
                  "") ==
              "") {
            await SharedPref().save("isEdit", "0");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return GenresPrefrences(
                        isCategoryType: true,
                        isEditType: "2",
                      );
                    },
                    transitionDuration: Duration(milliseconds: 150),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          return ClipPath(
                            clipper: CircularRevealClipper(
                                progress: animation.value),
                            child: child,
                          );
                        },
                        child: child,
                      );
                    },
                  ),
                  (Route route) => false);
            });
          } else {
            await SharedPref().save("isEdit", "1");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return Bottombar();
                    },
                    transitionDuration: Duration(milliseconds: 150),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          return ClipPath(
                            clipper: CircularRevealClipper(
                                progress: animation.value),
                            child: child,
                          );
                        },
                        child: child,
                      );
                    },
                  ),
                  (Route route) => false);
            });
          }
        } else {
          Utils.showSnackbar(
              context, "${generalProvider.userModel.message}", false);
          if (!mounted) return;
          Utils.hideProgress(context);
        }
      }
    } catch (e) {
      Utils.showSnackbar(
          context, "${generalProvider.userModel.message}", false);
      if (!mounted) return;
      Utils.hideProgress(context);
    }
  }
}

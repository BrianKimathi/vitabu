import 'dart:io';

import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webgenresprefrneces.dart';
import 'package:yourappname/webpages/webhome.dart';
import 'package:yourappname/webpages/weblogin.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/mytextformfield.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class WebRegister extends StatefulWidget {
  const WebRegister({super.key});

  @override
  State<WebRegister> createState() => _WebRegisterState();
}

class _WebRegisterState extends State<WebRegister> {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  final passwordController = TextEditingController();
  final confPasswordController = TextEditingController();

  String mobilenumber = "";
  String? strDeviceType, strPrivacyAndTNC, strDeviceToken;
  String? countryCode;
  bool obscureText = true;
  bool obscureText1 = true;
  bool isChecked = false;

  late GeneralProvider generalProvider;
  final SharedPref sharedPre = SharedPref();

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _getDeviceToken();
    _getData();
    super.initState();
  }

  _getDeviceToken() async {
    if (kIsWeb) {
      strDeviceType = "3";
      strDeviceToken = "123";
    } else if (Platform.isAndroid) {
      strDeviceType = "1";
      strDeviceToken = await FirebaseMessaging.instance.getToken();
    } else if (Platform.isIOS) {
      strDeviceType = "2";
      strDeviceToken = OneSignal.User.pushSubscription.id.toString();
    }
  }

  _getData() async {
    String? privacyUrl, termsConditionUrl;
    await generalProvider.getPages();
    if (!generalProvider.loading) {
      if (generalProvider.pagesModel.status == 200 &&
          generalProvider.pagesModel.result != null) {
        if ((generalProvider.pagesModel.result?.length ?? 0) > 0) {
          for (var i = 0;
              i < (generalProvider.pagesModel.result?.length ?? 0);
              i++) {
            if ((generalProvider.pagesModel.result?[i].title ?? "")
                .toLowerCase()
                .contains("privacy")) {
              privacyUrl = generalProvider.pagesModel.result?[i].url;
            }
            if ((generalProvider.pagesModel.result?[i].title ?? "")
                .toLowerCase()
                .contains("terms")) {
              termsConditionUrl = generalProvider.pagesModel.result?[i].url;
            }
          }
        }
      }
    }
    printLog('privacyUrl ==> $privacyUrl');
    printLog('termsConditionUrl ==> $termsConditionUrl');

    strPrivacyAndTNC = await Utils.getPrivacyTandCText(
      privacyUrl: privacyUrl ?? "",
      termsConditionUrl: termsConditionUrl ?? "",
    );
    printLog('strPrivacyAndTNC ==> $strPrivacyAndTNC');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final isMobile = screenWidth <= 600;

    return Scaffold(
      body: Row(
        children: [
          // ── Left Branding Panel ──
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorAccent.withOpacity(0.9),
                      colorAccent.withOpacity(0.7),
                      const Color(0xFF1E1B4B),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Join Us",
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Create your\naccount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Start your reading journey with thousands of books, audiobooks, and magazines.",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),
                        const Spacer(),
                        _Bullet("Free access to top titles"),
                        const SizedBox(height: 12),
                        _Bullet("Personalized recommendations"),
                        const SizedBox(height: 12),
                        _Bullet("Read offline, anytime"),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ── Right Registration Form ──
          Expanded(
            flex: 5,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : isDesktop ? 60 : 40,
                    vertical: 40,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Close button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F4F9),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => Navigator.canPop(context) ? Navigator.pop(context) : null,
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.close_rounded, size: 22, color: Color(0xFF64748B)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isDesktop ? 16 : 8),

                        // Header
                        Text(
                          Locales.string(context, "signup"),
                          style: TextStyle(
                            fontSize: isMobile ? 26 : 30,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          Locales.string(context, "signup_title"),
                          style: const TextStyle(fontSize: 15, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 28),

                        // First Name
                        _InputField(controller: firstnameController, hint: "Enter the First name", label: "firstname", icon: FontAwesomeIcons.user),
                        const SizedBox(height: 14),

                        // Last Name
                        _InputField(controller: lastnameController, hint: "Enter the Last Name", label: "lastname", icon: FontAwesomeIcons.user),
                        const SizedBox(height: 14),

                        // Email
                        _InputField(controller: emailController, hint: "Enter the email", label: "email", icon: FontAwesomeIcons.envelope),
                        const SizedBox(height: 14),

                        // Phone
                        _PhoneField(),
                        const SizedBox(height: 14),

                        // Password
                        _InputField(controller: passwordController, hint: "Enter the Passwrod", label: "password", icon: FontAwesomeIcons.lock, obscure: true),
                        const SizedBox(height: 14),

                        // Confirm Password
                        _InputField(controller: confPasswordController, hint: "Enter the Conf Passwrod", label: "password", icon: FontAwesomeIcons.lock, obscure: true),
                        const SizedBox(height: 12),

                        // Terms checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 24, width: 24,
                              child: Checkbox(
                                value: isChecked,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                side: const BorderSide(color: Color(0xFFCBD5E1)),
                                activeColor: colorAccent,
                                onChanged: (v) => setState(() => isChecked = v ?? false),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "I have read and agree to the Terms & Conditions, Privacy Policy, Refund Policy, and other applicable platform policies.",
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Register button
                        _RegisterBtn(),
                        const SizedBox(height: 20),

                        // Login link
                        _LoginLink(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _InputField({required TextEditingController controller, required String hint, required String label, required dynamic icon, bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Locales.string(context, label), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: TextFormField(
            controller: controller, obscureText: obscure,
            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
              hintText: hint, hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _PhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Phone Number", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: IntlPhoneField(
            disableLengthCheck: true, controller: numberController,
            autovalidateMode: AutovalidateMode.disabled,
            cursorColor: const Color(0xFF94A3B8), initialCountryCode: "IN",
            showCountryFlag: false, showDropdownIcon: true,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: Locales.string(context, "enteryourmobilenumber"),
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onChanged: (phone) => mobilenumber = phone.completeNumber,
            onCountryChanged: (c) => countryCode = "+${c.dialCode}",
          ),
        ),
      ],
    );
  }

  Widget _RegisterBtn() {
    return InkWell(
      onTap: _validateAndRegister,
      child: Container(
        width: double.infinity, height: 48,
        decoration: BoxDecoration(
          color: colorAccent, borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: colorAccent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        alignment: Alignment.center,
        child: generalProvider.isLogin
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(Locales.string(context, "signup"), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _LoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(Locales.string(context, "alreadyhaveanaccount"), style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        const SizedBox(width: 6),
        InkWell(
          onTap: () {
            Navigator.of(context).pushReplacement(PageRouteBuilder(
              pageBuilder: (_, __, ___) => const Weblogin(),
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ));
          },
          child: Text(Locales.string(context, "login"), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colorAccent)),
        ),
      ],
    );
  }

  void _validateAndRegister() {
    if (firstnameController.text.isEmpty) {
      Utils.showSnackbar(context, "enteryourfirstname", true);
    } else if (lastnameController.text.isEmpty) {
      Utils.showSnackbar(context, "enteryourlastname", true);
    } else if (emailController.text.isEmpty) {
      Utils.showSnackbar(context, "enteryouremail", true);
    } else if (mobilenumber.isEmpty) {
      Utils.showSnackbar(context, "enteryourmobilenumber", true);
    } else if (passwordController.text.isEmpty) {
      Utils.showSnackbar(context, "enteryourpassword", true);
    } else if (confPasswordController.text.isEmpty) {
      Utils.showSnackbar(context, "enteryourconfirmpassword", true);
    } else if (passwordController.text != confPasswordController.text) {
      Utils.showSnackbar(context, "passworddontmatch", true);
    } else if (!isChecked) {
      Utils.showSnackbar(context, "pleaseaccept", true);
    } else {
      _registerAPI();
    }
  }

  Future<void> _registerAPI() async {
    if (generalProvider.isLogin) return; // prevent double-tap
    generalProvider.setLogin(true);
    try {
      await generalProvider.getregister(
        firstnameController.text, lastnameController.text,
        emailController.text, passwordController.text,
        mobilenumber, strDeviceType, strDeviceToken,
      );
      printLog("RegisterAPI: userModel status = ${generalProvider.userModel.status}");
    } catch (e) {
      printLog("RegisterAPI: Exception = $e");
      generalProvider.setLogin(false);
      Utils.showSnackbar(context, "Connection error. Please try again.", true);
      return;
    }

    if (generalProvider.userModel.status == 200) {
      final u = generalProvider.userModel.result?[0];
      if (u == null) {
        generalProvider.setLogin(false);
        Utils.showSnackbar(context, "Invalid response from server", true);
        return;
      }
      await Utils.saveUserCreds(
        userID: u.id.toString() ?? "", categoryId: "",
        firstName: firstnameController.text,
        lastName: lastnameController.text,
        userName: "${firstnameController.text} ${lastnameController.text}",
        userImage: u.image ?? "", userEmail: emailController.text,
        mobileNumber: mobilenumber, walletCoin: "", address: "",
        isAuthor: "", deviceType: strDeviceType ?? "",
        deviceToken: strDeviceToken ?? "", description: "",
      );
      generalProvider.setLogin(false);
      await sharedPre.save("isEdit", "0");
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => WebGenresPrefrences(isCategoryType: true, isEditType: "2"),
          transitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
        ),
        (_) => false,
      );
    } else {
      Utils.showSnackbar(context, generalProvider.userModel.message ?? "Registration failed", true);
      generalProvider.setLogin(false);
    }
  }

  Widget _Bullet(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_rounded, size: 18, color: Colors.white.withOpacity(0.8)),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
      ],
    );
  }

  Widget numberTextField() {
    return IntlPhoneField(
      disableLengthCheck: true,
      textAlignVertical: TextAlignVertical.center,
      autovalidateMode: AutovalidateMode.disabled,
      controller: numberController,
      cursorColor: gray,
      style: Utils.googleFontStyle(
          1, 16, FontStyle.normal, black, FontWeight.w500),
      showCountryFlag: false,
      showDropdownIcon: false,
      initialCountryCode: "IN",
      dropdownTextStyle: Utils.googleFontStyle(
          1, 16, FontStyle.normal, black, FontWeight.w500),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        fillColor: white,
        border: InputBorder.none,
        filled: true,
        hintStyle: Utils.googleFontStyle(
            1, 14, FontStyle.normal, gray, FontWeight.w500),
        hintText: Locales.string(context, "enteryourmobilenumber"),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(7.0)),
          borderSide: BorderSide(color: gray, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(7.0)),
          borderSide: BorderSide(color: gray, width: 1),
        ),
      ),
      onChanged: (phone) {
        mobilenumber = phone.completeNumber;
      },
      onCountryChanged: (country) {
        countryCode = "+${country.dialCode.toString()}";
      },
    );
  }

  Widget goingRegister() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return Weblogin();
            },
            transitionDuration: Duration(milliseconds: 150),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return ClipPath(
                    clipper: CircularRevealClipper(progress: animation.value),
                    child: child,
                  );
                },
                child: child,
              );
            }));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: MyText(
                color: black.withOpacity(0.6),
                text: "alreadyhaveanaccount",
                fontsizeWeb: Dimens.medium14TextSize,
                fontsize: Dimens.medium14TextSize,
                maxline: 1,
                fontwaight: FontWeight.w400,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
                multilanguage: true),
          ),
          const SizedBox(width: 5),
          Flexible(
            fit: FlexFit.loose,
            child: MyText(
                color: colorPrimary,
                text: "login",
                fontsizeWeb: Dimens.medium14TextSize,
                fontsize: Dimens.medium14TextSize,
                maxline: 1,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
                multilanguage: true),
          ),
        ],
      ),
    );
  }

  Widget loginBtn() {
    return InkWell(
      onTap: () {
        bool emailValidation = RegExp(
                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(emailController.text);

        if (firstnameController.text.isEmpty) {
          Utils.showSnackbar(
            context,
            "please_enter_your_firstname",
            true,
          );
        } else if (lastnameController.text.isEmpty) {
          Utils.showSnackbar(
            context,
            "please_enter_your_lastname",
            true,
          );
        } else if (emailController.text.isEmpty) {
          Utils.showSnackbar(
            context,
            "please_enter_your_email",
            true,
          );
        } else if (!emailValidation) {
          Utils.showSnackbar(
            context,
            "invalid_email",
            true,
          );
        } else if (mobilenumber.isEmpty) {
          Utils.showSnackbar(
            context,
            "please_enter_your_mobilenumber",
            true,
          );
        } else if (!isChecked) {
          Utils.showSnackbar(context, "Please agree to the Terms & Conditions and Policies", false);
        } else if (passwordController.text.isEmpty) {
          Utils.showSnackbar(
            context,
            "please_enter_your_password",
            true,
          );
        } else if (passwordController.text.length > 6 &&
            passwordController.text.length <= 10) {
          Utils.showSnackbar(
            context,
            "password_must_be_6_digit_only",
            true,
          );
        } else if (confPasswordController.text.isEmpty) {
          Utils.showSnackbar(
            context,
            "please_enter_your_confirm_password",
            true,
          );
        } else if (confPasswordController.text != passwordController.text) {
          Utils.showSnackbar(
            context,
            "password_not_same",
            true,
          );
        } else {
          registerApi(
            firstnameController.text,
            lastnameController.text,
            emailController.text,
            passwordController.text,
            mobilenumber,
            strDeviceType,
            strDeviceToken,
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        curve: Curves.bounceInOut,
        width: MediaQuery.of(context).size.width,
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(10),
        ),
        child: generalProvider.isLogin
            ? const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  color: white,
                  strokeWidth: 2,
                ),
              )
            : MyText(
                color: white,
                text: "signup",
                fontsize: Dimens.medium16TextSize,
                fontsizeWeb: Dimens.medium16TextSize,
                fontwaight: FontWeight.w600,
                maxline: 1,
                multilanguage: true,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
              ),
      ),
    );
  }

/* Regiter api */
  registerApi(
    firstName,
    lastName,
    email,
    password,
    number,
    deviceType,
    deviceToken,
  ) async {
    generalProvider.setLogin(true);
    try {
      await generalProvider.getregister(
        firstName,
        lastName,
        email,
        password,
        number,
        deviceType,
        deviceToken,
      );

      if (generalProvider.userModel.status == 200) {
        Utils.saveUserCreds(
          userID: generalProvider.userModel.result?[0].id.toString() ?? "",
          categoryId:
              generalProvider.userModel.result?[0].categoryIds.toString() ?? "",
          firstName:
              generalProvider.userModel.result?[0].firstName.toString() ?? "",
          lastName:
              generalProvider.userModel.result?[0].lastName.toString() ?? "",
          userName:
              generalProvider.userModel.result?[0].userName.toString() ?? "",
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
          deviceType:
              generalProvider.userModel.result?[0].deviceType.toString() ?? "",
          deviceToken:
              generalProvider.userModel.result?[0].deviceToken.toString() ?? "",
          description:
              generalProvider.userModel.result?[0].description.toString() ?? "",
        );

        generalProvider.setLogin(false);

        final isCategoryEmpty =
            (generalProvider.userModel.result?[0].categoryIds ?? "") == "";
        await SharedPref().save("isEdit", isCategoryEmpty ? "0" : "1");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return isCategoryEmpty
                    ? WebGenresPrefrences(isCategoryType: true, isEditType: "2")
                    : WebHome();
              },
              transitionDuration: Duration(milliseconds: 150),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return ClipPath(
                      clipper: CircularRevealClipper(progress: animation.value),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
            ),
            (Route route) => false,
          );
        });
      } else {
        Utils.showSnackbar(context,
            generalProvider.userModel.message ?? "Something went wrong", false);
        generalProvider.setLogin(false);
      }
    } catch (e) {
      printLog("Register API Exception: $e");
      Utils.showSnackbar(
          context, "An error occurred. Please check your connection.", false);
      generalProvider.setLogin(false);
    }
  }
}

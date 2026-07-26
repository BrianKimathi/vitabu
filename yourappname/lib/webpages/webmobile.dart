import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webotp.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class WebMobile extends StatefulWidget {
  const WebMobile({super.key});

  @override
  State<WebMobile> createState() => _WebMobileState();
}

class _WebMobileState extends State<WebMobile> {
  String? countryCode = '', countryName = '';
  TextEditingController phoneController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left image (hidden on mobile)
                  if (screenWidth > 800)
                    Expanded(
                      flex: 5,
                      child: MyImage(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height,
                        imagePath: 'login_bg.png',
                        fit: BoxFit.cover,
                      ),
                    ),

                  // Right mobile login form
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.center,
                      padding: screenWidth > 1200
                          ? const EdgeInsets.fromLTRB(100, 40, 100, 40)
                          : screenWidth > 600
                              ? const EdgeInsets.fromLTRB(40, 40, 40, 40)
                              : const EdgeInsets.fromLTRB(20, 40, 20, 40),
                      decoration: const BoxDecoration(color: white),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // Logo
                            const MyImage(
                              height: 80,
                              imagePath: "appicon.png",
                              fit: BoxFit.contain,
                              isAppicon: true,
                            ),
                            const SizedBox(height: 20),
                            MyText(
                              text: "mobilenumb",
                              fontsizeWeb: Dimens.medium24TextSize,
                              fontsize: Dimens.medium24TextSize,
                              fontwaight: FontWeight.w700,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.center,
                              multilanguage: true,
                              fontstyle: FontStyle.normal,
                              color: const Color(0xFF1F2937),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "We'll send you a one-time code",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 24),
                            otpLogin(),
                            const SizedBox(height: 24),
                            btnSendOtp(),
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Positioned cancel button
              Positioned(
                top: 20,
                right: 20,
                child: SafeArea(
                  child: InkWell(
                    onTap: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorPrimaryDark,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget otpLogin() {
    return IntlPhoneField(
        controller: phoneController,
        disableLengthCheck: true,
        textAlignVertical: TextAlignVertical.center,
        autovalidateMode: AutovalidateMode.disabled,
        showCountryFlag: true,
        showDropdownIcon: true,
        autofocus: true,
        cursorColor: colorPrimary,
        dropdownIconPosition: IconPosition.trailing,
        dropdownIcon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 20,
          color: gray,
        ),
        initialCountryCode: Constant.initialCountryCode,
        onCountryChanged: (country) {
          countryCode = "+${country.dialCode.toString()}";
          countryName = country.code.replaceAll('+', '');
        },
        onChanged: (phone) {
          countryName = phone.countryISOCode;
          countryCode = phone.countryCode;
        },
        dropdownTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: black,
        ),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: black,
        ),
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: Color(0xFFE5E7EB), width: 1)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: red, width: 1)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: colorPrimary, width: 1.5)),
          fillColor: white,
          border: InputBorder.none,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        ));
  }

  Widget btnSendOtp() {
    return InkWell(
      onTap: () async {
        if (phoneController.text.isEmpty) {
          Utils.showSnackbar(context, "pleaseentermobilenumber", true);
        } else {
          Utils.showProgress(context);
          try {
            final response = await ApiService().sendOtpSms(mobileNumber: phoneController.text.toString());
            Utils.hideProgress(context);
            if (response.status == 200 && response.result != null) {
              String extractedOtp = "";
              if (response.result is Map<String, dynamic> && response.result['otp'] != null) {
                extractedOtp = response.result['otp'].toString();
              } else if (response.result is List && response.result.isNotEmpty && response.result[0] is Map && response.result[0]['otp'] != null) {
                extractedOtp = response.result[0]['otp'].toString();
              }
              Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return WebOtp(
                      mobileNumber: phoneController.text.toString(),
                      countryCode: countryCode ?? "",
                      countryName: countryName ?? "",
                      generatedOtp: extractedOtp,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 150),
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
            } else {
              Utils.showSnackbar(context, response.message ?? "Failed to send OTP", false);
            }
          } catch (e) {
            Utils.hideProgress(context);
            Utils.showSnackbar(context, e.toString(), false);
          }
        }
      },
      child: Container(
        width: double.infinity,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [colorPrimary, colorPrimaryDark]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorPrimary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Text(
          "Send OTP",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

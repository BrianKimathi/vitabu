import 'package:yourappname/pages/otp.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/customebutton.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:yourappname/webservice/apiservice.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  String? countryCode = '', countryName = '';
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF8F9FD),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                    "Phone Login",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Enter your mobile number to continue",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "We'll send you a one-time code",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 22),
                    otpLogin(isDark),
                    const SizedBox(height: 22),
                    btnSendOtp(isDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget otpLogin(bool isDark) {
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
        dropdownIcon: Icon(
          Icons.keyboard_arrow_down_rounded,
          size: 20,
          color: isDark ? Colors.grey[400] : gray,
        ),
        initialCountryCode: Constant.initialCountryCode,
        onCountryChanged: (country) {
          countryCode = "+${country.dialCode.toString()}";
          countryName = country.code.replaceAll('+', '');
          printLog('countrycode===> $countryCode');
          printLog('countryName===> $countryName');
        },
        onChanged: (phone) {
          printLog('===> ${phone.completeNumber}');
          printLog('===> ${phoneController.text}');

          countryName = phone.countryISOCode;
          countryCode = phone.countryCode;
        },
        dropdownTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : black,
        ),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : black,
        ),
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: red, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: colorPrimary, width: 1.5),
          ),
          fillColor: isDark ? const Color(0xFF252536) : white,
          border: InputBorder.none,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        ));
  }

  Widget btnSendOtp(bool isDark) {
    return InkWell(
      onTap: _sendOtpAndContinue,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [colorPrimary, colorPrimaryDark]),
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
          "Send OTP",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Future<void> _sendOtpAndContinue() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (phoneController.text.isEmpty) {
      Utils.showSnackbar(context, 'enteryourmobilenumbertologin', true);
      return;
    }
    final fullNumber =
        '${(countryCode ?? '').replaceAll('+', '')}${phoneController.text.trim()}';
    try {
      final smsResp = await ApiService().sendOtpSms(mobileNumber: fullNumber);
      if (!mounted) return;
      if ((smsResp.status ?? 0) != 200) {
        Utils.showSnackbar(
            context, (smsResp.message ?? 'Failed to send OTP SMS'), false);
        return;
      }
      String extractedOtp = "";
      if (smsResp.result is Map<String, dynamic> && smsResp.result['otp'] != null) {
        extractedOtp = smsResp.result['otp'].toString();
      } else if (smsResp.result is List && smsResp.result.isNotEmpty && smsResp.result[0] is Map && smsResp.result[0]['otp'] != null) {
        extractedOtp = smsResp.result[0]['otp'].toString();
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTP(
            mobileNumber: phoneController.text.toString(),
            countryCode: countryCode ?? "",
            countryName: countryName ?? "",
            serverOtp: extractedOtp.isNotEmpty ? extractedOtp : null,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      Utils.showSnackbar(context, "something_went_wrong", true);
    }
  }
}

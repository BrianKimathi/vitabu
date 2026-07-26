import 'dart:io';

import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/pages/genresprefrences.dart';
import 'package:yourappname/pages/login.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> with SingleTickerProviderStateMixin {
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  final passwordController = TextEditingController();
  final confPasswordController = TextEditingController();

  String mobilenumber = "";
  String? strDeviceType, strPrivacyAndTNC, strDeviceToken;
  String? countryCode;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool isChecked = false;

  late GeneralProvider generalProvider;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _getDeviceToken();
    _getData();

    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  _getDeviceToken() async {
    if (Platform.isAndroid) {
      strDeviceType = "1";
      strDeviceToken = await FirebaseMessaging.instance.getToken();
    } else {
      strDeviceType = "2";
      strDeviceToken = OneSignal.User.pushSubscription.id.toString();
    }
  }

  _getData() async {
    String? privacyUrl, termsConditionUrl;
    await generalProvider.getPages();
    if (!generalProvider.loading) {
      if (generalProvider.pagesModel.status == 200 && generalProvider.pagesModel.result != null) {
        for (var i = 0; i < (generalProvider.pagesModel.result?.length ?? 0); i++) {
          if ((generalProvider.pagesModel.result?[i].title ?? "").toLowerCase().contains("privacy")) {
            privacyUrl = generalProvider.pagesModel.result?[i].url;
          }
          if ((generalProvider.pagesModel.result?[i].title ?? "").toLowerCase().contains("terms")) {
            termsConditionUrl = generalProvider.pagesModel.result?[i].url;
          }
        }
      }
    }
    strPrivacyAndTNC = await Utils.getPrivacyTandCText(
      privacyUrl: privacyUrl ?? "",
      termsConditionUrl: termsConditionUrl ?? "",
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    emailController.dispose();
    numberController.dispose();
    passwordController.dispose();
    confPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF8F9FD),
      body: Consumer<GeneralProvider>(
        builder: (context, gp, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Hero gradient header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    bottom: 40,
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
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      MyImage(
                        height: 70,
                        imagePath: "appicon.png",
                        fit: BoxFit.contain,
                        isAppicon: true,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Join thousands of readers today",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                      child: Column(
                        children: [
                          // Name row
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  controller: firstnameController,
                                  label: "First Name",
                                  hint: "John",
                                  icon: Icons.person_outline_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInputField(
                                  controller: lastnameController,
                                  label: "Last Name",
                                  hint: "Doe",
                                  icon: Icons.person_outline_rounded,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildInputField(
                            controller: emailController,
                            label: "Email Address",
                            hint: "you@example.com",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          _buildInputField(
                            controller: passwordController,
                            label: "Password",
                            hint: "Min. 6 characters",
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            obscure: _showPassword,
                            onToggle: () => setState(() => _showPassword = !_showPassword),
                          ),
                          const SizedBox(height: 16),

                          _buildInputField(
                            controller: confPasswordController,
                            label: "Confirm Password",
                            hint: "Re-enter your password",
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            obscure: _showConfirmPassword,
                            onToggle: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                          ),
                          const SizedBox(height: 16),

                          // Phone field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Phone Number",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: IntlPhoneField(
                                    disableLengthCheck: true,
                                    autovalidateMode: AutovalidateMode.disabled,
                                    controller: numberController,
                                    cursorColor: colorPrimary,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                                    ),
                                    showCountryFlag: true,
                                    showDropdownIcon: true,
                                    initialCountryCode: "KE",
                                    dropdownIconPosition: IconPosition.trailing,
                                    dropdownTextStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      fillColor: Colors.transparent,
                                      filled: true,
                                      hintText: "712 345 678",
                                      hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 13),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                                    ),
                                    onChanged: (phone) => mobilenumber = phone.completeNumber,
                                    onCountryChanged: (country) => countryCode = "+${country.dialCode}",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Terms checkbox
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isDark ? colorPrimary.withOpacity(0.1) : colorPrimary.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isChecked ? colorPrimary.withOpacity(0.4) : (isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB)),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Checkbox(
                                    value: isChecked,
                                    onChanged: (v) => setState(() => isChecked = v ?? false),
                                    fillColor: MaterialStateProperty.resolveWith(
                                        (s) => s.contains(MaterialState.selected) ? colorPrimary : Colors.transparent),
                                    checkColor: Colors.white,
                                    side: BorderSide(color: colorPrimary, width: 1.5),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "I agree to the Terms & Conditions, Privacy Policy, Refund Policy and other applicable platform policies.",
                                    style: TextStyle(
                                      fontSize: 12,
                                      height: 1.5,
                                      color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Create account button
                          _buildPrimaryButton(
                            isLoading: gp.isLogin,
                            label: "Create Account",
                            onTap: _doRegister,
                          ),
                          const SizedBox(height: 24),

                          // Login link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.of(context).pushReplacement(PageRouteBuilder(
                                  pageBuilder: (c, a1, a2) => Login(),
                                  transitionDuration: const Duration(milliseconds: 200),
                                  transitionsBuilder: (c, a1, a2, child) =>
                                      ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
                                )),
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: colorPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.grey[300] : const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !obscure,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400], fontSize: 13),
              prefixIcon: Icon(icon, size: 18, color: colorPrimary),
              suffixIcon: isPassword
                  ? IconButton(
                      onPressed: onToggle,
                      icon: Icon(
                        obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        size: 18,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({required bool isLoading, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [colorPrimary, colorPrimaryDark]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: colorPrimary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }

  void _doRegister() {
    bool emailValidation = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailController.text);
    if (firstnameController.text.isEmpty) {
      Utils.showSnackbar(context, "Please Enter Your First Name", false);
    } else if (lastnameController.text.isEmpty) {
      Utils.showSnackbar(context, "Please Enter Your Last Name", false);
    } else if (emailController.text.isEmpty) {
      Utils.showSnackbar(context, "Please Enter Your Email", false);
    } else if (!emailValidation) {
      Utils.showSnackbar(context, "Invalid Email", false);
    } else if (passwordController.text.isEmpty) {
      Utils.showSnackbar(context, "Please Enter Your Password", false);
    } else if (passwordController.text.length < 6) {
      Utils.showSnackbar(context, "Password must be at least 6 characters", false);
    } else if (confPasswordController.text.isEmpty) {
      Utils.showSnackbar(context, "Please confirm your password", false);
    } else if (confPasswordController.text != passwordController.text) {
      Utils.showSnackbar(context, "Passwords do not match", false);
    } else if (mobilenumber.isEmpty) {
      Utils.showSnackbar(context, "Please Enter Your Mobile Number", false);
    } else if (!isChecked) {
      Utils.showSnackbar(context, "Please agree to the Terms & Conditions", false);
    } else {
      _registerApi(firstnameController.text, lastnameController.text, emailController.text,
          passwordController.text, mobilenumber, strDeviceType, strDeviceToken);
    }
  }

  _registerApi(firstName, lastName, email, password, number, deviceType, deviceToken) async {
    generalProvider.setLogin(true);
    try {
      await generalProvider.getregister(firstName, lastName, email, password, number, deviceType, deviceToken);
      if (generalProvider.userModel.status == 200) {
        Utils.saveUserCreds(
            userID: generalProvider.userModel.result?[0].id.toString() ?? "",
            categoryId: generalProvider.userModel.result?[0].categoryIds.toString() ?? "",
            firstName: generalProvider.userModel.result?[0].firstName.toString() ?? "",
            lastName: generalProvider.userModel.result?[0].lastName.toString() ?? "",
            userName: generalProvider.userModel.result?[0].userName.toString() ?? "",
            userImage: generalProvider.userModel.result?[0].image.toString() ?? "",
            userEmail: generalProvider.userModel.result?[0].email.toString() ?? "",
            mobileNumber: generalProvider.userModel.result?[0].mobileNumber.toString() ?? "",
            walletCoin: generalProvider.userModel.result?[0].walletAmount.toString() ?? "",
            address: generalProvider.userModel.result?[0].address.toString() ?? "",
            isAuthor: generalProvider.userModel.result?[0].isAuthor.toString() ?? "",
            deviceType: generalProvider.userModel.result?[0].deviceType.toString() ?? "",
            deviceToken: generalProvider.userModel.result?[0].deviceToken.toString() ?? "",
            description: generalProvider.userModel.result?[0].description.toString() ?? "");
        generalProvider.setLogin(false);
        if ((generalProvider.userModel.result?[0].categoryIds.toString() ?? "") == "") {
          await SharedPref().save("isEdit", "0");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (c, a1, a2) => GenresPrefrences(isCategoryType: true, isEditType: "2"),
                  transitionDuration: const Duration(milliseconds: 200),
                  transitionsBuilder: (c, a1, a2, child) =>
                      ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
                ),
                (r) => false);
          });
        } else {
          await SharedPref().save("isEdit", "1");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (c, a1, a2) => Bottombar(),
                  transitionDuration: const Duration(milliseconds: 200),
                  transitionsBuilder: (c, a1, a2, child) =>
                      ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
                ),
                (r) => false);
          });
        }
      } else {
        Utils.showSnackbar(context, generalProvider.userModel.message.toString(), false);
        generalProvider.setLogin(false);
      }
    } catch (e) {
      Utils.showSnackbar(context, generalProvider.userModel.message.toString(), false);
      generalProvider.setLogin(false);
    }
  }
}

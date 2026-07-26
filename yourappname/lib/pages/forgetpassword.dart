import 'package:yourappname/pages/register.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/provider/themeprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customebutton.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/mytextformfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final emailController = TextEditingController();
  late ThemeProvider themeProvider;

  @override
  void initState() {
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF8F9FD),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              // Hero gradient header
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: 20,
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
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Recover Password",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Enter your email to reset your password",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Form card
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
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Email Address",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF252536) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                          decoration: InputDecoration(
                            hintText: "you@example.com",
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              size: 18,
                              color: colorPrimary,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      Consumer<GeneralProvider>(
                        builder: (context, provider, child) {
                          return InkWell(
                            onTap: provider.forloading
                                ? null
                                : () async {
                                    String email = emailController.text.trim();
                                    final emailRegex =
                                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                                    if (email.isEmpty) {
                                      Utils.showSnackbar(
                                          context, "please_enter_your_email", true);
                                      return;
                                    } else if (!emailRegex.hasMatch(email)) {
                                      Utils.showSnackbar(
                                          context, "please_enter_valid_email", true);
                                      return;
                                    }

                                    provider.setforgotloading(true);
                                    await provider.forgotpassworddata(email);

                                    if (!context.mounted) return;

                                    Utils.showSnackbar(
                                      context,
                                      provider.successmodel.message ?? "",
                                      provider.successmodel.status != 200,
                                    );

                                    provider.setforgotloading(false);

                                    if (provider.successmodel.status == 200) {
                                      Navigator.pop(context);
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
                              child: provider.forloading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      "Submit",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      // Signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (_, a, b) => const Register(),
                                  transitionDuration: const Duration(milliseconds: 150),
                                  transitionsBuilder: (_, animation, __, child) {
                                    return ClipPath(
                                      clipper: CircularRevealClipper(
                                          progress: animation.value),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: colorPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:yourappname/pages/forgetpassword.dart';
import 'package:yourappname/pages/genresprefrences.dart';
import 'package:yourappname/pages/phonepage.dart';
import 'package:yourappname/pages/register.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  File? mProfileImg;
  SharedPref sharedPre = SharedPref();

  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  String appleEmail = "";
  bool _showPassword = false;
  String? strDeviceType, strDeviceToken;
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

  _getData() {
    if (Constant.isDemoMode) {
      emailController.text = "jhu@g.com";
      passwordController.text = "123456";
    }
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

  @override
  void dispose() {
    _animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MyImage(
                        height: 80,
                        imagePath: "appicon.png",
                        fit: BoxFit.contain,
                        isAppicon: true,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Sign in to continue to your library",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form card
                FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                      child: Column(
                        children: [
                          // Email field
                          _buildInputField(
                            controller: emailController,
                            label: "Email Address",
                            hint: "you@example.com",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),

                          // Password field
                          _buildInputField(
                            controller: passwordController,
                            label: "Password",
                            hint: "Enter your password",
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            obscure: _showPassword,
                            onToggle: () => setState(() => _showPassword = !_showPassword),
                          ),
                          const SizedBox(height: 12),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => ForgetPassword()),
                              ),
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: colorPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Login button
                          _buildPrimaryButton(
                            isLoading: generalProvider.isLogin,
                            label: "Sign In",
                            onTap: () => _doLogin(generalProvider),
                          ),

                          const SizedBox(height: 24),
                          _buildDivider("or continue with"),
                          const SizedBox(height: 20),

                          // OTP login
                          _buildSocialButton(
                            icon: Icons.phone_android_rounded,
                            label: "Sign in with Phone / OTP",
                            onTap: () => Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (c, a1, a2) => PhonePage(),
                              transitionDuration: const Duration(milliseconds: 200),
                              transitionsBuilder: (c, a1, a2, child) =>
                                  ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
                            )),
                          ),
                          const SizedBox(height: 12),

                          // Google login
                          _buildSocialButton(
                            imagePath: "ic_google.png",
                            label: "Sign in with Google",
                            onTap: gmailLogin,
                          ),
                          const SizedBox(height: 12),

                          // Apple login (iOS only)
                          if (Platform.isIOS)
                            _buildSocialButton(
                              icon: Icons.apple_rounded,
                              label: "Sign in with Apple",
                              onTap: signInWithApple,
                            ),

                          const SizedBox(height: 28),

                          // Register link
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
                                onTap: () => Navigator.of(context).pushReplacement(PageRouteBuilder(
                                  pageBuilder: (c, a1, a2) => Register(),
                                  transitionDuration: const Duration(milliseconds: 200),
                                  transitionsBuilder: (c, a1, a2, child) =>
                                      ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
                                )),
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
                color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.03),
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

  Widget _buildSocialButton({
    IconData? icon,
    String? imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              MyImage(imagePath: imagePath, height: 20, width: 20)
            else if (icon != null)
              Icon(icon, size: 20, color: isDark ? Colors.white : const Color(0xFF374151)),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[200] : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(child: Divider(color: isDark ? Colors.grey[800] : const Color(0xFFE5E7EB))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[400]),
          ),
        ),
        Expanded(child: Divider(color: isDark ? Colors.grey[800] : const Color(0xFFE5E7EB))),
      ],
    );
  }

  void _doLogin(GeneralProvider gp) {
    bool emailValidation = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailController.text);
    if (emailController.text.isEmpty) {
      Utils.showSnackbar(context, "enteryouremailtologin", true);
    } else if (passwordController.text.isEmpty) {
      Utils.showSnackbar(context, "enteryourpasswordtologin", true);
    } else if (!emailValidation) {
      Utils.showSnackbar(context, "invalidemail", true);
    } else {
      _normalLogin("4", emailController.text, passwordController.text, strDeviceType, strDeviceToken);
    }
  }

  _normalLogin(type, email, password, deviceType, deviceToken) async {
    generalProvider.setLogin(true);
    try {
      await generalProvider.getLoginAPI(type, email, password, deviceType, deviceToken);
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
          await sharedPre.save("isEdit", "0");
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
          await sharedPre.save("isEdit", "1");
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
        if (context.mounted) {
          FocusScope.of(context).unfocus();
          final msg = (generalProvider.userModel.message ?? "").toLowerCase().contains("email and password wrong")
              ? "Invalid email or password"
              : (generalProvider.userModel.message ?? "Invalid credentials");
          Utils.showSnackbar(context, msg, false);
        }
        generalProvider.setLogin(false);
      }
    } catch (e) {
      if (context.mounted) {
        FocusScope.of(context).unfocus();
        Utils.showSnackbar(context, "Invalid email or password", false);
      }
      generalProvider.setLogin(false);
    }
  }

  Future<void> gmailLogin() async {
    try {
      // serverClientId is NOT supported on web platform
      final googleSignIn = GoogleSignIn(
        serverClientId: (!kIsWeb && Constant.googleWebClientId.isNotEmpty)
            ? Constant.googleWebClientId
            : null,
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      if (!mounted) return;
      Utils.showProgress(context);

      final auth2 = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: auth2.accessToken, idToken: auth2.idToken);
      final userCredential = await auth.signInWithCredential(credential);
      mProfileImg = await Utils.saveImageInStorage(userCredential.user?.photoURL ?? "");
      final nameParts = (googleUser.displayName ?? "").split(" ");
      await loginApi("2", googleUser.email, nameParts.first,
          userCredential.user?.photoURL ?? "", nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "");
    } catch (e) {
      printLog("Google Login error: $e");
      if (mounted) {
        Utils.hideProgress(context);
        Utils.showSnackbar(
          context,
          "Google sign-in failed. Please ensure your SHA-1 fingerprint is registered in Firebase.",
          false,
        );
      }
    }
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  Future<User?> signInWithApple() async {
    final rawNonce = generateNonce();
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
        nonce: sha256ofString(rawNonce),
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
          accessToken: appleCredential.authorizationCode);
      final result = await auth.signInWithCredential(oauthCredential);
      await loginApi("3", result.user?.email ?? "", appleCredential.givenName ?? "",
          result.user?.photoURL ?? "", appleCredential.familyName ?? "");
    } catch (e) {
      printLog("Apple Login error: $e");
    }
    return null;
  }

  loginApi(type, email, firstName, image, lastName) async {
    Utils.showProgress(context);
    try {
      await generalProvider.getSocialAPI(type, email, firstName, image, lastName, strDeviceToken, strDeviceType);
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
        if (!mounted) return;
        Utils.hideProgress(context);
        if ((generalProvider.userModel.result?[0].categoryIds.toString() ?? "") == "") {
          await sharedPre.save("isEdit", "0");
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
          await sharedPre.save("isEdit", "1");
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
        Utils.hideProgress(context);
        if (context.mounted) Utils.showSnackbar(context, generalProvider.userModel.message ?? "", false);
      }
    } catch (e) {
      Utils.hideProgress(context);
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webforgetpassword.dart';
import 'package:yourappname/webpages/webgenresprefrneces.dart';
import 'package:yourappname/webpages/webhome.dart';
import 'package:yourappname/webpages/webmobile.dart';
import 'package:yourappname/webpages/webregister.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/mytextformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Weblogin extends StatefulWidget {
  const Weblogin({super.key});

  @override
  State<Weblogin> createState() => _WebloginState();
}

class _WebloginState extends State<Weblogin> {
  SharedPref sharedPre = SharedPref();
  final FirebaseAuth auth = FirebaseAuth.instance;
  File? mProfileImg;
  // Normal Login Controller
  String appleEmail = "";
  bool showhidePassword = true;
  String? strDeviceType, strDeviceToken;
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  late GeneralProvider generalProvider;

  @override
  void initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _getDeviceToken();
    super.initState();
    getData();
  }

  getData() {
    if (Constant.isDemoMode) {
      emailController.text = "jhu@g.com";
      passwordController.text = "123456";
    }
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final isMobile = screenWidth <= 600;

    return Scaffold(
      body: Consumer<GeneralProvider>(builder: (context, provider, child) {
        return Row(
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
                            child: Text(
                              "Welcome",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Sign in to\n${Constant.appName}",
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
                            "Discover books, audiobooks, and magazines curated just for you.",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              _Bullet("Read anytime, anywhere"),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _Bullet("Thousands of titles"),
                            ],
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ── Right Login Form ──
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
                              _CloseButton(),
                            ],
                          ),
                          SizedBox(height: isDesktop ? 20 : 10),

                          // Header
                          Text(
                            "login",
                            style: TextStyle(
                              fontSize: isMobile ? 26 : 30,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "login_web_des",
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Email
                          _InputField(
                            controller: emailController,
                            hint: "Enter the email",
                            label: "email",
                            icon: FontAwesomeIcons.envelope,
                            obscure: false,
                          ),
                          const SizedBox(height: 16),

                          // Password
                          _InputField(
                            controller: passwordController,
                            hint: "Enter the Passwrod",
                            label: "password",
                            icon: FontAwesomeIcons.lock,
                            obscure: showhidePassword,
                            suffix: _PasswordToggle(),
                          ),
                          const SizedBox(height: 16),

                          // Remember me + Forgot
                          _rememberData(),
                          const SizedBox(height: 24),

                          // Login button
                          loginBtn(),
                          const SizedBox(height: 20),

                          // Register link
                          goingRegister(),
                          const SizedBox(height: 24),

                          // Or divider
                          orSection(),
                          const SizedBox(height: 24),

                          // Social login
                          loginWithSocial(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
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

  Widget _CloseButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.close_rounded, size: 22, color: Color(0xFF64748B)),
        ),
      ),
    );
  }

  Widget _PasswordToggle() {
    return InkWell(
      onTap: () => setState(() => showhidePassword = !showhidePassword),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          showhidePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          size: 20,
          color: const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _InputField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required dynamic icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Locales.string(context, label),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
              suffixIcon: suffix,
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget goingRegister() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          Locales.string(context, "donthaveanaccount"),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 6),
        InkWell(
          onTap: () {
            Navigator.of(context).pushReplacement(PageRouteBuilder(
              pageBuilder: (_, __, ___) => const WebRegister(),
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ));
          },
          child: Text(
            Locales.string(context, "register"),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colorAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _rememberData() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            activeColor: colorAccent,
            checkColor: Colors.white,
            value: generalProvider.isCheck,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            onChanged: (value) => generalProvider.setCheck(value),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          "remember_me",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF475569)),
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (_, __, ___) => const Webforgetpassword(),
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ));
          },
          child: Text(
            Locales.string(context, "forget_password"),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget loginBtn() {
    return InkWell(
      onTap: () {
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
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: colorAccent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: colorAccent.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        alignment: Alignment.center,
        child: generalProvider.isLogin
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Text(
                Locales.string(context, "login"),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  Widget orSection() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            Locales.string(context, "or"),
            style: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
      ],
    );
  }

  Widget loginWithSocial() {
    return Column(
      children: [
        socialLoginButton(
          imagePath: "google_logo.png",
          text: "googlelogin",
          onTap: () => gmailLogin(),
        ),
        const SizedBox(height: 12),
        socialLoginButton(
          imagePath: "phone_logo.png",
          text: "otploginn",
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (_, __, ___) => const WebMobile(),
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            ));
          },
        ),
      ],
    );
  }

  Widget socialLoginButton({
    required String imagePath,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyImage(width: 22, height: 22, imagePath: imagePath),
            const SizedBox(width: 10),
            Text(
              Locales.string(context, text),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
            ),
          ],
        ),
      ),
    );
  }

  /* Normal login API Started */

  _normalLogin(type, email, password, deviceType, deviceToken) async {
    generalProvider.setLogin(true);
    try {
      await generalProvider.getLoginAPI(
          type, email, password, deviceType, deviceToken);

      if (generalProvider.userModel.status == 200) {
        await Utils.saveUserCreds(
            userID: generalProvider.userModel.result?[0].id.toString() ?? "",
            categoryId:
                generalProvider.userModel.result?[0].categoryIds.toString() ??
                    "",
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
                generalProvider.userModel.result?[0].deviceType.toString() ??
                    "",
            deviceToken: generalProvider.userModel.result?[0].deviceToken.toString() ?? "",
            description: generalProvider.userModel.result?[0].description.toString() ?? "");
        generalProvider.setLogin(false);
        generalProvider.setTab("1");
        if ((generalProvider.userModel.result?[0].categoryIds.toString() ??
                "") ==
            "") {
          await sharedPre.save("isEdit", "0");

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return WebGenresPrefrences(
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
                          clipper:
                              CircularRevealClipper(progress: animation.value),
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
          await sharedPre.save("isEdit", "1");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return WebHome();
                  },
                  transitionDuration: Duration(milliseconds: 150),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        return ClipPath(
                          clipper:
                              CircularRevealClipper(progress: animation.value),
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
        Utils().showToast(generalProvider.userModel.message ?? "");
        generalProvider.setLogin(false);
      }
    } catch (e) {
      Utils().showToast(generalProvider.userModel.message ?? "");
      generalProvider.setLogin(false);
    }
  }

  /* Normal login API End */
  // Login With Google
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

      GoogleSignInAccount user = googleUser;
      if (!mounted) return;
      Utils.showProgress(context);

      GoogleSignInAuthentication googleSignInAuthentication =
          await user.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential userCredential = await auth.signInWithCredential(credential);
      mProfileImg =
          await Utils.saveImageInStorage(userCredential.user?.photoURL ?? "");
      final String? fullName = googleUser.displayName;

      // Split full name into first and last names
      final List<String> nameParts = fullName?.split(' ') ?? [];
      final String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final String lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final String profilePhotoUrl =
          userCredential.user?.photoURL ?? user.photoUrl ?? '';
      await loginApi("2", user.email, firstName, profilePhotoUrl, lastName);
    } catch (e) {
      printLog("Google Login error: $e");
      if (mounted) {
        Utils.hideProgress(context);
        Utils().showToast("Google Sign-In failed.");
      }
    }
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> signInWithApple() async {
    // printLog("Click Apple");
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // printLog(appleCredential.authorizationCode);

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
          accessToken: appleCredential.authorizationCode);

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final authResult = await auth.signInWithCredential(oauthCredential);

      final firebaseUser = authResult.user;
      // printLog("=================");

      final userEmail = '${firebaseUser?.email}';
      // // First and last name (only available on first login)
      // final String? firstName = appleCredential.givenName;
      // final String? lastName = appleCredential.familyName;
      // printLog(firebaseUser?.email.toString() ?? "");
      // printLog(firebaseUser?.phoneNumber.toString() ?? "");
      // printLog(firebaseUser?.displayName.toString() ?? "");
      // printLog(firebaseUser?.photoURL.toString() ?? "");
      // printLog(
      //   "${firstName ?? ""} $lastName",
      // );
      // printLog("=================");

      final firebasedId = firebaseUser?.uid;
      printLog("firebasedId ===> $firebasedId");

      loginApi(
          "3",
          userEmail,
          appleCredential.givenName ?? "",
          firebaseUser?.photoURL.toString() ?? "",
          appleCredential.familyName ?? "");
    } catch (exception) {
      printLog("Apple Login exception =====> $exception");
    }
    return null;
  }

  loginApi(
    type,
    email,
    firstName,
    image,
    lastName,
  ) async {
    Utils.showProgress(context);

    try {
      await generalProvider.getSocialAPI(type, email, firstName, image,
          lastName, strDeviceToken, strDeviceType);
      if (generalProvider.userModel.status == 200) {
          await Utils.saveUserCreds(
              userID: generalProvider.userModel.result?[0].id.toString() ?? "",
              categoryId:
                  generalProvider.userModel.result?[0].categoryIds.toString() ??
                      "",
              firstName:
                  generalProvider.userModel.result?[0].firstName.toString() ??
                      "",
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
              deviceType: generalProvider.userModel.result?[0].deviceType.toString() ?? "",
              deviceToken: generalProvider.userModel.result?[0].deviceToken.toString() ?? "",
              description: generalProvider.userModel.result?[0].description.toString() ?? "");
          if (!mounted) return;
          Utils.hideProgress(context);
          generalProvider.setTab("1");
          if ((generalProvider.userModel.result?[0].categoryIds.toString() ??
                  "") ==
              "") {
            await sharedPre.save("isEdit", "0");

            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return WebGenresPrefrences(
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
            await sharedPre.save("isEdit", "1");
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return WebHome();
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
        Utils().showToast(generalProvider.userModel.message ?? "");
        if (!mounted) return;
        Utils.hideProgress(context);
      }
    } catch (e) {
      Utils().showToast(generalProvider.userModel.message ?? "");
      if (!mounted) return;
      Utils.hideProgress(context);
    }
  }
}

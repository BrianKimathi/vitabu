import 'dart:io';
import 'dart:math';
import 'package:yourappname/pages/audiobookplaying.dart';
import 'package:yourappname/pages/login.dart';
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/adhelper.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/webpages/webhome.dart';
import 'package:yourappname/webpages/weblogin.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:math' as number;
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:url_launcher/url_launcher.dart';

printLog(String message) {
  if (kDebugMode) {
    return print(message);
  }
}

/// Web: Books → book detail → Read book. Filter console with **WEB_READ_BOOK**.
void webReadBookLog(String step, [String? detail]) {
  if (!kDebugMode) return;
  final extra = (detail == null || detail.isEmpty) ? '' : ' | $detail';
  print('[WEB_READ_BOOK] $step$extra');
}

/// One-line PDF / file URL for logs (truncated). Does not hide domain/path.
String webReadBookFormatPdfUrl(String? url) {
  if (url == null || url.isEmpty) return '(empty)';
  final t = url.trim();
  if (t.length > 180) {
    return '${t.substring(0, 180)}… (totalLen=${t.length})';
  }
  return t;
}

class Utils {
  String formatedDate(DateTime date) {
    return DateFormat("MMMM dd, yyyy").format(date);
  }

  static String formatDate(String? date) {
    if (date == null || date.isEmpty) return "-";

    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('MMMM dd, yyyy').format(parsedDate);
    } catch (e) {
      return date; // fallback if parsing fails
    }
  }

  static String formatTransactionDate(String date) {
    try {
      final d = DateTime.parse(date);
      return Utils.timeAgo(d); // you already use this
    } catch (_) {
      return date;
    }
  }

  static String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) {
      return "Just now";
    }

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    }

    if (diff.inHours < 24) {
      return "${diff.inHours} hr ago";
    }

    if (diff.inDays == 1) {
      return "Yesterday at ${_formatTime(date)}";
    }

    if (diff.inDays < 7) {
      return "${diff.inDays} days ago";
    }

    return _formatFullDate(date);
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final amPm = date.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $amPm";
  }

  static String _formatFullDate(DateTime date) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    return "${months[date.month - 1]} ${date.day}, ${date.year} at ${_formatTime(date)}";
  }

  static ProgressDialog? prDialog;
  // Global FontFamily All app Text
  static TextStyle googleFontStyle(int inter, double fontsize,
      FontStyle fontstyle, Color color, FontWeight fontwaight) {
    if (inter == 1) {
      return GoogleFonts.roboto(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 2) {
      return GoogleFonts.outfit(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 3) {
      return GoogleFonts.rubik(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else {
      return GoogleFonts.inter(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    }
  }

/* Show message  Good Morning ,Good Afternoon ☀️*/
  static String getGreetingMessage() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 0 && hour < 12) {
      return "Good Morning";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  static Widget showBannerAd(BuildContext context) {
    if (!kIsWeb) {
      return Container(
        constraints: BoxConstraints(
          minHeight: 0,
          minWidth: 0,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: AdHelper.bannerAd(context),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  static loadAds(BuildContext context) async {
    AdHelper.getAds(context);
  }

  static Widget backIcon(BuildContext context) {
    return Iconify(
      Mdi.keyboard_backspace,
      size: 25,
      color: Theme.of(context).canvasColor,
    );
  }

  closeBtn(color, size) {
    return Icon(
      Icons.close_sharp,
      color: color,
      size: double.parse(size.toString()),
    );
  }

  static Future<dynamic> pushWebPage({
    required BuildContext context,
    required Widget newChild,
  }) async {
    printLog("pushWebPage newChild ============> $newChild");
    dynamic result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return newChild;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
    printLog("pushWebPage result =======> $result");
    return result;
  }

  static void getCurrencySymbol() async {
    SharedPref sharedPref = SharedPref();
    Constant.currencySymbol = await sharedPref.read("currency_code") ?? "";
    debugPrint('Constant currencySymbol ==> ${Constant.currencySymbol}');
    Constant.currency = await sharedPref.read("currency") ?? "";
    debugPrint('Constant currency ==> ${Constant.currency}');
  }

  static BoxDecoration textFieldBGWithBorder() {
    return BoxDecoration(
      color: white,
      border: Border.all(
        color: gray,
        width: .2,
      ),
      borderRadius: BorderRadius.circular(4),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setBGWithBorder(Color colorPrimary, Color colorBorder,
      double radius, double borderWidth) {
    return BoxDecoration(
      color: colorPrimary,
      border: Border.all(
        color: colorBorder,
        width: borderWidth,
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setBackground(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide > Dimens.minWidth;
  }

  static void showProgresss(
      BuildContext context, ProgressDialog prDialog, String dialogMsg) async {
    printLog("width =======> ${MediaQuery.of(context).size.width}");
    prDialog = ProgressDialog(context);

    //For normal dialog
    prDialog = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false, showLogs: false);
    prDialog.style(
      message: dialogMsg,
      borderRadius: 5,
      progressWidget: Container(
        padding: const EdgeInsets.all(8),
        child: const CircularProgressIndicator(),
      ),
      maxProgress: 100,
      progressTextStyle: const TextStyle(
        color: black,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      backgroundColor: white,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: const TextStyle(
        color: black,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    );

    await prDialog.show();
  }

  static void updatePremium(String isPremiumBuy) async {
    printLog('updatePremium isPremiumBuy ==> $isPremiumBuy');
    SharedPref sharedPref = SharedPref();
    await sharedPref.save("userpremium", isPremiumBuy);
    String? isPremium = await sharedPref.read("userpremium");
    printLog('updatePremium ===============> $isPremium');
  }

  static AppBar cusstomAppBar({
    required String? name,
    bool? multilanguage,
    bool centerTitle = false, // 👈 default left
    required BuildContext context,
  }) {
    return AppBar(
      elevation: 0,
      backgroundColor: Constant.isDarkMode ? appbarcolor : white,
      surfaceTintColor: transparent,
      titleSpacing: 0,
      centerTitle: centerTitle, // 👈 control center/left
      title: MyText(
        text: name ?? "",
        isfont: 3,
        fontstyle: FontStyle.normal,
        maxline: 1,
        overflow: TextOverflow.ellipsis,
        color: Constant.isDarkMode ? white : black,
        fontsize: Dimens.medium16TextSize,
        multilanguage: multilanguage ?? true,
        fontwaight: FontWeight.w500,
      ),
      leading: Utils.backButton(context),
    );
  }

// Global  Toast Message
  showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: colorPrimary,
        textColor: black,
        fontSize: 14);
  }

/* Country code get */
  String getCountryCodeFromNumber(String fullNumber) {
    if (fullNumber.startsWith('+')) {
      for (var country in countries) {
        if (fullNumber.startsWith('+${country.dialCode}')) {
          printLog("My Country Code log ${country.code}");
          return country.code; // This gives you something like "AU", "IN"
        }
      }
    }
    return Constant.initialCountryCode ?? ""; // fallback if not matched
  }

// Widget Page Loader
  static Widget pageLoader(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        color: colorPrimary,
      ),
    );
  }

  /* ***************** generate Unique OrderID START ***************** */
  static String generateRandomOrderID() {
    int getRandomNumber;
    String? finalOID;
    printLog("fixFourDigit =>>> ${Constant.fixFourDigit}");
    printLog("fixSixDigit =>>> ${Constant.fixSixDigit}");

    number.Random r = number.Random();
    int ran5thDigit = r.nextInt(9);
    printLog("Random ran5thDigit =>>> $ran5thDigit");

    int randomNumber = number.Random().nextInt(9999999);
    printLog("Random randomNumber =>>> $randomNumber");
    if (randomNumber < 0) {
      randomNumber = -randomNumber;
    }
    getRandomNumber = randomNumber;
    printLog("getRandomNumber =>>> $getRandomNumber");

    finalOID = "${Constant.fixFourDigit.toInt()}"
        "$ran5thDigit"
        "${Constant.fixSixDigit.toInt()}"
        "$getRandomNumber";
    printLog("finalOID =>>> $finalOID");

    return finalOID;
  }
  /* ***************** generate Unique OrderID END ***************** */

  static Future<String> getPrivacyTandCText(
      {required String privacyUrl, required String termsConditionUrl}) async {
    printLog('privacyUrl ==> $privacyUrl');
    printLog('T&C Url =====> $termsConditionUrl');

    String strPrivacyAndTNC =
        "<p> By selecting Create Account below, I agree to <a href=$termsConditionUrl>Terms and Conditions</a> &"
        " <a href=$privacyUrl>Privacy Policy</a> </p>";

    printLog('strPrivacyAndTNC =====> $strPrivacyAndTNC');
    return strPrivacyAndTNC;
  }

  static void showSnackbar(
      BuildContext context, String message, bool multilanguage) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: Colors.transparent,
      width: kIsWeb
          ? ((MediaQuery.of(context).size.width > 1000)
              ? (MediaQuery.of(context).size.width * 0.3)
              : (MediaQuery.of(context).size.width))
          : (MediaQuery.of(context).size.width),
      content: Container(
        constraints: const BoxConstraints(minHeight: kIsWeb ? 60 : 50),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: mainGradient(),
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.all(kIsWeb ? 15 : 10),
        child: MyText(
          text: message,
          multilanguage: multilanguage,
          fontstyle: FontStyle.normal,
          fontsize: Dimens.medium14TextSize,
          maxline: 5,
          overflow: TextOverflow.ellipsis,
          fontwaight: FontWeight.w500,
          color: white,
          textalign: TextAlign.center,
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static Html htmlTexts(BuildContext context, var strText) {
    return Html(
      data: strText,
      style: {
        "body": Style(
          color: Theme.of(context).primaryColor,
          fontSize: FontSize(Dimens.medium14TextSize),
          fontWeight: FontWeight.w400,
        ),
        "a": Style(
          color: colorAccent,
          fontSize: FontSize(Dimens.medium14TextSize),
          fontWeight: FontWeight.w700,
        ),
      },
      onLinkTap: (url, _, ___) async {
        printLog("htmlTexts url =========> $url");
        if (await canLaunchUrl(Uri.parse(url ?? ""))) {
          await launchUrl(
            Uri.parse(url ?? ""),
            mode: LaunchMode.platformDefault,
          );
        } else {
          throw 'Could not launch $url';
        }
      },
      shrinkWrap: true,
    );
  }

  static showDynamicSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        backgroundColor: colorPrimary,
        content: MyText(
          text: message,
          fontsize: Dimens.medium14TextSize,
          maxline: 2,
          fontwaight: FontWeight.w500,
          color: white,
          textalign: TextAlign.center,
        ),
      ),
    );
  }

/* Back Button in Ios and android */
  static backButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: Icon(
        Icons.arrow_back_ios_new,
        size: 20,
      ),
    );
  }

  static void showProgress(BuildContext context) async {
    if (prDialog != null && prDialog!.isShowing()) {
      return;
    }

    // For normal dialog
    prDialog = ProgressDialog(
      context,
      type: ProgressDialogType.normal,
      isDismissible: false,
      showLogs: false,
    );

    prDialog?.style(
      message: "Please Wait",
      borderRadius: 5,
      progressWidget: Container(
        padding: const EdgeInsets.all(8),
        child: const CircularProgressIndicator(),
      ),
      maxProgress: 100,
      progressTextStyle: const TextStyle(
        color: colorPrimaryDark,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      backgroundColor: white,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: const TextStyle(
        color: colorPrimaryDark,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    );

    try {
      await prDialog?.show();
    } catch (e) {
      printLog("showProgress exception => $e");
    }
  }

  static void hideProgress(BuildContext context) async {
    try {
      if (prDialog != null && prDialog!.isShowing()) {
        await prDialog!.hide();
      }
    } catch (e) {
      printLog("hideProgress exception => $e");
    }
  }

  static Future<void> deleteCacheDir() async {
    if (Platform.isAndroid) {
      var tempDir = await getTemporaryDirectory();

      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    }
  }

  static Future<void> redirectToMainPage(
      {required BuildContext context}) async {
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (BuildContext context) => const Bottombar()),
      (Route<dynamic> route) => false,
    ).then(
      (value) {
        if (!context.mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const Bottombar()),
        );
      },
    );
  }

  pdfIcon() {
    return Icon(
      Icons.picture_as_pdf_outlined,
      size: 26,
      color: colorPrimary,
    );
  }

// String Image Url Convert To File Variable And Pass Login With Gmail Method
  static Future<File?> saveImageInStorage(imgUrl) async {
    try {
      var response = await http.get(Uri.parse(imgUrl));
      Directory? documentDirectory;
      if (Platform.isAndroid) {
        documentDirectory = await getExternalStorageDirectory();
      } else {
        documentDirectory = await getApplicationDocumentsDirectory();
      }
      File file = File(path.join(documentDirectory?.path ?? "",
          '${DateTime.now().millisecondsSinceEpoch.toString()}.png'));
      file.writeAsBytesSync(response.bodyBytes);
      // This is a sync operation on a real
      // app you'd probably prefer to use writeAsByte and handle its Future
      return file;
    } catch (e) {
      printLog("saveImageInStorage Exception ===> $e");
      return null;
    }
  }

  static successDialog({required BuildContext context, required String? data}) {
    return showDialog(
        context: context,
        builder: (_) => Dialog(
              backgroundColor: transparent,
              insetPadding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Container(
                height: 310,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                decoration: BoxDecoration(
                    color: white, borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    MyImage(
                      imagePath: "appicon.png",
                      height: 210,
                      width: MediaQuery.of(context).size.width,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.09,
                    ),
                    MyText(
                      color: black,
                      text: data!,
                      textalign: TextAlign.center,
                      fontsize: Dimens.largeTextSize,
                      maxline: 5,
                      multilanguage: true,
                      fontwaight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
            ));
  }

  static checkLoginUser(BuildContext context) {
    if (Constant.userID != null) {
      return true;
    }

    Widget loginScreen;
    if (kIsWeb) {
      loginScreen = Weblogin();
    } else {
      loginScreen = Login();
    }

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) {
        return loginScreen;
      },
      transitionDuration: const Duration(milliseconds: 150),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
    ));

    return false;
  }

  static getCurrencyDetails() async {
    SharedPref sharedpre = SharedPref();
    Constant.currencyCode = await sharedpre.read("currency_code");
    Constant.currency = await sharedpre.read("currency");
    printLog("currencyCode -----?? ${Constant.currencyCode}");
    printLog("currency -----?? ${Constant.currency}");
  }

  static String convertToAgo(String dateTime) {
    DateTime input = DateTime.parse(dateTime);
    Duration diff = DateTime.now().difference(input);

    if (diff.inDays >= 1) {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} second${diff.inSeconds == 1 ? '' : 's'} ago';
    } else {
      return 'just now';
    }
  }

  static saveUserCreds({
    required userID,
    required categoryId,
    required firstName,
    required lastName,
    required userName,
    required userImage,
    required userEmail,
    required mobileNumber,
    required walletCoin,
    required address,
    required isAuthor,
    required deviceType,
    required deviceToken,
    required description,
  }) async {
    SharedPref sharedPre = SharedPref();
    if (userID != null) {
      await sharedPre.save("userid", userID);
      await sharedPre.save("categoryId", categoryId);
      await sharedPre.save("firstName", firstName);
      await sharedPre.save("lastName", lastName);
      await sharedPre.save("username", userName);
      await sharedPre.save("userimage", userImage);
      await sharedPre.save("useremail", userEmail);
      await sharedPre.save("usermobile", mobileNumber);
      await sharedPre.save("walletCoin", walletCoin);
      await sharedPre.save("address", address);
      await sharedPre.save("isAuthor", isAuthor);
      await sharedPre.save("deviceType", deviceType);
      await sharedPre.save("deviceToken", deviceToken);
      await sharedPre.save("description", description);
    } else {
      await sharedPre.remove("userid");
      await sharedPre.remove("categoryId");
      await sharedPre.remove("firstName");
      await sharedPre.remove("lastName");
      await sharedPre.remove("username");
      await sharedPre.remove("userimage");
      await sharedPre.remove("useremail");
      await sharedPre.remove("usermobile");
      await sharedPre.remove("walletCoin");
      await sharedPre.remove("address");
      await sharedPre.remove("isAuthor");
      await sharedPre.remove("deviceType");
      await sharedPre.remove("deviceToken");
      await sharedPre.remove("description");
    }

    Constant.userID = await sharedPre.read("userid");
    Constant.userName = await sharedPre.read("username");
    Constant.userCategoryId = await sharedPre.read("categoryId");
    Constant.isAuthor = await sharedPre.read("isAuthor");
    Constant.userimage = await sharedPre.read("userimage");
    Constant.isSubscription =
        int.tryParse(await sharedPre.read("is_subscription") ?? "0") ?? 0;

    printLog('setUserId userID ==> ${Constant.userID}');
    printLog('setUserId subscription ==> ${Constant.isSubscription}');

    printLog('setUserId userCategoryId ==> ${Constant.userCategoryId}');
  }

  static removeUser() async {
    SharedPref sharedPre = SharedPref();

    await sharedPre.remove("userid");
    await sharedPre.remove("categoryId");
    await sharedPre.remove("firstName");
    await sharedPre.remove("lastName");
    await sharedPre.remove("username");
    await sharedPre.remove("userimage");
    await sharedPre.remove("useremail");
    await sharedPre.remove("usermobile");
    await sharedPre.remove("walletCoin");
    await sharedPre.remove("address");
    await sharedPre.remove("isAuthor");
    await sharedPre.remove("deviceType");
    await sharedPre.remove("deviceToken");
    await sharedPre.remove("description");
    await sharedPre.remove("is_subscription");
  }

  /* Update Required profile data before Payment START ************************/
  static Widget dataUpdateDialog(
    BuildContext context, {
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController mobileController,
  }) {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        padding: const EdgeInsets.all(23),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /* Title & Subtitle */
            Container(
              alignment: Alignment.centerLeft,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    color: black,
                    text: "update_profile",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsize: Dimens.medium16TextSize,
                    fontwaight: FontWeight.w700,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ],
              ),
            ),

            /* Fullname */
            const SizedBox(height: 30),
            if (isNameReq)
              _buildTextFormField(
                controller: nameController,
                hintText: "full_name",
                inputType: TextInputType.name,
                readOnly: false,
              ),

            /* Email */
            if (isEmailReq)
              _buildTextFormField(
                controller: emailController,
                hintText: "email_address",
                inputType: TextInputType.emailAddress,
                readOnly: false,
              ),

            /* Mobile */
            if (isMobileReq)
              _buildTextFormField(
                controller: mobileController,
                hintText: "mobile_number",
                inputType: const TextInputType.numberWithOptions(
                    signed: false, decimal: false),
                readOnly: false,
              ),
            const SizedBox(height: 5),

            /* Cancel & Update Buttons */
            Container(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /* Cancel */
                  InkWell(
                    onTap: () {
                      // final profileEditProvider =
                      //     Provider.of<ProfileProvider>(context, listen: false);
                      // // if (!profileEditProvider.editprofileloading) {
                      //   Navigator.pop(context, false);
                      // }
                    },
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 75),
                      height: 50,
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: black,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const MyText(
                        color: black,
                        text: "Cancel",
                        multilanguage: false,
                        textalign: TextAlign.center,
                        fontsize: Dimens.medium16TextSize,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontwaight: FontWeight.w500,
                        fontstyle: FontStyle.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  /* Submit */
                  Consumer<ProfileProvider>(
                    builder: (context, profileEditProvider, child) {
                      // if (profileEditProvider.editprofileloading) {
                      //   return Container(
                      //     width: 100,
                      //     height: 50,
                      //     padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
                      //     alignment: Alignment.center,
                      //     child: pageLoader(),
                      //   );
                      // }
                      return InkWell(
                        onTap: () async {
                          final fullName =
                              nameController.text.toString().trim();
                          final emailAddress =
                              emailController.text.toString().trim();
                          final mobileNumber =
                              mobileController.text.toString().trim();

                          printLog(
                              "fullName =======> $fullName ; required ========> $isNameReq");
                          printLog(
                              "emailAddress ===> $emailAddress ; required ====> $isEmailReq");
                          printLog(
                              "mobileNumber ===> $mobileNumber ; required ====> $isMobileReq");
                          if (isNameReq && fullName.isEmpty) {
                            Utils.showSnackbar(context, "enter_fullname", true);
                          } else if (isEmailReq && emailAddress.isEmpty) {
                            Utils.showSnackbar(context, "enter_email", true);
                          } else if (isMobileReq && mobileNumber.isEmpty) {
                            Utils.showSnackbar(
                                context, "enter_mobile_number", true);
                          } else if (isEmailReq &&
                              !EmailValidator.validate(emailAddress)) {
                            Utils.showSnackbar(
                                context, "enter_valid_email", true);
                          } else {
                            // final profileEditProvider =
                            //     Provider.of<ProfileProvider>(context,
                            //         listen: false);
                            // await profileEditProvider.setUpdateLoading(true);

                            // await profileEditProvider.getUpdateDataForPayment(
                            //     fullName, emailAddress, mobileNumber);
                            // if (!profileEditProvider.editprofileloading) {
                            //   // await profileEditProvider.setUpdateLoading(false);
                            //   if (profileEditProvider.userModel.status == 200) {
                            //     if (isNameReq) {
                            //       await sharedPref.save('fullname', fullName);
                            //     }
                            //     if (isEmailReq) {
                            //       await sharedPref.save(
                            //           'newEmail', emailAddress);
                            //     }
                            //     if (isMobileReq) {
                            //       await sharedPref.save(
                            //           'mobilenumber', mobileNumber);
                            //     }
                            //     if (context.mounted) {
                            //       Navigator.pop(context, true);
                            //     }
                            //   }
                            // }
                          }
                        },
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 75),
                          height: 50,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(5),
                            shape: BoxShape.rectangle,
                          ),
                          child: const MyText(
                            color: black,
                            text: "submit",
                            textalign: TextAlign.center,
                            fontsize: Dimens.medium16TextSize,
                            multilanguage: true,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontwaight: FontWeight.w700,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType inputType,
    required bool readOnly,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 45),
      margin: const EdgeInsets.only(bottom: 25),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        textInputAction: TextInputAction.next,
        obscureText: false,
        maxLines: 1,
        readOnly: readOnly,
        cursorColor: colorAccent,
        cursorRadius: const Radius.circular(2),
        decoration: InputDecoration(
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7)),
            borderSide: BorderSide(width: 1, color: ligthDark),
          ),
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7)),
            borderSide: BorderSide(width: 1, color: ligthDark),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7)),
            borderSide: BorderSide(width: 1, color: ligthDark),
          ),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
              borderSide: BorderSide(width: 1, color: ligthDark)),
          filled: true,
          isDense: false,
          fillColor: transparent,
          hintText: hintText,
          hintStyle: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontSize: Dimens.medium14TextSize,
              color: black,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.roboto(
          textStyle: const TextStyle(
            fontSize: Dimens.medium14TextSize,
            color: black,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.normal,
          ),
        ),
      ),
    );
  }

  /* *********************** Update Required profile data before Payment END */

  // Time change code UTC forment to normal forment
  static timeDuaration(int inputTime) {
    int input = inputTime;
    if (input == 0) {
      return "";
    }

    int seconds = input ~/ 1000; // convert milliseconds to seconds
    int hours = seconds ~/ 3600;
    seconds %= 3600;
    int minutes = seconds ~/ 60;
    seconds %= 60;

    String output =
        "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";

    return output;
  }

  static dateConvert(String date, String format) {
    final DateTime now = DateTime.parse(date);
    final DateFormat formatter = DateFormat(format);
    return formatter.format(now);
  }

// Date chage code UTC forment to normal forment
  static dateTimeShow(String inputDate) {
    String input = inputDate;
    if (input.isEmpty) {
      return "";
    }
    try {
      DateTime dateTime = DateTime.parse(input);
      String output = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
      return output;
    } catch (e) {
      printLog("Error....${e.toString()}");
    }
  }

// Time chage code UTC forment to normal forment
  static timeShow(String inputDate) {
    String input = inputDate;
    if (input.isEmpty) {
      return "";
    }
    try {
      DateTime dateTime = DateTime.parse(input);
      String output = "${dateTime.hour}:${dateTime.second}";
      return output;
    } catch (e) {
      printLog("Error....${e.toString()}");
    }
  }

  static String kmbGenerator(int num) {
    return NumberFormat.compact().format(num);
  }

  static setFirstTime(value) async {
    SharedPref sharePref = SharedPref();
    await sharePref.save("seen", value);
    String seenValue = await sharePref.read("seen");
    printLog('setFirstTime seen ==> $seenValue');
  }

/* File path get Code */
  static String getEx(url) {
    String extension = path.extension(url).replaceFirst('.', '');

    printLog(extension); // Output: pdf
    return extension;
  }

  /* Music Panel */
  static Widget buildMusicPanel(context) {
    return ValueListenableBuilder(
      valueListenable: currentlyPlaying,
      builder: (BuildContext context, AudioPlayer? audioObject, Widget? child) {
        if (audioObject?.audioSource != null) {
          return AudioBookPlaying();
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  /* Url Luncher code */

  static Future<void> launchURL(url) async {
    final Uri uri = Uri.parse(url);
    printLog("Url====================>>>> $url");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  static int customCrossAxisCount(
      {required BuildContext context,
      required int height1600,
      required int height1200,
      required int height800,
      required int height400}) {
    if (MediaQuery.of(context).size.width > 1600) {
      return height1600;
    } else if (MediaQuery.of(context).size.width > 1200) {
      return height1200;
    } else if (MediaQuery.of(context).size.width > 800) {
      return height800;
    } else if (MediaQuery.of(context).size.width > 400) {
      return height400;
    } else {
      return height400;
    }
  }

/* Web details app bar */
  static Widget buildWebDetailsAppBar({
    required BuildContext context,
    String? title1,
    String? title2,
    String? title3,
    required bool isHome,
    bool? multilanguage,
    bool isFromHomeRedirect = false,
  }) {
    return Consumer<GeneralProvider>(
      builder: (context, generalprovider, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final bool isWide = screenWidth > 1000;

        return Container(
          height: 75,
          padding: isWide
              ? const EdgeInsets.symmetric(vertical: 20)
              : const EdgeInsets.fromLTRB(0, 10, 20, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    generalprovider.setTab("1");
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const WebHome()),
                      (route) => false,
                    );
                  }
                },
                child: MyText(
                  text: "home",
                  multilanguage: true,
                  fontsize: Dimens.medium16TextSize,
                  fontwaight: FontWeight.w600,
                  color: black,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if ((title1?.isNotEmpty ?? false) && !isFromHomeRedirect)
                _breadcrumbItem(context, title1!, multilanguage ?? true),
              if (title2?.isNotEmpty ?? false)
                _breadcrumbItem(context, title2!, multilanguage ?? true),
              if (title3?.isNotEmpty ?? false)
                _breadcrumbItem(context, title3!, multilanguage ?? true),
            ],
          ),
        );
      },
    );
  }

  static Widget _breadcrumbItem(
    BuildContext context,
    String text,
    bool multilanguage,
  ) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chevron_right,
            size: 18,
            color: black.withOpacity( 0.4),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
              },
              child: MyText(
                text: text,
                multilanguage: multilanguage,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontsize: Dimens.medium16TextSize,
                fontwaight: FontWeight.w500,
                color: colorPrimaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Helper for clickable breadcrumb

  /*Random color  */

  static Color getRandomLightColor() {
    final random = Random();
    final hue = random.nextDouble() * 360;
    final saturation = 0.25 + random.nextDouble() * 0.25;
    final lightness = 0.85 + random.nextDouble() * 0.10;
    return HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();
  }

  static Color getRandomDarkColor() {
    final random = Random();
    final hue = random.nextDouble() * 360;
    final saturation = 0.5 + random.nextDouble() * 0.4;
    final lightness = 0.25 + random.nextDouble() * 0.15;
    return HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();
  }

  static Future<dynamic> push(
    BuildContext context,
    Widget page, {
    Duration duration = const Duration(milliseconds: 150),
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: duration,
        pageBuilder: (context, animation, secondaryAnimation) {
          return page;
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
    );
  }
}

class ScreenSecurityService {
  static void enableScreenCapture() async {
    await ScreenProtector.preventScreenshotOn();
    if (Platform.isIOS) {
      await ScreenProtector.protectDataLeakageWithBlur();
    } else if (Platform.isAndroid) {
      await ScreenProtector.protectDataLeakageOn();
    }
  }

  static Future<void> allowScreenshot() async {
    await ScreenProtector.preventScreenshotOff();
    await ScreenProtector.protectDataLeakageOff();
  }
}

class AccessInfo {
  final String badgeLabel; // image upar
  final String priceText; // niche
  final Color badgeBg;
  final Color badgeTextColor;

  AccessInfo({
    required this.badgeLabel,
    required this.priceText,
    required this.badgeBg,
    required this.badgeTextColor,
  });
}

AccessInfo getAccessInfo({
  required String? accessType,
  required String? isBuy,
  required int isSubscription,
  required String? price,
}) {
  // FREE (Access Type 0)
  if (accessType == "0") {
    return AccessInfo(
      badgeLabel: "Free",
      priceText: "Free",
      badgeBg: const Color(0xFFD1FFD1),
      badgeTextColor: Colors.green.shade900,
    );
  }

  // PAID (Access Type 1)
  if (accessType == "1") {
    if (isBuy == "1") {
      return AccessInfo(
        badgeLabel: "Purchased",
        priceText: "Purchased",
        badgeBg: const Color(0xFFD1FFD1),
        badgeTextColor: Colors.green.shade900,
      );
    } else {
      return AccessInfo(
        badgeLabel: "Paid",
        priceText: "${Constant.currencySymbol} ${price ?? ""}",
        badgeBg: const Color(0xFFFFD1D1),
        badgeTextColor: Colors.red.shade900,
      );
    }
  }

  // SUBSCRIPTION (Access Type 2)
  if (accessType == "2") {
    if (isSubscription == 1) {
      return AccessInfo(
        badgeLabel: "Subscribed",
        priceText: "Subscribed",
        badgeBg: const Color(0xFFE0E7FF),
        badgeTextColor: const Color(0xFF3730A3),
      );
    } else {
      return AccessInfo(
        badgeLabel: "Subscription",
        priceText: "Subscription",
        badgeBg: const Color(0xFFD1E8FF),
        badgeTextColor: Colors.blue.shade900,
      );
    }
  }

  // FALLBACK
  return AccessInfo(
    badgeLabel: "Free",
    priceText: "Free",
    badgeBg: const Color(0xFFD1FFD1),
    badgeTextColor: Colors.green.shade900,
  );
}

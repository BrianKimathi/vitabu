class Constant {
  // Base URL for backend API requests.
  // Backend routes are mounted under /api (see admin_panel/app/Providers/RouteServiceProvider.php).
  final String baseurl = "https://console.vitabu.online/api/";

  static String appName = "Vitabu"; /* App display name */
  static String appPackageName =
      "com.mtaanihub.vitabu"; /* Enter your package name */
  static String? initialCountryCode = "KE";
  static String fireUserID = "0";
  static String appleAppId = ""; /* Enter your apple ID */
  static String googleWebClientId =
      "863664393620-gintnu45tvrl1p867tdcgkkn29fp547i.apps.googleusercontent.com";
  static String? appversion = '1.0.0';
  static String? appyear = '2026';

  static String? companytitle;
  static String? devlogo;

  /* Demo Mode */
  static bool isDemoMode = false;

  static String? userID;
  static String? userimage;
  static String? userName;

  static String? userCategoryId;
  static String? isAuthor;
  static String? appDescription;
  static String? contactInfo;
  static String? email;
  static String? address;
  static String? website;
  static String androidAppUrl =
      "https://play.google.com/store/apps/details?id=$appPackageName";
  static String iosAppUrl = "https://apps.apple.com/us/app/id$appleAppId";

  static String? currencySymbol;

  /* Show Ad By Type */

  static String rewardAdType = "rewardAd";
  static String interstialAdType = "interstialAd";

  static String? currency; // USD,INR etc..
  static String? currencyCode; // $

  static int fixFourDigit = 1317;
  static int fixSixDigit = 161613;

/* Dark Light Mode */
  static bool isDarkMode = false;

  static int? isSubscription;
}

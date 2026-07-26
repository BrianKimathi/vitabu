import 'package:yourappname/model/pagesmodel.dart' hide Result;
import 'package:yourappname/model/onboardingmodel.dart' hide Result;
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/model/usermodel.dart' hide Result;
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:yourappname/model/generalsettingmodel.dart';
import 'package:yourappname/webservice/apiservice.dart';

class GeneralProvider extends ChangeNotifier {
  int? bookRating;
  int? magazineRating;

  Generalsettingmodel generalModel = Generalsettingmodel();
  UserModel userModel = UserModel();
  SuccessModel addViewModel = SuccessModel();
  PagesModel pagesModel = PagesModel();
  OnBoardingModel onBoardingModel = OnBoardingModel();
  bool loading = false;
  bool isLogin = false;

  String? appDescription;
  String? contactInfo;
  String? email;
  String? address;
  String? website;
  SharedPref sharedPre = SharedPref();
  List<int> ids = [];
  int? pageIdex = 0;

  setIntroIndexChange(index) {
    if (index < 0) return;
    pageIdex = index;
    notifyListeners();
  }

  selectIds(index) {
    if (ids.contains(index)) {
      ids.remove(index);
    } else {
      ids.add(index);
    }
    notifyListeners();
  }

  Future<void> getGeneralsetting(context) async {
    loading = true;
    generalModel = await ApiService().generalsetting();
    appDescription = await sharedPre.read("app_desripation") ?? "";
    email = await sharedPre.read("email") ?? "";
    contactInfo = await sharedPre.read("contact") ?? "";
    website = await sharedPre.read("website") ?? "";
    if (generalModel.status == 200) {
      if (generalModel.result != null) {
        for (var i = 0; i < (generalModel.result?.length ?? 0); i++) {
          await sharedPre.save(
            generalModel.result?[i].key.toString() ?? "",
            generalModel.result?[i].value.toString() ?? "",
          );
          debugPrint(
              '${generalModel.result?[i].key.toString()} ==> ${generalModel.result?[i].value.toString()}');
        }

        await getOnBoarding();
        Constant.userID = await sharedPre.read("userid");
        Constant.userCategoryId = await sharedPre.read("categoryId");
        Constant.isAuthor = await sharedPre.read("isAuthor");
        Utils.getCurrencyDetails();
        Utils.getCurrencySymbol();
        Constant.appDescription = await sharedPre.read("app_description") ?? "";
        Constant.email = await sharedPre.read("email") ?? "";
        Constant.address = await sharedPre.read("address") ?? "";
        Constant.contactInfo = await sharedPre.read("contact") ?? "";
        Constant.website = await sharedPre.read("website") ?? "";
        Constant.devlogo = await sharedPre.read("company_logo") ?? "";
        Constant.companytitle = await sharedPre.read("company_name") ?? "";
        Constant.isSubscription =
            int.tryParse(await sharedPre.read("is_subscription") ?? "0") ?? 0;

        debugPrint("Is Subscription =========> ${Constant.isSubscription}");
        debugPrint("appDescription ===========> $appDescription");
        debugPrint(
            "appDescription ===========> ${Constant.userCategoryId ?? ""}");
      }
      applyScreenshotSetting(generalModel.result);
    }
    loading = false;
    notifyListeners();
  }

/* ---------------- Screeenshot manage  ---------------- */

  bool _isScreenshotAllowed = true;
  bool get isScreenshotAllowed => _isScreenshotAllowed;

  void applyScreenshotSetting(List<Result>? list) {
    try {
      final value = list!.firstWhere((e) => e.key == "screenshot").value;

      _isScreenshotAllowed = value == "1";
    } catch (e) {
      _isScreenshotAllowed = true;
    }

    if (_isScreenshotAllowed) {
      ScreenSecurityService.allowScreenshot();
    } else {
      ScreenSecurityService.enableScreenCapture();
    }

    notifyListeners();
  }

  Future<void> getOnBoarding() async {
    loading = true;
    onBoardingModel = await ApiService().onBoardingResponse();
    loading = false;
    notifyListeners();
  }

  Future<void> getPages() async {
    loading = true;
    pagesModel = await ApiService().pagesResponse();
    loading = false;
    notifyListeners();
  }

  Future<void> getLoginAPI(
      type, email, password, deviceType, deviceToken) async {
    loading = true;
    userModel = await ApiService()
        .normalLogin(type, email, password, deviceType, deviceToken);
    loading = false;
    notifyListeners();
  }

  Future<void> getSocialAPI(
    type,
    email,
    firstName,
    image,
    lastName,
    deviceToken,
    deviceType,
  ) async {
    loading = true;
    notifyListeners();
    try {
      userModel = await ApiService().socialLogin(
        type,
        email,
        firstName,
        image,
        lastName,
        deviceToken,
        deviceType,
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getOTPAPI(type, mobile, deviceToken, deviceType) async {
    loading = true;
    userModel =
        await ApiService().otpLogin(type, mobile, deviceToken, deviceType);
    loading = false;
    notifyListeners();
  }

  Future<void> getregister(
    firstName,
    lastName,
    email,
    password,
    number,
    deviceType,
    deviceToken,
  ) async {
    printLog("getregister called");

    loading = true;
    try {
      userModel = await ApiService().register(
        firstName,
        lastName,
        email,
        password,
        number,
        deviceType,
        deviceToken,
      );
      printLog("getregister status = ${userModel.status}");
    } catch (e) {
      printLog("getregister exception = $e");
      // Create a minimal error model so callers can check userModel.status
      userModel = UserModel(status: 400, message: "Connection error: $e");
    }
    loading = false;
    notifyListeners();
  }

  setLogin(value) {
    isLogin = value;
    notifyListeners();
  }

  addAddView(chapterid, bookid, magazineid) async {
    setLogin(true);
    addViewModel = await ApiService().addView(chapterid, bookid, magazineid);
    loading = false;
    notifyListeners();
  }

  setBookRating(int rating) {
    bookRating = rating;
    notifyListeners();
  }

  setMagazineRating(int rating) {
    magazineRating = rating;
    notifyListeners();
  }

/* NavigationBar Index */
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  /* Fogot password */
  SuccessModel successmodel = SuccessModel();
  bool forloading = false;
  Future<void> forgotpassworddata(email) async {
    setforgotloading(true);
    successmodel = await ApiService().forgotpassword(email);
    setforgotloading(false);
  }

  setforgotloading(value) {
    forloading = value;
    notifyListeners();
  }

/* ***************************** WEB Started ***************************** */
  bool isCheck = false;

  setCheck(index) {
    isCheck = index;
    notifyListeners();
  }

  String? selectTab = "1";

  setTab(value) {
    selectTab = value;
    notifyListeners();
  }

  bool isNotification = false;
  getNotificationSectionShowHide(notification) {
    isNotification = notification;
    printLog("My Notification Tab $isNotification");
    notifyListeners();
  }

/* ***************************** WEB EMD ***************************** */

  clearWeb() {
    isCheck = false;
    selectTab = "1";
  }

  clearProvider() {
    pageIdex = 0;
    ids = [];
    ids.clear();
    _currentIndex = 0;
  }
}

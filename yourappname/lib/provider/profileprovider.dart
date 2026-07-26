import 'dart:typed_data';

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:yourappname/model/getsociallinkmodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/model/usermodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/model/pagesmodel.dart';
import 'package:yourappname/model/profilemodel.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:yourappname/model/audiobookmodel.dart' as audio;
import 'package:yourappname/model/bookmodel.dart' as book;
import 'package:yourappname/model/magazinemodel.dart' as magazine;

class ProfileProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  UserModel userModel = UserModel();
  PagesModel pagesModel = PagesModel();
  SuccessModel successModel = SuccessModel();
  book.BookModel bookModel = book.BookModel();
  magazine.MagazineModel magazineModel = magazine.MagazineModel();
  audio.AudioBookModel audioBookModel = audio.AudioBookModel();
  bool loadMore = false;
  bool contentLoading = false;
  bool becomeAUthorLoading = false;
  bool contactloading = false;

  List<book.Result>? bookList = [];
  List<magazine.Result>? magazineList = [];
  List<audio.Result>? audioList = [];

  bool loading = false;
  String? selectedType = "1";

  // ---- OTP State ----
  bool otpSending = false;
  bool otpSent = false;
  bool otpVerified = false;
  String otpMessage = '';
  int otpTimerSeconds = 0;

  // ---- KYC Image State ----
  Uint8List? idFrontBytes;
  String? idFrontName;
  Uint8List? idBackBytes;
  String? idBackName;
  Uint8List? selfieBytes;
  String? selfieName;

  setType(index) {
    selectedType = index;
    notifyListeners();
  }

  setLoding(isLoding) {
    loading = isLoding;
    contentLoading = isLoding;
    notifyListeners();
  }

  SharedPref sharedPre = SharedPref();

    getProfile(userId) async {
    if (userId == null || userId.toString().trim().isEmpty || userId.toString() == "0") {
      loading = false;
      notifyListeners();
      return;
    }
    loading = true;
    profileModel = await ApiService().profileResponse(userId);

    if (profileModel.status == 200 &&
        profileModel.result != null &&
        profileModel.result!.isNotEmpty) {
      final result = profileModel.result!.first;

      await sharedPre.save(
        "is_subscription",
        (result.isSubscription ?? 0).toString(),
      );

      Constant.isSubscription = result.isSubscription ?? 0;
    }

    loading = false;
    notifyListeners();
  }

  getBecomeAuthor({
    required String role,
    required String paymentMethod,
    String? bankCode,
    String? bankname,
    String? bankholdername,
    String? accountno,
    String? mpesaPhone,
    String? mobileNumber,
    String? password,
    // KYC image files
    dynamic idFrontImage,
    dynamic idBackImage,
    dynamic selfieImage,
    String? otpCode,
  }) async {
    setBecomeAUthor(true);
    try {
      successModel = await ApiService().becomeAutherResponse(
        role: role,
        paymentMethod: paymentMethod,
        bankCode: bankCode,
        bankname: bankname,
        bankholdername: bankholdername,
        accountno: accountno,
        mpesaPhone: mpesaPhone,
        mobileNumber: mobileNumber,
        password: password,
        idFrontImage: idFrontImage,
        idBackImage: idBackImage,
        selfieImage: selfieImage,
        otpCode: otpCode,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = "something_went_wrong";
      if (data is Map<String, dynamic>) {
        final apiMessage = (data['message'] ?? '').toString();
        final apiErrors = data['errors'];
        if (apiMessage.isNotEmpty) {
          message = apiMessage;
        } else if (apiErrors is List && apiErrors.isNotEmpty) {
          message = apiErrors.first.toString();
        } else if (apiErrors is String && apiErrors.isNotEmpty) {
          message = apiErrors;
        }
      }
      successModel = SuccessModel(status: 400, message: message, result: []);
    } catch (_) {
      successModel =
          SuccessModel(status: 400, message: "something_went_wrong", result: []);
    }
    setBecomeAUthor(false);
  }

  // ---- OTP Methods ----
  Future<void> sendOtp() async {
    otpSending = true;
    otpMessage = '';
    notifyListeners();

    try {
      final result = await ApiService().sendAuthorOtp();
      if (result.status == 200) {
        otpSent = true;
        otpMessage = result.message ?? 'OTP sent successfully';
        _startOtpTimer();
      } else {
        otpSent = false;
        otpMessage = result.message ?? 'Failed to send OTP';
      }
    } catch (e) {
      otpSent = false;
      otpMessage = 'Failed to send OTP';
    }

    otpSending = false;
    notifyListeners();
  }

  Future<bool> verifyOtp(String otp) async {
    try {
      final result = await ApiService().verifyAuthorOtp(otp);
      if (result.status == 200) {
        otpVerified = true;
        otpMessage = result.message ?? 'OTP verified successfully';
        notifyListeners();
        return true;
      } else {
        otpVerified = false;
        otpMessage = result.message ?? 'Invalid OTP';
        notifyListeners();
        return false;
      }
    } catch (e) {
      otpVerified = false;
      otpMessage = 'Failed to verify OTP';
      notifyListeners();
      return false;
    }
  }

  void _startOtpTimer() {
    otpTimerSeconds = 300; // 5 minutes
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (otpTimerSeconds <= 0) {
        otpSent = false;
        notifyListeners();
        return false;
      }
      otpTimerSeconds--;
      notifyListeners();
      return true;
    });
  }

  void resetOtpState() {
    otpSending = false;
    otpSent = false;
    otpVerified = false;
    otpMessage = '';
    otpTimerSeconds = 0;
    notifyListeners();
  }

  // ---- KYC Image Methods ----
  void setIdFront(Uint8List bytes, String name) {
    idFrontBytes = bytes;
    idFrontName = name;
    notifyListeners();
  }

  void setIdBack(Uint8List bytes, String name) {
    idBackBytes = bytes;
    idBackName = name;
    notifyListeners();
  }

  void setSelfie(Uint8List bytes, String name) {
    selfieBytes = bytes;
    selfieName = name;
    notifyListeners();
  }

  void clearKycImages() {
    idFrontBytes = null;
    idFrontName = null;
    idBackBytes = null;
    idBackName = null;
    selfieBytes = null;
    selfieName = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> paystackBanks = [];
  Future<void> getPaystackBanks({String country = "kenya"}) async {
    try {
      final rawBanks = await ApiService().paystackBanks(country: country);
      // Deduplicate by bank code — Paystack sometimes returns the same
      // bank code twice (e.g. KES + USD variants), which crashes Flutter's
      // DropdownButton (assertion: exactly one item with a given value).
      final seenCodes = <String>{};
      paystackBanks = [];
      for (final bank in rawBanks) {
        final code = (bank['code'] ?? '').toString();
        if (code.isNotEmpty && !seenCodes.contains(code)) {
          seenCodes.add(code);
          paystackBanks.add(bank);
        }
      }
    } catch (_) {
      paystackBanks = [];
    }
    notifyListeners();
  }

  setBecomeAUthor(isLoding) {
    becomeAUthorLoading = isLoding;
    notifyListeners();
  }

  contactusdata(
    name,
    email,
    subject,
    details,
  ) async {
    contactus(true);
    successModel = await ApiService().contactusapi(
      name: name,
      email: email,
      subject: subject,
      details: details,
    );
    contactus(false);
  }

  contactus(isLoding) {
    contactloading = isLoding;
    notifyListeners();
  }

  getPages() async {
    loading = true;
    pagesModel = await ApiService().pagesResponse();
    loading = false;
    notifyListeners();
  }

  bool isLoading = false;
  Getsociallinkmodel getsociallinkmodel = Getsociallinkmodel();
  getsociallinkdata() async {
    isLoading = true;
    getsociallinkmodel = await ApiService().socialLink();
    isLoading = false;
    notifyListeners();
  }

// Book List API
  Future<void> getSectionBook(type, autherUerid, pageno) async {
    contentLoading = true;
    bookModel =
        await ApiService().authorContentResponse(type, autherUerid, pageno);
    if (bookModel.status == 200) {
      setPagination(bookModel.totalRows, bookModel.totalPage,
          bookModel.currentPage, bookModel.morePage);
      if (bookModel.result != null && (bookModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (bookModel.result?.length ?? 0); i++) {
          bookList?.add(bookModel.result?[i] ?? book.Result());
        }
        final Map<int, book.Result> postMap = {};
        bookList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        bookList = postMap.values.toList();
        setLoadMore(false);
        printLog("bookModel length :=2=> ${(bookModel.result?.length ?? 0)}");
      }
      printLog("getSectionDetails status :===> ${bookModel.status}");
      printLog("getSectionDetails message :==> ${bookModel.message}");
    }
    contentLoading = false;
    notifyListeners();
  }

  // Magazibe List API
  Future<void> getSectionMagazine(type, autherUerid, pageno) async {
    contentLoading = true;
    magazineModel =
        await ApiService().authorContentResponse(type, autherUerid, pageno);
    if (magazineModel.status == 200) {
      setPagination(magazineModel.totalRows, magazineModel.totalPage,
          magazineModel.currentPage, magazineModel.morePage);
      if (magazineModel.result != null &&
          (magazineModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (magazineModel.result?.length ?? 0); i++) {
          magazineList?.add(magazineModel.result?[i] ?? magazine.Result());
        }
        final Map<int, magazine.Result> postMap = {};
        magazineList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        magazineList = postMap.values.toList();
        setLoadMore(false);
        printLog(
            "bookModel length :=2=> ${(magazineModel.result?.length ?? 0)}");
      }
      printLog("getSectionDetails status :===> ${magazineModel.status}");
      printLog("getSectionDetails message :==> ${magazineModel.message}");
    }
    contentLoading = false;
    notifyListeners();
  }

  // Audio List API
  Future<void> getSectionAudio(type, autherUerid, pageno) async {
    contentLoading = true;
    audioBookModel =
        await ApiService().authorContentResponse(type, autherUerid, pageno);
    if (audioBookModel.status == 200) {
      setPagination(audioBookModel.totalRows, audioBookModel.totalPage,
          audioBookModel.currentPage, audioBookModel.morePage);
      if (audioBookModel.result != null &&
          (audioBookModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (audioBookModel.result?.length ?? 0); i++) {
          audioList?.add(audioBookModel.result?[i] ?? audio.Result());
        }
        final Map<int, audio.Result> postMap = {};
        audioList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        audioList = postMap.values.toList();
        setLoadMore(false);
      }
    }
    contentLoading = false;
    notifyListeners();
  }

  /*  Pagination start */
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  setLoadMore(loadMore) {
    printLog("setLoadMore loadMore :=> $loadMore");
    this.loadMore = loadMore;
    notifyListeners();
  }

  setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage;
    notifyListeners();
  }
  /*  Pagination end */

  providerNotifi() {
    notifyListeners();
  }

  String? webSelect = "1", webSelectTabName = "my_profile";

  setWebSelect(index, name) {
    webSelect = index;
    webSelectTabName = name;
    notifyListeners();
  }

  String? selectType = "1";

  setTab(type) {
    selectType = type;
    notifyListeners();
  }

  String currentIndex = "1";

  setWishListTab(index) {
    currentIndex = index;

    notifyListeners();
  }

/* Web Image Picked Code Started */
  Uint8List? imageBytes; // Stores image bytes for display
  String? fileName;
  bool imageSelected = false;
  String? mediaType;

  Future<void> pickImageWEB() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true, // Important to get bytes on web
    );

    if (result != null && result.files.single.bytes != null) {
      imageBytes = result.files.single.bytes;
      fileName = result.files.single.name;
      String extension = result.files.first.extension ?? 'jpeg';
      mediaType = 'image/$extension';
      notifyListeners();
    }
  }

  clearWeb() {
    webSelect = "1";
    webSelectTabName = "my_profile";
    imageBytes = null;
    fileName = "";
    mediaType;
    imageSelected = false;
    currentIndex = "1";
    selectType = "1";
  }

  clearData() {
    loading = false;
    bookModel = book.BookModel();
    magazineModel = magazine.MagazineModel();
    audioBookModel = audio.AudioBookModel();
    bookList = [];
    bookList?.clear();
    magazineList = [];
    magazineList?.clear();
    audioList = [];
    audioList?.clear();
    loadMore = false; /*  Pagination start */
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }

  clearProvider() {
    profileModel = ProfileModel();
    successModel = SuccessModel();
    userModel = UserModel();
    pagesModel = PagesModel();
    loading = false;
    selectedType = "1";
    becomeAUthorLoading = false;
    bookModel = book.BookModel();
    magazineModel = magazine.MagazineModel();
    audioBookModel = audio.AudioBookModel();
    loading = false;
    bookList = [];
    bookList?.clear();
    magazineList = [];
    magazineList?.clear();
    audioList = [];
    audioList?.clear();
    /*  Pagination start */
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    // Reset OTP & KYC state
    resetOtpState();
    clearKycImages();
  }
}


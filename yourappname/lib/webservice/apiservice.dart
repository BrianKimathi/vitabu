import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:yourappname/model/addhistorymodel.dart';
import 'package:yourappname/model/audiobookmodel.dart';
import 'package:yourappname/model/audiodetailmodel.dart';
import 'package:yourappname/model/audiosectionmodel.dart';
import 'package:yourappname/model/authormodel.dart';
import 'package:yourappname/model/autherprofilemodel.dart';
import 'package:yourappname/model/bankdetailsmodel.dart';
import 'package:yourappname/model/bookdetailmodel.dart';
import 'package:yourappname/model/bookmodel.dart';
import 'package:yourappname/model/chaptermodel.dart';
import 'package:yourappname/model/commanmodel.dart';
import 'package:yourappname/model/commentmodel.dart';
import 'package:yourappname/model/couponmodel.dart';
import 'package:yourappname/model/episodemodel.dart';
import 'package:yourappname/model/followlistmodel.dart';
import 'package:yourappname/model/getsociallinkmodel.dart';
import 'package:yourappname/model/magazinedetailsmodel.dart';
import 'package:yourappname/model/magazinemodel.dart';
import 'package:yourappname/model/onboardingmodel.dart';
import 'package:yourappname/model/paytmmodel.dart';
import 'package:yourappname/model/reviewmodel.dart';
import 'package:yourappname/model/sectionmodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/model/transactionhistorymodel.dart';
import 'package:yourappname/model/uploadbookmodel.dart';
import 'package:yourappname/model/usermodel.dart';
import 'package:yourappname/model/userplanhistory.dart';
import 'package:yourappname/model/userscriptionmodel.dart';
import 'package:yourappname/model/voucherlistmodel.dart';
import 'package:yourappname/model/wallethistorymodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/model/categorymodel.dart';
import 'package:yourappname/model/generalsettingmodel.dart';
import 'package:yourappname/model/pagesmodel.dart';
import 'package:yourappname/model/notificationmodel.dart';
import 'package:yourappname/model/packagemodel.dart';
import 'package:yourappname/model/paymentoptionmodel.dart';
import 'package:yourappname/model/profilemodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiService {
  String baseurl = Constant().baseurl;
  late Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
    );
    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        enabled: kDebugMode,
      ));
    }
  }

  Future<Generalsettingmodel> generalsetting() async {
    Generalsettingmodel generalsettingModel;
    String generalsetting = "general_setting";
    Response response = await dio.post(
      '$baseurl$generalsetting',
    );
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;

    generalsettingModel = Generalsettingmodel.fromJson(data);
    return generalsettingModel;
  }

  Future<OnBoardingModel> onBoardingResponse() async {
    OnBoardingModel generalsettingModel;
    String generalsetting = "get_onboarding_screen";
    Response response = await dio.post('$baseurl$generalsetting');
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    generalsettingModel = OnBoardingModel.fromJson(data);
    return generalsettingModel;
  }

  Future<PagesModel> pagesResponse() async {
    PagesModel getpagesModel;
    String getpages = "get_pages";
    Response response = await dio.post('$baseurl$getpages');
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    getpagesModel = PagesModel.fromJson(data);
    return getpagesModel;
  }

  Future<Getsociallinkmodel> socialLink() async {
    String apiName = "get_social_link";
    Response response = await dio.post('$baseurl$apiName');

    // Backend sometimes returns JSON as a String, but model parsers expect a Map.
    final decoded = response.data is String ? jsonDecode(response.data) : response.data;

    Getsociallinkmodel getsociallinkmodel =
        Getsociallinkmodel.fromJson(decoded);
    return getsociallinkmodel;
  }

  // Normal Login Api
  Future<UserModel> normalLogin(
    String type,
    String email,
    String password,
    String deviceType,
    String deviceToken,
  ) async {
    UserModel loginModel;
    String login = "login";
    Response response = await dio.post('$baseurl$login',
        data: FormData.fromMap({
          'type': type,
          'email': email,
          'password': password,
          'device_type': deviceType,
          'device_token': deviceToken,
        }));
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    loginModel = UserModel.fromJson(data);
    return loginModel;
  }

  // Social Login Api
  Future<UserModel> socialLogin(
    type,
    email,
    firstName,
    image,
    lastName,
    deviceToken,
    deviceType,
  ) async {
    UserModel loginModel;
    String login = "login";
    MultipartFile? imageFile;

    final String imageStr = image?.toString() ?? '';
    if (imageStr.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imageStr));

        if (response.statusCode == 200) {
          Uint8List imageBytes = response.bodyBytes;
          imageFile = MultipartFile.fromBytes(
            imageBytes,
            filename: "profile_image.jpg",
          );
        } else {
          printLog(
              'Failed to download image, status code: ${response.statusCode}');
        }
      } catch (e) {
        printLog('Error downloading image: $e');
      }
    }

    printLog("Image file prepared: $imageFile");

    // Build form data dynamically
    Map<String, dynamic> formMap = {
      'type': type,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'device_token': deviceToken,
      'device_type': deviceType,
    };

    // Only add image if present
    if (imageFile != null) {
      formMap['image'] = imageFile;
    }

    Response response = await dio.post(
      '$baseurl$login',
      data: FormData.fromMap(formMap),
      options: Options(
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    final data =
        response.data is String ? jsonDecode(response.data) : response.data;

    loginModel = UserModel.fromJson(data);

    return loginModel;
  }

// OTP Login Api
  Future<UserModel> otpLogin(
    type,
    mobile,
    deviceToken,
    deviceType,
  ) async {
    UserModel loginModel;
    String login = "login";
    Response response = await dio.post('$baseurl$login',
        data: FormData.fromMap({
          'type': type,
          'mobile_number': mobile,
          'device_token': deviceToken,
          'device_type': deviceType,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    loginModel = UserModel.fromJson(data);
    return loginModel;
  }

  Future<SuccessModel> forgotpassword(email) async {
    SuccessModel successmodel;
    String apiName = "forgot_password";
    Response response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({"email": email}),
    );
    successmodel = SuccessModel.fromJson((response.data));
    return successmodel;
  }

  Future<UserModel> register(
    firstName,
    lastName,
    email,
    password,
    number,
    deviceType,
    deviceToken,
  ) async {
    UserModel registerModel;
    String registration = "register";
    Response response = await dio.post('$baseurl$registration',
        data: FormData.fromMap({
          'first_name': firstName,
          "last_name": lastName,
          'email': email,
          'password': password,
          'mobile_number': number,
          'device_type': deviceType,
          'device_token': deviceToken,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    registerModel = UserModel.fromJson(data);
    return registerModel;
  }

  Future<UserModel> updateProfileResponse(
    userName,
    firstName,
    lastName,
    email,
    number,
    address,
    description,
    categoryId,
    image,
    deviceToken,
    deviceType,
  ) async {
    UserModel updateprofileModel;
    String updateprofile = "update_profile";

    Map<String, dynamic> formMap = {
      'user_id': Constant.userID ?? 0,
      "user_name": userName,
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "mobile_number": number,
      "address": address,
      "description": description,
      "category_ids": categoryId,
      'device_token': deviceToken,
      'device_type': deviceType,
    };

    if (image != null) {
      if (kIsWeb && image is Uint8List) {
        formMap["image"] = MultipartFile.fromBytes(
          image,
          filename: "profile_image.png",
        );
      } else if (image is File) {
        formMap["image"] = await MultipartFile.fromFile(
          image.path,
          filename: basename(image.path),
        );
      }
    }

    Response response = await dio.post('$baseurl$updateprofile',
        data: FormData.fromMap(formMap));

    final data =
        response.data is String ? jsonDecode(response.data) : response.data;

    updateprofileModel = UserModel.fromJson(data);
    return updateprofileModel;
  }

  Future<SuccessModel> becomeAutherResponse({
    required String role,
    required String paymentMethod,
    String? bankCode,
    String? bankname,
    String? bankholdername,
    String? accountno,
    String? mpesaPhone,
    String? mobileNumber,
    String? password,
    // KYC Image files
    dynamic idFrontImage,   // File (mobile) or Uint8List (web)
    dynamic idBackImage,    // File (mobile) or Uint8List (web)
    dynamic selfieImage,    // File (mobile) or Uint8List (web)
    String? otpCode,       // OTP for verification
  }) async {
    SuccessModel becomeAutherModel;
    String getprofile = "add_become_author_request";

    Map<String, dynamic> formMap = {
      'user_id': (Constant.userID == null) ? 0 : Constant.userID,
      'role': role,
      'payment_method': paymentMethod,
      'bank_code': bankCode ?? '',
      'bank_name': bankname ?? '',
      'bank_holder_name': bankholdername ?? '',
      'account_no': accountno ?? '',
      'mpesa_phone': mpesaPhone ?? '',
      'mobile_number': mobileNumber ?? '',
      if (password != null && password.isNotEmpty) 'password': password,
      if (otpCode != null && otpCode.isNotEmpty) 'otp_code': otpCode,
    };

    // Attach KYC images
    if (idFrontImage != null) {
      if (kIsWeb && idFrontImage is Uint8List) {
        formMap['id_front'] = MultipartFile.fromBytes(
          idFrontImage,
          filename: 'id_front.png',
        );
      } else if (idFrontImage is File) {
        formMap['id_front'] = await MultipartFile.fromFile(
          idFrontImage.path,
          filename: basename(idFrontImage.path),
        );
      }
    }
    if (idBackImage != null) {
      if (kIsWeb && idBackImage is Uint8List) {
        formMap['id_back'] = MultipartFile.fromBytes(
          idBackImage,
          filename: 'id_back.png',
        );
      } else if (idBackImage is File) {
        formMap['id_back'] = await MultipartFile.fromFile(
          idBackImage.path,
          filename: basename(idBackImage.path),
        );
      }
    }
    if (selfieImage != null) {
      if (kIsWeb && selfieImage is Uint8List) {
        formMap['selfie'] = MultipartFile.fromBytes(
          selfieImage,
          filename: 'selfie.png',
        );
      } else if (selfieImage is File) {
        formMap['selfie'] = await MultipartFile.fromFile(
          selfieImage.path,
          filename: basename(selfieImage.path),
        );
      }
    }

    Response response = await dio.post('$baseurl$getprofile',
        data: FormData.fromMap(formMap));
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    becomeAutherModel = SuccessModel.fromJson(data);
    return becomeAutherModel;
  }

  // Send OTP for author registration (to email + phone)
  Future<SuccessModel> sendAuthorOtp() async {
    SuccessModel model;
    String apiName = "send_author_otp";
    Response response = await dio.post('$baseurl$apiName',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        }));
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    model = SuccessModel.fromJson(data);
    return model;
  }

  // Verify OTP for author registration
  Future<SuccessModel> verifyAuthorOtp(String otp) async {
    SuccessModel model;
    String apiName = "verify_author_otp";
    Response response = await dio.post('$baseurl$apiName',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'otp': otp,
        }));
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    model = SuccessModel.fromJson(data);
    return model;
  }

  Future<List<Map<String, dynamic>>> paystackBanks({String country = "kenya"}) async {
    String apiName = "get_paystack_banks";
    Response response = await dio.post('$baseurl$apiName',
        data: FormData.fromMap({'country': country}));
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    if ((data['status'] ?? 0) != 200 || data['result'] == null) return [];
    return List<Map<String, dynamic>>.from(data['result']);
  }

  Future<SuccessModel> sendOtpSms({required String mobileNumber}) async {
    SuccessModel model;
    Response response = await dio.post('$baseurl${"send_otp_sms"}',
        data: FormData.fromMap({
          'mobile_number': mobileNumber,
        }));
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    model = SuccessModel.fromJson(data);
    return model;
  }

  Future<UserModel> profileCategoryUpdate(
    categoryIds,
    deviceType,
    deviceToken,
  ) async {
    UserModel updateprofileModel;
    String updateprofile = "update_profile";
    Response response = await dio.post('$baseurl$updateprofile',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'category_ids': categoryIds,
          'device_type': deviceType,
          'device_token': deviceToken,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    updateprofileModel = UserModel.fromJson(data);
    return updateprofileModel;
  }

  Future<ProfileModel> profileResponse(userId) async {
    ProfileModel profileModel;
    String getprofile = "get_profile";
    Response response = await dio.post('$baseurl$getprofile',
        data: FormData.fromMap({
          'user_id': userId,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    profileModel = ProfileModel.fromJson(data);
    return profileModel;
  }

  // section_list API
  Future<SectionModel> sectionList(sectionType, userCategoryId, pageno) async {
    String apiName = "get_section_list";

    Response response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({
        "section_type": sectionType,
        'user_id': Constant.userID ?? 0,
        "user_category_ids": userCategoryId,
        'page_no': pageno,
      }),
    );

    // Backend sometimes returns JSON as a String, but model parsers expect a Map.
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;

    return SectionModel.fromJson(data);
  }

/* Section Details page API */
  Future sectionDetailsResponse(sectionId, type, pageno) async {
    AudioBookModel audioBookModel;
    BookModel bookModel;
    MagazineModel magazineModel;
    CategoryModel categoryModel;
    AuthorModel authorModel;
    String sectionList = "get_section_detail";
    Response response;
    if (type == "1") {
      response = await dio.post('$baseurl$sectionList',
          data: FormData.fromMap({
            "section_id": sectionId,
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'page_no': pageno
          }));
// Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      audioBookModel = AudioBookModel.fromJson(data);
      return audioBookModel;
    } else if (type == "2") {
      response = await dio.post('$baseurl$sectionList',
          data: FormData.fromMap({
            "section_id": sectionId,
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'page_no': pageno
          }));
// Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      bookModel = BookModel.fromJson(data);
      return bookModel;
    } else if (type == "3") {
      response = await dio.post('$baseurl$sectionList',
          data: FormData.fromMap({
            "section_id": sectionId,
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'page_no': pageno
          }));

// Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      magazineModel = MagazineModel.fromJson(data);
      return magazineModel;
    } else if (type == "4") {
      response = await dio.post('$baseurl$sectionList',
          data: FormData.fromMap({
            "section_id": sectionId,
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'page_no': pageno
          }));

// Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      categoryModel = CategoryModel.fromJson(data);
      return categoryModel;
    } else if (type == "5") {
      response = await dio.post('$baseurl$sectionList',
          data: FormData.fromMap({
            "section_id": sectionId,
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'page_no': pageno
          }));

// Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      categoryModel = CategoryModel.fromJson(data);
      return categoryModel;
    } else {
      response = await dio.post('$baseurl$sectionList',
          data: FormData.fromMap({
            "section_id": sectionId,
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'page_no': pageno
          }));

// Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      authorModel = AuthorModel.fromJson(data);
      return authorModel;
    }
  }

/* Section Details pages API END */
  Future<AuthorModel> authorResponse(pageno) async {
    AuthorModel categoryModel;
    String getcategory = "get_author_list";
    Response response = await dio.post('$baseurl$getcategory',
        data: FormData.fromMap({'page_no': pageno}));
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    categoryModel = AuthorModel.fromJson(data);
    return categoryModel;
  }

  Future<CategoryModel> categoryResponse(pageno) async {
    CategoryModel categoryModel;
    String getcategory = "get_category";
    Response response = await dio.post('$baseurl$getcategory',
        data: FormData.fromMap({
          'page_no': pageno
          // Check the type of response.data
        }));
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    categoryModel = CategoryModel.fromJson(data);
    return categoryModel;
  }

  Future<CategoryModel> languageResponse(pageno) async {
    CategoryModel categoryModel;
    String getcategory = "get_language";
    Response response = await dio.post('$baseurl$getcategory',
        data: FormData.fromMap({
          'page_no': pageno
          // Check the type of response.data
        }));
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    categoryModel = CategoryModel.fromJson(data);
    return categoryModel;
  }

/* Bookmark api */
  Future getBookMark(type, pageno) async {
    BookModel bookModel;
    AudioBookModel audioBookModel;
    MagazineModel magazineModel;
    String deleteComment = "get_bookmark_content";
    Response response;
    if (type == "1") {
      response = await dio.post(
        '$baseurl$deleteComment',
        data: FormData.fromMap({
          'content_type': type,
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'page_no': pageno
        }),
      );
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      audioBookModel = AudioBookModel.fromJson(data);
      return audioBookModel;
    } else if (type == "2") {
      response = await dio.post(
        '$baseurl$deleteComment',
        data: FormData.fromMap({
          'content_type': type,
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'page_no': pageno
        }),
      );
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      bookModel = BookModel.fromJson(data);
      return bookModel;
    } else {
      response = await dio.post(
        '$baseurl$deleteComment',
        data: FormData.fromMap({
          'content_type': type,
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'page_no': pageno
        }),
      );
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      magazineModel = MagazineModel.fromJson(data);
      return magazineModel;
    }
  }
  /* END */

/* Search Api Started */

  Future searchResponse(type, name, pageno) async {
    BookModel bookModel;
    AudioBookModel audioBookModel;
    MagazineModel magazineModel;
    String deleteComment = "search_content";
    Response response;
    if (type == "1") {
      response = await dio.post(
        '$baseurl$deleteComment',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'content_type': type,
          "title": name,
          'page_no': pageno
        }),
      );
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      audioBookModel = AudioBookModel.fromJson(data);
      return audioBookModel;
    } else if (type == "2") {
      response = await dio.post(
        '$baseurl$deleteComment',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'content_type': type,
          "title": name,
          'page_no': pageno
        }),
      );
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      bookModel = BookModel.fromJson(data);
      return bookModel;
    } else {
      response = await dio.post(
        '$baseurl$deleteComment',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'content_type': type,
          "title": name,
          'page_no': pageno
        }),
      );
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      magazineModel = MagazineModel.fromJson(data);
      return magazineModel;
    }
  }

/* END */
  Future<NotificationModel> notificationResponse(pageno) async {
    NotificationModel notificationModel;
    String getnotification = "get_notification";
    Response response = await dio.post('$baseurl$getnotification',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'page_no': pageno
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    notificationModel = NotificationModel.fromJson(data);
    return notificationModel;
  }

  Future<SuccessModel> readnotificationResponse(String notificationid) async {
    SuccessModel readnotificationModel;
    String readnotification = "read_notfication";
    Response response = await dio.post('$baseurl$readnotification',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'notification_id': notificationid,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    readnotificationModel = SuccessModel.fromJson(data);
    return readnotificationModel;
  }
/* Bookmark Api */

  Future<SuccessModel> bookmarkResponse(contentType, contentId) async {
    SuccessModel successModel;
    String readnotification = "add_remove_bookmark";
    Response response = await dio.post('$baseurl$readnotification',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'content_type': contentType,
          "content_id": contentId
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    successModel = SuccessModel.fromJson(data);
    return successModel;
  }

/* Content View Api */
  Future<SuccessModel> contentViewResponse(
      contentType, contentId, subContentId) async {
    SuccessModel successModel;
    String readnotification = "add_content_view";
    Response response = await dio.post('$baseurl$readnotification',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'content_type': contentType,
          "content_id": contentId,
          "sub_content_id": subContentId,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    successModel = SuccessModel.fromJson(data);
    return successModel;
  }

/* Content Details page Api */
  Future contentDetailsResponse(contentType, contentId) async {
    AudioDetailModel audioDetailModel;
    BookDetailModel bookDetailModel;
    MagazineDetailModel magazineDetailModel;
    String readnotification = "get_content_detail";
    Response response;
    if (contentType == "1") {
      response = await dio.post('$baseurl$readnotification',
          data: FormData.fromMap({
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'content_type': contentType,
            "content_id": contentId
          }));
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      audioDetailModel = AudioDetailModel.fromJson(data);
      return audioDetailModel;
    } else if (contentType == "2") {
      response = await dio.post('$baseurl$readnotification',
          data: FormData.fromMap({
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'content_type': contentType,
            "content_id": contentId
          }));
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      bookDetailModel = BookDetailModel.fromJson(data);
      return bookDetailModel;
    } else {
      response = await dio.post('$baseurl$readnotification',
          data: FormData.fromMap({
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'content_type': contentType,
            "content_id": contentId
          }));
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      magazineDetailModel = MagazineDetailModel.fromJson(data);
      return magazineDetailModel;
    }
  }
  /* End */

/* Book Chapter Api */
  Future<ChapterModel> bookChapterResponse(novelId, pageNo) async {
    ChapterModel successModel;
    String readnotification = "get_chapter_by_novel";
    Response response = await dio.post('$baseurl$readnotification',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'novel_id': novelId,
          "page_no": pageNo,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    successModel = ChapterModel.fromJson(data);
    return successModel;
  }

/* Book Chapter Api */
  Future<EpisodeModel> audioBookEpisodeResponse(audioBookId, pageNo) async {
    EpisodeModel successModel;
    String readnotification = "get_episode_by_audiobook";
    Response response = await dio.post('$baseurl$readnotification',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'audio_book_id': audioBookId,
          "page_no": pageNo,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    successModel = EpisodeModel.fromJson(data);
    return successModel;
  }

/* Releated Content Show Api */

  Future reletedResponse(type, categoryId, contentId, pageno) async {
    BookModel bookModel;
    AudioBookModel audioBookModel;
    MagazineModel magazineModel;
    String deleteComment = "get_releted_content";
    printLog("My Category Ids is $categoryId");
    Response response;
    if (type == "1") {
      response = await dio.post(
        '$baseurl$deleteComment',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'content_type': type,
          "category_id": categoryId,
          "content_id": contentId,
          'page_no': pageno
        }),
      );
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      audioBookModel = AudioBookModel.fromJson(data);
      return audioBookModel;
    } else if (type == "2") {
      response = await dio.post(
        '$baseurl$deleteComment',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'content_type': type,
          "category_id": categoryId,
          "content_id": contentId,
          'page_no': pageno
        }),
      );
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      bookModel = BookModel.fromJson(data);
      return bookModel;
    } else {
      response = await dio.post(
        '$baseurl$deleteComment',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'content_type': type,
          "category_id": categoryId,
          "content_id": contentId,
          'page_no': pageno
        }),
      );
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      magazineModel = MagazineModel.fromJson(data);
      return magazineModel;
    }
  }

/* END */
/* Add Review Api Started */
  Future<SuccessModel> addReviewResponse(
      contentType, contentId, review, rating) async {
    SuccessModel successModel;
    String readnotification = "add_review";
    Response response = await dio.post('$baseurl$readnotification',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'content_type': contentType,
          "content_id": contentId,
          "review": review,
          "rating": rating
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    successModel = SuccessModel.fromJson(data);
    return successModel;
  }

  Future<SuccessModel> deleteReviewResponse(reviewId) async {
    SuccessModel successModel;
    String readnotification = "delete_review";
    Response response = await dio.post('$baseurl$readnotification',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'review_id': reviewId,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    successModel = SuccessModel.fromJson(data);
    return successModel;
  }

  Future<ReviewModel> reviewResponse(contentType, contentId, pageNo) async {
    ReviewModel successModel;
    String readnotification = "get_review";
    Response response = await dio.post('$baseurl$readnotification',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'content_type': contentType,
          "content_id": contentId,
          "page_no": pageNo,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    successModel = ReviewModel.fromJson(data);
    return successModel;
  }

/* Add Review Api END */

/*  Author Content Started */
  Future authorContentResponse(type, autherUerid, pageno) async {
    BookModel bookModel;
    MagazineModel magazineModel;
    AudioBookModel audioBookModel;
    String getprofile = "get_content_by_author";
    Response response;
    if (type == "1") {
      response = await dio.post('$baseurl$getprofile',
          data: FormData.fromMap({
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'content_type': type,
            'author_id': autherUerid,
            'page_no': pageno,
          }));
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      audioBookModel = AudioBookModel.fromJson(data);
      return audioBookModel;
    } else if (type == "2") {
      response = await dio.post('$baseurl$getprofile',
          data: FormData.fromMap({
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'content_type': type,
            'author_id': autherUerid,
            'page_no': pageno,
          }));
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      bookModel = BookModel.fromJson(data);
      return bookModel;
    } else {
      response = await dio.post('$baseurl$getprofile',
          data: FormData.fromMap({
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'content_type': type,
            'author_id': autherUerid,
            'page_no': pageno,
          }));
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      magazineModel = MagazineModel.fromJson(data);
      return magazineModel;
    }
  }

  /*  Category Content Started */
  Future categoryByContentResponse(type, categoryId, pageno) async {
    BookModel bookModel;
    MagazineModel magazineModel;
    AudioBookModel audioBookModel;
    String getprofile = "get_content_by_category";
    Response response;
    if (type == "1") {
      response = await dio.post('$baseurl$getprofile',
          data: FormData.fromMap({
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'content_type': type,
            'category_id': categoryId,
            'page_no': pageno,
          }));
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      audioBookModel = AudioBookModel.fromJson(data);
      return audioBookModel;
    } else if (type == "2") {
      response = await dio.post('$baseurl$getprofile',
          data: FormData.fromMap({
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'content_type': type,
            'category_id': categoryId,
            'page_no': pageno,
          }));
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      bookModel = BookModel.fromJson(data);
      return bookModel;
    } else {
      response = await dio.post('$baseurl$getprofile',
          data: FormData.fromMap({
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'content_type': type,
            'category_id': categoryId,
            'page_no': pageno,
          }));
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      magazineModel = MagazineModel.fromJson(data);
      return magazineModel;
    }
  }

  /*  Language Content Started */
  Future languageByContentResponse(type, languageId, pageno) async {
    BookModel bookModel;
    MagazineModel magazineModel;
    AudioBookModel audioBookModel;
    String getprofile = "get_content_by_language";
    Response response;
    if (type == "1") {
      response = await dio.post('$baseurl$getprofile',
          data: FormData.fromMap({
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'content_type': type,
            'language_id': languageId,
            'page_no': pageno,
          }));
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      audioBookModel = AudioBookModel.fromJson(data);
      return audioBookModel;
    } else if (type == "2") {
      response = await dio.post('$baseurl$getprofile',
          data: FormData.fromMap({
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'content_type': type,
            'language_id': languageId,
            'page_no': pageno,
          }));
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      bookModel = BookModel.fromJson(data);
      return bookModel;
    } else {
      response = await dio.post('$baseurl$getprofile',
          data: FormData.fromMap({
            'user_id': (Constant.userID == null) ? 0 : Constant.userID,
            'content_type': type,
            'language_id': languageId,
            'page_no': pageno,
          }));
      // Check the type of response.data
      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      magazineModel = MagazineModel.fromJson(data);
      return magazineModel;
    }
  }

  Future<PaymentOptionModel> paymentResponse() async {
    PaymentOptionModel paymentoptionModel;
    String paymentoption = "get_payment_option";
    Response response = await dio.post('$baseurl$paymentoption');
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    paymentoptionModel = PaymentOptionModel.fromJson(data);
    return paymentoptionModel;
  }

  Future<SuccessModel> addTransactionResponse(
    authorId,
    contentType,
    contentId,
    price,
    subContentId,
    transactionId, {
    String? paymentMethod,
    String? couponCode,
    double? totalTax,
    String? tax,
  }) async {
    SuccessModel paymentoptionModel;
    String paymentoption = "add_transaction";

    final finalPrice = double.tryParse(price.toString()) ?? 0;

    Map<String, dynamic> dataMap = {
      'user_id': Constant.userID ?? "0",
      "author_id": authorId ?? "0",
      "content_type": contentType ?? "0",
      "content_id": contentId ?? "0",
      "price": finalPrice,
      "sub_content_id":
          (subContentId == null || subContentId.toString().isEmpty)
              ? "0"
              : subContentId,
      "transaction_id": transactionId ?? "",
      "payment_method": paymentMethod ?? "",
      "sub_video_id": (subContentId == null || subContentId.toString().isEmpty)
          ? "0"
          : subContentId,
    };

    if (couponCode != null && couponCode.isNotEmpty) {
      dataMap["coupon_code"] = couponCode;
    }
    if (totalTax != null && totalTax > 0) {
      dataMap["total_tax"] = totalTax;
    }
    if (tax != null && tax.isNotEmpty) {
      dataMap["tax"] = tax;
    }

    printLog("Final Map Sending to Server: $dataMap");

    try {
      Response response = await dio.post(
        '$baseurl$paymentoption',
        data: FormData.fromMap(dataMap),
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final data =
          response.data is String ? jsonDecode(response.data) : response.data;
      paymentoptionModel = SuccessModel.fromJson(data);
      return paymentoptionModel;
    } catch (e) {
      printLog("Error in API Call: $e");
      rethrow;
    }
  }

  Future<SuccessModel> addchangestransactionstatus(
      String transactionId, int status) async {
    SuccessModel paymentStatusModel;
    const endpoint = "change_transaction_state";

    Response response = await dio.post(
      '$baseurl$endpoint',
      data: FormData.fromMap({
        "transaction_id": transactionId, // must be flat, not a map
        "status": status, // 0 = processing, 1 = success, 2 = failed
      }),
    );

    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    paymentStatusModel = SuccessModel.fromJson(data);

    return paymentStatusModel;
  }

  Future<TransactionHistoryModel> transactionHistory(
      contentType, pageno) async {
    TransactionHistoryModel transactionHistoryModel;
    String getTransactionHistory = "get_transaction_history";
    Response response = await dio.post('$baseurl$getTransactionHistory',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          "content_type": contentType,
          'page_no': pageno,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    transactionHistoryModel = TransactionHistoryModel.fromJson(data);
    return transactionHistoryModel;
  }

/* New Data END */
  Future<BookModel> popularbooks(pageno) async {
    BookModel bestEbookModel;
    String popularbooklist = "popular_book_list";
    Response response = await dio.post('$baseurl$popularbooklist',
        data: FormData.fromMap({
          'page_no': pageno,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    bestEbookModel = BookModel.fromJson(data);
    return bestEbookModel;
  }

  Future<AuthorModel> autherList(pageno) async {
    AuthorModel autherModel;
    String popularbooklist = "autherlist";
    Response response = await dio.post('$baseurl$popularbooklist',
        data: FormData.fromMap({
          'page_no': pageno,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    autherModel = AuthorModel.fromJson(data);
    return autherModel;
  }

  Future<BookModel> freeBooks(pageno) async {
    BookModel freeBooksModel;
    String freepaidbook = "free_paid_book";
    Response response = await dio.post('$baseurl$freepaidbook',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'is_paid': "0",
          'page_no': pageno,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    freeBooksModel = BookModel.fromJson(data);
    return freeBooksModel;
  }

  Future<BookModel> paidBooks(pageno) async {
    BookModel paidBooksModel;
    String freepaidbook = "free_paid_book";
    Response response = await dio.post('$baseurl$freepaidbook',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'is_paid': "1",
          'page_no': pageno,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    paidBooksModel = BookModel.fromJson(data);
    return paidBooksModel;
  }

  Future<BookModel> newArrivalbooks(pageno) async {
    BookModel newArrivalBooksModel;
    String freepaidbook = "new_arrival";
    Response response = await dio.post('$baseurl$freepaidbook',
        data: FormData.fromMap({
          'page_no': pageno,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    newArrivalBooksModel = BookModel.fromJson(data);
    return newArrivalBooksModel;
  }

  Future<BookModel> alsoLikebooks(pageno) async {
    BookModel alsoLikeBooksModel;
    String freepaidbook = "also_like";
    Response response = await dio.post('$baseurl$freepaidbook',
        data: FormData.fromMap({
          'page_no': pageno,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    alsoLikeBooksModel = BookModel.fromJson(data);
    return alsoLikeBooksModel;
  }

  Future<BookDetailModel> bookdetails(bookid) async {
    BookDetailModel bookDetailModel;
    String freepaidbook = "book_detail";
    Response response = await dio.post('$baseurl$freepaidbook',
        data: FormData.fromMap({
          'book_id': bookid,
          'user_id': (Constant.userID == null) ? 0 : Constant.userID
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    bookDetailModel = BookDetailModel.fromJson(data);
    return bookDetailModel;
  }

  Future<BookDetailModel> bookdetailsAuther(bookid, autherUserid) async {
    BookDetailModel bookDetailModel;
    String freepaidbook = "book_detail";
    Response response = await dio.post('$baseurl$freepaidbook',
        data: FormData.fromMap({'book_id': bookid, 'user_id': autherUserid}));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    bookDetailModel = BookDetailModel.fromJson(data);
    return bookDetailModel;
  }

  Future<BookDetailModel> megazinedetails(magazineid) async {
    BookDetailModel magazineDetailModel;
    String freepaidbook = "magazine_detail";
    Response response = await dio.post('$baseurl$freepaidbook',
        data: FormData.fromMap({
          'magazine_id': magazineid,
          'user_id': (Constant.userID == null) ? 0 : Constant.userID
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    magazineDetailModel = BookDetailModel.fromJson(data);
    return magazineDetailModel;
  }

  Future<BookDetailModel> megazinedetailsAuther(
      magazineid, autherUserid) async {
    BookDetailModel magazineDetailModel;
    String freepaidbook = "magazine_detail";
    Response response = await dio.post('$baseurl$freepaidbook',
        data: FormData.fromMap(
            {'magazine_id': magazineid, 'user_id': autherUserid}));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    magazineDetailModel = BookDetailModel.fromJson(data);
    return magazineDetailModel;
  }

  Future<ChapterModel> chapterByBook(bookid, pageno) async {
    ChapterModel bookChapterModel;
    String freepaidbook = "get_chapter_by_book";
    Response response = await dio.post('$baseurl$freepaidbook',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'book_id': bookid,
          'page_no': pageno,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    bookChapterModel = ChapterModel.fromJson(data);
    return bookChapterModel;
  }

  Future<ChapterModel> chapterByMagazine(magazineid) async {
    ChapterModel magazineChapterModel;
    String freepaidbook = "get_chapter_by_magazine";
    Response response = await dio.post('$baseurl$freepaidbook',
        data: FormData.fromMap({
          'magazine_id': magazineid,
          // 'page_no': pageno,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    magazineChapterModel = ChapterModel.fromJson(data);
    return magazineChapterModel;
  }

  Future<CommentModel> viewCommentSimple(type, bookid, magazineid) async {
    CommentModel commentModel;
    String freepaidbook = "view_comment";

    Map<String, dynamic> commentMap = {};
    if (type == "BOOK") {
      commentMap = {
        'book_id': bookid,
      };
    } else if (type == "MAGAZINE") {
      commentMap = {
        'magazine_id': magazineid,
      };
    }
    Response response = await dio.post('$baseurl$freepaidbook',
        data: FormData.fromMap(commentMap));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    commentModel = CommentModel.fromJson(data);
    return commentModel;
  }

  Future<CommentModel> viewCommentPagination(
      type, bookid, magazineid, pageno) async {
    CommentModel commentModel;
    String freepaidbook = "view_comment";

    Map<String, dynamic> commentMap = {};
    if (type == "BOOK") {
      commentMap = {
        'book_id': bookid,
        'page_no': pageno,
      };
    } else if (type == "MAGAZINE") {
      commentMap = {
        'magazine_id': magazineid,
        'page_no': pageno,
      };
    }
    Response response = await dio.post('$baseurl$freepaidbook',
        data: FormData.fromMap(commentMap));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    commentModel = CommentModel.fromJson(data);
    return commentModel;
  }

  Future<SuccessModel> addComment(
      type, comment, magazineid, bookid, rating) async {
    SuccessModel addcommnetSuccessModel;
    String addComment = "add_comment";
    Map<String, dynamic> addCommentMap = {};
    if (type == "1") {
      addCommentMap = {
        'book_id': bookid,
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'rating': rating,
        'comment': comment,
        'type': type
      };
    } else if (type == "2") {
      addCommentMap = {
        'magazine_id': magazineid,
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'comment': comment,
        'rating': rating,
        'type': type
      };
    }
    Response response = await dio.post(
      '$baseurl$addComment',
      data: FormData.fromMap(addCommentMap),
    );
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    addcommnetSuccessModel = SuccessModel.fromJson(data);
    return addcommnetSuccessModel;
  }

  Future<SuccessModel> editComment(
      type, comment, commentId, rating, bookID, magazineID) async {
    SuccessModel editcommnetSuccessModel;
    String editComment = "edit_comment";
    Response response = await dio.post(
      '$baseurl$editComment',
      data: FormData.fromMap({
        "type": type,
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'comment': comment,
        'comment_id': commentId,
        'rating': rating,
        'book_id': bookID,
        'magazine_id': magazineID
      }),
    );
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    editcommnetSuccessModel = SuccessModel.fromJson(data);
    return editcommnetSuccessModel;
  }

  Future<SuccessModel> deleteComment(commentId) async {
    SuccessModel deleteSuccessModel;
    String deleteComment = "delete_comment";
    Response response = await dio.post(
      '$baseurl$deleteComment',
      data: FormData.fromMap({
        'comment_id': commentId,
        // 'user_id': (Constant.userID == null) ? 0 : Constant.userID,
      }),
    );
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    deleteSuccessModel = SuccessModel.fromJson(data);
    return deleteSuccessModel;
  }

  Future<SuccessModel> addBookMarkBook(bookid) async {
    SuccessModel addBookMarkModel;
    String deleteComment = "add_bookmark";
    Response response = await dio.post(
      '$baseurl$deleteComment',
      data: FormData.fromMap({
        'book_id': bookid,
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
      }),
    );
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    addBookMarkModel = SuccessModel.fromJson(data);
    return addBookMarkModel;
  }

  Future<SuccessModel> addRemoveDownload(bookid) async {
    SuccessModel addremoveDownloadModel;
    String download = "add_download";
    Response response = await dio.post(
      '$baseurl$download',
      data: FormData.fromMap({
        'chapter_id': bookid,
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
      }),
    );
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    addremoveDownloadModel = SuccessModel.fromJson(data);
    return addremoveDownloadModel;
  }

  Future<SuccessModel> addBookMarkMagazine(magazineid) async {
    SuccessModel addBookMarkModel;
    String deleteComment = "add_bookmark";
    Response response = await dio.post(
      '$baseurl$deleteComment',
      data: FormData.fromMap({
        'magazine_id': magazineid,
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
      }),
    );
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    addBookMarkModel = SuccessModel.fromJson(data);
    return addBookMarkModel;
  }

  Future<SuccessModel> addVoucher(title, points) async {
    SuccessModel addVoucherModel;
    String deleteComment = "add_voucher";
    Response response = await dio.post(
      '$baseurl$deleteComment',
      data: FormData.fromMap({
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'title': title,
        'points': points,
      }),
    );
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    addVoucherModel = SuccessModel.fromJson(data);
    return addVoucherModel;
  }

  Future<VoucherListModel> getVoucherList() async {
    VoucherListModel voucherListModel;
    String deleteComment = "list_voucher";
    Response response = await dio.post(
      '$baseurl$deleteComment',
      data: FormData.fromMap({
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
      }),
    );
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    voucherListModel = VoucherListModel.fromJson(data);
    return voucherListModel;
  }

  Future<BookModel> getRelatedItems(
    type,
    detailsId,
    pageno,
  ) async {
    BookModel relatedItemsModel;
    String deleteComment = "related_item";
    Response response;

    response = await dio.post(
      '$baseurl$deleteComment',
      data: FormData.fromMap({
        'type': type,
        'detail_id': detailsId,
        'page_no': pageno,
      }),
    );

// Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    relatedItemsModel = BookModel.fromJson(data);
    return relatedItemsModel;
  }

  Future<BookModel> popularmagazines(pageno) async {
    BookModel popularMagazineModel;
    String deleteComment = "popular_magazine";
    Response response = await dio.post(
      '$baseurl$deleteComment',
      data: FormData.fromMap({
        'page_no': pageno,
      }),
    );
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    popularMagazineModel = BookModel.fromJson(data);
    return popularMagazineModel;
  }

  Future<BookModel> topDownloadMagazine(pageno) async {
    BookModel topDownloadMagazineModel;
    String deleteComment = "top_download_magazine";
    Response response = await dio.post(
      '$baseurl$deleteComment',
      data: FormData.fromMap({
        'page_no': pageno,
      }),
    );
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    topDownloadMagazineModel = BookModel.fromJson(data);
    return topDownloadMagazineModel;
  }

  Future<SuccessModel> addView(
      String? chapterid, String? bookid, String? magazineid) async {
    printLog("chapterid  == $chapterid");
    printLog("bookid  == $bookid");
    printLog("magazineid  == $magazineid");

    SuccessModel addViewModel;
    String getcategory = "add_view";
    Map<String, dynamic> addVeiwMap = {
      'user_id': (Constant.userID == null) ? 0 : Constant.userID
    };

    if (bookid != null && bookid != "") {
      addVeiwMap['book_id'] = bookid;
    }
    if (magazineid != null && magazineid != "") {
      addVeiwMap['magazine_id'] = magazineid;
    }
    if (chapterid != null && chapterid != "") {
      addVeiwMap['chapter_id'] = chapterid;
    }

    Response response = await dio.post('$baseurl$getcategory',
        data: FormData.fromMap(addVeiwMap));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    addViewModel = SuccessModel.fromJson(data);
    return addViewModel;
  }

  Future<BookModel> magazinebyCatagory(pageno, categoryid) async {
    BookModel categoryModel;
    String getcategory = "get_magazine_by_category";
    Response response = await dio.post('$baseurl$getcategory',
        data: FormData.fromMap({
          'page_no': pageno,
          'category_id': categoryid,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    categoryModel = BookModel.fromJson(data);
    return categoryModel;
  }

  Future<BookModel> bookbyCatagory(pageno, categoryid) async {
    BookModel categoryModel;
    String getcategory = "get_book_by_category";
    Response response = await dio.post('$baseurl$getcategory',
        data: FormData.fromMap({
          'page_no': pageno,
          'category_id': categoryid,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    categoryModel = BookModel.fromJson(data);
    return categoryModel;
  }

  Future<BookModel> suggestionbookmagazine(type, pageno) async {
    BookModel bookModel;
    String getsuggestion = "suggestion_list";
    Response response = await dio.post('$baseurl$getsuggestion',
        data: FormData.fromMap({
          'type': type,
          'page_no': pageno,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    bookModel = BookModel.fromJson(data);
    return bookModel;
  }

  Future<AtherProfileModel> autherProfile(autherUerid) async {
    AtherProfileModel autherProfileModel;
    String getprofile = "author_profile";
    Response response = await dio.post('$baseurl$getprofile',
        data: FormData.fromMap({
          'user_id': autherUerid,
          'to_user_id': (Constant.userID == null) ? 0 : Constant.userID
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    autherProfileModel = AtherProfileModel.fromJson(data);
    return autherProfileModel;
  }

  Future<BankDetailsModel> getBankDetailsAuther() async {
    BankDetailsModel bankDetailsModel;
    String getprofile = "get_bank_detail";
    Response response = await dio.post('$baseurl$getprofile',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    bankDetailsModel = BankDetailsModel.fromJson(data);
    return bankDetailsModel;
  }

  Future<BankDetailsModel> updateBankDetailsAuther(
      bankname, accountno, ifsccode, bankholdername) async {
    BankDetailsModel updateBankDetailsModel;
    String getprofile = "update_bank_detail";
    Response response = await dio.post('$baseurl$getprofile',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'bank_name': bankname,
          'account_no': accountno,
          'ifsc_code': ifsccode,
          'bank_holder_name': bankholdername
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    updateBankDetailsModel = BankDetailsModel.fromJson(data);
    return updateBankDetailsModel;
  }

  Future<BookModel> getBookByAuther(autherUerid, pageno) async {
    BookModel autherBookModel;
    String getprofile = "get_book_by_author";
    Response response = await dio.post('$baseurl$getprofile',
        data: FormData.fromMap({'user_id': autherUerid, 'page_no': pageno}));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    autherBookModel = BookModel.fromJson(data);
    return autherBookModel;
  }

  Future<BookModel> getMagazineByAuther(autherUerid, pageno) async {
    BookModel autherMagazineModel;
    String getprofile = "get_magazine_by_author";
    Response response = await dio.post('$baseurl$getprofile',
        data: FormData.fromMap({'user_id': autherUerid, 'page_no': pageno}));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    autherMagazineModel = BookModel.fromJson(data);
    return autherMagazineModel;
  }

  Future<UploadBookModel> uploadBook(
      // dynamic autherUerid,
      categoryid,
      title,
      price,
      description,
      sampleurlfile, // FILE
      urlfile, // FILE
      ispaid,
      image) async {
    UploadBookModel uploadBookModel;
    String getprofile = "upload_book";
    Response response = await dio.post('$baseurl$getprofile',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'category_id': categoryid,
          'title': title,
          'price': price,
          'description': description,
          'sample_url': await MultipartFile.fromFile(sampleurlfile),
          'url': await MultipartFile.fromFile(urlfile),
          'is_paid': ispaid,
          "image": await MultipartFile.fromFile(image),
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    uploadBookModel = UploadBookModel.fromJson(data);
    return uploadBookModel;
  }

  Future<UploadBookModel> uploadMagazine(
      dynamic categoryid,
      dynamic title,
      dynamic price,
      dynamic description,
      dynamic sampleurlfile, // FILE
      dynamic urlfile, // FILE
      dynamic ispaid,
      dynamic image) async {
    UploadBookModel uploadMagazineModel;
    String getprofile = "upload_magazine";
    Response response = await dio.post('$baseurl$getprofile',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'category_id': categoryid,
          'title': title,
          'price': price,
          'description': description,
          'sample_url': await MultipartFile.fromFile(sampleurlfile),
          'url': await MultipartFile.fromFile(urlfile),
          'is_paid': ispaid,
          "image": await MultipartFile.fromFile(image),
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    uploadMagazineModel = UploadBookModel.fromJson(data);
    return uploadMagazineModel;
  }

  // Future<UploadBookModel> updateBook(
  //     dynamic bookid,
  //     dynamic categoryid,
  //     dynamic title,
  //     dynamic price,
  //     dynamic description,
  //     dynamic sampleurlfile, // FILE
  //     dynamic urlfile, // FILE
  //     dynamic ispaid,
  //     dynamic image) async {
  //   printLog("title -----?? $title");
  //   // printLog("sampleurlfile -----?? $sampleurlfile");
  //   // printLog(
  //   //     "autherUerid -----?? ${(Constant.userID == null) ? 0 : Constant.userID}");
  //   // printLog("categoryid -----?? $categoryid");
  //   // printLog("bookid -----?? $bookid");
  //   // printLog("price -----?? $price");
  //   // printLog("description -----?? $description");
  //   // printLog("ispaid -----?? $ispaid");
  //   // printLog("image -----?? $image");
  //   // printLog("urlfile -----?? $urlfile");
  //   // UploadBookModel updateBookModel;
  //   // Map<String, dynamic> updateBookMap = {};
  //   // if (sampleurlfile == null && urlfile != null && image != null) {
  //   //   printLog("-----?? 0");
  //   //   updateBookMap = {
  //   //     'user_id': (Constant.userID == null) ? 0 : Constant.userID,
  //   //     'category_id': categoryid,
  //   //     'book_id': bookid,
  //   //     'title': title,
  //   //     'price': price,
  //   //     'description': description,
  //   //     'url': await MultipartFile.fromFile(urlfile),
  //   //     'is_paid': ispaid,
  //   //     "image": await MultipartFile.fromFile(image),
  //   //   };
  //   // } else if (sampleurlfile != null && urlfile == null && image != null) {
  //   //   printLog("-----?? 1");
  //   //   updateBookMap = {
  //   //     'user_id': (Constant.userID == null) ? 0 : Constant.userID,
  //   //     'category_id': categoryid,
  //   //     'book_id': bookid,
  //   //     'title': title,
  //   //     'price': price,
  //   //     'description': description,
  //   //     'sample_url': await MultipartFile.fromFile(sampleurlfile),
  //   //     'is_paid': ispaid,
  //   //     "image": await MultipartFile.fromFile(image),
  //   //   };
  //   // } else if (sampleurlfile != null && urlfile != null && image == null) {
  //   //   printLog("-----?? 2");
  //   //   updateBookMap = {
  //   //     'user_id': (Constant.userID == null) ? 0 : Constant.userID,
  //   //     'category_id': categoryid,
  //   //     'book_id': bookid,
  //   //     'title': title,
  //   //     'price': price,
  //   //     'description': description,
  //   //     'sample_url': await MultipartFile.fromFile(sampleurlfile),
  //   //     'url': await MultipartFile.fromFile(urlfile),
  //   //     'is_paid': ispaid,
  //   //   };
  //   // } else if (urlfile == null && sampleurlfile == null && image != null) {
  //   //   printLog("-----?? 3");
  //   //   updateBookMap = {
  //   //     'user_id': (Constant.userID == null) ? 0 : Constant.userID,
  //   //     'category_id': categoryid,
  //   //     'book_id': bookid,
  //   //     'title': title,
  //   //     'price': price,
  //   //     'description': description,
  //   //     'is_paid': ispaid,
  //   //     'image': await MultipartFile.fromFile(image),
  //   //   };
  //   // } else if (image == null && urlfile == null && sampleurlfile != null) {
  //   //   printLog("-----?? 4");
  //   //   updateBookMap = {
  //   //     'user_id': (Constant.userID == null) ? 0 : Constant.userID,
  //   //     'category_id': categoryid,
  //   //     'book_id': bookid,
  //   //     'title': title,
  //   //     'price': price,
  //   //     'sample_url': await MultipartFile.fromFile(sampleurlfile),
  //   //     'description': description,
  //   //     'is_paid': ispaid,
  //   //   };
  //   // } else if (image == null && sampleurlfile == null && urlfile != null) {
  //   //   printLog("-----?? 5");
  //   //   updateBookMap = {
  //   //     'user_id': (Constant.userID == null) ? 0 : Constant.userID,
  //   //     'category_id': categoryid,
  //   //     'book_id': bookid,
  //   //     'title': title,
  //   //     'price': price,
  //   //     'url': await MultipartFile.fromFile(urlfile),
  //   //     'description': description,
  //   //     'is_paid': ispaid,
  //   //   };
  //   // } else if (image == null && urlfile == null && sampleurlfile == null) {
  //   //   printLog("-----?? 6");
  //   //   updateBookMap = {
  //   //     'user_id': (Constant.userID == null) ? 0 : Constant.userID,
  //   //     'category_id': categoryid,
  //   //     'book_id': bookid,
  //   //     'title': title,
  //   //     'price': price,
  //   //     'description': description,
  //   //     'is_paid': ispaid,
  //   //   };
  //   // } else {
  //   //   printLog("-----?? 7");
  //   //   updateBookMap = {
  //   //     'user_id': (Constant.userID == null) ? 0 : Constant.userID,
  //   //     'category_id': categoryid,
  //   //     'book_id': bookid,
  //   //     'title': title,
  //   //     'price': price,
  //   //     'description': description,
  //   //     'is_paid': ispaid,
  //   //     'sample_url': await MultipartFile.fromFile(sampleurlfile),
  //   //     'url': await MultipartFile.fromFile(urlfile),
  //   //     'image': await MultipartFile.fromFile(image),
  //   //   };
  //   // }
  //   // printLog("updateBookMap -----?? $updateBookMap");

  //   // String getprofile = "update_book";
  //   // Response response = await dio.post('$baseurl$getprofile',
  //   //     data: FormData.fromMap(updateBookMap))
  //   //     // Check the type of response.data
  //   // final data =
  //   //     response.data is String ? jsonDecode(response.data) : response.data;;
  //   // printLog("updateBookModel -----?? ${data}");
  //   // // Check the type of response.data
  //   // final data =
  //   //     response.data is String ? jsonDecode(response.data) : response.data;
  //   // updateBookModel = UploadBookModel.fromJson(data);
  //   // printLog("updateBookModel -----?? $updateBookModel");
  //   // return updateBookModel;
  // }

  Future<UploadBookModel> updateMagazine(
      dynamic magazineid,
      dynamic categoryid,
      dynamic title,
      dynamic price,
      dynamic description,
      dynamic sampleurlfile, // FILE
      dynamic urlfile, // FILE
      dynamic ispaid,
      dynamic image) async {
    printLog("title -----?? $title");
    printLog("sampleurlfile -----?? $sampleurlfile");
    printLog(
        "autherUerid -----?? ${(Constant.userID == null) ? 0 : Constant.userID}");
    printLog("categoryid -----?? $categoryid");
    printLog("magazineid -----?? $magazineid");
    printLog("price -----?? $price");
    printLog("description -----?? $description");
    printLog("ispaid -----?? $ispaid");
    printLog("image -----?? $image");
    printLog("urlfile -----?? $urlfile");
    UploadBookModel updateMagazineModel;
    Map<String, dynamic> updateBookMap = {};
    if (sampleurlfile == null && urlfile != null && image != null) {
      printLog("-----?? 0");
      updateBookMap = {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'category_id': categoryid,
        'magazine_id': magazineid,
        'title': title,
        'price': price,
        'description': description,
        'url': await MultipartFile.fromFile(urlfile),
        'is_paid': ispaid,
        "image": await MultipartFile.fromFile(image),
      };
    } else if (sampleurlfile != null && urlfile == null && image != null) {
      printLog("-----?? 1");
      updateBookMap = {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'category_id': categoryid,
        'magazine_id': magazineid,
        'title': title,
        'price': price,
        'description': description,
        'sample_url': await MultipartFile.fromFile(sampleurlfile),
        'is_paid': ispaid,
        "image": await MultipartFile.fromFile(image),
      };
    } else if (sampleurlfile != null && urlfile != null && image == null) {
      printLog("-----?? 2");
      updateBookMap = {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'category_id': categoryid,
        'magazine_id': magazineid,
        'title': title,
        'price': price,
        'description': description,
        'sample_url': await MultipartFile.fromFile(sampleurlfile),
        'url': await MultipartFile.fromFile(urlfile),
        'is_paid': ispaid,
      };
    } else if (urlfile == null && sampleurlfile == null && image != null) {
      printLog("-----?? 3");
      updateBookMap = {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'category_id': categoryid,
        'magazine_id': magazineid,
        'title': title,
        'price': price,
        'description': description,
        'is_paid': ispaid,
        'image': await MultipartFile.fromFile(image),
      };
    } else if (image == null && urlfile == null && sampleurlfile != null) {
      printLog("-----?? 4");
      updateBookMap = {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'category_id': categoryid,
        'magazine_id': magazineid,
        'title': title,
        'price': price,
        'sample_url': await MultipartFile.fromFile(sampleurlfile),
        'description': description,
        'is_paid': ispaid,
      };
    } else if (image == null && sampleurlfile == null && urlfile != null) {
      printLog("-----?? 5");
      updateBookMap = {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'category_id': categoryid,
        'magazine_id': magazineid,
        'title': title,
        'price': price,
        'url': await MultipartFile.fromFile(urlfile),
        'description': description,
        'is_paid': ispaid,
      };
    } else if (image == null && urlfile == null && sampleurlfile == null) {
      printLog("-----?? 6");
      updateBookMap = {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'category_id': categoryid,
        'magazine_id': magazineid,
        'title': title,
        'price': price,
        'description': description,
        'is_paid': ispaid,
      };
    } else {
      printLog("-----?? 7");
      updateBookMap = {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'category_id': categoryid,
        'magazine_id': magazineid,
        'title': title,
        'price': price,
        'description': description,
        'is_paid': ispaid,
        'sample_url': await MultipartFile.fromFile(sampleurlfile),
        'url': await MultipartFile.fromFile(urlfile),
        'image': await MultipartFile.fromFile(image),
      };
    }
    printLog("updateMagazineMap -----?? $updateBookMap");

    String getprofile = "update_magazine";
    Response response = await dio.post('$baseurl$getprofile',
        data: FormData.fromMap(updateBookMap));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;

    updateMagazineModel = UploadBookModel.fromJson(data);

    printLog("updateMagazineModel -----?? $updateMagazineModel");
    return updateMagazineModel;
  }

  Future<SuccessModel> deleteBook(String bookid) async {
    SuccessModel deleteBookModel;
    String getprofile = "delete_book";
    Response response = await dio.post('$baseurl$getprofile',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'book_id': bookid,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    deleteBookModel = SuccessModel.fromJson(data);
    return deleteBookModel;
  }

  Future<SuccessModel> followunfollow(toUserID) async {
    SuccessModel followunfollowModel;
    String followunfollow = "follow_unfollow";
    Response response = await dio.post('$baseurl$followunfollow',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'to_user_id': toUserID,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    followunfollowModel = SuccessModel.fromJson(data);
    return followunfollowModel;
  }

  Future<SuccessModel> deleteMagazine(String magazineid) async {
    SuccessModel deleteBookModel;
    String getprofile = "delete_magazine";
    Response response = await dio.post('$baseurl$getprofile',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'magazine_id': magazineid,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    deleteBookModel = SuccessModel.fromJson(data);
    return deleteBookModel;
  }

  Future<FollowListModel> followinglist(pageno) async {
    FollowListModel followinglistModel;
    String getfollowinglist = "get_following_list";
    Response response = await dio.post('$baseurl$getfollowinglist',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'page_no': pageno
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    followinglistModel = FollowListModel.fromJson(data);
    return followinglistModel;
  }

  Future<FollowListModel> followerlist(pageno) async {
    FollowListModel followerlistModel;
    String getfollowinglist = "get_follower_list";
    Response response = await dio.post('$baseurl$getfollowinglist',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'page_no': pageno
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    followerlistModel = FollowListModel.fromJson(data);
    return followerlistModel;
  }

  Future<PackageModel> package() async {
    PackageModel getpackageModel;
    String getpackage = "get_plan";
    Response response = await dio.post('$baseurl$getpackage',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    getpackageModel = PackageModel.fromJson(data);
    return getpackageModel;
  }

  Future<WalletHistoryModel> walletHistory(pageno) async {
    WalletHistoryModel getwalletHistoryModel;
    String getpackage = "get_wallet_history";
    Response response = await dio.post('$baseurl$getpackage',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'page_no': pageno,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    getwalletHistoryModel = WalletHistoryModel.fromJson(data);
    return getwalletHistoryModel;
  }

  Future<BookModel> searchMagazine(name, pageno) async {
    BookModel magazineSearchModel;
    String searchvideo = "search_magazine";
    Response response = await dio.post('$baseurl$searchvideo',
        data: FormData.fromMap({
          'name': name,
          'page_no': pageno,
        }));
    // Check the type of response.data
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;
    magazineSearchModel = BookModel.fromJson(data);
    return magazineSearchModel;
  }

  Future<SuccessModel> bookRating(bookid, rating) async {
    SuccessModel bookRatingModel;
    String likedislike = "add_book_rating";
    Response response = await dio.post('$baseurl$likedislike',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'book_id': bookid,
          'rating': rating
        }));
    bookRatingModel = SuccessModel.fromJson(response.data);
    return bookRatingModel;
  }

  Future<SuccessModel> magazineRating(magazineid, rating) async {
    SuccessModel magazineRatingModel;
    String likedislike = "add_magazine_rating";
    Response response = await dio.post('$baseurl$likedislike',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'magazine_id': magazineid,
          'rating': rating
        }));
    magazineRatingModel = SuccessModel.fromJson(response.data);
    return magazineRatingModel;
  }

  Future<SuccessModel> addContinueRead(bookid) async {
    SuccessModel successModel;
    String addtransaction = "add_continue_read";
    Response response = await dio.post('$baseurl$addtransaction',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'book_id': bookid,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<BookModel> getContinueRead(pageno) async {
    BookModel continueReadModel;
    String addtransaction = "get_continue_read";
    Response response = await dio.post('$baseurl$addtransaction',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'page_no': pageno,
        }));
    continueReadModel = BookModel.fromJson(response.data);
    return continueReadModel;
  }

  Future<BookModel> getPurchaseList(type, pageno) async {
    BookModel purchaseListModel;
    String addtransaction = "get_purchase_list";
    Response response = await dio.post('$baseurl$addtransaction',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'type': type,
          'page_no': pageno,
        }));
    purchaseListModel = BookModel.fromJson(response.data);
    return purchaseListModel;
  }

  Future<SuccessModel> addPackageTransection(packageId, amount) async {
    SuccessModel successModel;
    String addtransaction = "add_package_transaction";
    Response response = await dio.post('$baseurl$addtransaction',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID ?? "",
          'package_id': packageId,
          'price': amount,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> addChapterTransection(
    autherid,
    amount,
    bookChapterId,
  ) async {
    SuccessModel successModel;
    String addtransaction = "add_transaction";
    Response response = await dio.post('$baseurl$addtransaction',
        data: FormData.fromMap({
          'type': "3",
          'user_id': (Constant.userID == null) ? 0 : Constant.userID ?? "",
          'author_id': autherid,
          'amount': amount,
          'book_chapter_id': bookChapterId,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> addBookTransection(autherid, amount, bookId) async {
    SuccessModel successModel;
    String addtransaction = "add_transaction";
    Response response = await dio.post('$baseurl$addtransaction',
        data: FormData.fromMap({
          'type': "1",
          'user_id': (Constant.userID == null) ? 0 : Constant.userID ?? "",
          'author_id': autherid,
          'amount': amount,
          'book_id': bookId,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> addMagazineTransection(
      autherid, amount, magazineid) async {
    SuccessModel successModel;
    String addtransaction = "add_transaction";
    Response response = await dio.post('$baseurl$addtransaction',
        data: FormData.fromMap({
          'type': "2",
          'user_id': (Constant.userID == null) ? 0 : Constant.userID ?? "",
          'author_id': autherid,
          'amount': amount,
          'magazine_id': magazineid,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

// Future<SuccessModel> addTransection(
//       autherid,
//       amount,
//       bookId,
//       magazineId,
//       bookChapterId,
//       voucherId,
//       voucherAmount,
//       transectionId,
//       transectionAmount,
//       walletAmount,
//       type) async {
//     SuccessModel successModel;
//     String addtransaction = "add_transaction";
//     Response response = await dio.post('$baseurl$addtransaction',
//         data: FormData.fromMap({
//           'user_id': (Constant.userID == null) ? 0 : Constant.userID ?? "",
//           'author_id': autherid,
//           'amount': amount,
//           'book_id': bookId,
//           'magazine_id': magazineId,
//           'book_chapter_id': bookChapterId,
//           'voucher_id': voucherId,
//           'voucher_amount': voucherAmount,
//           'transcation_id': transectionId,
//           'transcation_amount': transectionAmount,
//           'wallet_amount': walletAmount,
//           'type': type,
//         }));
//     successModel = SuccessModel.fromJson(response.data);
//     return successModel;
//   }

  // get_payment_token API
  Future<PayTmModel> getPaytmToken(merchantID, orderId, custmoreID, channelID,
      txnAmount, website, callbackURL, industryTypeID) async {
    PayTmModel payTmModel;
    String paytmToken = "get_payment_token";
    printLog("paytmToken API :==> $baseurl$paytmToken");
    Response response = await dio.post(
      '$baseurl$paytmToken',
      data: FormData.fromMap({
        'MID': merchantID,
        'order_id': orderId,
        'CUST_ID': custmoreID,
        'CHANNEL_ID': channelID,
        'TXN_AMOUNT': txnAmount,
        'WEBSITE': website,
        'CALLBACK_URL': callbackURL,
        'INDUSTRY_TYPE_ID': industryTypeID,
      }),
    );

    payTmModel = PayTmModel.fromJson(response.data);
    return payTmModel;
  }

  // add_amount_wallet API
  Future<SuccessModel> addAmountWallet(
      amount, transactionId, description) async {
    printLog("addAmountToWallet amount ===========> $amount");
    printLog("addAmountToWallet transactionId ====> $transactionId");
    printLog("addAmountToWallet description ======> $description");
    SuccessModel liveStreamModel;
    String addAmountToWalletAPI = "add_amount_wallet";
    Response response = await dio.post(
      '$baseurl$addAmountToWalletAPI',
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'amount': amount,
        'transaction_id': transactionId,
        'description': description,
      },
    );
    liveStreamModel = SuccessModel.fromJson(response.data);
    return liveStreamModel;
  }

  // apply_coupon API
  Future<CouponModel> applyPackageCoupon(couponCode, packageId) async {
    CouponModel couponModel;
    String applyCoupon = "apply_coupon";
    Response response = await dio.post(
      '$baseurl$applyCoupon',
      data: {
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'apply_coupon_type': "1",
        'unique_id': couponCode,
        'package_id': packageId,
      },
    );

    couponModel = CouponModel.fromJson(response.data);
    return couponModel;
  }

  // update_profile API
  Future<UserModel> updateDataForPayment(fullName, email, mobileNumber) async {
    printLog(
        "updateDataForPayment userID :====> ${(Constant.userID == null) ? 0 : Constant.userID}");
    printLog("updateDataForPayment fullName :==> $fullName");
    printLog("updateDataForPayment email :=====> $email");
    printLog("updateProfile mobileNumber :=====> $mobileNumber");

    UserModel updateprofileModel;
    String apiName = "update_profile";
    Response response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'full_name': fullName,
        'email': email,
        'mobile_number': mobileNumber,
      }),
    );

    updateprofileModel = UserModel.fromJson(response.data);
    return updateprofileModel;
  }

/* Audio Section Api */
  Future<AudioSectionModel> audioSectionResponse(sectionType) async {
    AudioSectionModel audioSectionModel;
    String apiName = "get_content_section";
    Response response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({
        'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        'section_type': sectionType,
      }),
    );

    audioSectionModel = AudioSectionModel.fromJson(response.data);
    return audioSectionModel;
  }

  Future<CommonModel> getCategoryContent({
    contentType,
    categoryId,
    authorId,
    languageId,
    pageno,
  }) async {
    const apiName = "get_content";

    final response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({
        'content_type': contentType,
        if (categoryId != null) 'category_id': categoryId,
        if (authorId != null) 'author_id': authorId,
        if (languageId != null) 'language_id': languageId,
        'user_id': Constant.userID ?? 0,
        "page_no": pageno,
      }),
    );

    // On web/proxy setups Dio can return JSON as String. Decode safely.
    final data =
        response.data is String ? jsonDecode(response.data) : response.data;

    return CommonModel.fromJson(data);
  }

  Future<SuccessModel> contactusapi({
    name,
    email,
    subject,
    details,
  }) async {
    const apiName = "contact_us";

    final response = await dio.post(
      '$baseurl$apiName',
      data: FormData.fromMap({
        'user_id': Constant.userID ?? 0,
        'name': name,
        'email': email,
        'subject': subject,
        if (details != null) 'details': details,
      }),
    );

    return SuccessModel.fromJson(response.data);
  }

/* --------------------------------- 1.3 version api start -------------------------- */

  Future<SuccessModel> buyplanapi({
    required String planid,
    required String price,
    String? couponcode,
    String? totaltax,
    String? tax,
    String? transactionid,
    String? paymentmethod,
  }) async {
    SuccessModel successModel;
    String addtransaction = "buy_plan";

    final Map<String, dynamic> body = {
      'user_id': Constant.userID ?? 0,
      'plan_id': planid,
      'price': price,
    };

    if (couponcode != null && couponcode.isNotEmpty) {
      body['coupon_code'] = couponcode;
    }

    if (totaltax != null && totaltax.isNotEmpty) {
      body['total_tax'] = totaltax;
    }

    if (tax != null && tax.isNotEmpty) {
      body['tax'] = tax;
    }

    if (transactionid != null && transactionid.isNotEmpty) {
      body['transaction_id'] = transactionid;
    }

    if (paymentmethod != null && paymentmethod.isNotEmpty) {
      body['payment_method'] = paymentmethod;
    }

    Response response = await dio.post(
      '$baseurl$addtransaction',
      data: FormData.fromMap(body),
    );

    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<Usersubscriptionmodel> usersubscriptionplan() async {
    Usersubscriptionmodel usersubscriptionmodel;
    String addtransaction = "get_user_plan";
    Response response = await dio.post('$baseurl$addtransaction',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
        }));
    usersubscriptionmodel = Usersubscriptionmodel.fromJson(response.data);
    return usersubscriptionmodel;
  }

  Future<Userplanhistorymodel> subscriptionhistory(status, pageno) async {
    Userplanhistorymodel userplanhistorymodel;
    String addtransaction = "get_user_plan_history";
    Response response = await dio.post('$baseurl$addtransaction',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          if (status != null) 'status': status,
          'page_no': pageno
        }));
    userplanhistorymodel = Userplanhistorymodel.fromJson(response.data);
    return userplanhistorymodel;
  }

  Future<SuccessModel> canelsubscription(tid) async {
    SuccessModel successModel;
    String addtransaction = "cancel_subscription";
    Response response = await dio.post('$baseurl$addtransaction',
        data: FormData.fromMap({'transaction_id': tid}));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<Addhistorymodel> addhistoryapi(authorid, contenttype, contentid,
      subcontentid, timespend, isSubscription, lastposition) async {
    Addhistorymodel addhistorymodel;
    String addtransaction = "add_history";
    Response response = await dio.post('$baseurl$addtransaction',
        data: FormData.fromMap({
          'user_id': (Constant.userID == null) ? 0 : Constant.userID,
          'author_id': authorid,
          'content_type': contenttype,
          'content_id': contentid,
          if (subcontentid != null) 'sub_content_id': subcontentid,
          'time_spend': timespend,
          'is_subscription': isSubscription,
          'last_position': lastposition
        }));
    addhistorymodel = Addhistorymodel.fromJson(response.data);
    return addhistorymodel;
  }
}

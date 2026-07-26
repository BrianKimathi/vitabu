import 'package:yourappname/model/usermodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/model/profilemodel.dart';

class UpdateprofileProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  UserModel userModel = UserModel();
  bool loading = false;
  bool isUpdate = false;

  setUpdate(isLoding) {
    isUpdate = isLoding;
    notifyListeners();
  }

  setLoding(isLoding) {
    loading = isLoding;
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

  Future<void> getUpdateProfile(
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
    setUpdate(true);
    userModel = await ApiService().updateProfileResponse(
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
    );
    setUpdate(false);
  }

  providerNotified() {
    notifyListeners();
  }
}


import 'dart:io';
import 'package:yourappname/pages/genresprefrences.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/provider/updateprofileprovider.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  final String? autherUserid;
  const UpdateProfile({super.key, this.autherUserid});

  @override
  State<UpdateProfile> createState() => UpdateProfileState();
}

class UpdateProfileState extends State<UpdateProfile> {
  final ImagePicker picker = ImagePicker();

  File? _image;
  bool iseditimg = false;
  String userid = "", name = "";
  TextEditingController userNameController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String? userImage, categoryIds, categoryName, type;
  String? strDeviceType, strPrivacyAndTNC, strDeviceToken;

  List<String> categoryNameList = [];

  late UpdateprofileProvider updateprofileProvider;
  @override
  void initState() {
    updateprofileProvider =
        Provider.of<UpdateprofileProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi();
    });
    super.initState();
    _getDeviceToken();
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

  getApi() async {
    updateprofileProvider.setLoding(true);
    await updateprofileProvider.getProfile(Constant.userID);

    if (updateprofileProvider.profileModel.status == 200) {
      userImage =
          updateprofileProvider.profileModel.result?[0].image.toString() ?? "";
      userNameController.text =
          updateprofileProvider.profileModel.result?[0].userName.toString() ??
              "";
      firstnameController.text =
          updateprofileProvider.profileModel.result?[0].firstName.toString() ??
              "";
      lastnameController.text =
          updateprofileProvider.profileModel.result?[0].lastName.toString() ??
              "";
      numberController.text = updateprofileProvider
              .profileModel.result?[0].mobileNumber
              .toString() ??
          "";
      emailController.text =
          updateprofileProvider.profileModel.result?[0].email.toString() ?? "";
      bioController.text = updateprofileProvider
              .profileModel.result?[0].description
              .toString() ??
          "";
      addressController.text =
          updateprofileProvider.profileModel.result?[0].address.toString() ??
              "";

      categoryIds = updateprofileProvider.profileModel.result?[0].categoryIds
              .toString() ??
          "";
      categoryName = updateprofileProvider.profileModel.result?[0].categoryName
              .toString() ??
          "";

      if (categoryName != null) {
        categoryNameList = (categoryName ?? "").split(",");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Utils.backButton(context),
          centerTitle: false,
          titleSpacing: 0,
          title: MyText(
            text: "editprofile",
            multilanguage: true,
            fontstyle: FontStyle.normal,
            isfont: 3,
            fontwaight: FontWeight.w600,
            fontsize: Dimens.medium16TextSize,
          ),
        ),
        body: Consumer<UpdateprofileProvider>(
            builder: (context, updateprofileProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      _image == null
                          ? MyNetworkImage(
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              radius: 200,
                              imagePath: userImage ?? "")
                          : Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: FileImage(_image ?? File('')),
                                      fit: BoxFit.cover)),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () async {
                            XFile? image = await picker.pickImage(
                                source: ImageSource.gallery, imageQuality: 100);
                            if (image != null) {
                              setState(() {
                                _image = File(image.path);
                                iseditimg = true;
                              });
                            }
                          },
                          child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: black, width: 0.5),
                                color: colorPrimary,
                              ),
                              child: Icon(
                                FontAwesomeIcons.arrowUpFromBracket,
                                size: 18,
                                color: colorAccent,
                              )),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Align(
                  alignment: Alignment.center,
                  child: MyText(
                    text: "change_profile_picture",
                    fontsize: Dimens.medium14TextSize,
                    multilanguage: true,
                    fontwaight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 20),
                Divider(thickness: 1, color: gray, height: 20),
                SizedBox(height: 20),
                _myTitle(title: "user_name"),
                SizedBox(height: 10),
                myTextField(userNameController, TextInputAction.next,
                    TextInputType.text, Locales.string(context, "user_name")),
                SizedBox(height: 20),
                _myTitle(title: "firstname"),
                SizedBox(height: 10),
                myTextField(firstnameController, TextInputAction.next,
                    TextInputType.text, Locales.string(context, "firstname")),
                SizedBox(height: 20),
                _myTitle(title: "lastname"),
                SizedBox(height: 10),
                myTextField(lastnameController, TextInputAction.next,
                    TextInputType.text, Locales.string(context, "lastname")),
                SizedBox(height: 20),
                _myTitle(title: "email_address"),
                SizedBox(height: 10),
                myTextField(emailController, TextInputAction.next,
                    TextInputType.text, Locales.string(context, "email")),
                SizedBox(height: 20),
                _myTitle(title: "phone_number"),
                SizedBox(height: 10),
                myTextField(
                    numberController,
                    TextInputAction.next,
                    TextInputType.number,
                    Locales.string(context, "phone_number")),
                SizedBox(height: 20),
                _myTitle(title: "address"),
                SizedBox(height: 10),
                myTextField(addressController, TextInputAction.next,
                    TextInputType.text, Locales.string(context, "address")),
                SizedBox(height: 20),
                _myTitle(title: "bio"),
                SizedBox(height: 10),
                myTextField(bioController, TextInputAction.next,
                    TextInputType.text, Locales.string(context, "bio")),
                SizedBox(height: 20),
                _myTitle(title: "category"),
                SizedBox(height: 10),
                categoryData(),
                SizedBox(height: 30),
                InkWell(
                  splashColor: transparent,
                  focusColor: transparent,
                  hoverColor: transparent,
                  onTap: () {
                    dynamic image;

                    if (iseditimg) {
                      image = File(_image!.path);
                    } else {
                      image = File("");
                    }

                    updateAPI(
                      userNameController.text,
                      firstnameController.text,
                      lastnameController.text,
                      emailController.text,
                      numberController.text,
                      addressController.text,
                      bioController.text,
                      categoryIds ?? "",
                      image,
                      strDeviceToken,
                      strDeviceType,
                    );
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 80),
                      height: 45,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      curve: Curves.bounceInOut,
                      width: updateprofileProvider.isUpdate
                          ? 100
                          : MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: colorAccent,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: updateprofileProvider.isUpdate
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                color: white,
                                strokeWidth: 2,
                              ),
                            )
                          : MyText(
                              color: white,
                              text: "update",
                              multilanguage: true,
                              textalign: TextAlign.center,
                              fontsize: Dimens.medium14TextSize,
                              fontwaight: FontWeight.w500,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }));
  }

/* Category Widget Show */
  Widget categoryData() {
    return InkWell(
      splashColor: transparent,
      hoverColor: transparent,
      focusColor: transparent,
      onTap: () async {
        final result = await Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return GenresPrefrences(
              isCategoryType: false,
              categoryIds: categoryIds,
              categoryName: categoryName,
              isEditType: "1",
            );
          },
          transitionDuration: Duration(milliseconds: 150),
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
        if (result != null && result is Map<String, dynamic>) {
          type = result['type'] ?? "";
          categoryIds = result['ids'] ?? "";
          categoryName = result['name'] ?? "";
          if (type == '1') {
            type = type;
            categoryIds = categoryIds;
            categoryNameList = (categoryName ?? "").split(",");
            printLog("My New Selected Category List is $categoryNameList");
          }
          updateprofileProvider.providerNotified();
        }
        printLog("My New Selected Category is $categoryName");
      },
      child: Container(
          padding: EdgeInsets.fromLTRB(15, 14, 15, 14),
          width: MediaQuery.sizeOf(context).width,
          decoration: BoxDecoration(
              color: Constant.isDarkMode ? graycolor : Color(0xFFC4CCCC),
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  children: List.generate(
                    categoryNameList.length,
                    (index) {
                      return Container(
                        padding: EdgeInsets.fromLTRB(15, 4, 15, 4),
                        decoration: BoxDecoration(
                            color: Constant.isDarkMode ? gray : black,
                            borderRadius: BorderRadius.circular(8)),
                        child: MyText(
                          color: Constant.isDarkMode ? black : white,
                          text: categoryNameList[index],
                          fontsize: Dimens.medium14TextSize,
                          multilanguage: false,
                          fontwaight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_outlined,
                size: 20,
              )
            ],
          )),
    );
  }

/* END */

  updateAPI(
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
    try {
      await updateprofileProvider.getUpdateProfile(
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
          deviceType);
      if (updateprofileProvider.userModel.status == 200) {
        Utils.saveUserCreds(
            userID:
                updateprofileProvider.userModel.result?[0].id.toString() ?? "",
            categoryId: updateprofileProvider.userModel.result?[0].categoryIds
                    .toString() ??
                "",
            firstName: updateprofileProvider.userModel.result?[0].firstName
                    .toString() ??
                "",
            lastName:
                updateprofileProvider.userModel.result?[0].lastName.toString() ??
                    "",
            userName:
                updateprofileProvider.userModel.result?[0].userName.toString() ??
                    "",
            userImage:
                updateprofileProvider.userModel.result?[0].image.toString() ??
                    "",
            userEmail:
                updateprofileProvider.userModel.result?[0].email.toString() ??
                    "",
            mobileNumber:
                updateprofileProvider.userModel.result?[0].mobileNumber.toString() ?? "",
            walletCoin: updateprofileProvider.userModel.result?[0].walletAmount.toString() ?? "",
            address: updateprofileProvider.userModel.result?[0].address.toString() ?? "",
            isAuthor: updateprofileProvider.userModel.result?[0].isAuthor.toString() ?? "",
            deviceType: updateprofileProvider.userModel.result?[0].deviceType.toString() ?? "",
            deviceToken: updateprofileProvider.userModel.result?[0].deviceToken.toString() ?? "",
            description: updateprofileProvider.userModel.result?[0].description.toString() ?? "");

        if (!mounted) return;
        Navigator.pop(context);

/* Update Data And Call the Profile API */
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);

        profileProvider.setLoding(false);
        profileProvider.getProfile(Constant.userID);
      } else {
        if (!mounted) return;
        Utils.showSnackbar(
            context, updateprofileProvider.userModel.message ?? "", false);
      }
    } catch (e) {
      if (!mounted) return;
      Utils.showSnackbar(
          context, updateprofileProvider.userModel.message ?? "", false);
    }
  }

  Widget _myTitle({required String? title}) {
    return MyText(
      text: title ?? "",
      fontsize: Dimens.medium16TextSize,
      multilanguage: true,
      fontwaight: FontWeight.w500,
    );
  }

  Widget myTextField(controller, textInputAction, keyboardType, labletext) {
    return TextFormField(
      textAlign: TextAlign.left,
      obscureText: false,
      keyboardType: keyboardType,
      controller: controller,
      textInputAction: textInputAction,
      cursorColor: Constant.isDarkMode ? white : black,
      showCursor: true,
      style: GoogleFonts.roboto(
          fontSize: Dimens.medium14TextSize,
          color: Constant.isDarkMode ? white : black,
          fontWeight: FontWeight.w400),
      decoration: InputDecoration(
        hintText: labletext,
        hintStyle: GoogleFonts.roboto(
            fontSize: Dimens.medium14TextSize,
            color: Constant.isDarkMode ? white : black,
            fontWeight: FontWeight.w400),
        contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        fillColor: Constant.isDarkMode ? graycolor : Color(0xFFC4CCCC),
        filled: true,
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

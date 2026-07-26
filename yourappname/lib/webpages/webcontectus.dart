import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webwidget/footerweb.dart';
import 'package:yourappname/webwidget/interactivecontainer.dart';
import 'package:yourappname/webwidget/webappbar.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WebContectUS extends StatefulWidget {
  const WebContectUS({super.key});

  @override
  State<WebContectUS> createState() => _WebContectUSState();
}

class _WebContectUSState extends State<WebContectUS> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController descController = TextEditingController();

  GeneralProvider generalProvider = GeneralProvider();
  ProfileProvider profileProvider = ProfileProvider();
  @override
  void initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    getApiData();
  }

  Future getApiData() async {
    await generalProvider.getGeneralsetting(context);
    profileProvider.getsociallinkdata();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final contentWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 20;

    return WebAppBar(widget: SingleChildScrollView(
      child: Consumer2<GeneralProvider, ProfileProvider>(
          builder: (context, provider, profileprovider, child) {
        return Column(
          children: [
            Center(
              child: Container(
                width: contentWidth,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth <= 1000 ? 10 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Utils.buildWebDetailsAppBar(
                        context: context,
                        isHome: false,
                        title1: "contact_us",
                        multilanguage: true),
                    _buildData(),
                  ],
                ),
              ),
            ),
            FooterWeb(),
          ],
        );
      }),
    ));
  }

  Widget _buildData() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        MyImage(
          imagePath: "google_map.png",
          radius: 0,
          fit: BoxFit.fill,
          height: 400,
          width: MediaQuery.sizeOf(context).width,
        ),
        Padding(
          padding: EdgeInsets.only(top: 300),
          child: Container(
            margin: MediaQuery.sizeOf(context).width > 1400
                ? EdgeInsets.fromLTRB(250, 0, 250, 50)
                : MediaQuery.sizeOf(context).width > 1000
                    ? EdgeInsets.fromLTRB(180, 0, 180, 50)
                    : MediaQuery.sizeOf(context).width > 800
                        ? EdgeInsets.fromLTRB(120, 0, 120, 50)
                        : EdgeInsets.fromLTRB(20, 0, 20, 50),
            padding: EdgeInsets.fromLTRB(40, 25, 40, 25),
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                MyText(
                  text: "contact_information",
                  maxline: 1,
                  multilanguage: true,
                  fontsize: Dimens.text38Size,
                  fontsizeWeb: Dimens.text38Size,
                  fontwaight: FontWeight.w600,
                ),
                MyText(
                  text: "contact_us_description",
                  maxline: 2,
                  multilanguage: true,
                  fontstyle: FontStyle.italic,
                  fontsize: Dimens.medium18TextSize,
                  fontsizeWeb: Dimens.medium18TextSize,
                  fontwaight: FontWeight.w400,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 30,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        spacing: 20,
                        children: [
                          MyText(
                            text: "office",
                            maxline: 1,
                            multilanguage: true,
                            fontsize: Dimens.medium20TextSize,
                            fontsizeWeb: Dimens.medium20TextSize,
                            fontwaight: FontWeight.w500,
                          ),
                          MyText(
                            text: Constant.address ?? "",
                            maxline: 2,
                            fontstyle: FontStyle.italic,
                            fontsize: Dimens.medium16TextSize,
                            fontsizeWeb: Dimens.medium16TextSize,
                            fontwaight: FontWeight.w400,
                          ),
                          MyText(
                            text: Constant.email ?? "",
                            maxline: 2,
                            fontstyle: FontStyle.italic,
                            fontsize: Dimens.medium16TextSize,
                            fontsizeWeb: Dimens.medium16TextSize,
                            fontwaight: FontWeight.w400,
                          ),
                          MyText(
                            text: Constant.website ?? "",
                            maxline: 1,
                            fontsize: Dimens.medium14TextSize,
                            fontsizeWeb: Dimens.medium14TextSize,
                            fontwaight: FontWeight.w400,
                          ),
                          MyText(
                            text: Constant.contactInfo ?? "",
                            maxline: 1,
                            fontsize: Dimens.medium14TextSize,
                            fontsizeWeb: Dimens.medium14TextSize,
                            fontwaight: FontWeight.w400,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                MyText(
                  text: "social_media",
                  maxline: 1,
                  multilanguage: true,
                  fontsize: Dimens.medium20TextSize,
                  fontsizeWeb: Dimens.medium20TextSize,
                  fontwaight: FontWeight.w500,
                ),
                _buildSocialLink(),
                MyText(
                  text: "get_in_touch",
                  maxline: 1,
                  multilanguage: true,
                  fontsize: Dimens.text38Size,
                  fontsizeWeb: Dimens.text38Size,
                  fontwaight: FontWeight.w500,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          _myTitle(title: "name"),
                          myTextField(nameController, TextInputAction.next,
                              TextInputType.name, "name"),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          _myTitle(title: "email"),
                          myTextField(emailController, TextInputAction.next,
                              TextInputType.emailAddress, "email"),
                        ],
                      ),
                    )
                  ],
                ),
                _myTitle(title: "subject"),
                myTextField(subjectController, TextInputAction.next,
                    TextInputType.text, "subject"),
                _myTitle(title: "desc_details"),
                TextFormField(
                  textAlign: TextAlign.left,
                  obscureText: false,
                  maxLines: 5,
                  minLines: 3,
                  keyboardType: TextInputType.text,
                  controller: descController,
                  textInputAction: TextInputAction.done,
                  cursorColor: black,
                  showCursor: true,
                  style: GoogleFonts.roboto(
                      fontSize: Dimens.medium16TextSize,
                      color: black,
                      fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    hintText: Locales.string(context, "desc_details"),
                    hintStyle: GoogleFonts.roboto(
                        fontSize: Dimens.medium14TextSize,
                        color: black,
                        fontWeight: FontWeight.w400),
                    fillColor: white,
                    filled: true,
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      borderSide: BorderSide(
                          width: 1, color: gray, style: BorderStyle.solid),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      borderSide: BorderSide(
                          width: 1, color: gray, style: BorderStyle.solid),
                    ),
                    disabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      borderSide: BorderSide(
                          width: 1, color: gray, style: BorderStyle.solid),
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                      borderSide: BorderSide(
                          width: 1, color: gray, style: BorderStyle.solid),
                    ),
                  ),
                ),
                InteractiveContainer(child: (isHovered) {
                  return InkWell(
                      hoverColor: transparent,
                      splashColor: transparent,
                      focusColor: transparent,
                      highlightColor: transparent,
                      onTap: () {
                        if (!Utils.checkLoginUser(context)) {
                          return; // login dialog open thayi ne return thai jase
                        } else if (nameController.text.trim().isEmpty) {
                          Utils.showSnackbar(
                            context,
                            'please_enter_your_name',
                            true,
                          );
                        } else if (emailController.text.trim().isEmpty) {
                          Utils.showSnackbar(
                            context,
                            'please_enter_your_email',
                            true,
                          );
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(emailController.text.trim())) {
                          Utils.showSnackbar(
                            context,
                            'please_enter_valid_email',
                            true,
                          );
                        } else if (subjectController.text.trim().isEmpty) {
                          Utils.showSnackbar(
                            context,
                            'please_enter_your_subject',
                            true,
                          );
                        } else {
                          contactus(
                            nameController.text.trim(),
                            emailController.text.trim(),
                            subjectController.text.trim(),
                            descController.text.trim(),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(5),
                      child: AnimatedScale(
                        scale: isHovered ? 1.05 : 1,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeInOut,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25, vertical: 14),
                          decoration: BoxDecoration(
                            color: isHovered ? colorAccent : colorPrimary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: MyText(
                              color: white,
                              multilanguage: true,
                              text: "submit_message",
                              textalign: TextAlign.left,
                              fontsize: Dimens.medium14TextSize,
                              fontsizeWeb: Dimens.medium14TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                        ),
                      ));
                })
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLink() {
    // return Consumer<ProfileProvider>(
    //     builder: (context, profileprovider, child) {
    //   if (profileprovider.loading) {
    //     return const SizedBox.shrink();
    //   } else {
    //     if (profileprovider.socialLinkModel.status == 200 &&
    //         profileprovider.socialLinkModel.result != null) {
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      children: List.generate(
        profileProvider.getsociallinkmodel.result?.length ?? 0,
        (index) {
          return buildSocialIcon(
              iconUrl:
                  profileProvider.getsociallinkmodel.result?[index].image ?? "",
              onClick: () {
                // Navigator.of(context).push(PageRouteBuilder(
                //   pageBuilder: (context, animation, secondaryAnimation) {
                //     return CommonPage(
                //         appBarTitle: profileProvider
                //                 .getsociallinkmodel.result?[index].name
                //                 .toString() ??
                //             "",
                //         loadURL: profileProvider
                //                 .getsociallinkmodel.result?[index].url ??
                //             "");
                //   },
                //   transitionDuration: Duration(milliseconds: 150),
                //   transitionsBuilder:
                //       (context, animation, secondaryAnimation, child) {
                //     return AnimatedBuilder(
                //       animation: animation,
                //       builder: (context, child) {
                //         return ClipPath(
                //           clipper:
                //               CircularRevealClipper(progress: animation.value),
                //           child: child,
                //         );
                //       },
                //       child: child,
                //     );
                //   },
                // ));
                Utils.launchURL(
                  profileProvider.getsociallinkmodel.result?[index].url ?? "",
                );
              });
        },
      ),
    );
    //     } else {
    //       return const SizedBox.shrink();
    //     }
    //   }
    // });
  }

  Widget buildSocialIcon({
    required String iconUrl,
    required Function() onClick,
  }) {
    return InteractiveContainer(child: (isHovered) {
      return InkWell(
          hoverColor: transparent,
          splashColor: transparent,
          focusColor: transparent,
          highlightColor: transparent,
          onTap: onClick,
          borderRadius: BorderRadius.circular(5),
          child: AnimatedScale(
            scale: isHovered ? 1.05 : 1,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: MyNetworkImage(
              imagePath: iconUrl,
              width: 35,
              height: 35,
              fit: BoxFit.fill,
              radius: 4,
            ),
          ));
    });
  }

  Widget _myTitle({required String? title}) {
    return MyText(
      text: title ?? "",
      fontsize: Dimens.medium16TextSize,
      fontsizeWeb: Dimens.medium16TextSize,
      multilanguage: true,
      fontwaight: FontWeight.w700,
    );
  }

  Widget myTextField(controller, textInputAction, keyboardType, labletext) {
    return TextFormField(
      textAlign: TextAlign.left,
      obscureText: false,
      keyboardType: keyboardType,
      controller: controller,
      textInputAction: textInputAction,
      cursorColor: black,
      showCursor: true,
      style: GoogleFonts.roboto(
          fontSize: Dimens.medium16TextSize,
          color: black,
          fontWeight: FontWeight.w700),
      decoration: InputDecoration(
        hintText: Locales.string(context, labletext),
        hintStyle: GoogleFonts.roboto(
            fontSize: Dimens.medium14TextSize,
            color: black,
            fontWeight: FontWeight.w400),
        contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        fillColor: white,
        filled: true,
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
          borderSide:
              BorderSide(width: 1, color: gray, style: BorderStyle.solid),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
          borderSide:
              BorderSide(width: 1, color: gray, style: BorderStyle.solid),
        ),
        disabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
          borderSide:
              BorderSide(width: 1, color: gray, style: BorderStyle.solid),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(0)),
          borderSide:
              BorderSide(width: 1, color: gray, style: BorderStyle.solid),
        ),
      ),
    );
  }

/* Mobile View Form */

  contactus(name, email, subject, details) async {
    try {
      await profileProvider.contactusdata(name, email, subject, details);
      if (profileProvider.successModel.status == 200) {
        if (!mounted) return;
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        Utils.showSnackbar(
            context, profileProvider.successModel.message ?? "", false);
      }
    } catch (e) {
      if (!mounted) return;
      Utils.showSnackbar(
          context, profileProvider.successModel.message ?? "", false);
    }
  }
}

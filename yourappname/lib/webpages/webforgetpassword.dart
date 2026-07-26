import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/provider/themeprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/mytextformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class Webforgetpassword extends StatefulWidget {
  const Webforgetpassword({super.key});

  @override
  State<Webforgetpassword> createState() => _WebforgetpasswordState();
}

class _WebforgetpasswordState extends State<Webforgetpassword> {
  final emailController = TextEditingController();
  late ThemeProvider themeProvider;

  @override
  void initState() {
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left image (hidden on mobile)
                  if (screenWidth > 800)
                    Expanded(
                      flex: 5,
                      child: MyImage(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height,
                        imagePath: 'login_bg.png',
                        fit: BoxFit.cover,
                      ),
                    ),

                  // Right forgot password form
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height,
                      alignment: Alignment.center,
                      padding: screenWidth > 1200
                          ? EdgeInsets.fromLTRB(100, 40, 100, 40)
                          : screenWidth > 600
                              ? EdgeInsets.fromLTRB(40, 40, 40, 40)
                              : EdgeInsets.fromLTRB(20, 40, 20, 40),
                      decoration: const BoxDecoration(color: white),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            MyText(
                              text: "recover_password",
                              fontsizeWeb: Dimens.medium24TextSize,
                              fontsize: Dimens.medium24TextSize,
                              fontwaight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.center,
                              multilanguage: true,
                              fontstyle: FontStyle.normal,
                            ),
                            const SizedBox(height: 20),
                            MyText(
                              text: "forget_title",
                              fontsizeWeb: Dimens.medium18TextSize,
                              fontsize: Dimens.medium24TextSize,
                              fontwaight: FontWeight.w400,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              textalign: TextAlign.center,
                              multilanguage: true,
                              fontstyle: FontStyle.normal,
                            ),
                            const SizedBox(height: 20),
                            MyTextFormField(
                              controller: emailController,
                              backgroundColor: white,
                              obscureText: false,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icon(FontAwesomeIcons.envelope,
                                  size: 20, color: colorPrimary),
                              borderRadius: 8,
                              errorBorderRadius: 8,
                              enableBorderRadius: 8,
                              focusedBorderRadius: 8,
                              hintText: "Enter the email",
                              labelText: Locales.string(context, "email"),
                            ),
                            const SizedBox(height: 10),
                            loginBtn(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Cancel / Close button on top-right
              Positioned(
                top: 20,
                right: 20,
                child: SafeArea(
                  child: InkWell(
                    onTap: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: colorPrimaryDark),
                      child: const Icon(
                        Icons.close,
                        size: 20,
                        color: white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget loginBtn() {
    return Consumer<GeneralProvider>(builder: (context, provider, child) {
      return InkWell(
        onTap: () async {
          String email = emailController.text.trim();
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

          if (email.isEmpty) {
            Utils.showSnackbar(context, "please_enter_your_email", true);
            return;
          } else if (!emailRegex.hasMatch(email)) {
            Utils.showSnackbar(context, "please_enter_valid_email", true);
            return;
          }

          provider.setforgotloading(true);
          await provider.forgotpassworddata(email);

          if (context.mounted) {
            if (provider.successmodel.status == 200) {
              Utils.showSnackbar(
                context,
                provider.successmodel.message ?? "",
                false,
              );
              provider.setforgotloading(false);
              Navigator.pop(context);
            } else {
              Utils.showSnackbar(
                context,
                provider.successmodel.message ?? "",
                false,
              );
              provider.setforgotloading(false);
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          curve: Curves.bounceInOut,
          width: MediaQuery.of(context).size.width,
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorPrimaryDark,
            borderRadius: BorderRadius.circular(10),
          ),
          child: provider.forloading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: white,
                    strokeWidth: 2,
                  ),
                )
              : MyText(
                  color: colorPrimary,
                  text: "send_link",
                  fontsize: Dimens.medium16TextSize,
                  fontsizeWeb: Dimens.medium16TextSize,
                  fontwaight: FontWeight.w600,
                  maxline: 1,
                  multilanguage: true,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                ),
        ),
      );
    });
  }
}

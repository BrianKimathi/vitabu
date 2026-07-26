import 'package:yourappname/pages/notificationpage.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/provider/themeprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/changelanguage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:provider/provider.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  SharedPref sharedpre = SharedPref();
  dynamic selectedLanguagecode;
  late ProfileProvider profileProvider;
  late ThemeProvider themeSwitcherProvider;
  @override
  void initState() {
    themeSwitcherProvider = Provider.of<ThemeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi();
    });
    super.initState();
  }

  getApi() {
    profileProvider.setLoding(true);
    profileProvider.getProfile(Constant.userID);
    profileProvider.getPages();
    profileProvider.getsociallinkdata();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? appbarcolor : white,
      appBar: AppBar(
        backgroundColor: isDark ? appbarcolor : white,
        surfaceTintColor: transparent,
        leading: Utils.backButton(context),
        centerTitle: false,
        title: MyText(
          text: "setting",
          // color: isDark? white : black,
          fontstyle: FontStyle.normal,
          maxline: 1,
          multilanguage: true,
          textalign: TextAlign.left,
          fontsize: Dimens.medium16TextSize,
          fontwaight: FontWeight.w600,
        ),
      ),
      body: Consumer<ThemeProvider>(builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              _myTitle(
                  iconData: Ic.baseline_notifications_none,
                  title: 'notification',
                  onTap: () {
                    Utils.push(context, NotificationPage());
                  }),
              SizedBox(
                height: 20,
              ),
              dayNightMode(),
              SizedBox(
                height: 20,
              ),
              _myTitle(
                  iconData: MaterialSymbols.language,
                  title: 'language',
                  onTap: () {
                    Utils.push(context, ChangeLanguage());
                  }),
            ],
          ),
        );
      }),
    );
  }

  /* Helper widget */

  Widget _myTitle({
    required String iconData,
    required String title,
    bool? multilanguage,
    required VoidCallback onTap,
  }) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return InkWell(
      splashColor: transparent,
      focusColor: transparent,
      hoverColor: transparent,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDark
                  ? gray.withOpacity( 0.2)
                  : gray.withOpacity( 0.5),
            ),
            child: Iconify(
              iconData,
              size: 22,
              color: isDark ? colorPrimaryDark : colorPrimary,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: MyText(
              text: title,
              multilanguage: multilanguage ?? true,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              fontsize: Dimens.medium14TextSize,
              fontwaight: FontWeight.w600,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_outlined,
            size: 20,
            color: isDark ? colorPrimaryDark : colorPrimary,
          ),
        ],
      ),
    );
  }

  Widget dayNightMode() {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      final isDark = context.watch<ThemeProvider>().isDarkMode;

      return InkWell(
        onTap: () {
          themeProvider.toggleTheme();
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDark
                      ? gray.withOpacity( 0.2)
                      : gray.withOpacity( 0.5),
                  shape: BoxShape.rectangle),
              child: Icon(
                isDark ? FontAwesomeIcons.sun : FontAwesomeIcons.moon,
                size: 20,
                color: isDark ? colorPrimaryDark : colorPrimary,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: MyText(
                text:
                    isDark ? "enable_day_light_mode" : "enable_day_night_mode",
                multilanguage: true,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontsize: Dimens.medium14TextSize,
                fontwaight: FontWeight.w600,
              ),
            ),
            SizedBox(
              width: 35,
              child: Consumer<ProfileProvider>(
                builder: (context, data, child) {
                  return Switch(
                    thumbColor: WidgetStatePropertyAll<Color>(gray),
                    trackColor: WidgetStatePropertyAll<Color>(
                        gray.withOpacity( 0.5)),
                    // inactiveThumbColor: colorPrimaryDark,
                    // activeTrackColor: gray,
                    // inactiveTrackColor: colorPrimary,
                    value: isDark ? true : false,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  );
                },
              ),
            )
          ],
        ),
      );
    });
  }
}

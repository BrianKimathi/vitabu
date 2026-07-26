import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class ChangeLanguage extends StatelessWidget {
  const ChangeLanguage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.isDarkMode ? appbarcolor : white,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Constant.isDarkMode ? appbarcolor : white,
        surfaceTintColor: transparent,
        leading: Utils.backButton(context),
        titleSpacing: 0,
        title: MyText(
          text: "language",
          fontstyle: FontStyle.normal,
          maxline: 1,
          multilanguage: true,
          textalign: TextAlign.left,
          isfont: 2,
          fontsize: Dimens.medium16TextSize,
          fontwaight: FontWeight.w600,
        ),
      ),
      bottomNavigationBar: const SizedBox.shrink(),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildLanguage(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLanguage(
    BuildContext context,
  ) {
    String currentLocale =
        LocaleNotifier.of(context)?.locale?.languageCode ?? "en";

    List<Map<String, String>> languages = [
      {"name": "Arabic", "code": "ar", "flag": "🇦🇪"},
      {"name": "English", "code": "en", "flag": "🇺🇸"},
      {"name": "French", "code": "fr", "flag": "🇫🇷"},
      {"name": "Hindi", "code": "hi", "flag": "🇮🇳"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: "chooselanguge",
          color: Constant.isDarkMode ? white : black,
          multilanguage: true,
          fontsize: Dimens.medium22TextSize,
          isfont: 2,
          fontwaight: FontWeight.bold,
        ),
        SizedBox(height: 8),
        MyText(
          text: "langaugede",
          multilanguage: true,
          fontsize: Dimens.medium14TextSize,
          color: Constant.isDarkMode ? gray.withOpacity( 0.7) : gray,
          isfont: 3,
          fontstyle: FontStyle.normal,
          fontwaight: FontWeight.w500,
          maxline: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 25),
        MyText(
          text: "alllanguage",
          multilanguage: true,
          fontsize: Dimens.medium16TextSize,
          color: Constant.isDarkMode ? white : black,
          fontstyle: FontStyle.normal,
          isfont: 3,
          maxline: 1,
          fontwaight: FontWeight.w600,
        ),
        const SizedBox(height: 15),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: languages.length,
          separatorBuilder: (context, index) =>
              Divider(height: 1, color: Colors.grey.shade200),
          itemBuilder: (context, index) {
            return buildLanguageItem(
              context: context,
              langName: languages[index]['name']!,
              langCode: languages[index]['code']!,
              flag: languages[index]['flag']!,
              selectedLang: currentLocale,
            );
          },
        ),
      ],
    );
  }

  Widget buildLanguageItem({
    required BuildContext context,
    required String langName,
    required String langCode,
    required String flag,
    required String selectedLang,
  }) {
    final isSelected = selectedLang == langCode;

    return ListTile(
      onTap: () {
        LocaleNotifier.of(context)?.change(langCode);
        Navigator.pop(context);
      },
      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),

      /// FLAG BG
      leading: Container(
        height: 40,
        width: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Constant.isDarkMode ? graycolor : Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Text(flag, style: const TextStyle(fontSize: 20)),
      ),

      /// LANGUAGE NAME
      title: MyText(
        color: isSelected
            ? colorPrimaryDark
            : (Constant.isDarkMode ? white : black),
        text: langName,
        fontsize: Dimens.medium14TextSize,
        isfont: 3,
        fontstyle: FontStyle.normal,
        overflow: TextOverflow.ellipsis,
        maxline: 1,
        fontwaight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),

      /// RADIO INDICATOR
      trailing: Container(
        height: 22,
        width: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? colorPrimaryDark
                : (Constant.isDarkMode
                    ? white.withOpacity( 0.3)
                    : Colors.grey.shade300),
            width: 2,
          ),
          color: isSelected ? colorPrimaryDark : transparent,
        ),
        child:
            isSelected ? const Icon(Icons.check, size: 14, color: white) : null,
      ),
    );
  }
}

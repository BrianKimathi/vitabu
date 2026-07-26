import 'package:yourappname/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';

class MyText extends StatelessWidget {
  final String text;
  final double? fontsize, fontsizeWeb;
  final bool? multilanguage;
  final int? maxline;
  final FontStyle? fontstyle;
  final TextAlign? textalign;
  final FontWeight? fontwaight;
  final Color? color;
  final TextOverflow? overflow;

  // 🔹 underline options
  final bool? underline;
  final Color? underlineColor;
  final double? underlineThickness;
  final TextDecorationStyle? underlineStyle;
  final double? lineHeight; // 👈 underline spacing mate

  // 🔹 font switch flag
  // 1 = SF Pro Display
  // 2 = Lato
  // 3 = Poppins
  // default = Gotham
  final int? isfont;

  const MyText({
    super.key,
    this.color,
    required this.text,
    this.fontsize,
    this.fontsizeWeb,
    this.multilanguage,
    this.maxline,
    this.overflow,
    this.textalign,
    this.fontwaight,
    this.fontstyle,
    this.isfont,
    this.underline,
    this.underlineColor,
    this.underlineThickness,
    this.underlineStyle,
    this.lineHeight,
  });

  TextStyle _getTextStyle(BuildContext context) {
    final double? size =
        kIsWeb || Utils.isTablet(context) ? fontsizeWeb : fontsize;

    return _baseStyle(
      context,
      size,
      decoration:
          underline == true ? TextDecoration.underline : TextDecoration.none,
      decorationColor: underlineColor ?? Colors.black,
      decorationThickness: underlineThickness ?? 1,
      decorationStyle: underlineStyle ?? TextDecorationStyle.solid,
      lineHeight: lineHeight,
    );
  }

  TextStyle _baseStyle(
    BuildContext context,
    double? size, {
    required TextDecoration decoration,
    required Color decorationColor,
    required double decorationThickness,
    required TextDecorationStyle decorationStyle,
    double? lineHeight, // ✅ correct
  }) {
    switch (isfont) {
      case 1:
        return TextStyle(
          fontFamily: 'SFProDisplay',
          fontSize: size,
          fontStyle: fontstyle,
          fontWeight: fontwaight,
          color: color ?? Theme.of(context).textTheme.bodyLarge!.color,
          decoration: decoration,
          decorationColor: decorationColor,
          decorationThickness: decorationThickness,
          decorationStyle: decorationStyle,
          height: lineHeight ?? 1.3,
        );

      case 2:
        return GoogleFonts.lato(
          fontSize: size,
          fontStyle: fontstyle,
          fontWeight: fontwaight,
          color: color ?? Theme.of(context).textTheme.bodyLarge!.color,
          decoration: decoration,
          decorationColor: decorationColor,
          decorationThickness: decorationThickness,
          decorationStyle: decorationStyle,
          height: lineHeight ?? 1.3,
        );

      case 3:
        return GoogleFonts.poppins(
          fontSize: size,
          fontStyle: fontstyle,
          fontWeight: fontwaight,
          color: color ?? Theme.of(context).textTheme.bodyLarge!.color,
          decoration: decoration,
          decorationColor: decorationColor,
          decorationThickness: decorationThickness,
          decorationStyle: decorationStyle,
          height: lineHeight ?? 1.3,
        );

      default:
        return GoogleFonts.poppins(
          fontSize: size,
          fontStyle: fontstyle,
          fontWeight: fontwaight,
          color: color ?? Theme.of(context).textTheme.bodyLarge!.color,
          decoration: decoration,
          decorationColor: decorationColor,
          decorationThickness: decorationThickness,
          decorationStyle: decorationStyle,
          height: lineHeight ?? 1.3,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getTextStyle(context);

    return multilanguage == true
        ? LocaleText(
            text,
            textAlign: textalign,
            maxLines: maxline,
            overflow: overflow ?? TextOverflow.ellipsis,
            style: style,
          )
        : Text(
            text,
            textAlign: textalign,
            maxLines: maxline,
            softWrap: false, // 🔥 IMPORTANT
            overflow: overflow ?? (kIsWeb ? null : TextOverflow.ellipsis),
            style: style,
          );
  }
}

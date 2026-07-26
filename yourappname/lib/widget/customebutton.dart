import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/material.dart';

class CustomeButton extends StatelessWidget {
  final String text;
  final double? fontsize, radius, height, width, iconSize;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor, iconColor, borderColor;
  final IconData? icon;
  final IconAlignment? iconAlignment;
  final FontWeight? fontWeight;
  final bool? multilanguage, isNormal;
  final FontStyle? fontStyle;

  const CustomeButton(
      {super.key,
      required this.text,
      required this.onTap,
      this.iconAlignment,
      this.fontStyle,
      this.borderColor,
      this.multilanguage,
      this.fontsize,
      this.textColor,
      this.fontWeight,
      this.radius,
      this.isNormal,
      this.height,
      this.color,
      this.icon,
      this.iconColor,
      this.iconSize,
      this.width});

  @override
  Widget build(BuildContext context) {
    return isNormal == true
        ? ElevatedButton.icon(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
                backgroundColor: color ?? colorPrimary,
                side: BorderSide(
                    width: 1,
                    color: borderColor ?? colorPrimary,
                    style: BorderStyle.solid),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius ?? 10)),
                minimumSize: Size(
                    width ?? MediaQuery.sizeOf(context).width, height ?? 50)),
            label: MyText(
              text: text,
              multilanguage: multilanguage ?? true,
              fontstyle: fontStyle,
              fontsize: fontsize ?? Dimens.medium18TextSize,
              color: textColor ?? colorAccent,
              fontwaight: fontWeight ?? FontWeight.w400,
            ),
            iconAlignment: iconAlignment ?? IconAlignment.end,
            icon: Icon(
              icon,
              size: iconSize ?? 20,
              color: iconColor ?? colorAccent,
            ),
          )
        : InkWell(
            splashColor: transparent,
            focusColor: transparent,
            hoverColor: transparent,
            onTap: onTap,
            child: Container(
              height: height ?? 50,
              width: width ?? MediaQuery.sizeOf(context).width,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: color ?? colorPrimary,
                borderRadius: BorderRadius.circular(radius ?? 10),
                border: Border.all(
                    width: 1,
                    color: borderColor ?? colorPrimary,
                    style: BorderStyle.solid),
              ),
              child: MyText(
                text: text,
                fontstyle: fontStyle,
                multilanguage: multilanguage ?? true,
                fontsize: fontsize ?? Dimens.medium18TextSize,
                color: textColor ?? colorAccent,
                fontwaight: fontWeight ?? FontWeight.w400,
              ),
            ),
          );
  }
}

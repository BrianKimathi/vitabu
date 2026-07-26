import 'package:flutter/material.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';

class MyTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Color? cursorColor;
  final double? gapPadding;
  final double? boxMinHeight;
  final double? boxMinWidth;
  final double? contentPadding;
  final Color? borderColor;
  final Color? disaledBorderColor;
  final Color? enableBorderColor;
  final Color? errorBorderColor;
  final Color? focusedBorderColor;
  final double? borderRadius;
  final double? disaledBorderRadius;
  final double? enableBorderRadius;
  final double? errorBorderRadius;
  final double? focusedBorderRadius;
  final double? borderWidth;
  final double? disaledBorderWidth;
  final double? enableBorderWidth;
  final double? errorBorderWidth;
  final double? focusedBorderWidth;
  final bool obscureText;
  final String? errorText;
  final String? labelText;
  final String? hintText;
  final String? prefixTest;
  final String? suffixText;
  final TextStyle? errorTextStyle;
  final TextStyle? labelTextStyle;
  final TextStyle? hintTextStyle;
  final TextStyle? prefixTestStyle;
  final TextStyle? suffixTextStyle;
  final TextStyle? normalTextStyle;
  final TextInputType? keyboardType;
  final bool? enabled, readOnly;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final int? errorMaxLines;
  final int? hintMaxLines;
  final Color? backgroundColor;
  final int? maxLines;
  final int? minLines;
  final void Function(String)? onChanged;
  final FloatingLabelBehavior? floatingLabelBehavior;
  final void Function()? onEditingComplete;

  const MyTextFormField(
      {super.key,
      this.readOnly,
      this.controller,
      this.focusNode,
      this.cursorColor,
      this.gapPadding,
      this.boxMinHeight,
      this.boxMinWidth,
      this.contentPadding,
      this.borderColor,
      this.disaledBorderColor,
      this.enableBorderColor,
      this.errorBorderColor,
      this.focusedBorderColor,
      this.borderRadius,
      this.disaledBorderRadius,
      this.enableBorderRadius,
      this.errorBorderRadius,
      this.focusedBorderRadius,
      this.borderWidth,
      this.disaledBorderWidth,
      this.enableBorderWidth,
      this.errorBorderWidth,
      this.focusedBorderWidth,
      required this.obscureText,
      this.errorText,
      this.labelText,
      this.hintText,
      this.prefixTest,
      this.suffixText,
      this.errorTextStyle,
      this.labelTextStyle,
      this.hintTextStyle,
      this.prefixTestStyle,
      this.suffixTextStyle,
      this.normalTextStyle,
      this.keyboardType,
      this.enabled,
      this.prefix,
      this.suffix,
      this.prefixIcon,
      this.errorMaxLines,
      this.hintMaxLines,
      this.onChanged,
      this.backgroundColor,
      this.floatingLabelBehavior,
      this.maxLines,
      this.minLines,
      this.onEditingComplete});

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  bool obscureText1 = true; // Control password visibility locally

  @override
  void initState() {
    super.initState();
    obscureText1 =
        widget.obscureText; // Set initial state based on widget property
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onEditingComplete: widget.onEditingComplete,
      maxLines: widget.maxLines ?? 1,
      minLines: widget.minLines ?? 1,
      onTapOutside: (event) => {FocusManager.instance.primaryFocus?.unfocus()},
      controller: widget.controller,
      focusNode: widget.focusNode,
      readOnly: widget.readOnly ?? false,
      cursorColor: widget.cursorColor ?? colorPrimary,
      decoration: InputDecoration(
        floatingLabelBehavior: widget.floatingLabelBehavior,
        filled: true,
        fillColor: widget.backgroundColor ?? white,
        constraints: BoxConstraints(
          minHeight: widget.boxMinHeight ?? 0.0,
          minWidth: widget.boxMinWidth ?? double.infinity,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 4.0),
          borderSide: BorderSide(
            width: 1,
            color: widget.borderColor ?? gray,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(widget.disaledBorderRadius ?? 4.0),
          borderSide: BorderSide(
            width: widget.disaledBorderWidth ?? 1,
            color: widget.disaledBorderColor ?? gray,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.enableBorderRadius ?? 4.0),
          borderSide: BorderSide(
            width: widget.enableBorderWidth ?? 1,
            color: widget.enableBorderColor ?? gray,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.errorBorderRadius ?? 4.0),
          borderSide: BorderSide(
            width: widget.errorBorderWidth ?? 1,
            color: widget.errorBorderColor ?? gray,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(widget.focusedBorderRadius ?? 4.0),
          borderSide: BorderSide(
            width: widget.focusedBorderWidth ?? 1,
            color: widget.focusedBorderColor ?? gray,
          ),
        ),
        errorText: widget.errorText,
        errorStyle: widget.errorTextStyle ??
            Utils.googleFontStyle(2, Dimens.medium18TextSize, FontStyle.normal,
                gray, FontWeight.w400),
        hintText: widget.hintText,
        hintStyle: widget.hintTextStyle ??
            Utils.googleFontStyle(2, Dimens.medium16TextSize, FontStyle.normal,
                gray, FontWeight.w400),
        labelText: widget.labelText,
        labelStyle: widget.labelTextStyle ??
            Utils.googleFontStyle(2, Dimens.medium16TextSize, FontStyle.normal,
                gray, FontWeight.w400),
        prefixText: widget.prefixTest,
        prefixStyle: widget.prefixTestStyle ??
            Utils.googleFontStyle(2, Dimens.medium16TextSize, FontStyle.normal,
                gray, FontWeight.w400),
        suffixText: widget.suffixText,
        suffixStyle: widget.suffixTextStyle ??
            Utils.googleFontStyle(2, Dimens.medium16TextSize, FontStyle.normal,
                gray, FontWeight.w500),
        prefix: widget.prefix,
        prefixIcon: widget.prefixIcon,
        suffix: widget.suffix,
        suffixIcon:
            widget.obscureText // Only show suffixIcon for password fields
                ? IconButton(
                    icon: Icon(
                      obscureText1
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: black,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureText1 = !obscureText1;
                      });
                    },
                  )
                : null,
        errorMaxLines: widget.errorMaxLines,
        hintMaxLines: widget.hintMaxLines,
      ),
      autofocus: false,
      keyboardType: widget.keyboardType,
      obscureText: obscureText1,
      style: widget.normalTextStyle ??
          Utils.googleFontStyle(2, Dimens.medium16TextSize, FontStyle.normal,
              black, FontWeight.w500),
      enabled: widget.enabled,
      onChanged: widget.onChanged,
    );
  }
}

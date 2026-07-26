import 'package:flutter/material.dart';

/* Dark mode Color */
const appbarcolor = Color(0xFF181919);
const graycolor  = Color(0xFF313333);
// Button/theme red (used widely across web + mobile widgets).
const colorPrimary = Color(0xFF4E45B8);
const colorPrimaryDark = Color(0xFF3D35A0);
const colorAccent = Color(0xFF4E45B8);
const green = Color(0xFF027A36);
const black = Color(0xff272828);
const white = Color(0xffffffff);
const gray = Color(0xff909797);
const red = Color(0xffFF0000);
const yello = Color(0xffFEC854);
const ligthDark = Color(0xff2D3047);
const darkgray = Color(0xff6D6161);
const transparent = Color(0x00000000);
// /* END  */









/* Web Colors */
const lightcofe = Color(0xffFAF1FF);
const lightpurple = Color(0xffFAF4EB);
const purple = Color(0xffF4E6E5);
const lightblue = Color(0xffE6F2F4);
const lightpink = Color(0xffFFF6F6);
LinearGradient mainGradient() {
  return const LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      colorPrimary,
      colorPrimaryDark,
    ],
  );
}

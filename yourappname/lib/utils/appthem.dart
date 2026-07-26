import 'package:yourappname/utils/color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // 🌙 Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: colorPrimaryDark,
    scaffoldBackgroundColor: appbarcolor,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: appbarcolor,
        selectedIconTheme: IconThemeData(color: colorAccent),
        selectedItemColor: colorAccent,
        unselectedIconTheme: const IconThemeData(color: gray),
        unselectedItemColor: gray),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: black,
      surfaceTintColor: transparent,
      titleTextStyle: TextStyle(color: white),
    ),
    canvasColor: white,
    cardColor: colorPrimary,
    textTheme: const TextTheme(
      bodySmall: TextStyle(color: colorPrimary),
      titleLarge: TextStyle(color: white),
      bodyLarge: TextStyle(color: white),
      bodyMedium: TextStyle(color: colorAccent),
    ),
    iconTheme: const IconThemeData(color: white),
    buttonTheme: const ButtonThemeData(buttonColor: colorPrimaryDark),
  );

  // ☀️ Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: colorPrimary,
    scaffoldBackgroundColor: white,
    appBarTheme: const AppBarTheme(
      backgroundColor: white,
      surfaceTintColor: transparent,
      titleTextStyle: TextStyle(color: colorPrimaryDark),
    ),
    cardColor: white,
    canvasColor: colorPrimary,
    bottomAppBarTheme: const BottomAppBarThemeData(color: white),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedIconTheme: IconThemeData(color: colorAccent),
        selectedItemColor: colorAccent,
        unselectedIconTheme: const IconThemeData(color: colorPrimary),
        unselectedItemColor: colorPrimary),
    textTheme: const TextTheme(
      bodySmall: TextStyle(color: colorPrimaryDark),
      titleLarge: TextStyle(color: black),
      bodyLarge: TextStyle(color: black),
      bodyMedium: TextStyle(color: colorAccent),
    ),
    iconTheme: const IconThemeData(color: colorPrimaryDark),
    buttonTheme: ButtonThemeData(buttonColor: colorPrimary),
  );
}

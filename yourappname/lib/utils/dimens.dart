import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Dimens {
  static const double smallTextSize = 10;
  static const double medium11TextSize = 11;
  static const double medium12TextSize = 12;
  static const double medium13TextSize = 13;

  static const double medium14TextSize = 14;
  static const double medium15TextSize = 15;

  static const double medium16TextSize = 16;
  static const double medium20TextSize = 20;
  static const double medium22TextSize = 22;

  static const double medium18TextSize = 18;
  static const double medium24TextSize = 24;
  static const double largeTextSize = 20;
  static double webhomeTabHeight = 90;
  static const double appbarTextSize = 24;
  static const double tabbarTextSize = 18;
  static const double bookNameSize = 11;
  static const double bookTitleize = 13;
  static const double titleTextSize = 36;
  static const double discriptionTextSize = 10;
  static const double catagoryTextSize = 10;
  static const double moreTextSize = 18;
  static const double text28Size = 28;
  static const double text35Size = 35;
  static const double text38Size = 38;
  static const double text32Size = 32;
  static const double text30Size = 30;
  static double bottomWebPadding = 70;
  static double minWidth = 550;
  static bool isBigScreen(BuildContext context) {
    return ((kIsWeb) && MediaQuery.of(context).size.width > 840);
  }
}

import 'package:flutter/material.dart';

class AutherProvider extends ChangeNotifier {
  String currentIndex = "1";

  setWishListTab(index) {
    currentIndex = index;

    notifyListeners();
  }

  clearWeb() {
    currentIndex = "1";
  }
}

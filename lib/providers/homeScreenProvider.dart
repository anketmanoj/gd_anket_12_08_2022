import 'package:flutter/material.dart';

class HomeScreenProvider with ChangeNotifier {
  bool _isHomeScreen = true;
  bool get isHomeScreen => _isHomeScreen;

  setHomeScreen(bool value) {
    _isHomeScreen = value;
    notifyListeners();
  }
}

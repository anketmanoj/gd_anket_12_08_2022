import 'package:flutter/material.dart';

class CaratProvider extends ChangeNotifier {
  int _carats = 0;
  int get getCarats => _carats;

  void setCarats(int value) {
    _carats = value;
    notifyListeners();
  }
}

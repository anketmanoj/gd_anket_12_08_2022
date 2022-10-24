import 'package:flutter/material.dart';

class ArViewcollectionProvider extends ChangeNotifier {
  String _selectedValue = "showBoth";

  String get getSelectedValue => _selectedValue;

  void setSelectedValue(String value) {
    _selectedValue = value;
    notifyListeners();
  }
}

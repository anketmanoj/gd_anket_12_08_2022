import 'package:flutter/material.dart';

class SignUpUser with ChangeNotifier {
  late String _email;
  late String _password;
  late String _name;
  late String _phone;
  late String _otp;
  late DateTime _dob;
  late String _location;

  String get getEmail => _email;
  String get password => _password;
  String get name => _name;
  String get phone => _phone;
  String get otp => _otp;
  DateTime get dob => _dob;
  String get location => _location;

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setName(String name) {
    _name = name;
    notifyListeners();
  }

  void setPhone(String phone) {
    _phone = phone;
    notifyListeners();
  }

  void setOtp(String otp) {
    _otp = otp;
    notifyListeners();
  }

  void setDob(DateTime dob) {
    _dob = dob;
    notifyListeners();
  }

  void setLocation(String location) {
    _location = location;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

class User extends ChangeNotifier {
  String? token;
  String? lirstName;
  String? lastName;

  User({this.token, this.lirstName, this.lastName});
  void setToken(String token) {
    this.token = token;
    notifyListeners();
  }

  bool isLoggedIn() {
    return token != null;
  }
}

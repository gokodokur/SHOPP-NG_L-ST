import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:listcom/constant/app_constants.dart';
import 'package:listcom/helper/database_helper.dart';
import 'package:listcom/model/user.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewmodel with ChangeNotifier {
  User? user;
  String? errorMessage;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  //Giriş controllerları
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Kayıt controllerları
  TextEditingController rNameController = TextEditingController();
  TextEditingController rEmailController = TextEditingController();
  TextEditingController rPasswordController = TextEditingController();

  String hashPassword(String input) =>
      hex.encode(md5.convert(utf8.encode(input + AppConstants.saltText)).bytes);
  bool checkPassword(String input, String passwordHash) =>
      passwordHash == hashPassword(input);

  Future<bool> register() async {
    final preferences = await SharedPreferences.getInstance();
    if (rEmailController.text.isNotEmpty &&
        rPasswordController.text.isNotEmpty &&
        rNameController.text.isNotEmpty) {
      if ((await _dbHelper.getUserByEmail(rEmailController.text)) == null) {
        user = User(
            id: int.parse(randomNumeric(4)),
            email: rEmailController.text,
            passwordHash: hashPassword(rPasswordController.text),
            name: rNameController.text);
        await _dbHelper.insertUser(user!);
        preferences.setString(AppConstants.storedUser, user!.toJson());
        notifyListeners();
        return true;
      } else {
        errorMessage = "Bu mail adresi zaten uygulamaya kayıtlı";
        notifyListeners();
        return false;
      }
    } else {
      errorMessage = "Lütfen tüm alanları eksiksiz doldurunuz";
      notifyListeners();
      return false;
    }
  }

  Future<bool> login() async {
    final preferences = await SharedPreferences.getInstance();

    User? newUser = await _dbHelper.getUserByEmail(emailController.text);
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      if (newUser != null) {
        if (checkPassword(passwordController.text, newUser.passwordHash)) {
          preferences.setString(AppConstants.storedUser, newUser.toJson());
          user = newUser;
          notifyListeners();
          return true;
        } else {
          errorMessage = "Şifre hatalı. Lütfen şifrenizi kontrol ediniz";
          notifyListeners();

          return false;
        }
      } else {
        errorMessage = "Bu mail adresine ait kullanıcı bulunamadı";
        notifyListeners();
        return false;
      }
    } else {
      errorMessage = "Lütfen tüm alanları eksiksiz doldurun";
      notifyListeners();
      return false;
    }
  }

  clearUserData() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.remove(AppConstants.storedUser);
    user = null;
    notifyListeners();
  }

  initStoredUser() async {
    final preferences = await SharedPreferences.getInstance();
    String? userData = preferences.getString(AppConstants.storedUser);
    if (userData != null) {
      user = User.fromJson(userData);
      notifyListeners();
    }
  }
}

import 'dart:convert';

import 'package:gpspro/Config.dart';
import 'package:gpspro/Constants.dart';
import 'package:gpspro/api/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  static late SharedPreferences prefs;

  static String PREF_LANGUAGE = "language";
  static String PREF_EMAIL = "email";
  static String PREF_PASSWORD = "password";
  static String PREF_URL = "url";
  static String PREF_USER = "user";

  static String? getLanguage() {
    return prefs.getString(PREF_LANGUAGE);
  }

  static void setLanguage(String lang) {
    prefs.setString(PREF_LANGUAGE, lang);
  }

  static String? getEmail() {
    return prefs.getString(PREF_EMAIL);
  }

  static void setEmail(String email) {
    prefs.setString(PREF_EMAIL, email);
  }

  static String getServerUrl() {
    return prefs.getString(PREF_URL) == null
        ? SERVER_URL
        : prefs.getString(PREF_URL)!;
  }

  static void setServerUrl(String url) {
    prefs.setString(PREF_URL, url);
  }

  static String? getPassword() {
    return prefs.getString(PREF_PASSWORD).toString();
  }

  static void setPassword(String password) {
    prefs.setString(PREF_PASSWORD, password);
  }

  static User getUser() {
    return User.fromJson(json.decode(prefs.getString(PREF_USER)!));
  }

  static void setUser(String user) {
    prefs.setString(PREF_USER, user);
  }

  static void doLogout() {
    prefs.clear();
  }
}

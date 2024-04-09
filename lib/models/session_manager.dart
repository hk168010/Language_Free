import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  static Future<void> saveUsername(String username) async {
    await _storage.write(key: 'username', value: username);
  }

  static Future<void> saveToken(String accesstoken) async {
    await _storage.write(key: 'accesstoken', value: accesstoken);
  }

  static Future<void> saveUserId(String id) async {
    await _storage.write(key: 'userid', value: id);
    print("Session Uid$id");
  }

  static Future<void> saveLoginTime(DateTime loginTime) async {
    String timestamp = loginTime.toIso8601String();
    await _storage.write(key: 'loginTime', value: timestamp);
  }

  static Future<bool> isSessionExpired() async {
    String? storedTimestamp = await _storage.read(key: 'loginTime');
    if (storedTimestamp != null) {
      DateTime loginTime = DateTime.parse(storedTimestamp);
      DateTime now = DateTime.now();
      const int sessionTimeoutMinutes = 60;
      if (now.difference(loginTime).inMinutes > sessionTimeoutMinutes) {
        return true;
      }
    }
    return false;
  }

  static Future<void> updateSession({
    int? userId,
    String? uiLanguagePreference,
    String? translationLanguageFrom,
    String? translationLanguageTo,
    String? conversationLanguageFrom,
    String? conversationLanguageTo,
    String? pictureLangTo,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await prefs.setInt('userId', userId);
    }
    if (uiLanguagePreference != null) {
      await prefs.setString('uiLanguagePreference', uiLanguagePreference);
    }
    if (translationLanguageFrom != null) {
      await prefs.setString('translationLanguageFrom', translationLanguageFrom);
    }
    if (translationLanguageTo != null) {
      await prefs.setString('translationLanguageTo', translationLanguageTo);
    }
    if (conversationLanguageFrom != null) {
      await prefs.setString(
          'conversationLanguageFrom', conversationLanguageFrom);
    }
    if (conversationLanguageTo != null) {
      await prefs.setString('conversationLanguageTo', conversationLanguageTo);
    }
    if (pictureLangTo != null) {
      await prefs.setString('pictureLangTo', pictureLangTo);
    }
  }

  static Future<String> getSessionDataAndConvertToJson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? 0;
    String uiLanguagePreference = prefs.getString('uiLanguagePreference') ?? '';
    String translationLanguageFrom =
        prefs.getString('translationLanguageFrom') ?? '';
    String translationLanguageTo =
        prefs.getString('translationLanguageTo') ?? '';
    String conversationLanguageFrom =
        prefs.getString('conversationLanguageFrom') ?? '';
    String conversationLanguageTo =
        prefs.getString('conversationLanguageTo') ?? '';
    String pictureLangTo = prefs.getString('pictureLangTo') ?? '';
    Map<String, dynamic> jsonData = {
      'userId': userId,
      'uiLanguagePreference': uiLanguagePreference,
      'translationLanguageFrom': translationLanguageFrom,
      'translationLanguageTo': translationLanguageTo,
      'conversationLanguageFrom': conversationLanguageFrom,
      'conversationLanguageTo': conversationLanguageTo,
      'pictureLangTo': pictureLangTo,
    };
    String jsonString = jsonEncode(jsonData);
    return jsonString;
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: 'username');
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'accesstoken');
  }

  static Future<String?> getUserid() async {
    return await _storage.read(key: 'userid');
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: 'userid');
    await _storage.delete(key: 'username');
  }

  static Future<void> saveLangInterface(String langInterface) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('langInterface', langInterface);
  }

  static Future<String?> getLangInterface() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('langInterface');
  }

  static Future<void> clearLangInterface() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('langInterface');
  }
}

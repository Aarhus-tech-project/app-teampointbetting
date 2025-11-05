import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:point_betting/models/global_http.dart';
import 'package:point_betting/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = GlobalHttp.baseUrl;
  static const String _tokenKey = "access_token";
  static const String _refreshKey = "refresh_token";
  static const String _expiryKey = "expires_at";

  static Future<void> saveAuthData({
    required String accessToken, 
    required String refreshToken, 
    required DateTime expiry
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, accessToken);
    await prefs.setString(_refreshKey, refreshToken);
    await prefs.setInt(
      _expiryKey, 
      expiry.millisecondsSinceEpoch
    );
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  static Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    final expiry = prefs.getInt(_expiryKey);
    if (expiry == null) return false;
    return DateTime.now().millisecondsSinceEpoch < expiry;
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_expiryKey);
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$_baseUrl/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      return {
        "success": true, 
        "message": "Registration successful"
      };
    }

    return {
      "success": false,
      "message": jsonDecode(response.body)?["detail"] ??
          "Registration failed"
    };
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$_baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "twoFactorCode": "string",
        "twoFactorRecoveryCode": "string"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveAuthData(
        accessToken: "${data['tokenType']} ${data['accessToken']}",
        refreshToken: data['refreshToken'],
        expiry: DateTime.now().add(Duration(seconds: data['expiresIn'])),
      );
      return {
        "success": true, 
        "message": "Login successful"
      };
    }

    return {
      "success": false,
      "message": "failed"
      // "message": jsonDecode(response.body)?["detail"] ??
      //     "Login failed"
    };
  }

  static Future<Map<String, dynamic>> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      return {
        "success": false, 
        "message": "No refresh token found"
      };
    }

    final url = Uri.parse("$_baseUrl/refresh");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "refreshToken": refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveAuthData(
        accessToken: "${data['tokenType']} ${data['accessToken']}",
        refreshToken: data['refreshToken'],
        expiry: DateTime.now().add(Duration(seconds: data['expiresIn'])),
      );
      return {
        "success": true, 
        "message": "Token refreshed successfully"
      };
    }

    return {
      "success": false, 
      "message": jsonDecode(response.body)?["detail"] ??
          "Token refresh failed"
    };
  }

  static Future<void> logout(BuildContext context) async {
    await clearAuthData();

    if (!context.mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  static Future<Map<String, dynamic>> getValidAccessToken() async {
    bool isValid = await isTokenValid();

    if (!isValid) {
      final refreshResult = await refreshToken();
      if (refreshResult["success"] != true) {
        return {
          "success": false,
          "message": "Session expired. Please log in again.",
          "accessToken": null
        };
      }
    }

    final String? accessToken = await getAccessToken();
    if (accessToken == null) {
      return {
        "success": false,
        "message": "No access token found. Please log in.",
        "accessToken": null
      };
    }

    return {
      "success": true,
      "accessToken": accessToken,
    };
  }
}
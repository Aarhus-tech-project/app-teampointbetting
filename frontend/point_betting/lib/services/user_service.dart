import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:point_betting/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _baseUrl = "http://192.168.102.2:5000";

  Future<Map<String, dynamic>> fetchUserInfo() async {
    final tokenResult = await AuthService.getValidAccessToken();
    if (tokenResult["success"] != true) return tokenResult;

    final accessToken = tokenResult["accessToken"];

    final url = Uri.parse("$_baseUrl/api/User/get-info");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${accessToken.replaceAll('Bearer ', '')}",
      },
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_info', response.body);
      return {
        "success": true,
        "message": "User info fetched successfully."
      };
    }

    return {
      "success": false,
      "message": "Failed to fetch user info. Please try again."
    };
  }

  Future<Map<String, dynamic>> getCachedUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString('user_info');

    if (userInfoString != null) {
      return {
        "success": true,
        "data": jsonDecode(userInfoString)
      };
    }

    return {
      "success": false,
      "message": "No cached user info found."
    };
  }

  Future<Map<String, dynamic>> fetchLeaderboard() async {
    final tokenResult = await AuthService.getValidAccessToken();
    if (tokenResult["success"] != true) return tokenResult;

    final accessToken = tokenResult["accessToken"];

    final url = Uri.parse("$_baseUrl/api/User/leaderboard");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${accessToken.replaceAll('Bearer ', '')}",
      },
    );

    if (response.statusCode == 200) {
      return {
        "success": true,
        "data": jsonDecode(response.body)
      };
    }

    return {
      "success": false,
      "message": "Failed to fetch leaderboard. Please try again."
    };
  }
}
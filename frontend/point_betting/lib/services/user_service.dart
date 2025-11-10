import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:point_betting/models/global_http.dart';
import 'package:point_betting/models/global_user.dart';
import 'package:point_betting/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _baseUrl = GlobalHttp.baseUrl;

  static Future<Map<String, dynamic>> fetchUserInfo() async {
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

  static Future<void> setGlobalUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userInfoString = prefs.getString('user_info');
    if (userInfoString != null) {
      final userInfo = jsonDecode(userInfoString);

      GlobalUser.id = userInfo["id"] ?? '';
      GlobalUser.userName = userInfo["userName"] ?? '';
      GlobalUser.email = userInfo["email"] ?? '';
      GlobalUser.points = userInfo["points"] ?? 0;
      GlobalUser.phoneNumber = userInfo["phoneNumber"] ?? '';
    }
  }
  
  static Future<Map<String, dynamic>> updateUserProfile() async {
    final tokenResult = await AuthService.getValidAccessToken();
    if (tokenResult["success"] != true) return tokenResult;

    final accessToken = tokenResult["accessToken"];

    final url = Uri.parse("$_baseUrl/api/User/add-info");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${accessToken.replaceAll('Bearer ', '')}",
      },
      body: jsonEncode({
        "userName": GlobalUser.userName,
        "phoneNumber": GlobalUser.phoneNumber,
        "points": GlobalUser.points,
      }),
    );

    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": "Profile updated successfully."
      };
    }

    return {
      "success": false,
      "message": "Failed to update profile. Please try again."
    };
  }

  static Future<Map<String, dynamic>> fetchLeaderboard() async {
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
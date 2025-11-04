import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:point_betting/utilities/auth_service.dart';

class BetService {
  static const String _baseUrl = "http://192.168.102.2:5000";

  static Future<Map<String, dynamic>> _getValidAccessToken() async {
    bool isValid = await AuthService.isTokenValid();

    if (!isValid) {
      final refreshResult = await AuthService.refreshToken();
      if (refreshResult["success"] != true) {
        return {
          "success": false,
          "message": "Session expired. Please log in again.",
          "accessToken": null
        };
      }
    }

    final String? accessToken = await AuthService.getAccessToken();
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

  static Future<Map<String, dynamic>> fetchBets() async {
    final tokenResult = await _getValidAccessToken();
    if (tokenResult["success"] != true) return tokenResult;

    final accessToken = tokenResult["accessToken"];

    final url = Uri.parse("$_baseUrl/api/Bet");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": accessToken,
      },
    );

    if (response.statusCode == 200) {
      return {
        "success": true,
        "data": jsonDecode(response.body)
      };
    } else {
      return {
        "success": false,
        "message": "Failed to fetch bets. Please try again."
      };
    }
  }

  static Future<Map<String, dynamic>> createBet({
    required String subject,
    required DateTime deadline,
  }) async {
    final tokenResult = await _getValidAccessToken();
    if (tokenResult["success"] != true) return tokenResult;

    final accessToken = tokenResult["accessToken"];

    final url = Uri.parse("$_baseUrl/api/Bet/create");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${accessToken.replaceAll('Bearer ', '')}"
      },
      body: jsonEncode({
        "subject": subject,
        "deadline": deadline.toUtc().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": "Bet created successfully"
      };
    } else {
      return {
        "success": false,
        "message": "Failed to create bet. Please try again."
      };
    }
  }

  static Future<Map<String, dynamic>> answerBet({
    required String betId,
    required String answer,
    required int bettedPoints, 
  }) async {
    final tokenResult = await _getValidAccessToken();
    if (tokenResult["success"] != true) return tokenResult;

    final accessToken = tokenResult["accessToken"];

    final url = Uri.parse("$_baseUrl/api/BetAnswer");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": accessToken,
      },
      body: jsonEncode({
        "betId": betId,
        "answer": answer,
        "bettedPoints": bettedPoints,
      }),
    );

    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": "Answered bet successfully"
      };
    } else {
      return {
        "success": false,
        "message": "Failed to answer bet. Please try again."
      };
    }
  }
}
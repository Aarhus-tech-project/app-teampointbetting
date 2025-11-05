import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:point_betting/models/global_http.dart';
import 'package:point_betting/models/global_user.dart';
import 'package:point_betting/services/auth_service.dart';

class BetService {
  static const String _baseUrl = GlobalHttp.baseUrl;

  static Future<Map<String, dynamic>> fetchBets() async {
    final tokenResult = await AuthService.getValidAccessToken();
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
    }

    return {
      "success": false,
      "message": "Failed to fetch bets. Please try again."
    };
  }

  static Future<Map<String, dynamic>> createBet({
    required String subject,
    required DateTime deadline,
  }) async {
    final tokenResult = await AuthService.getValidAccessToken();
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
    } 

    return {
      "success": false,
      "message": "Failed to create bet. Please try again."
    };
  }

  static Future<Map<String, dynamic>> answerBet({
    required String betId,
    required String answer,
    required int bettedPoints, 
  }) async {
    final tokenResult = await AuthService.getValidAccessToken();
    if (tokenResult["success"] != true) return tokenResult;

    final accessToken = tokenResult["accessToken"];

    final url = Uri.parse("$_baseUrl/api/BetAnswer");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${accessToken.replaceAll('Bearer ', '')}",
      },
      body: jsonEncode({
        "betId": betId,
        "answer": answer,
        "bettedPoints": bettedPoints,
      }),
    );

    if (response.statusCode == 401 || response.statusCode == 403) {
      return {
        "success": false,
        "message": "Forbidden, you have already answered this bet."
      };
    }

    if (response.statusCode == 200) {
      return {
        "success": true,
        "message": "Answered bet successfully"
      };
    }

    return {
      "success": false,
      "message": "Failed to answer bet. Please try again."
    };
  }

  static Future<Map<String, dynamic>> getUserAnswers() async {
    final tokenResult = await AuthService.getValidAccessToken();
    if (tokenResult["success"] != true) return tokenResult;

    final accessToken = tokenResult["accessToken"];

    final userId = GlobalUser.id;

    final url = Uri.parse("$_baseUrl/api/BetAnswer/userId?userId=$userId");
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
      "message": "Failed to fetch user answers. Please try again."
    };
  }
}
import 'package:flutter/material.dart';
import 'package:point_betting/models/global_user.dart';
import 'package:point_betting/services/message_service.dart';
import 'package:point_betting/services/user_service.dart';
import '../theme/colors.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  bool _isLoading = false;
  List<dynamic> _leaderboard = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
    });

    final result = await UserService.fetchLeaderboard();

    setState(() {
      if (result["success"] == true) {
        _leaderboard = result["data"];
      } else {
        _leaderboard = [];
        showMessage(context, result["message"], type: MessageType.error);
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        title: const Text("Leaderboard", style: TextStyle(color: AppColors.whiteColor)),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.goldColor,
        backgroundColor: AppColors.bgColor,
        onRefresh: _loadLeaderboard,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.goldColor),
              )
            : _leaderboard.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 250),
                      Center(
                        child: Text(
                          "No leaderboard data found.",
                          style: TextStyle(color: AppColors.whiteColor),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _leaderboard.length,
                    itemBuilder: (context, index) {
                      final user = _leaderboard[index];
                      final rank = index + 1;
                      final username = user["userName"] ?? "Unknown";
                      final points = user["points"] ?? 0;

                      return Card(
                        color: user["userName"] == GlobalUser.userName ? AppColors.accentBlue : AppColors.goldColor,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: user["userName"] == GlobalUser.userName ? AppColors.goldColor : AppColors.accentBlue,
                            child: Text(
                              rank.toString(),
                              style: const TextStyle(color: AppColors.whiteColor),
                            ),
                          ),
                          title: Text(
                            username,
                            style: const TextStyle(color: AppColors.whiteColor, fontSize: 18),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "$points",
                                style: const TextStyle(color: AppColors.whiteColor, fontSize: 16),
                              ),
                              Icon(Icons.attach_money, color: AppColors.redColor)
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

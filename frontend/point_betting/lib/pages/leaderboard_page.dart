import 'package:flutter/material.dart';
import '../theme/colors.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.leaderboard, size: 80, color: AppColors.goldColor),
            SizedBox(height: 20),
            Text(
              'Leaderboard',
              style: TextStyle(color: AppColors.whiteColor, fontSize: 28),
            ),
          ],
        ),
      ),
    );
  }
}

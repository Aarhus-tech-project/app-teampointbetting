import 'package:flutter/material.dart';
import 'package:point_betting/services/auth_service.dart';
import '../theme/colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) {
    AuthService.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _logout(context),
        backgroundColor: AppColors.accentBlue,
        foregroundColor: AppColors.whiteColor,
        child: const Text('Logout'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person, size: 80, color: AppColors.goldColor),
            SizedBox(height: 20),
            Text(
              'Profile Page',
              style: TextStyle(color: AppColors.whiteColor, fontSize: 28),
            ),
          ],
        ),
      ),
    );
  }
}
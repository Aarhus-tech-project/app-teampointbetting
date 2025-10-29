import 'package:flutter/material.dart';
import '../theme/colors.dart';

class SpinTheWheelPage extends StatelessWidget {
  const SpinTheWheelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.casino, size: 80, color: AppColors.goldColor),
            SizedBox(height: 20),
            Text(
              'Spin the Wheel!',
              style: TextStyle(color: AppColors.whiteColor, fontSize: 28),
            ),
          ],
        ),
      ),
    );
  }
}

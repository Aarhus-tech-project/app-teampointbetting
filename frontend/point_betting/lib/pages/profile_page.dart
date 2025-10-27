import 'package:flutter/material.dart';

const Color bgColor = Color(0xFF56858B);
const Color goldColor = Color(0xFFA58D00);
const Color whiteColor = Color(0xFFFFFFFF);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person, size: 80, color: goldColor),
            SizedBox(height: 20),
            Text(
              'Profile Page',
              style: TextStyle(color: whiteColor, fontSize: 28),
            ),
          ],
        ),
      ),
    );
  }
}

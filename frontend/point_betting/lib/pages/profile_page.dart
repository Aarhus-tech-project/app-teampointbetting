import 'package:flutter/material.dart';
import 'login_page.dart';

const Color bgColor = Color(0xFF56858B);
const Color accentBlue = Color(0xFF001EFF);
const Color goldColor = Color(0xFFA58D00);
const Color whiteColor = Color(0xFFFFFFFF);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) {
    // TODO: Push LoginPage and remove history so back button won't return to Profile
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _logout(context),
        backgroundColor: accentBlue,
        foregroundColor: whiteColor,
        child: const Text('Logout'),
      ),
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
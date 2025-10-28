import 'package:flutter/material.dart';

const Color bgColor = Color(0xFF56858B);
const Color goldColor = Color(0xFFA58D00);
const Color whiteColor = Color(0xFFFFFFFF);

class SpinTheWheelPage extends StatelessWidget {
  const SpinTheWheelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.casino, size: 80, color: goldColor),
            SizedBox(height: 20),
            Text(
              'Spin the Wheel!',
              style: TextStyle(color: whiteColor, fontSize: 28),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

const Color bgColor = Color(0xFF56858B);
const Color accentBlue = Color(0xFF001EFF);
const Color redColor = Color(0xFFD20202);
const Color goldColor = Color(0xFFA58D00);
const Color whiteColor = Color(0xFFFFFFFF);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() => _counter++);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You have pressed the button:',
              style: const TextStyle(color: whiteColor, fontSize: 20),
            ),
            const SizedBox(height: 12),
            Text(
              '$_counter',
              style: const TextStyle(
                color: redColor,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        child: const Icon(Icons.add),
      ),
    );
  }
}

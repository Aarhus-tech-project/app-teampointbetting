import 'package:flutter/material.dart';
import '../main.dart';
import 'signup_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login(BuildContext context) {
    // TODO: Add real authentication later
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage(title: 'PointBetting Home Page')),
    );
  }

  void _signup(BuildContext context) {
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => SignupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to PointBetting',
              style: const TextStyle(color: goldColor, fontSize: 50),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _login(context),
              child: const Text("Login"),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => _signup(context), 
              child: const Text("Sign Up"),
            )
          ],
        ),
      ),
    );
  }
}

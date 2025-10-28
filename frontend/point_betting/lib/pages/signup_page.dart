import 'package:flutter/material.dart';
import 'login_page.dart';
import '../main.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();

  void _signup(BuildContext context) {
    // TODO: Add real authentication later
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage(title: 'PointBetting Home Page')),
    );
  }

  void _backToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                filled: true,
                fillColor: whiteColor,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                filled: true,
                fillColor: whiteColor,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                filled: true,
                fillColor: whiteColor,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: telephoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Telephone",
                filled: true,
                fillColor: whiteColor,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _signup(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: whiteColor,
              ),
              child: const Text("Sign Up"),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => _backToLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: whiteColor,
              ),
              child: const Text("Back to Login"),
            )
          ],
        ),
      ),
    );
  }
}

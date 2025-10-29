import 'package:flutter/material.dart';
import '../main.dart';
import 'signup_page.dart';
import '../theme/colors.dart';
import '../utilities/messages.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login(BuildContext context) {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      showMessage(context, "Please enter both username and password", type: MessageType.error);
      return;
    }

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
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome to PointBetting',
                    style: const TextStyle(color: AppColors.goldColor, fontSize: 50),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: usernameController,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      labelText: "Username",
                      filled: true,
                      fillColor: AppColors.whiteColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      labelText: "Password",
                      filled: true,
                      fillColor: AppColors.whiteColor,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _login(context),
                      child: const Text("Login", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _signup(context),
                      child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'login_page.dart';
import '../theme/colors.dart';
import '../services/message_service.dart';
import '../services/auth_service.dart';

class SignupPage extends StatelessWidget {
  SignupPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();

  void _signup(BuildContext context) async {
    String email = emailController.text.trim();
    // String username = usernameController.text.trim();
    String password = passwordController.text.trim();
    // String telephone = telephoneController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage(context, "Please enter both email and password", type: MessageType.error);
      return;
    }

    final result = await AuthService.register(
      email: email,
      password: password,
    );

    if (!context.mounted) return;

    if (result["success"]) {
      showMessage(context, result["message"], type: MessageType.success);
      _backToLogin(context);
    } else {
      showMessage(context, result["message"], type: MessageType.error);
    }
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
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(title: const Text("Sign Up")),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Sign Up for PointBetting',
                  style: const TextStyle(color: AppColors.goldColor, fontSize: 50),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(fontSize: 18),
                    filled: true,
                    fillColor: AppColors.whiteColor,
                  ),
                ),
                // const SizedBox(height: 20),
                // TextField(
                //   controller: usernameController,
                //   style: const TextStyle(fontSize: 20),
                //   decoration: const InputDecoration(
                //     labelText: "Username",
                //     labelStyle: TextStyle(fontSize: 18),
                //     filled: true,
                //     fillColor: AppColors.whiteColor,
                //   ),
                // ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 20),
                  decoration: const InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(fontSize: 18),
                    filled: true,
                    fillColor: AppColors.whiteColor,
                  ),
                ),
                // const SizedBox(height: 20),
                // TextField(
                //   controller: telephoneController,
                //   keyboardType: TextInputType.phone,
                //   style: const TextStyle(fontSize: 20),
                //   decoration: const InputDecoration(
                //     labelText: "Telephone",
                //     labelStyle: TextStyle(fontSize: 18),
                //     filled: true,
                //     fillColor: AppColors.whiteColor,
                //   ),
                // ),
                const SizedBox(height: 35),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _signup(context),
                    child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _backToLogin(context),
                    child: const Text("Back to Login", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

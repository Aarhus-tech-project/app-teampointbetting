import 'package:flutter/material.dart';
import 'package:point_betting/models/global_user.dart';
import 'package:point_betting/services/message_service.dart';
import 'package:point_betting/services/user_service.dart';
import 'pages/home_page.dart';
import 'pages/spin_the_wheel_page.dart';
import 'pages/leaderboard_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';
import 'theme/colors.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check token validity before launching the app
  final bool valid = await AuthService.isTokenValid();

  runApp(MyApp(isLoggedIn: valid));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PointBetting',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bgColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: AppColors.whiteColor,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.accentBlue,
          selectedItemColor: AppColors.goldColor,
          unselectedItemColor: AppColors.white70,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.accentBlue,
          foregroundColor: AppColors.whiteColor,
        ),
      ),
      home: !isLoggedIn
          ? const MainPage(title: 'PointBetting Home Page')
          : LoginPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SpinTheWheelPage(),
    LeaderboardPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _getUserInfo() async {
    final fetchUserResult = await UserService.fetchUserInfo();
    if (fetchUserResult["success"] != true) {
      if (!mounted) return;
      showMessage(context, fetchUserResult["message"], type: MessageType.error);
    }
    setState(() {
      UserService.setGlobalUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              GlobalUser.userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Row(
              children: [
                Text(
                  "${GlobalUser.points}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Icon(Icons.attach_money, color: AppColors.goldColor),
              ],
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppColors.goldColor,
        unselectedItemColor: AppColors.white70,
        backgroundColor: AppColors.accentBlue,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: "Spin The Wheel"),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: "Leaderboard"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

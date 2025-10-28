import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/spin_the_wheel_page.dart';
import 'pages/leaderboard_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';

// Refined color palette
const Color bgColor = Color(0xFF56858B);       // teal background
const Color accentBlue = Color(0xFF001EFF);    // AppBar & FAB
const Color goldColor = Color(0xFFA58D00);     // selected items
const Color redColor = Color(0xFFD20202);      // counters/alerts
const Color whiteColor = Color(0xFFFFFFFF);    // text
const Color white70 = Color(0xB3FFFFFF);       // unselected

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PointBetting',
      theme: ThemeData(
        scaffoldBackgroundColor: bgColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: accentBlue,
          foregroundColor: whiteColor,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: accentBlue,
          selectedItemColor: goldColor,
          unselectedItemColor: white70,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentBlue,
          foregroundColor: whiteColor,
        ),
      ),
      home: LoginPage(),
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

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: goldColor,
        unselectedItemColor: white70,
        backgroundColor: accentBlue,
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

import 'package:flutter/material.dart';
import 'package:point_betting/models/global_user.dart';
import 'package:point_betting/services/message_service.dart';
import 'package:point_betting/services/user_service.dart';
import 'package:point_betting/pages/home_page.dart';
import 'package:point_betting/pages/spin_the_wheel_page.dart';
import 'package:point_betting/pages/leaderboard_page.dart';
import 'package:point_betting/pages/profile_page.dart';
import 'package:point_betting/pages/login_page.dart';
import 'package:point_betting/theme/colors.dart';
import 'package:point_betting/services/auth_service.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'dart:io' show Platform; // only use for mobile checks

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String backgroundTaskName = "check_bets_task";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    // Initialize background task
    await Workmanager().initialize(callbackDispatcher);
    print('WorkManager initialized====================================================');
    // Register periodic background task (runs every 15 minutes)
    await Workmanager().registerPeriodicTask(
      "1",
      backgroundTaskName,
      frequency: const Duration(minutes: 15),
      // constraints: Constraints(networkType: NetworkType.connected),
    );
    print('Background task registered====================================================');
  }

  // Check login token before launch
  final bool valid = await AuthService.isTokenValid();

  runApp(MyApp(isLoggedIn: valid));
}

// method to manually run the background task logic
void _triggerManualTask() async {
  print('Manual Task Triggered: Checking Bets');
  final prefs = await SharedPreferences.getInstance();
  final myBetsData = prefs.getString('my_bets');
  final joinedBetsData = prefs.getString('joined_bets');

  if (myBetsData == null && joinedBetsData == null) {
    return;
  }

  final now = DateTime.now();
  bool updated = false;

  // CHECK OWN BETS — Need to fill correct answer
  if (myBetsData != null) {
    final List<Map<String, dynamic>> myBets =
        List<Map<String, dynamic>>.from(jsonDecode(myBetsData));

    for (final bet in myBets) {
      final deadline = bet["deadline"];
      final correctAnswer = bet["correctAnswer"];

      if (deadline == null) continue;
      final deadlineDate = DateTime.tryParse(deadline)?.add(Duration(hours: 1));
      if (deadlineDate == null) continue;

      // Deadline passed but answer not filled
      if (deadlineDate.isBefore(now) &&
          (correctAnswer == null || correctAnswer.toString().isEmpty) &&
          bet["notifiedMissingAnswer"] != true) {
        await _showBetNotification(
          "Your bet \"${bet["subject"] ?? "Unnamed"}\" needs a result!",
          body: "Deadline passed — please fill in the correct answer.",
        );
        bet["notifiedMissingAnswer"] = true;
        updated = true;
      }
    }

    if (updated) {
      await prefs.setString('my_bets', jsonEncode(myBets));
    }
  }

  // CHECK JOINED BETS — Bet finished
  if (joinedBetsData != null) {
    final List<Map<String, dynamic>> joinedBets =
        List<Map<String, dynamic>>.from(jsonDecode(joinedBetsData));

    for (final bet in joinedBets) {
      final deadline = bet["deadline"];
      final correctAnswer = bet["correctAnswer"];

      if (deadline == null) continue;
      final deadlineDate = DateTime.tryParse(deadline);
      if (deadlineDate == null) continue;

      // Bet ended, correct answer is given
      if (deadlineDate.isBefore(now) &&
          correctAnswer != null &&
          correctAnswer.toString().isNotEmpty &&
          bet["notifiedFinished"] != true) {
        await _showBetNotification(
          "A bet you joined is finished!",
          body:
              "\"${bet["subject"] ?? "Unnamed"}\" has been resolved with answer: $correctAnswer",
        );
        bet["notifiedFinished"] = true;
        updated = true;
      }
    }

    if (updated) {
      await prefs.setString('joined_bets', jsonEncode(joinedBets));
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == backgroundTaskName) {
      final prefs = await SharedPreferences.getInstance();

      final myBetsData = prefs.getString('my_bets');
      final joinedBetsData = prefs.getString('joined_bets');
      print( 'Background Task Running: Checking Bets');
      if (myBetsData == null && joinedBetsData == null) {
        return Future.value(true);
      }

      final now = DateTime.now();
      bool updated = false;

      // CHECK OWN BETS — Need to fill correct answer
      if (myBetsData != null) {
        final List<Map<String, dynamic>> myBets =
            List<Map<String, dynamic>>.from(jsonDecode(myBetsData));

        for (final bet in myBets) {
          final deadline = bet["deadline"];
          final correctAnswer = bet["correctAnswer"];

          if (deadline == null) continue;
          final deadlineDate = DateTime.tryParse(deadline)?.add(Duration(hours: 1));
          if (deadlineDate == null) continue;

          // Deadline passed but answer not filled
          if (deadlineDate.isBefore(now) &&
              (correctAnswer == null || correctAnswer.toString().isEmpty) &&
              bet["notifiedMissingAnswer"] != true) {
            await _showBetNotification(
              "Your bet \"${bet["subject"] ?? "Unnamed"}\" needs a result!",
              body: "Deadline passed — please fill in the correct answer.",
            );
            bet["notifiedMissingAnswer"] = true;
            updated = true;
          }
        }

        if (updated) {
          await prefs.setString('my_bets', jsonEncode(myBets));
        }
      }

      // CHECK JOINED BETS — Bet finished
      if (joinedBetsData != null) {
        final List<Map<String, dynamic>> joinedBets =
            List<Map<String, dynamic>>.from(jsonDecode(joinedBetsData));

        for (final bet in joinedBets) {
          final deadline = bet["deadline"];
          final correctAnswer = bet["correctAnswer"];

          if (deadline == null) continue;
          final deadlineDate = DateTime.tryParse(deadline);
          if (deadlineDate == null) continue;

          // Bet ended, correct answer is given
          if (deadlineDate.isBefore(now) &&
              correctAnswer != null &&
              correctAnswer.toString().isNotEmpty &&
              bet["notifiedFinished"] != true) {
            await _showBetNotification(
              "A bet you joined is finished!",
              body:
                  "\"${bet["subject"] ?? "Unnamed"}\" has been resolved with answer: $correctAnswer",
            );
            bet["notifiedFinished"] = true;
            updated = true;
          }
        }

        if (updated) {
          await prefs.setString('joined_bets', jsonEncode(joinedBets));
        }
      }

      return Future.value(true);
    }

    return Future.value(true);
  });
}

Future<void> _showBetNotification(String title, {String? body}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'bets_channel',
    'Bet Notifications',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body ?? '',
    notificationDetails,
  );
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
      home: isLoggedIn
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

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
    }
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
      body: Column(
        children: [
          // Pages or other widgets
          Expanded(child: _pages[_selectedIndex]),

          // Button to trigger the background task manually
          _selectedIndex == 0 ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _triggerManualTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                "Trigger Task Manually",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ) : Container(),
        ],
      ),
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

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:point_betting/services/auth_service.dart';
import 'package:point_betting/services/bet_service.dart';
import 'package:point_betting/services/message_service.dart';
import 'package:point_betting/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/colors.dart';
import '../models/global_user.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

File? _profileImage;
final ImagePicker _picker = ImagePicker();

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditing = false;
  List _bets = [];
  List _joinedBets = [];

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
    _loadBetsData();
    _loadProfileImage();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _nameController.text = GlobalUser.userName;
      _emailController.text = GlobalUser.email;
      _phoneController.text = GlobalUser.phoneNumber;
    });
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imageString = prefs.getString("profile_image");
    if (imageString != null) {
      setState(() {
        _profileImage = File.fromUri(Uri.parse(imageString));
      });
    }
  }

  Future<void> _loadBetsData() async {
    final prefs = await SharedPreferences.getInstance();

    // Fetch all bets
    final betResult = await BetService.fetchBets();
    if (!mounted) return;

    if (betResult["success"]) {
      final fetchedBets = betResult["data"] as List;

      // Add local-only flags for each bet
      for (final bet in fetchedBets) {
        bet["notifiedMissingAnswer"] ??= false; // creator reminder
        bet["notifiedFinished"] ??= false; // participant result notice
      }

      setState(() {
        _bets = fetchedBets;
      });

      // Save only your own bets locally (bets you created)
      final myBets = fetchedBets.where((b) => b["userId"] == GlobalUser.id).toList();
      await prefs.setString("my_bets", jsonEncode(myBets));
    } else {
      showMessage(context, betResult["message"], type: MessageType.error);
    }

    // Fetch joined bets
    final betAnswerResult = await BetService.getUserAnswers();
    if (!mounted) return;

    if (betAnswerResult["success"]) {
      final joinedBets = betAnswerResult["data"] as List;

      // Add same local-only flags
      for (final bet in joinedBets) {
        bet["notifiedMissingAnswer"] ??= false;
        bet["notifiedFinished"] ??= false;
      }

      setState(() {
        _joinedBets = joinedBets;
      });

      await prefs.setString("joined_bets", jsonEncode(joinedBets));
    } else {
      showMessage(context, betAnswerResult["message"], type: MessageType.error);
    }
  }

  void _toggleEdit() {
    setState(() => _isEditing = !_isEditing);
  }

  void _saveProfile() async {
    GlobalUser.userName = _nameController.text;
    GlobalUser.email = _emailController.text;
    GlobalUser.phoneNumber = _phoneController.text;

    final result = await UserService.updateUserProfile();
    if (!mounted) return;
    if (result["success"]) {
      setState(() {
        _isEditing = false;
      });
      showMessage(context, result["message"], type: MessageType.success);
    }
    else {
      showMessage(context, result["message"], type: MessageType.error);
    }
  }

  Future<bool> _requestPermissions() async {
    if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
    return true;
    }

    final statuses = await [
      Permission.camera,
      Permission.photos,
      Permission.storage,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> _pickProfileImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a Photo"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() => _profileImage = File(image.path));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("profile_image", _profileImage!.uri.toString());
      }
    } else {
      if (!mounted) return;
      showMessage(context, "Camera permission denied!", type: MessageType.error);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _profileImage = File(image.path));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("profile_image", _profileImage!.uri.toString());
    }
  }

  void _logout(BuildContext context) {
    AuthService.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        title: const Text("Profile", style: TextStyle(color: AppColors.whiteColor)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _logout(context),
        backgroundColor: AppColors.accentBlue,
        foregroundColor: AppColors.whiteColor,
        child: const Icon(Icons.logout),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.goldColor,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS) && _isEditing) { 
                      final granted = await _requestPermissions();
                      if (granted) {
                        _pickProfileImage(context);
                      } else {
                        showMessage(context, "Permission denied!", type: MessageType.error);
                      }
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.bgColor,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? const Icon(Icons.person, size: 40, color: AppColors.goldColor)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                _isEditing
                    ? Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: "Name",
                              labelStyle: TextStyle(color: AppColors.whiteColor),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.whiteColor)),
                            ),
                            style: const TextStyle(color: AppColors.whiteColor),
                          ),
                          // TextField(
                          //   controller: _emailController,
                          //   decoration: const InputDecoration(
                          //     labelText: "Email",
                          //     labelStyle: TextStyle(color: AppColors.whiteColor),
                          //     enabledBorder: UnderlineInputBorder(
                          //         borderSide: BorderSide(color: AppColors.whiteColor)),
                          //   ),
                          //   style: const TextStyle(color: AppColors.whiteColor),
                          // ),
                          TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: "Phone Number",
                              labelStyle: TextStyle(color: AppColors.whiteColor),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.whiteColor)),
                            ),
                            style: const TextStyle(color: AppColors.whiteColor),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                            ),
                            child: const Text("Save", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Text(
                            GlobalUser.userName,
                            style: const TextStyle(
                                color: AppColors.whiteColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            GlobalUser.email,
                            style: const TextStyle(color: AppColors.white70),
                          ),
                          Text(
                            GlobalUser.phoneNumber,
                            style: const TextStyle(color: AppColors.white70),
                          ),
                          TextButton(
                            onPressed: _toggleEdit,
                            child: const Text("Edit Profile",
                                style: TextStyle(color: AppColors.whiteColor)),
                          ),
                        ],
                      ),
              ],
            ),
          ),

          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.goldColor,
            labelColor: AppColors.goldColor,
            unselectedLabelColor: AppColors.whiteColor,
            tabs: const [
              Tab(text: "My Bets"),
              Tab(text: "Joined Bets"),
            ],
          ),

          // 🔹 Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyBetsTab(),
                _buildJoinedBetsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyBetsTab() {
    final myBets = _bets.where((bet) => 
      bet["userId"] == GlobalUser.id &&
      (bet["correctAnswer"] == null || bet["correctAnswer"].toString().isEmpty)
    ).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: myBets.length,
      itemBuilder: (context, i) {
        final bet = myBets[i];
        final subject = bet["subject"] ?? "Unknown";
        final deadline = bet["deadline"];
        final formattedDate = deadline != null
            ? DateFormat("yyyy-MM-dd HH:mm")
                .format(DateTime.parse(deadline).add(Duration(hours: 1)))
            : "No deadline";
        final canInsertCorrectAnswer = deadline != null && DateTime.parse(deadline).isBefore(DateTime.now()) && 
            (bet["correctAnswer"] == null || bet["correctAnswer"].toString().isEmpty);

        return Card(
          color: AppColors.goldColor,
          child: ListTile(
            title: Text(subject, style: const TextStyle(color: AppColors.whiteColor)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Deadline: $formattedDate",
                  style: const TextStyle(color: AppColors.redColor)
                ),
                const SizedBox(height: 4),
                Text(
                  "Yes: ${bet["totalYesPersons"] ?? 0} people (${bet["totalYesPoints"] ?? 0} points)",
                  style: const TextStyle(color: AppColors.whiteColor),
                ),
                Text(
                  "No: ${bet["totalNoPersons"] ?? 0} people (${bet["totalNoPoints"] ?? 0} points)",
                  style: const TextStyle(color: AppColors.whiteColor),
                ),
                canInsertCorrectAnswer ? const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Tap to enter the correct answer",
                    style: TextStyle(color: AppColors.accentBlue, fontStyle: FontStyle.italic),
                  ),
                ) : const SizedBox.shrink(),
              ],
            ),
            onTap: () {
            if (canInsertCorrectAnswer) {
              _showEnterAnswerDialog(bet);
            }
          },
          ),
        );
      },
    );
  }

  void _showEnterAnswerDialog(Map bet) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgColor,
          title: Text(
            "Select Correct Answer for ${bet["subject"] ?? "Bet"}",
            style: const TextStyle(color: AppColors.whiteColor),
          ),
          content: const Text(
            "Tap the correct answer:",
            style: TextStyle(color: AppColors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.redColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                await _submitAnswer(bet, "Yes");
                Navigator.of(context).pop();
              },
              child: const Text("Yes", style: TextStyle(color: AppColors.whiteColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.redColor),
              onPressed: () async {
                await _submitAnswer(bet, "No");
                Navigator.of(context).pop();
              },
              child: const Text("No", style: TextStyle(color: AppColors.whiteColor)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitAnswer(Map bet, String answer) async {
    // Send to server
    final result = await BetService().setCorrectAnswer(
      betId: bet["betId"],
      correctAnswer: answer,
    );
    if (!mounted) return;
    if (result["success"] == true) {
      showMessage(context, "Answer saved successfully", type: MessageType.success);
    } else {
      showMessage(context, result["message"], type: MessageType.error);
      return;
    }

    // Save locally
    setState(() {
      bet["correctAnswer"] = answer;
    });

    // Save to SharedPreferences for background worker
    final prefs = await SharedPreferences.getInstance();
    final myBetsData = prefs.getString("my_bets");
    if (myBetsData != null) {
      final myBetsList = List<Map<String, dynamic>>.from(jsonDecode(myBetsData));
      final index = myBetsList.indexWhere((b) => b["betId"] == bet["betId"]);
      if (index != -1) {
        myBetsList[index]["correctAnswer"] = answer;
        await prefs.setString("my_bets", jsonEncode(myBetsList));
      }
    }

    // Update user data
    final userResult = await UserService.fetchUserInfo();
    if (!mounted) return;
    if (userResult["success"] != true) {
      showMessage(context, userResult["message"], type: MessageType.error);
      return;
    }
    UserService.setGlobalUserInfo();
  }

  Widget _buildJoinedBetsTab() {
    final joinedBets = _bets.where((bet) => 
      _joinedBets.any((answer) => 
        answer["betId"] == bet["betId"] && 
        (bet["correctAnswer"] == null || bet["correctAnswer"].toString().isEmpty
      )
    )).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: joinedBets.length,
      itemBuilder: (context, i) {
        final bet = joinedBets[i];
        final subject = bet["subject"] ?? "Unknown";
        final deadline = bet["deadline"];
        final formattedDate = deadline != null
            ? DateFormat("yyyy-MM-dd HH:mm")
                .format(DateTime.parse(deadline).add(Duration(hours: 1)))
            : "No deadline";
        return Card(
          color: AppColors.accentBlue,
          child: ListTile(
            title: Text(subject, style: const TextStyle(color: AppColors.whiteColor)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Deadline: $formattedDate",
                  style: const TextStyle(color: AppColors.redColor)
                ),
                const SizedBox(height: 4),
                Text(
                  "Yes: ${bet["totalYesPersons"] ?? 0} people (${bet["totalYesPoints"] ?? 0} points)",
                  style: const TextStyle(color: AppColors.whiteColor),
                ),
                Text(
                  "No: ${bet["totalNoPersons"] ?? 0} people (${bet["totalNoPoints"] ?? 0} points)",
                  style: const TextStyle(color: AppColors.whiteColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
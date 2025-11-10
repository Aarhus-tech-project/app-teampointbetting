import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:point_betting/services/auth_service.dart';
import 'package:point_betting/services/bet_service.dart';
import 'package:point_betting/services/message_service.dart';
import 'package:point_betting/services/user_service.dart';
import '../theme/colors.dart';
import '../models/global_user.dart';

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
  }

  Future<void> _loadUserData() async {
    setState(() {
      _nameController.text = GlobalUser.userName;
      _emailController.text = GlobalUser.email;
      _phoneController.text = GlobalUser.phoneNumber;
    });
  }

  Future<void> _loadBetsData() async {
    final betResult = await BetService.fetchBets();
    if (!mounted) return;
    if (betResult["success"]) {
      setState(() {
        _bets = betResult["data"];
      });
    } else {
      showMessage(context, betResult["message"], type: MessageType.error);
    }

    final betAnswerResult = await BetService.getUserAnswers();
    if (!mounted) return;
    if (betAnswerResult["success"]) {
      setState(() {
        _joinedBets = betAnswerResult["data"];
      });
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
                const Icon(Icons.person, size: 80, color: AppColors.whiteColor),
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
                          TextField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              labelStyle: TextStyle(color: AppColors.whiteColor),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.whiteColor)),
                            ),
                            style: const TextStyle(color: AppColors.whiteColor),
                          ),
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
    final myBets = _bets.where((bet) => bet["userId"] == GlobalUser.id).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: myBets.length,
      itemBuilder: (context, i) {
        final bet = myBets[i];
        final subject = bet["subject"] ?? "Unknown";
        final deadline = bet["deadline"];
        final formattedDate = deadline != null
            ? DateFormat("yyyy-MM-dd HH:mm")
                .format(DateTime.parse(deadline))
            : "No deadline";
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJoinedBetsTab() {
    final joinedBets = _bets.where((bet) =>
        _joinedBets.any((answer) => answer["betId"] == bet["betId"])).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: joinedBets.length,
      itemBuilder: (context, i) {
        final bet = joinedBets[i];
        final subject = bet["subject"] ?? "Unknown";
        final deadline = bet["deadline"];
        final formattedDate = deadline != null
            ? DateFormat("yyyy-MM-dd HH:mm")
                .format(DateTime.parse(deadline))
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
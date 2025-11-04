import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:point_betting/utilities/bet_service.dart';
import '../theme/colors.dart';
import '../utilities/message_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  List<dynamic> _bets = [];

  @override
  void initState() {
    super.initState();
    _loadBets();
  }

  Future<void> _loadBets() async {
    setState(() {
      _isLoading = true;
    });

    final result = await BetService.fetchBets();

    setState(() {
      _isLoading = false;
      if (result["success"] == true) {
        _bets = result["data"];
      } else {
        showMessage(context, result["message"], type: MessageType.error);
        _bets = []; 
      }
    });
  }

  Future<void> _showCreateBetDialog() async {
    final subjectController = TextEditingController();
    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgColor,
          title: const Text(
            "Create a New Bet",
            style: TextStyle(color: AppColors.whiteColor),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: subjectController,
                    style: const TextStyle(color: AppColors.whiteColor),
                    decoration: const InputDecoration(
                      labelText: "Bet Subject",
                      labelStyle: TextStyle(color: AppColors.whiteColor),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.goldColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.goldColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedDate != null
                              ? "Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDate!)}"
                              : "No deadline selected",
                          style: const TextStyle(color: AppColors.whiteColor),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today,
                            color: AppColors.goldColor),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: const TimeOfDay(hour: 12, minute: 0),
                            );
                            if (time != null) {
                              setState(() {
                                selectedDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: AppColors.goldColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldColor,
              ),
              onPressed: () async {
                if (subjectController.text.isEmpty || selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter all fields")),
                  );
                  return;
                }

                Navigator.pop(context); // close dialog
                await _createBet(subjectController.text, selectedDate!);
              },
              child: const Text("Create Bet"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createBet(String subject, DateTime deadline) async {
    setState(() {
      _isLoading = true;
    });

    final result = await BetService.createBet(
      subject: subject,
      deadline: deadline,
    );

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;
    if (result["success"] == true) {
      showMessage(context, result["message"], type: MessageType.success);
      _loadBets();
    } else {
      showMessage(context, result["message"], type: MessageType.error);
    }
  }

  Future<void> _joinBetDialog(Map<String, dynamic> bet) async {
    final TextEditingController pointsController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.bgColor,
          title: const Text(
            "Join Bet",
            style: TextStyle(color: AppColors.whiteColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bet["subject"] ?? "No subject",
                style: const TextStyle(color: AppColors.whiteColor, fontSize: 16),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.whiteColor),
                decoration: const InputDecoration(
                  labelText: "Betted Points",
                  labelStyle: TextStyle(color: AppColors.whiteColor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.goldColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.goldColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: AppColors.redColor),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              onPressed: () {
                final int? points = int.tryParse(pointsController.text);
                if (points == null || points <= 0) {
                  showMessage(context, "Please enter a valid number of points.", type: MessageType.error);
                  return;
                }
                Navigator.pop(context);
                _joinBet(bet["id"], "Yes", points);
              },
              child: const Text("Yes"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
              ),
              onPressed: () {
                final int? points = int.tryParse(pointsController.text);
                if (points == null || points <= 0) {
                  showMessage(context, "Please enter a valid number of points.", type: MessageType.error);
                  return;
                }
                Navigator.pop(context);
                _joinBet(bet["id"], "No", points);
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }


  Future<void> _joinBet(String betId, String answer, int bettedPoints) async {
    final answerResult = await BetService.answerBet(betId: betId, answer: answer, bettedPoints: bettedPoints);

    if (!mounted) return;

    if (answerResult["success"] == true) {
      showMessage(context, answerResult["message"], type: MessageType.success);
    } else {
      showMessage(context, answerResult["message"], type: MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        title: const Text("Bets", style: TextStyle(color: AppColors.whiteColor)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.goldColor),
            onPressed: _loadBets,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.goldColor))
          : _bets.isEmpty
              ? Center(
                  child: Text(
                    "No bets available.",
                    style: const TextStyle(color: AppColors.whiteColor),
                  ),
                )
              : ListView.builder(
                  itemCount: _bets.length,
                  itemBuilder: (context, index) {
                    final bet = _bets[index];
                    final subject = bet["subject"] ?? "Unknown";
                    final deadline = bet["deadline"];
                    final formattedDate = deadline != null
                        ? DateFormat("yyyy-MM-dd HH:mm").format(DateTime.parse(deadline))
                        : "No deadline";

                    return Card(
                      color: AppColors.goldColor,
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(
                          subject,
                          style: const TextStyle(color: AppColors.whiteColor, fontSize: 18),
                        ),
                        subtitle: Text(
                          "Deadline: $formattedDate",
                          style: const TextStyle(color: AppColors.redColor),
                        ),
                        onTap: () => _joinBetDialog(bet),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateBetDialog,
        backgroundColor: AppColors.accentBlue,
        child: const Icon(Icons.add),
      ),
    );
  }
}

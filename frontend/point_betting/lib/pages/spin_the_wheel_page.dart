import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:point_betting/models/global_user.dart';
import 'package:point_betting/models/wheel_multipliers.dart';
import 'package:point_betting/services/message_service.dart';
import 'package:point_betting/services/user_service.dart';
import '../theme/colors.dart';

class SpinTheWheelPage extends StatefulWidget {
  const SpinTheWheelPage({super.key});

  @override
  State<SpinTheWheelPage> createState() => _SpinTheWheelPageState();
}

class _SpinTheWheelPageState extends State<SpinTheWheelPage> {
  final TextEditingController _pointsController = TextEditingController();
  final StreamController<int> _controller = StreamController<int>();
  final List<Map<String, Object>> _multipliers = WheelMultipliers.multipliers;
  bool _isSpinning = false;

  @override
  void dispose() {
    _controller.close();
    _pointsController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    final points = int.tryParse(_pointsController.text);

    if (points == null || points <= 0) {
      showMessage(context, "Enter a valid whole number of points", type: MessageType.error);
      return;
    }
    if (GlobalUser.points > 0 && points > GlobalUser.points) {
      showMessage(context, "You don't have enough points to spin", type: MessageType.error);
      return;
    }
    if (GlobalUser.points == 0 && points > 25) {
      showMessage(context, "You only have 25 pity points to spin with", type: MessageType.error);
      return;
    }

    setState(() {
      _isSpinning = true;
    });

    final selected = Random().nextInt(_multipliers.length);
    _controller.add(selected);

    Future.delayed(const Duration(seconds: 5), () async {
      final multiplier = _multipliers[selected]["multiplier"] as double;

      // Multiply and round to int
      final newPoints = max(0, (points * multiplier).round());

      setState(() {
        _isSpinning = false;
        GlobalUser.points = GlobalUser.points - points + newPoints;
        _pointsController.clear();
      });

      final userResult = await UserService.updateUserProfile();
      if (!mounted) return;

      if (userResult["success"] != true) {
        showMessage(context, userResult["message"], type: MessageType.error);
        return;
      }

      showMessage(
        context,
        "You won ${multiplier}x! Total: $newPoints points",
        type: MessageType.info,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        title: const Text(
          "Spin the Wheel",
          style: TextStyle(color: AppColors.whiteColor),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Expanded(
              child: FortuneWheel(
                selected: _controller.stream,
                animateFirst: false,
                indicators: const <FortuneIndicator>[
                  FortuneIndicator(
                    alignment: Alignment.topCenter,
                    child: TriangleIndicator(color: AppColors.goldColor),
                  ),
                ],
                items: _multipliers
                    .map(
                      (m) => FortuneItem(
                        child: Text(
                          "${m["multiplier"]}x",
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        style: FortuneItemStyle(
                          color: m["color"] as Color,
                          borderColor: AppColors.goldColor,
                          borderWidth: 2,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: AppColors.whiteColor),
              decoration: InputDecoration(
                labelText: GlobalUser.points == 0
                    ? "Enter Points... You have 25 pity points!"
                    : "Enter Points",
                labelStyle: const TextStyle(color: AppColors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.goldColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.accentBlue),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSpinning ? null : _spinWheel,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldColor,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isSpinning ? "Spinning..." : "Spin!",
                style: const TextStyle(color: AppColors.whiteColor, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

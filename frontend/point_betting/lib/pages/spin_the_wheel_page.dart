import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import '../theme/colors.dart';

class SpinTheWheelPage extends StatefulWidget {
  const SpinTheWheelPage({super.key});

  @override
  State<SpinTheWheelPage> createState() => _SpinTheWheelPageState();
}

class _SpinTheWheelPageState extends State<SpinTheWheelPage> {
  final TextEditingController _pointsController = TextEditingController();
  final StreamController<int> _controller = StreamController<int>();
  final List<double> _multipliers = [0, 0.5, 1.25, 1.5, 1.25, 0.5, 2];
  bool _isSpinning = false;
  double? _result;

  @override
  void dispose() {
    _controller.close();
    _pointsController.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    final points = double.tryParse(_pointsController.text);
    if (points == null || points <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid amount of points")),
      );
      return;
    }

    setState(() {
      _isSpinning = true;
      _result = null;
    });

    final selected = Random().nextInt(_multipliers.length);
    _controller.add(selected);

    Future.delayed(const Duration(seconds: 5), () {
      final multiplier = _multipliers[selected];
      final newPoints = points * multiplier;
      setState(() {
        _isSpinning = false;
        _result = newPoints;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "🎉 You won ${multiplier}x! Total: ${newPoints.toStringAsFixed(2)} points",
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.goldColor,
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
                items: [
                  for (var multiplier in _multipliers)
                    FortuneItem(
                      child: Text(
                        "${multiplier}x",
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                      style: FortuneItemStyle(
                        color: AppColors.accentBlue,
                        borderColor: AppColors.goldColor,
                        borderWidth: 2,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.whiteColor),
              decoration: InputDecoration(
                labelText: "Enter Points",
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isSpinning ? "Spinning..." : "Spin!",
                style: const TextStyle(
                    color: AppColors.whiteColor, fontSize: 18),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              Text(
                "You now have ${_result!.toStringAsFixed(2)} points!",
                style: const TextStyle(
                    color: AppColors.whiteColor, fontSize: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

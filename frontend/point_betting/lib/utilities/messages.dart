import 'package:flutter/material.dart';
import '../theme/colors.dart';

enum MessageType { error, info }

void showMessage(BuildContext context, String message, {MessageType type = MessageType.info}) {
  Color backgroundColor;

  switch (type) {
    case MessageType.error:
      backgroundColor = AppColors.redColor;
      break;
    case MessageType.info:
      backgroundColor = AppColors.white70;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

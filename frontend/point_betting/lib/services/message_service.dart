import 'package:flutter/material.dart';
import '../theme/colors.dart';

enum MessageType { error, info, success }

void showMessage(BuildContext context, String message, {MessageType type = MessageType.info}) {
  Color backgroundColor;
  Color textColor = AppColors.whiteColor;

  switch (type) {
    case MessageType.error:
      backgroundColor = AppColors.redColor;
      break;
    case MessageType.info:
      backgroundColor = AppColors.white70;
      textColor = AppColors.bgColor;
      break;
    case MessageType.success:
      backgroundColor = AppColors.goldColor;
      break;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: textColor)),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

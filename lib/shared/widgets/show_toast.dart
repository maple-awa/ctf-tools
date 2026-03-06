import 'package:flutter/material.dart';

/// 显示统一样式的提示消息。
void showToast(String message, BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: colorScheme.inverseSurface,
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      closeIconColor: colorScheme.onInverseSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      duration: const Duration(seconds: 2),
    ),
  );
}

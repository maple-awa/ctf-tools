import 'package:flutter/material.dart';

/// 显示统一样式的提示消息。
///
/// [message] 为提示内容，[context] 用于定位当前页面的 `ScaffoldMessenger`。
void showToast(String message, BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: colorScheme.primary,
      duration: const Duration(seconds: 2),
    ),
  );
}

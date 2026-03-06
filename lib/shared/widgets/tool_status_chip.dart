import 'package:flutter/material.dart';

/// 统一状态标签，替代旧式彩色小容器。
class ToolStatusChip extends StatelessWidget {
  const ToolStatusChip({
    super.key,
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      avatar: icon == null ? null : Icon(icon, size: 16, color: scheme.primary),
      label: Text(label),
      backgroundColor: scheme.secondaryContainer,
      labelStyle: TextStyle(
        color: scheme.onSecondaryContainer,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

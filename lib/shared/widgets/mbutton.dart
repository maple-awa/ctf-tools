import 'package:flutter/material.dart';

/// 统一样式的功能按钮。
class MElevatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final Color? iconColor;
  final String text;
  final Color? textColor;

  const MElevatedButton({
    super.key,
    required this.icon,
    this.iconColor,
    required this.text,
    this.textColor,
    this.onPressed,
  });

  @override
  State<MElevatedButton> createState() => _MElevatedButtonState();
}

class _MElevatedButtonState extends State<MElevatedButton> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = widget.textColor ?? scheme.onSecondaryContainer;
    return FilledButton.tonalIcon(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: foreground,
        iconColor: widget.iconColor ?? foreground,
        visualDensity: VisualDensity.standard,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: widget.onPressed,
      icon: Icon(widget.icon, size: 18),
      label: Text(
        widget.text,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(color: foreground, fontSize: 13),
      ),
    );
  }
}

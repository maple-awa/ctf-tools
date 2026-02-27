import 'package:flutter/material.dart';

/// 统一样式的功能按钮。
class MElevatedButton extends StatefulWidget {
  /// 点击事件。
  final VoidCallback onPressed;

  /// 按钮图标。
  final IconData icon;

  /// 图标颜色。
  final Color iconColor;

  /// 按钮文案。
  final String text;

  /// 文案颜色。
  final Color textColor;

  const MElevatedButton({
    super.key,
    required this.icon,
    this.iconColor = const Color(0xFF2B64D1),
    required this.text,
    this.textColor = const Color(0xFF2B64D1),
    required this.onPressed,
  });

  @override
  State<MElevatedButton> createState() => _MElevatedButtonState();
}

class _MElevatedButtonState extends State<MElevatedButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = _hovered
        ? const Color(0xFF17315F)
        : const Color(0xFF122244);

    final scale = _pressed
        ? 0.98
        : _hovered
        ? 1.01
        : 1.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          scale: scale,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              elevation: _hovered ? 3 : 1,
              backgroundColor: bgColor,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: widget.onPressed,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: widget.iconColor, size: 17),
                const SizedBox(width: 4),
                Text(
                  widget.text,
                  style: TextStyle(color: widget.textColor, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

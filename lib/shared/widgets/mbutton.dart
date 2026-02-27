import 'package:flutter/material.dart';

/// 统一样式的功能按钮。
class MElevatedButton extends StatefulWidget {
  /// 点击事件。
  final VoidCallback onPressed;

  /// 按钮图标。
  final IconData icon;

  /// 图标颜色。
  final Color? iconColor;

  /// 按钮文案。
  final String text;

  /// 文案颜色。
  final Color? textColor;

  const MElevatedButton({
    super.key,
    required this.icon,
    this.iconColor,
    required this.text,
    this.textColor,
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
    final scheme = Theme.of(context).colorScheme;
    final iconColor = widget.iconColor ?? scheme.primary;
    final textColor = widget.textColor ?? scheme.primary;
    final bgColor = _hovered
        ? scheme.primary.withValues(alpha: 0.55)
        : scheme.primary.withValues(alpha: 0.35);

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 在极窄宽度下退化为仅图标，避免 RenderFlex overflow。
                final compact =
                    constraints.maxWidth.isFinite && constraints.maxWidth < 56;
                final textWidth = constraints.maxWidth.isFinite
                    ? (constraints.maxWidth - 24).clamp(0.0, 240.0)
                    : 240.0;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: iconColor, size: 17),
                    if (!compact) ...[
                      const SizedBox(width: 4),
                      SizedBox(
                        width: textWidth,
                        child: Text(
                          widget.text,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: TextStyle(color: textColor, fontSize: 13),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

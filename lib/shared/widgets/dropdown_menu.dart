import 'package:flutter/material.dart';

/// 通用下拉选择组件。
class MDropdownMenu extends StatefulWidget {
  /// 选项变化回调。
  final ValueChanged<String>? onChanged;

  /// 初始值。
  final String initialValue;

  /// 可选项列表。
  final List<String> items;

  const MDropdownMenu({
    super.key,
    this.onChanged,
    required this.initialValue,
    required this.items,
  });

  @override
  MDropdownMenuState createState() => MDropdownMenuState();
}

class MDropdownMenuState extends State<MDropdownMenu> {
  late String selected;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant MDropdownMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.items.contains(selected)) {
      selected = widget.items.isNotEmpty ? widget.items.first : '';
    } else if (oldWidget.initialValue != widget.initialValue &&
        widget.items.contains(widget.initialValue)) {
      selected = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = _hovered
        ? scheme.primary.withValues(alpha: 0.9)
        : scheme.primary.withValues(alpha: 0.55);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(minWidth: 72),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: scheme.surfaceContainerHighest.withValues(alpha: 0.9),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: DropdownButton<String>(
              value: selected,
              elevation: 3,
              isDense: true,
              style: TextStyle(color: scheme.onSurface, fontSize: 12),
              underline: Container(),
              selectedItemBuilder: (context) {
                return widget.items
                    .map(
                      (item) => ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          item,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                        ),
                      ),
                    )
                    .toList();
              },
              items: widget.items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selected = value;
                });
                widget.onChanged?.call(value);
              },
            ),
          ),
        ),
      ),
    );
  }
}

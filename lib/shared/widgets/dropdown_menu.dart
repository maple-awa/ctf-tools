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
    final borderColor = _hovered
        ? const Color(0xFF2E4EC9)
        : const Color(0xFF0F17AA);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: _hovered
              ? [
                  const BoxShadow(
                    color: Color(0x221B3EA3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Theme(
          data: Theme.of(
            context,
          ).copyWith(canvasColor: const Color(0xFF0F172A)),
          child: DropdownButton<String>(
            value: selected,
            elevation: 3,
            style: const TextStyle(color: Colors.white, fontSize: 12),
            underline: Container(),
            items: widget.items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
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
    );
  }
}

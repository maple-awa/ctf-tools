import 'package:flutter/material.dart';

/// 通用下拉选择组件。
class MDropdownMenu extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final String initialValue;
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
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 132, maxWidth: 220),
      child: DropdownMenu<String>(
        initialSelection: selected,
        width: 180,
        enabled: widget.onChanged != null,
        textStyle: TextStyle(color: scheme.onSurface, fontSize: 13),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: scheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        onSelected: widget.onChanged == null
            ? null
            : (value) {
                if (value == null) return;
                setState(() {
                  selected = value;
                });
                widget.onChanged?.call(value);
              },
        dropdownMenuEntries: widget.items
            .map((item) => DropdownMenuEntry<String>(value: item, label: item))
            .toList(),
      ),
    );
  }
}

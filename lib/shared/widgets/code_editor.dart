import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeEditor extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final double height;
  final bool readOnly;

  const CodeEditor({
    super.key,
    required this.controller,
    required this.label,
    required this.height,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        minLines: null,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(fontFamily: 'monospace'),
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: readOnly ? scheme.surfaceContainer : null,
          suffixIcon: IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.content_copy),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: controller.text));
              }
            },
          ),
        ),
        keyboardType: TextInputType.multiline,
      ),
    );
  }
}

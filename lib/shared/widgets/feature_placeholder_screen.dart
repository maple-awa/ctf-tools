import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';

/// 用于尚未补齐的模块，避免错误跳转到无关页面。
class FeaturePlaceholderScreen extends StatelessWidget {
  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
    required this.availableNow,
    required this.nextSteps,
  });

  final String title;
  final String description;
  final List<String> availableNow;
  final List<String> nextSteps;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ToolPageShell(
      title: title,
      description: description,
      child: Column(
        children: [
          ToolSectionCard(
            title: '当前状态',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '该模块已接入导航，但当前版本只完成了可复用骨架和部分核心能力。',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                ...availableNow.map((item) => _bullet(context, item)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ToolSectionCard(
            title: '后续建议',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: nextSteps.map((item) => _bullet(context, item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(BuildContext context, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Icon(Icons.circle, size: 7, color: scheme.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

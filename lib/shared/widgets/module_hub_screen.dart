import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ModuleHubSection {
  const ModuleHubSection({
    required this.title,
    required this.summary,
    required this.route,
    required this.icon,
    required this.inputs,
    required this.highlights,
    this.sampleRoute,
  });

  final String title;
  final String summary;
  final String route;
  final IconData icon;
  final List<String> inputs;
  final List<String> highlights;
  final String? sampleRoute;
}

class ModuleHubScreen extends StatelessWidget {
  const ModuleHubScreen({
    super.key,
    required this.title,
    required this.description,
    required this.badge,
    required this.sections,
    required this.statusItems,
    required this.recommendedFlows,
    this.knownLimits = const [],
  });

  final String title;
  final String description;
  final String badge;
  final List<ModuleHubSection> sections;
  final List<String> statusItems;
  final List<String> recommendedFlows;
  final List<String> knownLimits;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ToolPageShell(
      title: title,
      description: description,
      badge: badge,
      child: Column(
        children: [
          ToolSectionCard(
            title: '模块状态',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: statusItems.map((item) => _bullet(context, item)).toList(),
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '子工具',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 760;
                return GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: sections.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: compact ? 1 : 2,
                    mainAxisSpacing: kToolSectionGap,
                    crossAxisSpacing: kToolSectionGap,
                    childAspectRatio: compact ? 1.25 : 1.36,
                  ),
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => context.go(section.route),
                        child: Container(
                          padding: const EdgeInsets.all(kToolSectionPadding),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                scheme.primaryContainer.withValues(alpha: 0.14),
                                scheme.surfaceContainer,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: scheme.primary.withValues(alpha: 0.14),
                                    child: Icon(section.icon, color: scheme.primary, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      section.title,
                                      style: TextStyle(
                                        color: scheme.onSurface,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                section.summary,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12.5,
                                  height: 1.55,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '输入格式',
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.5,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: section.inputs.map((item) => Chip(label: Text(item))).toList(),
                              ),
                              const Spacer(),
                              Text(
                                section.highlights.join(' / '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 11.5,
                                  height: 1.45,
                                ),
                              ),
                              if (section.sampleRoute != null) ...[
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: () => context.go(section.sampleRoute!),
                                  icon: const Icon(Icons.play_circle_outline),
                                  label: const Text('打开样例入口'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '推荐链路',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recommendedFlows.map((item) => _bullet(context, item)).toList(),
            ),
          ),
          if (knownLimits.isNotEmpty) ...[
            const SizedBox(height: kToolSectionGap),
            ToolSectionCard(
              title: '当前限制',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: knownLimits.map((item) => _bullet(context, item)).toList(),
              ),
            ),
          ],
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

import 'package:ctf_tools/shared/layout/responsive.dart';
import 'package:flutter/material.dart';

const double kToolPagePadding = 16;
const double kToolPageMaxWidth = 1120;
const double kToolSectionPadding = 14;
const double kToolSectionRadius = 20;
const double kToolHeroRadius = 24;
const double kToolSectionGap = 12;
const double kToolTabViewportHeight = 720;
const double kToolOutputHeight = 280;
const double kToolLargeOutputHeight = 400;

/// 统一的工具页外壳，负责标题、说明与滚动布局。
class ToolPageShell extends StatelessWidget {
  const ToolPageShell({
    super.key,
    required this.title,
    this.description,
    required this.child,
    this.actions,
    this.badge,
  });

  final String title;
  final String? description;
  final Widget child;
  final List<Widget>? actions;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.surface,
                scheme.surfaceContainerLowest,
                scheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kToolPagePadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: kToolPageMaxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PageHero(
                      title: title,
                      description: description,
                      badge: badge,
                      actions: actions,
                      isMobile: isMobile,
                    ),
                    const SizedBox(height: kToolSectionGap),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 统一样式的工具区域卡片。
class ToolSectionCard extends StatelessWidget {
  const ToolSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(kToolSectionPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kToolSectionRadius),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.8),
          ),
          gradient: LinearGradient(
            colors: [scheme.surfaceContainerLow, scheme.surfaceContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (trailing case final trailing?) ...[trailing],
              ],
            ),
            const SizedBox(height: kToolSectionGap),
            child,
          ],
        ),
      ),
    );
  }
}

class _PageHero extends StatelessWidget {
  const _PageHero({
    required this.title,
    required this.description,
    required this.badge,
    required this.actions,
    required this.isMobile,
  });

  final String title;
  final String? description;
  final String? badge;
  final List<Widget>? actions;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 18 : 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kToolHeroRadius),
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer.withValues(alpha: 0.92),
              scheme.surfaceContainerHigh,
              scheme.tertiaryContainer.withValues(alpha: 0.78),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (badge != null)
                  Chip(
                    label: Text(badge!),
                    avatar: Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: scheme.primary,
                    ),
                  ),
                Chip(
                  label: const Text('Material 3'),
                  avatar: Icon(
                    Icons.layers_outlined,
                    size: 16,
                    color: scheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: isMobile ? 24 : 32,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  description!,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ),
            ],
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(spacing: 8, runSpacing: 8, children: actions!),
            ],
          ],
        ),
      ),
    );
  }
}

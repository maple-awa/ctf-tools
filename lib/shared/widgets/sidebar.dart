import 'package:ctf_tools/core/route/app_routes.dart';
import 'package:ctf_tools/core/route/nav_item.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 左侧导航栏组件。
class Sidebar extends StatefulWidget {
  final double width;
  final VoidCallback? onNavigate;

  const Sidebar({super.key, this.width = 280, this.onNavigate});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? expandedMenu;
  String? _version;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _version = '${packageInfo.version}+${packageInfo.buildNumber}';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _version = 'Unknown';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final scheme = Theme.of(context).colorScheme;
    final computedExpanded = _inferExpandedMenu(location);
    final currentExpanded = expandedMenu ?? computedExpanded;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: widget.width,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          border: Border(right: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: kToolSectionGap),
            Expanded(
              child: ListView(
                children: [
                  ...navItems
                      .where((item) => _isTopLevel(item.route))
                      .map(
                        (item) => _buildTopLevel(
                          context,
                          item,
                          location,
                          currentExpanded,
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(kToolSectionPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kToolSectionRadius),
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer,
              scheme.tertiaryContainer.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: scheme.surface,
              child: Icon(
                Icons.terminal_rounded,
                color: scheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CTF TOOLBOX',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Material You workspace',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(Icons.info_outline, color: scheme.primary),
        title: Text(
          'Version ${_version ?? '...'}',
          style: TextStyle(
            color: scheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Flutter + Material 3',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }

  bool _isTopLevel(String route) => route.split('/').length == 2;

  bool _routeMatches(String location, String route) {
    if (route == '/') return location == '/';
    return location == route || location.startsWith('$route/');
  }

  String? _inferExpandedMenu(String location) {
    if (location == '/') return '/';
    final topLevels = navItems.where((item) => _isTopLevel(item.route));
    for (final item in topLevels) {
      if (item.route == '/') continue;
      if (_routeMatches(location, item.route)) return item.route;
    }
    return null;
  }

  Widget _buildTopLevel(
    BuildContext context,
    NavItem item,
    String location,
    String? currentExpanded,
  ) {
    final isExpanded = currentExpanded == item.route;
    final isActive = _routeMatches(location, item.route);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          _NavigationTile(
            icon: item.icon,
            title: item.name,
            selected: isActive,
            expanded: isExpanded,
            expandable: item.isContainerOnly,
            onTap: () {
              setState(() {
                expandedMenu = item.route;
              });
              context.go(item.route);
              widget.onNavigate?.call();
            },
            onExpandTap: item.isContainerOnly
                ? () {
                    setState(() {
                      expandedMenu = isExpanded ? null : item.route;
                    });
                  }
                : null,
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: navItems
                  .where((sub) => sub.route.startsWith('${item.route}/'))
                  .map(
                    (sub) => Padding(
                      padding: const EdgeInsets.only(left: 18, top: 6),
                      child: _NavigationTile(
                        icon: sub.icon,
                        title: sub.name,
                        selected: _routeMatches(location, sub.route),
                        compact: true,
                        onTap: () {
                          context.go(sub.route);
                          widget.onNavigate?.call();
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.expanded = false,
    this.expandable = false,
    this.compact = false,
    this.onExpandTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final bool expanded;
  final bool expandable;
  final bool compact;
  final VoidCallback onTap;
  final VoidCallback? onExpandTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = selected
        ? scheme.secondaryContainer
        : Colors.transparent;
    final foreground = selected
        ? scheme.onSecondaryContainer
        : scheme.onSurface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(compact ? 16 : 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(compact ? 16 : 18),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 14 : 16,
            vertical: compact ? 10 : 12,
          ),
          child: Row(
            children: [
              Icon(icon, size: compact ? 18 : 20, color: foreground),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: foreground,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: compact ? 13 : 14,
                  ),
                ),
              ),
              if (expandable)
                InkResponse(
                  radius: 18,
                  onTap: onExpandTap,
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 180),
                    turns: expanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: foreground,
                      size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

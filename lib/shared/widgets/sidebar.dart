import 'package:ctf_tools/core/route/app_routes.dart';
import 'package:ctf_tools/core/route/nav_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 左侧导航栏组件。
class Sidebar extends StatefulWidget {
  final double width;
  final VoidCallback? onNavigate;

  const Sidebar({super.key, this.width = 220, this.onNavigate});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  /// 当前展开的一级菜单路由。
  String? expandedMenu;

  /// 应用版本号（如 `1.0.0+1`）。
  String? _version;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  /// 从平台读取应用版本信息并写入状态。
  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final versionString = '${packageInfo.version}+${packageInfo.buildNumber}';
      if (mounted) {
        setState(() {
          _version = versionString;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _version = 'Unknown';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final scheme = Theme.of(context).colorScheme;

    // 根据当前路由推导默认展开菜单，避免 "/" 前缀导致误命中。
    final computedExpanded = _inferExpandedMenu(location);
    final currentExpanded = expandedMenu ?? computedExpanded;

    return Container(
      width: widget.width,
      color: scheme.surfaceContainerLowest,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topLogo(scheme),
            const SizedBox(height: 4),
            // 一级菜单
            ...navItems
                .where((item) => _isTopLevel(item.route))
                .map(
                  (item) =>
                      _buildTopLevel(context, item, location, currentExpanded),
                ),
            const SizedBox(height: 12),
            // 底栏
            _buildFooter(scheme),
          ],
        ),
      ),
    );
  }

  /// 构建顶部 Logo 区域。
  Widget _topLogo(ColorScheme scheme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * -6),
            child: child,
          ),
        );
      },
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(Icons.terminal, color: scheme.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              "CTF TOOLBOX",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建底部版本信息卡片。
  Widget _buildFooter(ColorScheme scheme) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: scheme.surfaceContainerHigh,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            "Version ${_version ?? '...'}",
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  /// 判断是否为顶级路由（形如 `/xxx`）。
  bool _isTopLevel(String route) {
    return route.split("/").length == 2;
  }

  bool _routeMatches(String location, String route) {
    if (route == "/") return location == "/";
    return location == route || location.startsWith("$route/");
  }

  String? _inferExpandedMenu(String location) {
    if (location == "/") return "/";
    final topLevels = navItems.where((item) => _isTopLevel(item.route));
    for (final item in topLevels) {
      if (item.route == "/") continue;
      if (_routeMatches(location, item.route)) {
        return item.route;
      }
    }
    return null;
  }

  /// 构建一级菜单项及其展开逻辑。
  Widget _buildTopLevel(
    BuildContext context,
    NavItem item,
    String location,
    String? currentExpanded,
  ) {
    final bool isExpanded = currentExpanded == item.route;
    final bool isActive = _routeMatches(location, item.route);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _menuCard(
          icon: item.icon,
          title: item.name,
          selected: isActive,
          expanded: isExpanded,
          isContainerOnly: item.isContainerOnly,
          onTap: () {
            setState(() {
              if (item.isContainerOnly) {
                // 折叠型菜单：只切换展开/收起，不跳转
                expandedMenu = isExpanded ? null : item.route;
              } else {
                // 非折叠型菜单：跳转 + 展开（不收起）
                expandedMenu = item.route;
                context.go(item.route);
                widget.onNavigate?.call();
              }
            });
          },
        ),

        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Column(
                    children: navItems
                        .where((sub) => sub.route.startsWith("${item.route}/"))
                        .map(
                          (sub) => _subMenuCard(
                            icon: sub.icon,
                            title: sub.name,
                            selected: location == sub.route,
                            onTap: () {
                              context.go(sub.route);
                              widget.onNavigate?.call();
                            },
                          ),
                        )
                        .toList(),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  /// 构建一级菜单卡片。
  Widget _menuCard({
    required IconData icon,
    required String title,
    required bool selected,
    required bool expanded,
    required bool isContainerOnly,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected
              ? scheme.primary.withValues(alpha: 0.16)
              : scheme.surfaceContainerLowest,
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: selected ? 1.04 : 1,
              duration: const Duration(milliseconds: 140),
              child: Icon(
                icon,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
            ),
            if (isContainerOnly)
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: selected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建二级菜单卡片。
  Widget _subMenuCard({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected
              ? scheme.primary.withValues(alpha: 0.14)
              : scheme.surfaceContainerLowest,
        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: selected ? 1.05 : 1,
              duration: const Duration(milliseconds: 140),
              child: Icon(
                icon,
                size: 18,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

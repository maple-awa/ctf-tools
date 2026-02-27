import 'package:ctf_tools/core/route/app_routes.dart';
import 'package:ctf_tools/core/route/nav_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 左侧导航栏组件。
class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

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

    // 自动展开当前路由的父菜单
    for (final item in navItems) {
      if (_isTopLevel(item.route) && location.startsWith(item.route)) {
        expandedMenu ??= item.route;
      }
    }

    return Container(
      width: 220,
      color: const Color(0xFF0D121C),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topLogo(),
            const SizedBox(height: 4),
            // 一级菜单
            ...navItems
                .where((item) => _isTopLevel(item.route))
                .map((item) => _buildTopLevel(context, item, location)),
            const SizedBox(height: 12),
            // 底栏
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// 构建顶部 Logo 区域。
  Widget _topLogo() {
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
        child: const Row(
          children: [
            Icon(Icons.terminal, color: Color(0xFF2B6CDE), size: 28),
            SizedBox(width: 12),
            Text(
              "CTF TOOLBOX",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2B6CDE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建底部版本信息卡片。
  Widget _buildFooter() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: const Color(0xFF0E1726),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            "Version ${_version ?? '...'}",
            style: const TextStyle(color: Color(0xFF505364)),
          ),
        ),
      ),
    );
  }

  /// 判断是否为顶级路由（形如 `/xxx`）。
  bool _isTopLevel(String route) {
    return route.split("/").length == 2;
  }

  /// 构建一级菜单项及其展开逻辑。
  Widget _buildTopLevel(BuildContext context, NavItem item, String location) {
    final bool isExpanded = expandedMenu == item.route;
    final bool isActive = item.route == "/"
        ? location == "/"
        : location.startsWith(item.route);

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
                            onTap: () => context.go(sub.route),
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
          color: selected ? const Color(0xFF0F1B31) : const Color(0xFF0D121C),
          border: Border.all(
            color: selected ? const Color(0xFF274C8E) : const Color(0x00000000),
          ),
        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: selected ? 1.04 : 1,
              duration: const Duration(milliseconds: 140),
              child: Icon(
                icon,
                color: selected
                    ? const Color(0xFF2B64CC)
                    : const Color(0xFF646C7A),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? const Color(0xFF285ABA)
                      : const Color(0xFF646C7A),
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
                  color: selected
                      ? const Color(0xFF285ABA)
                      : const Color(0xFF646C7A),
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
          color: selected ? const Color(0xFF0F1B31) : const Color(0xFF0D121C),
        ),
        child: Row(
          children: [
            AnimatedScale(
              scale: selected ? 1.05 : 1,
              duration: const Duration(milliseconds: 140),
              child: Icon(
                icon,
                size: 18,
                color: selected
                    ? const Color(0xFF2453AC)
                    : const Color(0xFF7D8597),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: selected
                    ? const Color(0xFF2453AC)
                    : const Color(0xFF9AA4B2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

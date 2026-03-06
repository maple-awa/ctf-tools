import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

/// 侧边栏导航项定义。
class NavItem {
  /// 展示名称。
  final String name;

  /// 路由路径。
  final String route;

  /// 菜单图标。
  final IconData icon;

  /// 路由页面构建函数。
  final Widget Function(BuildContext, GoRouterState) builder;

  /// 是否为带子菜单的分组入口。
  final bool isContainerOnly;

  NavItem({
    required this.name,
    required this.route,
    required this.icon,
    required this.builder,
    this.isContainerOnly = false,
  });
}

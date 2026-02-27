import 'package:ctf_tools/shared/widgets/sidebar.dart';
import 'package:flutter/material.dart';

/// 带侧边栏的主框架布局。
class MainLayout extends StatelessWidget {
  /// 页面主体内容。
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Sidebar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}

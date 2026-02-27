import 'package:ctf_tools/shared/widgets/sidebar.dart';
import 'package:ctf_tools/shared/layout/responsive.dart';
import 'package:flutter/material.dart';

/// 带侧边栏的主框架布局。
class MainLayout extends StatefulWidget {
  /// 页面主体内容。
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final GlobalKey<ScaffoldState> _mobileScaffoldKey =
      GlobalKey<ScaffoldState>();
  bool _drawerOpen = false;

  void _toggleMobileMenu() {
    if (_drawerOpen) {
      _mobileScaffoldKey.currentState?.closeDrawer();
      return;
    }
    _mobileScaffoldKey.currentState?.openDrawer();
  }

  void _closeMobileMenu() {
    if (!_drawerOpen) return;
    _mobileScaffoldKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = Responsive.isMobileWidth(constraints.maxWidth);
        final scheme = Theme.of(context).colorScheme;
        if (isMobile) {
          return Scaffold(
            key: _mobileScaffoldKey,
            backgroundColor: scheme.surface,
            drawer: Drawer(
              width: 262,
              child: SafeArea(
                child: Sidebar(width: 262, onNavigate: _closeMobileMenu),
              ),
            ),
            onDrawerChanged: (opened) {
              if (_drawerOpen == opened) return;
              setState(() {
                _drawerOpen = opened;
              });
            },
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 10,
                      bottom: 8,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Material(
                        color: scheme.primary.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _toggleMobileMenu,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _drawerOpen ? Icons.close : Icons.terminal,
                                  color: scheme.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'CTF',
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Sidebar(),
              Expanded(child: widget.child),
            ],
          ),
        );
      },
    );
  }
}

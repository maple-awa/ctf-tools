import 'package:ctf_tools/shared/layout/responsive.dart';
import 'package:ctf_tools/shared/widgets/sidebar.dart';
import 'package:flutter/material.dart';

/// 带侧边栏的主框架布局。
class MainLayout extends StatefulWidget {
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
    } else {
      _mobileScaffoldKey.currentState?.openDrawer();
    }
  }

  void _closeMobileMenu() {
    if (_drawerOpen) {
      _mobileScaffoldKey.currentState?.closeDrawer();
    }
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
              width: 300,
              child: SafeArea(
                child: Sidebar(width: 300, onNavigate: _closeMobileMenu),
              ),
            ),
            onDrawerChanged: (opened) {
              if (_drawerOpen != opened) {
                setState(() {
                  _drawerOpen = opened;
                });
              }
            },
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: _toggleMobileMenu,
                          icon: Icon(
                            _drawerOpen ? Icons.close : Icons.menu_rounded,
                          ),
                          label: const Text('导航'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'CTF Tools',
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: scheme.surface,
          body: DecoratedBox(
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
            child: Row(
              children: [
                const Sidebar(),
                const VerticalDivider(width: 1),
                Expanded(child: widget.child),
              ],
            ),
          ),
        );
      },
    );
  }
}

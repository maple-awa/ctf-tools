import 'package:ctf_tools/shared/layout/responsive.dart';
import 'package:ctf_tools/shared/providers/theme/theme_color.dart';
import 'package:ctf_tools/shared/providers/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _version = '${info.version}+${info.buildNumber}';
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
    final isMobile = Responsive.isMobile(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '设置',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: isMobile ? 24 : 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '主题、配色与应用信息',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionCard(
                    scheme: scheme,
                    title: '主题模式',
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: scheme.primary,
                      activeTrackColor: scheme.primary.withValues(alpha: 0.4),
                      title: Text(
                        '暗色模式',
                        style: TextStyle(color: scheme.onSurface),
                      ),
                      subtitle: Text(
                        themeProvider.isDark ? '当前为暗色主题' : '当前为亮色主题',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      value: themeProvider.isDark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    scheme: scheme,
                    title: '主题配色',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(AppTheme.colors.length, (index) {
                        final item = AppTheme.colors[index];
                        final selected =
                            index == themeProvider.selectedColorIndex;
                        final color = themeProvider.isDark
                            ? item.dark
                            : item.light;
                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => themeProvider.setColorIndex(index),
                          child: Container(
                            width: isMobile ? 140 : 170,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? scheme.primary
                                    : scheme.outlineVariant,
                                width: selected ? 1.6 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: scheme.onSurface),
                                  ),
                                ),
                                if (selected)
                                  Icon(
                                    Icons.check,
                                    size: 16,
                                    color: scheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sectionCard(
                    scheme: scheme,
                    title: '应用信息',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '版本: $_version',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'CTF Tools - 编码、网络与分析辅助工具集',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionCard({
    required ColorScheme scheme,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

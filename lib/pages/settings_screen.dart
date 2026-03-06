import 'package:ctf_tools/shared/providers/theme/theme_color.dart';
import 'package:ctf_tools/shared/providers/theme/theme_provider.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
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
    final scheme = Theme.of(context).colorScheme;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return ToolPageShell(
          title: '设置',
          description: '统一管理主题、配色和当前应用信息，整体样式已切换到 Material 3。',
          badge: 'Preferences',
          child: Column(
            children: [
              ToolSectionCard(
                title: '主题模式',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '暗色模式',
                        style: TextStyle(color: scheme.onSurface),
                      ),
                      subtitle: Text(
                        themeProvider.isDark ? '当前为暗色主题' : '当前为亮色主题',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      value: themeProvider.isDark,
                      onChanged: themeProvider.setDarkMode,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text(
                              '当前配色：${themeProvider.selectedThemeColor.name}',
                            ),
                            avatar: Icon(
                              Icons.palette_outlined,
                              size: 16,
                              color: scheme.primary,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: themeProvider.resetAppearance,
                            icon: const Icon(Icons.restart_alt),
                            label: const Text('恢复默认'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: kToolSectionGap),
              ToolSectionCard(
                title: '主题配色',
                child: Wrap(
                  spacing: kToolSectionGap,
                  runSpacing: kToolSectionGap,
                  children: List.generate(AppTheme.colors.length, (index) {
                    final item = AppTheme.colors[index];
                    final selected = index == themeProvider.selectedColorIndex;
                    final color = themeProvider.isDark ? item.dark : item.light;
                    return SizedBox(
                      width: 160,
                      child: Card(
                        color: selected
                            ? scheme.primaryContainer
                            : scheme.surfaceContainer,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            kToolSectionRadius,
                          ),
                          onTap: () => themeProvider.setColorIndex(index),
                          child: Padding(
                            padding: const EdgeInsets.all(kToolSectionPadding),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      color: selected
                                          ? scheme.onPrimaryContainer
                                          : scheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  Icon(
                                    Icons.check_circle,
                                    color: scheme.primary,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: kToolSectionGap),
              ToolSectionCard(
                title: '应用信息',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.info_outline, color: scheme.primary),
                      title: Text(
                        '版本',
                        style: TextStyle(color: scheme.onSurface),
                      ),
                      subtitle: Text(
                        _version,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.palette_outlined,
                        color: scheme.primary,
                      ),
                      title: Text(
                        '设计语言',
                        style: TextStyle(color: scheme.onSurface),
                      ),
                      subtitle: Text(
                        'Material 3 / Material You',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

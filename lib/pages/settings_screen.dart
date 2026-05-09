import 'package:ctf_tools/shared/providers/theme/theme_color.dart';
import 'package:ctf_tools/shared/providers/theme/theme_provider.dart';
import 'package:ctf_tools/shared/providers/config/config_provider.dart';
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
    return Consumer2<ThemeProvider, ConfigProvider>(
      builder: (context, themeProvider, configProvider, _) {
        return ToolPageShell(
          title: '设置',
          description: '统一管理主题、配色和当前应用信息，整体样式已切换到 Material 3。',
          badge: 'Preferences',
          child: Column(
            children: [
              ToolSectionCard(
                title: '快速配置',
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(
                          Icons.tune,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      title: const Text('应用配置'),
                      subtitle: Text(
                        '字体、布局、编辑器等本地化配置',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                      onTap: () {
                        // 导航到配置页面
                        // Navigator.pushNamed(context, '/settings/config');
                      },
                    ),
                    const Divider(height: 1),
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

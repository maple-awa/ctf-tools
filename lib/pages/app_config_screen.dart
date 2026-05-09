import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ctf_tools/shared/providers/config/config_provider.dart';
import 'package:ctf_tools/shared/models/app_config.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:ctf_tools/widgets/config_presets_widget.dart';
import 'package:ctf_tools/widgets/config_history_widget.dart';
import 'package:ctf_tools/widgets/config_import_export_dialog_enhanced.dart';
import 'package:ctf_tools/widgets/system_font_picker_dialog.dart';

/// 应用配置页面 - 提供完整的本地化配置界面
class AppConfigScreen extends StatefulWidget {
  const AppConfigScreen({super.key});

  @override
  State<AppConfigScreen> createState() => _AppConfigScreenState();
}

class _AppConfigScreenState extends State<AppConfigScreen> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Consumer<ConfigProvider>(
      builder: (context, configProvider, _) {
        return ToolPageShell(
          title: '应用配置',
          description: '自定义字体、布局、编辑器等本地化配置，配置后自动生效',
          badge: 'Configuration',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ConfigPresetsWidget(),
                const SizedBox(height: 16),
                _buildFontSection(configProvider, scheme),
                const SizedBox(height: 16),
                _buildLayoutSection(configProvider, scheme),
                const SizedBox(height: 16),
                _buildEditorSection(configProvider, scheme),
                const SizedBox(height: 16),
                _buildToolPrefsSection(configProvider, scheme),
                const SizedBox(height: 16),
                _buildAdvancedSection(configProvider, scheme),
                const SizedBox(height: 16),
                const ConfigHistoryWidget(),
                const SizedBox(height: 24),
                _buildActionButtons(configProvider, scheme),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildFontSection(ConfigProvider provider, ColorScheme scheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.font_download, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  '字体配置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const SystemFontPickerDialog(),
                    );
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('选择系统字体'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '当前字体',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: scheme.outline),
                        ),
                        child: Text(
                          provider.font.name,
                          style: TextStyle(
                            fontFamily: provider.font.family,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '字体族',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          provider.font.family.isEmpty
                              ? '系统默认'
                              : provider.font.family,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '基础字号：${provider.font.baseSize.toStringAsFixed(1)}',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      Slider(
                        value: provider.font.baseSize,
                        min: 10.0,
                        max: 24.0,
                        divisions: 28,
                        label: provider.font.baseSize.toStringAsFixed(1),
                        onChanged: (value) {
                          provider.setFontSize(value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: scheme.outline),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '预览',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aa 字',
                        style: TextStyle(
                          fontFamily: provider.font.family,
                          fontSize: provider.font.baseSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutSection(ConfigProvider provider, ColorScheme scheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.grid_view, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  '布局配置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('紧凑模式'),
              subtitle: Text(
                provider.layout.compactMode 
                    ? '使用更小的间距和侧边栏' 
                    : '使用标准间距和侧边栏',
              ),
              value: provider.layout.compactMode,
              onChanged: (_) => provider.toggleCompactMode(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '侧边栏宽度：${provider.layout.sidebarWidth.toInt()}px',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      Slider(
                        value: provider.layout.sidebarWidth,
                        min: 180.0,
                        max: 320.0,
                        divisions: 28,
                        label: '${provider.layout.sidebarWidth.toInt()}px',
                        onChanged: (value) {
                          provider.setLayout(LayoutConfig(
                            sidebarWidth: value,
                            compactMode: provider.layout.compactMode,
                            cardRadius: provider.layout.cardRadius,
                            contentPadding: provider.layout.contentPadding,
                          ));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '卡片圆角：${provider.layout.cardRadius.toInt()}px',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      Slider(
                        value: provider.layout.cardRadius,
                        min: 0.0,
                        max: 24.0,
                        divisions: 24,
                        label: '${provider.layout.cardRadius.toInt()}px',
                        onChanged: (value) {
                          provider.setLayout(LayoutConfig(
                            sidebarWidth: provider.layout.sidebarWidth,
                            compactMode: provider.layout.compactMode,
                            cardRadius: value,
                            contentPadding: provider.layout.contentPadding,
                          ));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorSection(ConfigProvider provider, ColorScheme scheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  '编辑器配置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('自动换行'),
              subtitle: const Text('长文本自动换行显示'),
              value: provider.editor.wordWrap,
              onChanged: (value) {
                provider.setEditor(EditorConfig(
                  fontSize: provider.editor.fontSize,
                  wordWrap: value,
                  lineNumbers: provider.editor.lineNumbers,
                  minimap: provider.editor.minimap,
                  tabSize: provider.editor.tabSize,
                  theme: provider.editor.theme,
                ));
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('显示行号'),
              subtitle: const Text('在代码编辑器中显示行号'),
              value: provider.editor.lineNumbers,
              onChanged: (value) {
                provider.setEditor(EditorConfig(
                  fontSize: provider.editor.fontSize,
                  wordWrap: provider.editor.wordWrap,
                  lineNumbers: value,
                  minimap: provider.editor.minimap,
                  tabSize: provider.editor.tabSize,
                  theme: provider.editor.theme,
                ));
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('缩略图'),
              subtitle: const Text('显示代码缩略图预览'),
              value: provider.editor.minimap,
              onChanged: (value) {
                provider.setEditor(EditorConfig(
                  fontSize: provider.editor.fontSize,
                  wordWrap: provider.editor.wordWrap,
                  lineNumbers: provider.editor.lineNumbers,
                  minimap: value,
                  tabSize: provider.editor.tabSize,
                  theme: provider.editor.theme,
                ));
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '编辑器字号：${provider.editor.fontSize}px',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      Slider(
                        value: provider.editor.fontSize.toDouble(),
                        min: 10.0,
                        max: 24.0,
                        divisions: 14,
                        label: '${provider.editor.fontSize}px',
                        onChanged: (value) {
                          provider.setEditor(EditorConfig(
                            fontSize: value.toInt(),
                            wordWrap: provider.editor.wordWrap,
                            lineNumbers: provider.editor.lineNumbers,
                            minimap: provider.editor.minimap,
                            tabSize: provider.editor.tabSize,
                            theme: provider.editor.theme,
                          ));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tab 缩进：${provider.editor.tabSize} 空格',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      Slider(
                        value: provider.editor.tabSize.toDouble(),
                        min: 2.0,
                        max: 8.0,
                        divisions: 6,
                        label: '${provider.editor.tabSize} 空格',
                        onChanged: (value) {
                          provider.setEditor(EditorConfig(
                            fontSize: provider.editor.fontSize,
                            wordWrap: provider.editor.wordWrap,
                            lineNumbers: provider.editor.lineNumbers,
                            minimap: provider.editor.minimap,
                            tabSize: value.toInt(),
                            theme: provider.editor.theme,
                          ));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolPrefsSection(ConfigProvider provider, ColorScheme scheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  '工具偏好',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('自动复制结果'),
              subtitle: const Text('操作完成后自动复制到剪贴板'),
              value: provider.toolPrefs.autoCopyResult,
              onChanged: (value) {
                provider.setToolPrefs(ToolPreferences(
                  autoCopyResult: value,
                  confirmClear: provider.toolPrefs.confirmClear,
                  maxHistoryItems: provider.toolPrefs.maxHistoryItems,
                  showTooltips: provider.toolPrefs.showTooltips,
                ));
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('清空前确认'),
              subtitle: const Text('清空输入输出前弹出确认对话框'),
              value: provider.toolPrefs.confirmClear,
              onChanged: (value) {
                provider.setToolPrefs(ToolPreferences(
                  autoCopyResult: provider.toolPrefs.autoCopyResult,
                  confirmClear: value,
                  maxHistoryItems: provider.toolPrefs.maxHistoryItems,
                  showTooltips: provider.toolPrefs.showTooltips,
                ));
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('显示工具提示'),
              subtitle: const Text('显示功能说明和提示信息'),
              value: provider.toolPrefs.showTooltips,
              onChanged: (value) {
                provider.setToolPrefs(ToolPreferences(
                  autoCopyResult: provider.toolPrefs.autoCopyResult,
                  confirmClear: provider.toolPrefs.confirmClear,
                  maxHistoryItems: provider.toolPrefs.maxHistoryItems,
                  showTooltips: value,
                ));
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '历史最大条目数：${provider.toolPrefs.maxHistoryItems}',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                      Slider(
                        value: provider.toolPrefs.maxHistoryItems.toDouble(),
                        min: 10.0,
                        max: 200.0,
                        divisions: 19,
                        label: provider.toolPrefs.maxHistoryItems.toString(),
                        onChanged: (value) {
                          provider.setToolPrefs(ToolPreferences(
                            autoCopyResult: provider.toolPrefs.autoCopyResult,
                            confirmClear: provider.toolPrefs.confirmClear,
                            maxHistoryItems: value.toInt(),
                            showTooltips: provider.toolPrefs.showTooltips,
                          ));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSection(ConfigProvider provider, ColorScheme scheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings_applications, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  '高级设置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('自动保存配置'),
              subtitle: const Text('配置变更后自动保存到本地'),
              value: provider.config.autoSave,
              onChanged: provider.setAutoSave,
            ),
            const SizedBox(height: 16),
            const Text(
              '导出路径',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: '默认导出路径',
                helperText: '用于设置文件导出和保存的默认目录',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.folder),
              ),
              onChanged: provider.setExportPath,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ConfigProvider provider, ColorScheme scheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (provider.hasUnsavedChanges)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.save, size: 16, color: scheme.onTertiaryContainer),
                const SizedBox(width: 4),
                Text(
                  '有未保存的更改',
                  style: TextStyle(
                    color: scheme.onTertiaryContainer,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const ConfigImportExportDialogEnhanced(),
            );
          },
          icon: const Icon(Icons.backup),
          label: const Text('导入/导出'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () async {
            final result = await provider.saveConfig();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text('配置已保存'),
                    ],
                  ),
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              );
            }
          },
          icon: const Icon(Icons.save),
          label: const Text('保存配置'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('确认重置'),
                content: const Text('确定要恢复为默认配置吗？此操作不可撤销。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('取消'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      provider.resetToDefaults();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.refresh, color: Colors.orange),
                              const SizedBox(width: 8),
                              const Text('已重置为默认配置'),
                            ],
                          ),
                          backgroundColor: scheme.surfaceContainerHighest,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('确认'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.restore),
          label: const Text('恢复默认'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ctf_tools/shared/providers/config/config_provider.dart';
import 'package:ctf_tools/shared/models/app_config.dart';

/// 预设配置组件 - 提供快速配置方案
class ConfigPresetsWidget extends StatelessWidget {
  const ConfigPresetsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final configProvider = context.watch<ConfigProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  '预设配置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              '快速应用预设的配置方案',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _PresetCard(
                  icon: Icons.comfortable,
                  title: '舒适阅读',
                  description: '大字体、宽间距，适合长时间阅读',
                  color: Colors.blue,
                  onTap: () => _applyPreset(context, configProvider, 'reading'),
                ),
                _PresetCard(
                  icon: Icons.speed,
                  title: '紧凑高效',
                  description: '小字体、紧凑布局，提高屏幕利用率',
                  color: Colors.green,
                  onTap: () => _applyPreset(context, configProvider, 'compact'),
                ),
                _PresetCard(
                  icon: Icons.code,
                  title: '开发者',
                  description: '等宽字体、显示行号，适合代码编辑',
                  color: Colors.purple,
                  onTap: () => _applyPreset(context, configProvider, 'developer'),
                ),
                _PresetCard(
                  icon: Icons.accessibility,
                  title: '无障碍',
                  description: '超大字体、高对比度，易于识别',
                  color: Colors.orange,
                  onTap: () => _applyPreset(context, configProvider, 'accessible'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _applyPreset(
    BuildContext context,
    ConfigProvider provider,
    String preset,
  ) {
    switch (preset) {
      case 'reading':
        provider.setFont(const FontConfig(
          name: '大号字体',
          family: 'MapleFont',
          baseSize: 18.0,
        ));
        provider.setLayout(const LayoutConfig(
          sidebarWidth: 260.0,
          compactMode: false,
          cardRadius: 16.0,
          contentPadding: 20.0,
        ));
        provider.setAutoSave(true);
        break;
        
      case 'compact':
        provider.setFont(const FontConfig(
          name: '默认',
          family: 'MapleFont',
          baseSize: 12.0,
        ));
        provider.setLayout(LayoutConfig.compactLayout);
        provider.setAutoSave(true);
        break;
        
      case 'developer':
        provider.setFont(const FontConfig(
          name: '等宽字体',
          family: 'monospace',
          baseSize: 13.0,
        ));
        provider.setEditor(const EditorConfig(
          fontSize: 13,
          wordWrap: false,
          lineNumbers: true,
          minimap: true,
          tabSize: 2,
          theme: 'default',
        ));
        break;
        
      case 'accessible':
        provider.setFont(const FontConfig(
          name: '大号字体',
          family: 'MapleFont',
          baseSize: 22.0,
        ));
        provider.setLayout(const LayoutConfig(
          sidebarWidth: 280.0,
          compactMode: false,
          cardRadius: 16.0,
          contentPadding: 24.0,
        ));
        provider.setToolPrefs(const ToolPreferences(
          autoCopyResult: true,
          confirmClear: true,
          maxHistoryItems: 100,
          showTooltips: true,
        ));
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text('已应用 ${_presetNames[preset]} 配置'),
          ],
        ),
        backgroundColor: scheme.surfaceContainerHighest,
      ),
    );
  }

  static const Map<String, String> _presetNames = {
    'reading': '舒适阅读',
    'compact': '紧凑高效',
    'developer': '开发者',
    'accessible': '无障碍',
  };
}

class _PresetCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _PresetCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

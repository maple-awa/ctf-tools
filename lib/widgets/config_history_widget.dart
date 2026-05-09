import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ctf_tools/shared/providers/config/config_provider.dart';
import 'package:ctf_tools/shared/models/app_config.dart';
import 'package:intl/intl.dart';

/// 配置历史组件 - 追踪配置变更历史
class ConfigHistoryWidget extends StatefulWidget {
  const ConfigHistoryWidget({super.key});

  @override
  State<ConfigHistoryWidget> createState() => _ConfigHistoryWidgetState();
}

class _ConfigHistoryWidgetState extends State<ConfigHistoryWidget> {
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // TODO: 从本地存储加载历史记录
    setState(() {
      _history = [
        {
          'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
          'action': '修改字体大小',
          'detail': '14.0 → 16.0',
        },
        {
          'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
          'action': '切换紧凑模式',
          'detail': '关闭 → 开启',
        },
        {
          'timestamp': DateTime.now().subtract(const Duration(days: 1)),
          'action': '导入配置',
          'detail': '从备份恢复',
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  '配置历史',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _history.clear();
                    });
                  },
                  icon: const Icon(Icons.delete_sweep, size: 16),
                  label: const Text('清空'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_history.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.history_toggle_off, size: 48, color: scheme.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        '暂无配置历史记录',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _history.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = _history[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: scheme.primaryContainer,
                      radius: 20,
                      child: Icon(
                        _getActionIcon(item['action'] as String),
                        color: scheme.onPrimaryContainer,
                        size: 20,
                      ),
                    ),
                    title: Text(item['action'] as String),
                    subtitle: Text(item['detail'] as String),
                    trailing: Text(
                      _formatTime(item['timestamp'] as DateTime),
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  IconData _getActionIcon(String action) {
    if (action.contains('字体')) return Icons.font_download;
    if (action.contains('布局')) return Icons.grid_view;
    if (action.contains('编辑器')) return Icons.code;
    if (action.contains('导入')) return Icons.import_contacts;
    if (action.contains('导出')) return Icons.export;
    return Icons.settings;
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return DateFormat('MM-dd HH:mm').format(time);
    }
  }
}

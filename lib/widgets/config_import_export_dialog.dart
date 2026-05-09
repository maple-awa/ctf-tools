import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ctf_tools/shared/providers/config/config_provider.dart';

/// 配置导入/导出对话框
class ConfigImportExportDialog extends StatefulWidget {
  const ConfigImportExportDialog({super.key});

  @override
  State<ConfigImportExportDialog> createState() => _ConfigImportExportDialogState();
}

class _ConfigImportExportDialogState extends State<ConfigImportExportDialog> {
  final TextEditingController _importController = TextEditingController();
  bool _showImport = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final configProvider = context.watch<ConfigProvider>();

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.settings_backup_restore, color: scheme.primary),
          const SizedBox(width: 8),
          const Text('配置管理'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_showImport) ...[
                Card(
                  child: ListTile(
                    leading: Icon(Icons.export, color: scheme.primary),
                    title: const Text('导出配置'),
                    subtitle: Text(
                      '将当前配置导出为 JSON 字符串',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () {
                        final json = configProvider.exportConfig();
                        Clipboard.setData(ClipboardData(text: json));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('配置已复制到剪贴板')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('复制'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.import_contacts, color: scheme.primary),
                    title: const Text('导入配置'),
                    subtitle: Text(
                      '从 JSON 字符串导入配置',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _showImport = true;
                        });
                      },
                      icon: const Icon(Icons.file_upload),
                      label: const Text('导入'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: scheme.surfaceContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '当前配置状态',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('字体', configProvider.font.name, scheme),
                        _buildInfoRow('字号', configProvider.font.baseSize.toStringAsFixed(1), scheme),
                        _buildInfoRow(
                          '布局',
                          configProvider.layout.compactMode ? '紧凑' : '标准',
                          scheme,
                        ),
                        _buildInfoRow(
                          '自动保存',
                          configProvider.config.autoSave ? '开启' : '关闭',
                          scheme,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _importController,
                  decoration: const InputDecoration(
                    labelText: '粘贴配置 JSON',
                    border: OutlineInputBorder(),
                    helperText: '粘贴之前导出的配置字符串',
                  ),
                  maxLines: 10,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showImport = false;
                        });
                      },
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        try {
                          configProvider.importConfig(_importController.text);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('配置导入成功'),
                                ],
                              ),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.error, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text('导入失败：${e.toString()}'),
                                ],
                              ),
                              backgroundColor: Colors.red.shade100,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.file_download),
                      label: const Text('确认导入'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('关闭'),
        ),
      ],
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: TextStyle(
              color: scheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }
}

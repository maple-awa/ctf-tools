import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ctf_tools/shared/providers/config/config_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

/// 增强版配置导入导出对话框
class ConfigImportExportDialogEnhanced extends StatefulWidget {
  const ConfigImportExportDialogEnhanced({super.key});

  @override
  State<ConfigImportExportDialogEnhanced> createState() =>
      _ConfigImportExportDialogEnhancedState();
}

class _ConfigImportExportDialogEnhancedState
    extends State<ConfigImportExportDialogEnhanced> {
  final TextEditingController _importController = TextEditingController();
  bool _showImport = false;
  String _exportMode = 'standard'; // standard, withMetadata, pretty
  bool _isExporting = false;
  bool _isValidating = false;
  String? _validationResult;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final configProvider = context.watch<ConfigProvider>();

    return Dialog(
      child: Container(
        width: 700,
        height: 600,
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.settings_backup_restore, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '配置管理',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (configProvider.hasUnsavedChanges)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.save, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            '未保存',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // 主体内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_showImport) ...[
                      // 导出选项卡
                      _buildExportSection(configProvider, scheme),
                      const SizedBox(height: 16),
                      // 导入选项卡
                      _buildImportCard(scheme),
                      const SizedBox(height: 16),
                      // 配置信息
                      _buildConfigInfo(configProvider, scheme),
                    ] else ...[
                      // 导入界面
                      _buildImportInterface(scheme),
                    ],
                  ],
                ),
              ),
            ),

            // 底部操作栏
            _buildBottomBar(configProvider, scheme),
          ],
        ),
      ),
    );
  }

  Widget _buildExportSection(
    ConfigProvider configProvider,
    ColorScheme scheme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.file_upload, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  '导出配置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 导出模式选择
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'standard',
                  label: Text('标准'),
                  icon: Icon(Icons.description),
                ),
                ButtonSegment(
                  value: 'pretty',
                  label: Text('格式化'),
                  icon: Icon(Icons.format_indent_increase),
                ),
                ButtonSegment(
                  value: 'metadata',
                  label: Text('带元数据'),
                  icon: Icon(Icons.info),
                ),
              ],
              selected: {_exportMode},
              onSelectionChanged: (Set<String> selection) {
                setState(() => _exportMode = selection.first);
              },
            ),
            const SizedBox(height: 16),
            // 导出预览
            if (_isExporting)
              const Center(child: CircularProgressIndicator())
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: scheme.outline),
                ),
                height: 200,
                child: SingleChildScrollView(
                  child: Text(
                    _generateExportPreview(configProvider),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // 导出按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final json = _generateExportPreview(configProvider);
                    await Clipboard.setData(ClipboardData(text: json));
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('已复制到剪贴板'),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('复制'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _isExporting
                      ? null
                      : () async {
                          setState(() => _isExporting = true);
                          await Future.delayed(
                            const Duration(milliseconds: 100),
                          );

                          String json;
                          switch (_exportMode) {
                            case 'metadata':
                              json = configProvider.exportConfigWithMetadata();
                              break;
                            case 'pretty':
                              json = configProvider.exportConfig(
                                prettyPrint: true,
                              );
                              break;
                            default:
                              json = configProvider.exportConfig(
                                prettyPrint: false,
                              );
                          }

                          try {
                            final path = await FilePicker.platform.saveFile(
                              dialogTitle: '保存配置',
                              fileName:
                                  'ctf_tools_config_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json',
                              bytes: null,
                            );

                            if (path != null) {
                              await File(path).writeAsString(json);
                              // 保存到文件
                              // TODO: 实现文件写入
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                        ),
                                        const SizedBox(width: 8),
                                        Text('已保存到：$path'),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Text('保存失败：${e.toString()}'),
                                    ],
                                  ),
                                  backgroundColor: Colors.red.shade100,
                                ),
                              );
                            }
                          }

                          setState(() => _isExporting = false);
                        },
                  icon: const Icon(Icons.save),
                  label: const Text('保存到文件'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportCard(ColorScheme scheme) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.import_contacts, color: scheme.primary),
        title: const Text('导入配置'),
        subtitle: Text(
          '从 JSON 字符串或文件导入配置',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        trailing: ElevatedButton.icon(
          onPressed: () {
            setState(() => _showImport = true);
          },
          icon: const Icon(Icons.file_upload),
          label: const Text('导入'),
        ),
      ),
    );
  }

  Widget _buildConfigInfo(ConfigProvider configProvider, ColorScheme scheme) {
    return Card(
      color: scheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '当前配置状态',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: scheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () async {
                    setState(() => _isValidating = true);
                    await Future.delayed(const Duration(milliseconds: 100));

                    final result = configProvider.validateConfig();
                    setState(() {
                      _isValidating = false;
                      _validationResult = result.isValid
                          ? '✓ 配置验证通过'
                          : '✗ ${result.errors.join(', ')}';
                    });
                  },
                  icon: _isValidating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified),
                  label: const Text('验证配置'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow('字体', configProvider.font.name, scheme),
            _buildInfoRow(
              '字号',
              configProvider.font.baseSize.toStringAsFixed(1),
              scheme,
            ),
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
            _buildInfoRow(
              '编辑器字号',
              '${configProvider.editor.fontSize}px',
              scheme,
            ),
            if (_validationResult != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _validationResult!.startsWith('✓')
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      _validationResult!.startsWith('✓')
                          ? Icons.check_circle
                          : Icons.error,
                      color: _validationResult!.startsWith('✓')
                          ? Colors.green
                          : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationResult!,
                        style: TextStyle(
                          color: _validationResult!.startsWith('✓')
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImportInterface(ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _importController,
          decoration: InputDecoration(
            labelText: '粘贴配置 JSON',
            border: const OutlineInputBorder(),
            helperText: '粘贴之前导出的配置字符串，或从文件导入',
            prefixIcon: const Icon(Icons.paste),
          ),
          maxLines: 15,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                      );

                  if (result != null && result.files.single.path != null) {
                    // TODO: 读取文件内容
                    setState(() {
                      _importController.text =
                          '[文件路径：${result.files.single.path}]';
                    });
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('选择文件失败：${e.toString()}'),
                          ],
                        ),
                        backgroundColor: Colors.red.shade100,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('从文件导入'),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    setState(() => _showImport = false);
                  },
                  child: const Text('取消'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final configProvider = context.read<ConfigProvider>();
                    final result = await configProvider.importConfig(
                      _importController.text,
                    );

                    if (!mounted) return;

                    Navigator.of(context).pop();

                    if (result.success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              const Text('配置导入成功'),
                            ],
                          ),
                          action: SnackBarAction(
                            label: '保存',
                            onPressed: () => configProvider.saveConfig(),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.error, color: Colors.red),
                              const SizedBox(width: 8),
                              Text('导入失败：${result.error}'),
                            ],
                          ),
                          backgroundColor: Colors.red.shade100,
                          action: SnackBarAction(
                            label: '重试',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    const ConfigImportExportDialogEnhanced(),
                              );
                            },
                          ),
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
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
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

  Widget _buildBottomBar(ConfigProvider configProvider, ColorScheme scheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('关闭'),
          ),
          const SizedBox(width: 8),
          if (configProvider.hasUnsavedChanges)
            ElevatedButton.icon(
              onPressed: () async {
                await configProvider.saveConfig();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text('配置已保存'),
                        ],
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('保存配置'),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
            ),
        ],
      ),
    );
  }

  String _generateExportPreview(ConfigProvider configProvider) {
    switch (_exportMode) {
      case 'metadata':
        return configProvider.exportConfigWithMetadata();
      case 'pretty':
        return configProvider.exportConfig(prettyPrint: true);
      default:
        return configProvider.exportConfig(prettyPrint: false);
    }
  }

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }
}

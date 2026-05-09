import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ctf_tools/shared/providers/config/config_provider.dart';
import 'package:ctf_tools/shared/utils/system_font_scanner.dart';
import 'package:file_picker/file_picker.dart';

/// 系统字体选择对话框
class SystemFontPickerDialog extends StatefulWidget {
  const SystemFontPickerDialog({super.key});

  @override
  State<SystemFontPickerDialog> createState() => _SystemFontPickerDialogState();
}

class _SystemFontPickerDialogState extends State<SystemFontPickerDialog>
    with SingleTickerProviderStateMixin {
  List<SystemFontInfo> _fonts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'chinese';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFonts();
  }

  Future<void> _loadFonts() async {
    setState(() => _isLoading = true);

    List<SystemFontInfo> fonts;
    switch (_selectedCategory) {
      case 'chinese':
        fonts = SystemFontScanner.getCommonChineseFonts();
        break;
      case 'english':
        fonts = SystemFontScanner.getCommonEnglishFonts();
        break;
      case 'monospace':
        fonts = SystemFontScanner.getCommonMonospaceFonts();
        break;
      default:
        fonts = await SystemFontScanner.scanSystemFonts();
    }

    setState(() {
      _fonts = fonts;
      _isLoading = false;
    });
  }

  List<SystemFontInfo> get _filteredFonts {
    if (_searchQuery.isEmpty) return _fonts;
    return _fonts
        .where((font) =>
            font.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _pickCustomFont() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ttf', 'otf', 'ttc'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final name = result.files.single.name;
        if (mounted) {
          context.read<ConfigProvider>().setCustomFont(path, name);
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text('已选择自定义字体：$name'),
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
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Text('选择字体失败：${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red.shade100,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final configProvider = context.watch<ConfigProvider>();

    return Dialog(
      child: Container(
        width: 600,
        height: 500,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
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
                  Icon(Icons.font_download, color: scheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '选择字体',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.folder_open),
                    tooltip: '选择自定义字体文件',
                    onPressed: _pickCustomFont,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // 搜索栏
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '搜索字体...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: scheme.surfaceContainer,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),

            // 分类标签
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.translate), text: '中文'),
                Tab(icon: Icon(Icons.text_fields), text: '英文'),
                Tab(icon: Icon(Icons.code), text: '等宽'),
              ],
              onTap: (index) {
                final categories = ['chinese', 'english', 'monospace'];
                setState(() => _selectedCategory = categories[index]);
                _loadFonts();
              },
            ),

            // 字体列表
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredFonts.length,
                      itemBuilder: (context, index) {
                        final font = _filteredFonts[index];
                        final isSelected =
                            configProvider.font.family == font.family;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isSelected
                              ? scheme.primaryContainer
                              : scheme.surfaceContainer,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(
                              font.name,
                              style: TextStyle(
                                fontFamily: font.family.isEmpty
                                    ? null
                                    : font.family,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              font.family.isEmpty
                                  ? '系统默认'
                                  : font.family,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: scheme.primary,
                                  )
                                : null,
                            onTap: () {
                              if (font.family.isEmpty) {
                                configProvider.setSystemFont('', '系统默认');
                              } else {
                                configProvider.setSystemFont(
                                    font.family, font.name);
                              }
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.green),
                                      const SizedBox(width: 8),
                                      Text('已选择：${font.name}'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),

            // 底部信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '共找到 ${_filteredFonts.length} 个字体',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ctf_tools/shared/models/app_config.dart';

/// 应用配置提供者 - 管理所有本地化配置
class ConfigProvider with ChangeNotifier {
  AppConfig _config = AppConfig.defaultConfig;
  bool _isLoaded = false;
  bool _hasUnsavedChanges = false;
  final List<ConfigHistoryItem> _history = [];

  AppConfig get config => _config;
  bool get isLoaded => _isLoaded;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  List<ConfigHistoryItem> get history => List.unmodifiable(_history);

  // 快捷访问
  FontConfig get font => _config.font;
  LayoutConfig get layout => _config.layout;
  EditorConfig get editor => _config.editor;
  ToolPreferences get toolPrefs => _config.toolPrefs;
  UIConfig get uiConfig => _config.uiConfig;
  String get language => _config.language;

  /// 加载配置
  Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('app_config');

      if (configJson != null) {
        final decoded = jsonDecode(configJson) as Map<String, dynamic>;
        _config = AppConfig.fromJson(decoded);
        _addHistory('加载配置', '从本地存储加载');
      } else {
        _addHistory('初始化配置', '使用默认配置');
      }

      // 加载历史记录
      await _loadHistory();

      _isLoaded = true;
      _hasUnsavedChanges = false;
      notifyListeners();
      debugPrint('配置加载成功');
    } catch (e) {
      debugPrint('加载配置失败：$e');
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// 加载历史记录
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('config_history');
      if (historyJson != null) {
        _history.clear();
        for (final item in historyJson) {
          final decoded = jsonDecode(item) as Map<String, dynamic>;
          _history.add(ConfigHistoryItem.fromJson(decoded));
        }
      }
    } catch (e) {
      debugPrint('加载历史记录失败：$e');
    }
  }

  /// 保存历史记录
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _history
          .take(100) // 最多保存 100 条
          .map((item) => jsonEncode(item.toJson()))
          .toList();
      await prefs.setStringList('config_history', historyJson);
    } catch (e) {
      debugPrint('保存历史记录失败：$e');
    }
  }

  /// 添加历史记录
  void _addHistory(String action, String detail) {
    final item = ConfigHistoryItem(
      timestamp: DateTime.now(),
      action: action,
      detail: detail,
    );
    _history.insert(0, item);
    _saveHistory();
  }

  /// 保存配置
  Future<void> saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configCopy = _config.copyWith(
        lastModified: DateTime.now(),
      );
      final configJson = jsonEncode(configCopy.toJson());
      await prefs.setString('app_config', configJson);
      _hasUnsavedChanges = false;
      _addHistory('保存配置', '配置已保存到本地');
      notifyListeners();
      debugPrint('配置已保存');
    } catch (e) {
      debugPrint('保存配置失败：$e');
    }
  }

  /// 自动保存
  Future<void> autoSave() async {
    if (_config.autoSave && _hasUnsavedChanges) {
      await saveConfig();
    }
  }

  /// 更新语言
  void setLanguage(String language) {
    _config = _config.copyWith(language: language);
    _hasUnsavedChanges = true;
    _addHistory('修改语言', '设置为：$language');
    notifyListeners();
  }

  /// 更新字体配置
  void setFont(FontConfig font) {
    _config = _config.copyWith(font: font);
    _hasUnsavedChanges = true;
    _addHistory('修改字体', '设置为：${font.name} (${font.baseSize}px)');
    notifyListeners();
  }

  /// 更新字体大小
  void setFontSize(double baseSize) {
    _config = _config.copyWith(
      font: _config.font.copyWith(baseSize: baseSize),
    );
    _hasUnsavedChanges = true;
    _addHistory('修改字号', '${_config.font.baseSize.toStringAsFixed(1)} → ${baseSize.toStringAsFixed(1)}');
    notifyListeners();
  }

  /// 设置系统字体
  void setSystemFont(String family, String name) {
    _config = _config.copyWith(
      font: _config.font.copyWith(
        family: family,
        name: name,
        isSystemFont: true,
      ),
    );
    _hasUnsavedChanges = true;
    _addHistory('设置系统字体', name);
    notifyListeners();
  }

  /// 选择自定义字体文件
  void setCustomFont(String path, String name) {
    _config = _config.copyWith(
      font: _config.font.copyWith(
        family: name,
        name: name,
        customPath: path,
        isSystemFont: false,
      ),
    );
    _hasUnsavedChanges = true;
    _addHistory('设置自定义字体', name);
    notifyListeners();
  }

  /// 更新布局配置
  void setLayout(LayoutConfig layout) {
    _config = _config.copyWith(layout: layout);
    _hasUnsavedChanges = true;
    _addHistory('修改布局', layout.compactMode ? '紧凑模式' : '标准模式');
    notifyListeners();
  }

  /// 切换紧凑模式
  void toggleCompactMode() {
    final newLayout = _config.layout.compactMode
        ? LayoutConfig.defaultLayout
        : LayoutConfig.compactLayout;
    setLayout(newLayout);
  }

  /// 更新编辑器配置
  void setEditor(EditorConfig editor) {
    _config = _config.copyWith(editor: editor);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  /// 更新工具偏好
  void setToolPrefs(ToolPreferences prefs) {
    _config = _config.copyWith(toolPrefs: prefs);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  /// 更新界面配置
  void setUIConfig(UIConfig config) {
    _config = _config.copyWith(uiConfig: config);
    _hasUnsavedChanges = true;
    _addHistory('修改界面配置', '缩放比例：${config.scaleFactor}');
    notifyListeners();
  }

  /// 设置自动保存
  void setAutoSave(bool value) {
    _config = _config.copyWith(autoSave: value);
    _hasUnsavedChanges = true;
    _addHistory('自动保存', value ? '开启' : '关闭');
    notifyListeners();
  }

  /// 设置导出路径
  void setExportPath(String path) {
    _config = _config.copyWith(exportPath: path);
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  /// 重置为默认配置
  void resetToDefaults() {
    _config = AppConfig.defaultConfig;
    _hasUnsavedChanges = true;
    _addHistory('重置配置', '已恢复为默认配置');
    notifyListeners();
  }

  /// 导入配置 (增强版)
  Future<ImportResult> importConfig(String jsonStr) async {
    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      // 验证配置版本
      final version = decoded['configVersion'] as String? ?? '1.0.0';
      if (!_isCompatibleVersion(version)) {
        return ImportResult(
          success: false,
          error: '配置版本不兼容：$version',
        );
      }

      // 验证必要字段
      if (!decoded.containsKey('font') ||
          !decoded.containsKey('layout') ||
          !decoded.containsKey('editor')) {
        return ImportResult(
          success: false,
          error: '配置文件格式不完整',
        );
      }

      _config = AppConfig.fromJson(decoded);
      _hasUnsavedChanges = true;
      _addHistory('导入配置', '从 JSON 导入配置');

      notifyListeners();
      return ImportResult(success: true);
    } catch (e) {
      return ImportResult(
        success: false,
        error: '解析失败：${e.toString()}',
      );
    }
  }

  /// 检查版本兼容性
  bool _isCompatibleVersion(String version) {
    // 简单的版本兼容性检查
    final majorVersion = version.split('.').first;
    return majorVersion == '1';
  }

  /// 导出配置 (增强版)
  String exportConfig({bool prettyPrint = true}) {
    if (prettyPrint) {
      return const JsonEncoder.withIndent('  ').convert(_config.toJson());
    }
    return jsonEncode(_config.toJson());
  }

  /// 导出配置到文件 (带元数据)
  String exportConfigWithMetadata() {
    final metadata = {
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': '1.4.0',
      'platform': 'cross-platform',
      'config': _config.toJson(),
    };
    return const JsonEncoder.withIndent('  ').convert(metadata);
  }

  /// 导入带元数据的配置
  Future<ImportResult> importConfigWithMetadata(String jsonStr) async {
    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      if (decoded.containsKey('config')) {
        final configData = decoded['config'] as Map<String, dynamic>;
        return await importConfig(jsonEncode(configData));
      } else {
        return await importConfig(jsonStr);
      }
    } catch (e) {
      return ImportResult(
        success: false,
        error: '解析失败：${e.toString()}',
      );
    }
  }

  /// 批量导入配置 (合并模式)
  Future<ImportResult> importConfigMerge(String jsonStr) async {
    try {
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      final importedConfig = AppConfig.fromJson(decoded);

      // 合并配置，保留当前设置中未导入的部分
      _config = _config.copyWith(
        font: importedConfig.font,
        layout: importedConfig.layout,
        editor: importedConfig.editor,
        toolPrefs: importedConfig.toolPrefs,
      );
      _hasUnsavedChanges = true;
      _addHistory('合并配置', '从 JSON 导入并合并');

      notifyListeners();
      return ImportResult(success: true);
    } catch (e) {
      return ImportResult(
        success: false,
        error: '合并失败：${e.toString()}',
      );
    }
  }

  /// 清除历史记录
  Future<void> clearHistory() async {
    _history.clear();
    await _saveHistory();
    _addHistory('清空历史', '配置历史已清空');
    notifyListeners();
  }

  /// 验证配置
  ValidationResult validateConfig() {
    final errors = <String>[];

    // 验证字体
    if (_config.font.baseSize < 8.0 || _config.font.baseSize > 72.0) {
      errors.add('字体大小超出有效范围 (8-72)');
    }

    // 验证布局
    if (_config.layout.sidebarWidth < 150.0 ||
        _config.layout.sidebarWidth > 500.0) {
      errors.add('侧边栏宽度超出有效范围 (150-500)');
    }

    // 验证编辑器
    if (_config.editor.fontSize < 8 || _config.editor.fontSize > 48) {
      errors.add('编辑器字号超出有效范围 (8-48)');
    }

    // 验证工具偏好
    if (_config.toolPrefs.maxHistoryItems < 0 ||
        _config.toolPrefs.maxHistoryItems > 1000) {
      errors.add('历史条目数超出有效范围 (0-1000)');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
    );
  }
}

/// 配置历史记录项
class ConfigHistoryItem {
  final DateTime timestamp;
  final String action;
  final String detail;

  const ConfigHistoryItem({
    required this.timestamp,
    required this.action,
    required this.detail,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'action': action,
      'detail': detail,
    };
  }

  factory ConfigHistoryItem.fromJson(Map<String, dynamic> json) {
    return ConfigHistoryItem(
      timestamp: DateTime.parse(json['timestamp'] as String),
      action: json['action'] as String,
      detail: json['detail'] as String,
    );
  }
}

/// 导入结果
class ImportResult {
  final bool success;
  final String? error;

  const ImportResult({
    required this.success,
    this.error,
  });
}

/// 验证结果
class ValidationResult {
  final bool isValid;
  final List<String> errors;

  const ValidationResult({
    required this.isValid,
    required this.errors,
  });
}

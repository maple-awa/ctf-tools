import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 系统字体扫描器 - 扫描并获取系统可用字体
class SystemFontScanner {
  static const List<String> _systemFontExtensions = [
    '.ttf',
    '.otf',
    '.ttc',
  ];

  /// 获取系统字体目录
  static List<String> getSystemFontDirectories() {
    final directories = <String>[];
    
    if (Platform.isWindows) {
      directories.add(r'C:\Windows\Fonts');
    } else if (Platform.isMacOS) {
      directories.add('/Library/Fonts');
      directories.add('/System/Library/Fonts');
      directories.add('${Platform.environment['HOME']}/Library/Fonts');
    } else if (Platform.isLinux) {
      directories.add('/usr/share/fonts');
      directories.add('/usr/local/share/fonts');
      directories.add('${Platform.environment['HOME']}/.fonts');
      directories.add('${Platform.environment['HOME']}/.local/share/fonts');
    } else if (Platform.isAndroid) {
      directories.add('/system/fonts');
    } else if (Platform.isIOS) {
      // iOS 不允许访问系统字体目录
    }
    
    return directories;
  }

  /// 扫描系统字体
  static Future<List<SystemFontInfo>> scanSystemFonts() async {
    final fonts = <SystemFontInfo>[];
    
    try {
      for (final dirPath in getSystemFontDirectories()) {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          await for (final entity in dir.list(recursive: true)) {
            if (entity is File) {
              final ext = entity.path.split('.').last.toLowerCase();
              if (_systemFontExtensions.contains('.$ext')) {
                final fontName = _extractFontName(entity.path);
                fonts.add(SystemFontInfo(
                  name: fontName,
                  path: entity.path,
                  family: fontName,
                ));
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('扫描系统字体失败：$e');
    }
    
    // 添加默认字体
    fonts.insert(0, const SystemFontInfo(
      name: '系统默认',
      path: '',
      family: '',
    ));
    
    // 去重
    final uniqueFonts = fonts.fold<List<SystemFontInfo>>([], (previous, element) {
      if (!previous.any((f) => f.family == element.family)) {
        previous.add(element);
      }
      return previous;
    });
    
    return uniqueFonts;
  }

  /// 从路径提取字体名称
  static String _extractFontName(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    final nameWithoutExt = fileName.split('.').first;
    return nameWithoutExt
        .replaceAll(RegExp(r'[-_]'), ' ')
        .split(' ')
        .map((word) => 
          word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  /// 获取常用中文字体
  static List<SystemFontInfo> getCommonChineseFonts() {
    return [
      const SystemFontInfo(name: '系统默认', path: '', family: ''),
      const SystemFontInfo(name: '思源黑体', path: '', family: 'Noto Sans SC'),
      const SystemFontInfo(name: '思源宋体', path: '', family: 'Noto Serif SC'),
      const SystemFontInfo(name: '微软雅黑', path: '', family: 'Microsoft YaHei'),
      const SystemFontInfo(name: '宋体', path: '', family: 'SimSun'),
      const SystemFontInfo(name: '黑体', path: '', family: 'SimHei'),
      const SystemFontInfo(name: '楷体', path: '', family: 'KaiTi'),
      const SystemFontInfo(name: '仿宋', path: '', family: 'FangSong'),
      const SystemFontInfo(name: '华文黑体', path: '', family: 'STHeiti'),
      const SystemFontInfo(name: '华文宋体', path: '', family: 'STSong'),
      const SystemFontInfo(name: '幼圆', path: '', family: 'YouYuan'),
      const SystemFontInfo(name: '隶书', path: '', family: 'LiSu'),
    ];
  }

  /// 获取常用英文字体
  static List<SystemFontInfo> getCommonEnglishFonts() {
    return [
      const SystemFontInfo(name: 'System Default', path: '', family: ''),
      const SystemFontInfo(name: 'Arial', path: '', family: 'Arial'),
      const SystemFontInfo(name: 'Helvetica', path: '', family: 'Helvetica'),
      const SystemFontInfo(name: 'Times New Roman', path: '', family: 'Times New Roman'),
      const SystemFontInfo(name: 'Courier New', path: '', family: 'Courier New'),
      const SystemFontInfo(name: 'Verdana', path: '', family: 'Verdana'),
      const SystemFontInfo(name: 'Georgia', path: '', family: 'Georgia'),
      const SystemFontInfo(name: 'Palatino', path: '', family: 'Palatino'),
      const SystemFontInfo(name: 'Garamond', path: '', family: 'Garamond'),
      const SystemFontInfo(name: 'Bookman', path: '', family: 'Bookman'),
      const SystemFontInfo(name: 'Comic Sans MS', path: '', family: 'Comic Sans MS'),
      const SystemFontInfo(name: 'Trebuchet MS', path: '', family: 'Trebuchet MS'),
      const SystemFontInfo(name: 'Arial Black', path: '', family: 'Arial Black'),
      const SystemFontInfo(name: 'Impact', path: '', family: 'Impact'),
    ];
  }

  /// 获取常用等宽字体 (适合代码编辑)
  static List<SystemFontInfo> getCommonMonospaceFonts() {
    return [
      const SystemFontInfo(name: 'System Mono', path: '', family: ''),
      const SystemFontInfo(name: 'Consolas', path: '', family: 'Consolas'),
      const SystemFontInfo(name: 'Monaco', path: '', family: 'Monaco'),
      const SystemFontInfo(name: 'Menlo', path: '', family: 'Menlo'),
      const SystemFontInfo(name: 'Courier New', path: '', family: 'Courier New'),
      const SystemFontInfo(name: 'Source Code Pro', path: '', family: 'Source Code Pro'),
      const SystemFontInfo(name: 'Fira Code', path: '', family: 'Fira Code'),
      const SystemFontInfo(name: 'JetBrains Mono', path: '', family: 'JetBrains Mono'),
      const SystemFontInfo(name: 'Inconsolata', path: '', family: 'Inconsolata'),
      const SystemFontInfo(name: 'DejaVu Sans Mono', path: '', family: 'DejaVu Sans Mono'),
    ];
  }
}

/// 系统字体信息
class SystemFontInfo {
  final String name;
  final String path;
  final String family;

  const SystemFontInfo({
    required this.name,
    required this.path,
    required this.family,
  });

  @override
  String toString() => name;
}

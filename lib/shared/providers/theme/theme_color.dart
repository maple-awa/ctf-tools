import 'package:flutter/material.dart';

/// 主题色对（亮色/暗色）定义。
class ThemeColor {
  /// 主题名称。
  final String name;

  /// 亮色模式主色。
  final Color light;

  /// 暗色模式主色。
  final Color dark;

  const ThemeColor({
    required this.name,
    required this.light,
    required this.dark,
  });
}

/// 应用主题构建器。
class AppTheme {
  static const List<ThemeColor> colors = [
    ThemeColor(
      name: 'Ocean',
      light: Color(0xFF2F7DD1),
      dark: Color(0xFF6DA9FF),
    ),
    ThemeColor(
      name: 'Emerald',
      light: Color(0xFF158F6A),
      dark: Color(0xFF4DD3A6),
    ),
    ThemeColor(
      name: 'Indigo',
      light: Color(0xFF4B63D2),
      dark: Color(0xFF8FA2FF),
    ),
    ThemeColor(name: 'Teal', light: Color(0xFF0E8A90), dark: Color(0xFF47C9D1)),
    ThemeColor(
      name: 'Amber',
      light: Color(0xFFB97A12),
      dark: Color(0xFFFFC24D),
    ),
    ThemeColor(
      name: 'Coral',
      light: Color(0xFFBF5B47),
      dark: Color(0xFFFF9178),
    ),
    ThemeColor(
      name: 'Slate',
      light: Color(0xFF5A6C82),
      dark: Color(0xFF9FB3CC),
    ),
    ThemeColor(
      name: 'Crimson',
      light: Color(0xFFB2455A),
      dark: Color(0xFFFF8FA2),
    ),
  ];

  /// 创建一个亮色模式（Light Mode）的 ThemeData 主题。
  ///
  /// [primaryColor] 是用户选择的主色调（例如蓝色、红色等），
  /// 该颜色将作为应用的主要品牌色，用于 AppBar、按钮、高亮文本等。
  static ThemeData lightTheme(Color primaryColor) {
    final base = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );
    final scheme = base.copyWith(
      surface: const Color(0xFFF7F9FC),
      onSurface: const Color(0xFF1A2433),
      onSurfaceVariant: const Color(0xFF5B6778),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF1F4F9),
      surfaceContainer: const Color(0xFFEBEFF6),
      surfaceContainerHigh: const Color(0xFFE3E8F1),
      surfaceContainerHighest: const Color(0xFFDCE3EE),
      outlineVariant: const Color(0xFFD0D8E4),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'MapleFont',
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: scheme.onSurface),
        titleMedium: TextStyle(color: scheme.onSurface),
      ),
    );
  }

  /// 创建一个暗色模式（Dark Mode）的 ThemeData 主题。
  ///
  /// [primary] 为主色调，将应用到 AppBar 与颜色种子方案。
  static ThemeData darkTheme(Color primary) {
    final base = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    );
    final scheme = base.copyWith(
      surface: const Color(0xFF11161D),
      onSurface: const Color(0xFFE5ECF4),
      onSurfaceVariant: const Color(0xFFA7B3C4),
      surfaceContainerLowest: const Color(0xFF0C1117),
      surfaceContainerLow: const Color(0xFF161D26),
      surfaceContainer: const Color(0xFF1B2430),
      surfaceContainerHigh: const Color(0xFF212C3A),
      surfaceContainerHighest: const Color(0xFF273444),
      outlineVariant: const Color(0xFF334154),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'MapleFont',
      brightness: Brightness.dark,
      primaryColor: primary,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: scheme.onSurface),
        titleMedium: TextStyle(color: scheme.onSurface),
      ),
    );
  }
}

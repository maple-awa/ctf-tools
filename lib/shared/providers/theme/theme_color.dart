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
    ThemeColor(name: 'Blue',    light: Color(0xFFA7C7E7), dark: Color(0xFF6FA8DC)),
    ThemeColor(name: 'Rose',    light: Color(0xFFFFB3B3), dark: Color(0xFFFF8F8F)),
    ThemeColor(name: 'Mint',    light: Color(0xFFB5EAD7), dark: Color(0xFF88D4AB)),
    ThemeColor(name: 'Lavender',light: Color(0xFFD8BFD8), dark: Color(0xFFC8A2C8)),
    ThemeColor(name: 'Peach',   light: Color(0xFFFFDAB9), dark: Color(0xFFFFB97C)),
    ThemeColor(name: 'Sky',     light: Color(0xFFB0E0E6), dark: Color(0xFF87CEEB)),
  ];

  /// 创建一个亮色模式（Light Mode）的 ThemeData 主题。
  ///
  /// [primaryColor] 是用户选择的主色调（例如蓝色、红色等），
  /// 该颜色将作为应用的主要品牌色，用于 AppBar、按钮、高亮文本等。
  static ThemeData lightTheme(Color primaryColor) {
    return ThemeData(
      // 设置主题的整体亮度为“亮色模式”
      // 这会影响部分内置 widget 的默认行为（如 Switch、Slider）
      brightness: Brightness.light,

      // 设置主色调（Primary Color）
      // 虽然现代 Flutter 更推荐使用 colorScheme，但保留此字段可兼容旧组件
      primaryColor: primaryColor,

      // 设置 Scaffold 的背景色为纯白色
      // Scaffold 是大多数页面的根容器，其背景决定了页面底色
      scaffoldBackgroundColor: Colors.white,

      // 配置 AppBar（顶部导航栏）的样式
      appBarTheme: AppBarTheme(
        // AppBar 的背景色使用用户选择的主色调
        backgroundColor: primaryColor,
        // AppBar 上的文字和图标颜色设为白色，确保在彩色背景上清晰可见
        foregroundColor: Colors.white,
      ),

      // 使用 ColorScheme.fromSeed 自动生成一套协调的配色方案
      // 这是 Flutter 3.0+ 推荐的方式，能自动派生出 primary, secondary, surface 等颜色
      colorScheme: ColorScheme.fromSeed(
        // 以用户选择的颜色作为“种子色”（seed color）
        // 系统会基于此色智能生成一组和谐的辅助色
        seedColor: primaryColor,
        // 明确指定此 ColorScheme 用于亮色模式
        // 这样生成的 surface、background 等颜色会自动适配浅色背景
        brightness: Brightness.light,
      ),

      // 自定义文本样式（TextTheme）
      // 注意：在亮色模式下，文字应为深色以保证可读性
      textTheme: TextTheme(
        // bodyMedium 用于普通段落文本
        // 使用 Colors.black87（87% 不透明度的黑色），比纯黑更柔和，减少视觉疲劳
        bodyMedium: TextStyle(color: Colors.black87),
        // titleMedium 用于中等标题
        // 使用纯黑色以保持标题的醒目性
        titleMedium: TextStyle(color: Colors.black),
      ),
    );
  }

  /// 创建一个暗色模式（Dark Mode）的 ThemeData 主题。
  ///
  /// [primary] 为主色调，将应用到 AppBar 与颜色种子方案。
  static ThemeData darkTheme(Color primary) {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.grey[300]),
        titleMedium: TextStyle(color: Colors.white),
      ),
    );
  }
}

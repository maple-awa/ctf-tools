import 'package:flutter/material.dart';

/// 主题色对（亮色/暗色）定义。
class ThemeColor {
  final String name;
  final Color light;
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
    ThemeColor(name: 'Ocean', light: Color(0xFF2F7DD1), dark: Color(0xFF6DA9FF)),
    ThemeColor(
      name: 'Emerald',
      light: Color(0xFF158F6A),
      dark: Color(0xFF4DD3A6),
    ),
    ThemeColor(name: 'Indigo', light: Color(0xFF4B63D2), dark: Color(0xFF8FA2FF)),
    ThemeColor(name: 'Teal', light: Color(0xFF0E8A90), dark: Color(0xFF47C9D1)),
    ThemeColor(name: 'Amber', light: Color(0xFFB97A12), dark: Color(0xFFFFC24D)),
    ThemeColor(name: 'Coral', light: Color(0xFFBF5B47), dark: Color(0xFFFF9178)),
    ThemeColor(name: 'Slate', light: Color(0xFF5A6C82), dark: Color(0xFF9FB3CC)),
    ThemeColor(name: 'Crimson', light: Color(0xFFB2455A), dark: Color(0xFFFF8FA2)),
  ];

  static ThemeData lightTheme(Color primaryColor) {
    final base = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );
    final scheme = base.copyWith(
      surface: const Color(0xFFF8FAFD),
      surfaceDim: const Color(0xFFD9E0EA),
      surfaceBright: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF16202C),
      onSurfaceVariant: const Color(0xFF566273),
      surfaceContainerLowest: const Color(0xFFFFFFFF),
      surfaceContainerLow: const Color(0xFFF2F5FA),
      surfaceContainer: const Color(0xFFEBEFF5),
      surfaceContainerHigh: const Color(0xFFE4EAF2),
      surfaceContainerHighest: const Color(0xFFDDE5EF),
      outlineVariant: const Color(0xFFD3DBE6),
      shadow: const Color(0x1A000000),
    );
    return _buildTheme(scheme, Brightness.light, primaryColor);
  }

  static ThemeData darkTheme(Color primaryColor) {
    final base = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    );
    final scheme = base.copyWith(
      surface: const Color(0xFF10151C),
      surfaceDim: const Color(0xFF0A0F14),
      surfaceBright: const Color(0xFF2E3948),
      onSurface: const Color(0xFFE6EDF5),
      onSurfaceVariant: const Color(0xFFA6B3C5),
      surfaceContainerLowest: const Color(0xFF0B1016),
      surfaceContainerLow: const Color(0xFF151C24),
      surfaceContainer: const Color(0xFF1B2430),
      surfaceContainerHigh: const Color(0xFF222D3A),
      surfaceContainerHighest: const Color(0xFF293544),
      outlineVariant: const Color(0xFF374557),
      shadow: const Color(0x66000000),
    );
    return _buildTheme(scheme, Brightness.dark, primaryColor);
  }

  static ThemeData _buildTheme(
    ColorScheme scheme,
    Brightness brightness,
    Color primaryColor,
  ) {
    final baseTextTheme = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    final textTheme = baseTextTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
      fontFamily: 'MapleFont',
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'MapleFont',
      brightness: brightness,
      primaryColor: primaryColor,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme.copyWith(
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: scheme.surfaceTint,
        shadowColor: scheme.shadow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.onPrimary;
          }
          return scheme.outline;
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.secondaryContainer,
        selectedColor: scheme.primaryContainer,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerLow),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        side: WidgetStatePropertyAll(BorderSide(color: scheme.outlineVariant)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        textStyle: WidgetStatePropertyAll(TextStyle(color: scheme.onSurface)),
        hintStyle: WidgetStatePropertyAll(
          TextStyle(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

import 'package:ctf_tools/core/route/app_routes.dart';
import 'package:ctf_tools/shared/providers/theme/theme_color.dart';
import 'package:ctf_tools/shared/providers/theme/theme_provider.dart';
import 'package:ctf_tools/shared/providers/config/config_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 应用入口函数，初始化全局状态并启动 Flutter 应用。
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 预加载配置
  final configProvider = ConfigProvider();
  await configProvider.loadConfig();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: configProvider),
      ],
      child: const MyApp(),
    ),
  );
}

/// 应用根组件，负责注入路由与主题配置。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, ConfigProvider>(
      builder: (context, themeProvider, configProvider, _) {
        final lightTheme = AppTheme.lightTheme(
          themeProvider.selectedThemeColor.light,
        );
        final darkTheme = AppTheme.darkTheme(
          themeProvider.selectedThemeColor.dark,
        );
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: getRoute,
          theme: lightTheme.copyWith(
            textTheme: lightTheme.textTheme.copyWith(
              bodyLarge: lightTheme.textTheme.bodyLarge?.copyWith(
                fontFamily: configProvider.font.family,
                fontSize: configProvider.font.baseSize,
              ),
              bodyMedium: lightTheme.textTheme.bodyMedium?.copyWith(
                fontFamily: configProvider.font.family,
                fontSize: configProvider.font.baseSize,
              ),
              bodySmall: lightTheme.textTheme.bodySmall?.copyWith(
                fontFamily: configProvider.font.family,
                fontSize: configProvider.font.baseSize - 2,
              ),
            ),
          ),
          darkTheme: darkTheme.copyWith(
            textTheme: darkTheme.textTheme.copyWith(
              bodyLarge: darkTheme.textTheme.bodyLarge?.copyWith(
                fontFamily: configProvider.font.family,
                fontSize: configProvider.font.baseSize,
              ),
              bodyMedium: darkTheme.textTheme.bodyMedium?.copyWith(
                fontFamily: configProvider.font.family,
                fontSize: configProvider.font.baseSize,
              ),
              bodySmall: darkTheme.textTheme.bodySmall?.copyWith(
                fontFamily: configProvider.font.family,
                fontSize: configProvider.font.baseSize - 2,
              ),
            ),
          ),
          themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,
        );
      },
    );
  }
}

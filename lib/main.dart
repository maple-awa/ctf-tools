import 'package:ctf_tools/core/route/app_routes.dart';
import 'package:ctf_tools/shared/providers/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// 应用入口函数，初始化全局状态并启动 Flutter 应用。
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

/// 应用根组件，负责注入路由与主题配置。
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: getRoute,
      theme: ThemeData(
          fontFamily: "MapleFont"
      ),
      darkTheme: ThemeData(
          fontFamily: "MapleFont"
      ),
    );
  }
}
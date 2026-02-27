# 代码风格
- 使用 Dart/Flutter 组件化开发，StatefulWidget + 局部方法拆分
- 主题色统一通过 `Theme.of(context).colorScheme` 获取，避免硬编码 Color
- 响应式通过 `lib/shared/layout/responsive.dart` 断点控制
- 中文文案与注释较多，命名以英文标识符为主
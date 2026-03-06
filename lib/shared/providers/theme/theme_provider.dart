import 'package:ctf_tools/shared/providers/theme/theme_color.dart';
import 'package:flutter/material.dart';

/// 全局主题状态管理器。
class ThemeProvider with ChangeNotifier {
  static const int _defaultColorIndex = 0;

  bool _isDark = false;
  int _colorIndex = _defaultColorIndex;

  /// 当前是否为暗色模式。
  bool get isDark => _isDark;

  /// 当前主题主色。
  Color get color => _isDark
      ? AppTheme.colors[_colorIndex].dark
      : AppTheme.colors[_colorIndex].light;

  /// 当前选中的主题色对。
  ThemeColor get selectedThemeColor => AppTheme.colors[_colorIndex];

  /// 当前主题色索引。
  int get selectedColorIndex => _colorIndex;

  /// 当前生效的主题对象。
  ThemeData get currentTheme => _isDark
      ? AppTheme.darkTheme(selectedThemeColor.dark)
      : AppTheme.lightTheme(selectedThemeColor.light);

  /// 在亮色与暗色之间切换。
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  /// 显式设置暗色模式。
  void setDarkMode(bool value) {
    if (_isDark == value) return;
    _isDark = value;
    notifyListeners();
  }

  /// 根据索引切换主题色。
  ///
  /// 当 [index] 越界时抛出 [RangeError]。
  void setColorIndex(int index) {
    if (index < 0 || index >= AppTheme.colors.length) {
      throw RangeError.index(index, AppTheme.colors, 'index');
    }
    if (_colorIndex == index) return;
    _colorIndex = index;
    notifyListeners();
  }

  /// 恢复默认主题配置。
  void resetAppearance() {
    final changed = _isDark || _colorIndex != _defaultColorIndex;
    if (!changed) return;
    _isDark = false;
    _colorIndex = _defaultColorIndex;
    notifyListeners();
  }
}

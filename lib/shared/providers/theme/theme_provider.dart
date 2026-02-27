import 'package:ctf_tools/shared/providers/theme/theme_color.dart';
import 'package:flutter/material.dart';

/// 全局主题状态管理器。
class ThemeProvider with ChangeNotifier {
  bool _isDark = false;
  int _colorIndex = 0;

  /// 当前是否为暗色模式。
  bool get isDark => _isDark;

  /// 当前主题主色。
  Color get color => _isDark ? AppTheme.colors[_colorIndex].dark : AppTheme.colors[_colorIndex].light;

  /// 当前主题色索引。
  int get selectedColorIndex => _colorIndex;

  /// 当前生效的主题对象。
  ThemeData get currentTheme => _isDark ? AppTheme.darkTheme(color) : AppTheme.lightTheme(color);

  /// 在亮色与暗色之间切换。
  void toggleTheme() {
    _isDark = !_isDark;
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
}

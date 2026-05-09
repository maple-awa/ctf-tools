# 关于页面 - 功能文档

## 📋 概述

为 CTF 工具箱添加了全新的关于页面，包含项目信息展示、GitHub 链接、检查更新等功能，采用 Material 3 设计语言，视觉效果出众。

---

## ✨ 功能特性

### 1. 项目信息卡片 📱

**显示内容**:
- 应用名称
- 版本号 (可点击复制)
- 构建号 (可点击复制)
- 包名 (可点击复制)

**设计特点**:
- 渐变背景
- 图标标识
- 复制功能
- 动画效果

### 2. 项目链接卡片 🔗

**包含链接**:
- **GitHub 仓库**: `https://github.com/mapale-dev/ctf-tools`
- **项目文档**: `https://github.com/mapale-dev/ctf-tools#readme`
- **问题反馈**: `https://github.com/mapale-dev/ctf-tools/issues`
- **开源协议**: `https://github.com/mapale-dev/ctf-tools/blob/main/LICENSE`

**设计特点**:
- 卡片式布局
- 链接预览
- 一键打开
- 图标标识

### 3. 功能特性展示 🎯

**展示内容**:
- 编码解码
- 密码学
- 隐写工具
- 网络协议
- 二进制分析
- 本地化配置
- Material 3
- 跨平台

**设计形式**:
- Chip 标签
- 图标 + 文字
- 响应式布局

### 4. 技术栈展示 💻

**技术栈信息**:
- Flutter - 跨平台 UI 框架
- Dart - 编程语言
- Material 3 - 设计语言
- Provider - 状态管理
- GoRouter - 路由管理

**展示方式**:
- 列表形式
- 图标 + 名称 + 描述

### 5. 检查更新功能 🔄

**功能流程**:
1. 点击"检查更新"按钮
2. 显示加载动画
3. 模拟检查 (2 秒延迟)
4. 显示检查结果
5. 如有更新，提供更新按钮

**检查内容**:
- 当前版本对比
- 更新消息显示
- 更新按钮 (跳转到 Releases 页面)

**视觉效果**:
- 加载动画
- 状态图标
- 颜色区分 (新绿色/最新灰色)

### 6. 页脚信息 ℹ️

**包含内容**:
- 制作者信息:"Made with ❤️ by MapleLeaf"
- 版权信息
- Open Source 标识
- MIT License 标识
- 年份自动更新

---

## 🎨 设计亮点

### 1. 渐变效果
```dart
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    scheme.primaryContainer.withOpacity(0.3),
    scheme.surface,
    scheme.tertiaryContainer.withOpacity(0.2),
  ],
)
```

### 2. 动画效果
- 淡入动画 (FadeTransition)
- 缩放动画 (ScaleAnimation)
- 弹性效果 (ElasticOut)
- 持续时间：1200ms

### 3. 卡片设计
- 无阴影 (elevation: 0)
- 边框描边
- 圆角：16px
- 半透明背景

### 4. 交互反馈
- 悬停效果
- 点击波纹
- 复制提示
- 加载状态

---

## 🎯 使用方式

### 访问关于页面

**路径 1**: 设置页面 → 关于

**路径 2**: 代码调用
```dart
showDialog(
  context: context,
  builder: (context) => const AboutDialogEnhanced(),
);
```

### 检查更新

1. 打开关于页面
2. 滚动到"检查更新"卡片
3. 点击"检查更新"按钮
4. 等待检查结果
5. 如有更新，点击"更新"按钮

### 复制信息

- 点击版本号 → 复制版本号
- 点击构建号 → 复制构建号
- 点击包名 → 复制包名

### 打开链接

- 点击任意项目链接卡片
- 自动在浏览器中打开

---

## 📦 依赖要求

```yaml
url_launcher: ^6.3.1        # 打开外部链接
package_info_plus: ^9.0.0   # 获取应用信息
```

---

## 🔧 自定义配置

### 修改项目信息

在 `pubspec.yaml` 中修改:
```yaml
name: ctf_tools
description: "MapleLeaf 蜜汁 CTF 工具箱"
version: 1.4.0+5
```

### 修改链接

编辑 `about_dialog_enhanced.dart`:
```dart
_buildLinkButton(
  '自定义链接',
  'https://your-url.com',
  Icons.link,
  scheme,
),
```

### 修改检查更新逻辑

当前为模拟检查，实际使用需要:
```dart
Future<void> _checkForUpdates() async {
  // 1. 调用 GitHub API
  final response = await http.get(
    Uri.parse('https://api.github.com/repos/mapale-dev/ctf-tools/releases/latest'),
  );
  
  // 2. 解析响应
  final data = jsonDecode(response.body);
  final latestVersion = data['tag_name'];
  
  // 3. 版本对比
  final hasUpdate = _compareVersions(
    _packageInfo.version,
    latestVersion,
  );
  
  // 4. 更新状态
  setState(() {
    _isCheckingUpdate = false;
    _hasUpdate = hasUpdate;
    _latestVersion = latestVersion;
  });
}
```

---

## 🎨 视觉效果

### 头部区域
- 渐变背景 (primary → tertiary)
- 圆形图标容器
- 应用名称
- 版本标签

### 内容区域
- 5 个信息卡片
- 统一的圆角和边框
- 半透明背景色
- 图标颜色区分

### 底部区域
- 分割线
- 制作者信息
- 开源标识
- 许可协议

---

## 📱 响应式设计

### 窗口尺寸
- 宽度：600px
- 最大宽度：600px
- 高度：自适应

### 布局适配
- Wrap 组件 (功能特性)
- SingleChildScrollView (内容滚动)
- Flexible (灵活布局)
- Spacer (空间分配)

---

## 🚀 性能优化

### 1. 懒加载
- 包信息异步加载
- 动画按需执行

### 2. 状态管理
- 只重新构建必要部分
- 使用 AnimatedBuilder

### 3. 资源优化
- 图标使用内置 Icons
- 无外部图片资源

---

## 🔒 安全性

### 链接安全
- 使用 `canLaunchUrl` 检查
- 外部浏览器打开
- HTTPS 优先

### 权限控制
- 无需特殊权限
- 仅访问公开 API

---

## 📊 技术实现

### 动画系统
```dart
AnimationController + Tween + CurvedAnimation
```

### 状态管理
```dart
StatefulWidget + setState
```

### 数据获取
```dart
PackageInfo.fromPlatform()
```

### 外部链接
```dart
launchUrl(uri, mode: LaunchMode.externalApplication)
```

---

## 🐛 故障排除

### 问题 1: 链接无法打开
**解决**:
- 检查 url_launcher 依赖
- 确认平台配置正确
- 检查 URL 格式

### 问题 2: 版本信息不显示
**解决**:
- 检查 package_info_plus 依赖
- 确认 pubspec.yaml 配置
- 重新编译应用

### 问题 3: 动画卡顿
**解决**:
- 减少动画数量
- 优化动画曲线
- 使用性能分析工具

---

## 🎯 最佳实践

### 1. 代码组织
- 分离 UI 和逻辑
- 使用 Widget 方法
- 提取可复用组件

### 2. 用户体验
- 提供加载反馈
- 错误友好提示
- 操作确认

### 3. 可维护性
- 清晰注释
- 统一命名
- 模块化设计

---

## 🔮 未来计划

### 短期
- [ ] 实际更新检查 (GitHub API)
- [ ] 更新日志显示
- [ ] 贡献者列表

### 中期
- [ ] 应用内更新
- [ ] 版本历史
- [ ] 下载统计

### 长期
- [ ] 多语言支持
- [ ] 主题自定义
- [ ] 更多统计信息

---

## 📝 总结

关于页面现在包含:
- ✅ 完整的项目信息展示
- ✅ GitHub 链接集合
- ✅ 功能特性展示
- ✅ 技术栈介绍
- ✅ 检查更新功能
- ✅ 精美的视觉效果
- ✅ 流畅的动画
- ✅ 良好的交互反馈

是了解项目和获取更新的重要窗口！🎉

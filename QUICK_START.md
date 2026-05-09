# 快速启动指南

## 安装依赖

```bash
flutter pub get
```

## 运行应用

```bash
flutter run
```

## 访问配置

1. **设置页面**: 点击侧边栏 → 设置
2. **详细配置**: 设置 → 应用配置
3. **配置管理**: 设置 → 配置管理

## 新增配置功能速览

### 4 种预设配置
- 📖 舒适阅读 - 适合长时间使用
- ⚡ 紧凑高效 - 提高屏幕利用率
- 💻 开发者 - 代码编辑优化
- ♿ 无障碍 - 超大字体高对比

### 主要配置项
- 字体：5 种字体可选，支持自定义字号
- 布局：侧边栏宽度、卡片圆角、紧凑模式
- 编辑器：换行、行号、缩略图、Tab 缩进
- 工具：自动复制、确认清空、历史数量

### 配置管理
- 导入/导出 JSON 配置
- 自动保存 (默认开启)
- 配置历史记录
- 一键恢复默认

## 配置文件位置

配置使用 SharedPreferences 存储在本地:
- Key: `app_config`
- Format: JSON

## 示例：导出配置

1. 设置 → 配置管理
2. 点击"导出配置"的"复制"按钮
3. 配置 JSON 已复制到剪贴板

## 示例：导入配置

1. 设置 → 配置管理
2. 点击"导入配置"的"导入"按钮
3. 粘贴 JSON 字符串
4. 点击"确认导入"

## 开发者 API

```dart
// 获取配置提供者
final config = context.read<ConfigProvider>();

// 修改配置
config.setFontSize(16.0);
config.toggleCompactMode();
config.setAutoSave(false);

// 保存配置
await config.saveConfig();

// 导出配置
String json = config.exportConfig();

// 导入配置
config.importConfig(jsonString);
```

## 详细文档

- CONFIG_GUIDE.md - 完整配置指南
- LOCALIZATION_CONFIG_SUMMARY.md - 实现总结

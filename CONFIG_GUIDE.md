# CTF 工具箱 - 本地化配置指南

## 概述

本项目现已支持完整的本地化配置系统，所有配置项都会持久化存储在本地，支持导入/导出和预设方案。

## 配置入口

### 1. 设置页面
- 路径：点击侧边栏 → 设置
- 提供快速配置入口：
  - 应用配置：进入详细配置页面
  - 配置管理：导入/导出配置
  - 暗色模式切换

### 2. 配置页面
- 路径：设置 → 应用配置
- 路由：`/settings/config`
- 提供所有可配置项的完整界面

## 可配置项详解

### 1. 字体配置

#### 字体族
支持以下字体:
- **默认**: MapleFont (项目定制字体)
- **思源黑体**: Noto Sans SC
- **Roboto**: 标准西文字体
- **等宽字体**: monospace
- **大号字体**: 默认字体的大号版本

#### 基础字号
- 范围：10.0 - 24.0
- 默认：14.0
- 实时预览效果

### 2. 布局配置

#### 紧凑模式
- **开启**: 使用更小的间距和侧边栏 (200px)
- **关闭**: 使用标准间距和侧边栏 (240px)

#### 侧边栏宽度
- 范围：180 - 320px
- 默认：240px
- 可拖动滑块调整

#### 卡片圆角
- 范围：0 - 24px
- 默认：12px
- 影响所有卡片的圆角大小

### 3. 编辑器配置

适用于所有代码编辑工具:

#### 自动换行
- 长文本自动换行显示
- 默认：开启

#### 显示行号
- 在代码编辑器左侧显示行号
- 默认：开启

#### 缩略图
- 显示代码缩略图预览
- 默认：关闭

#### 编辑器字号
- 范围：10 - 24px
- 默认：14px

#### Tab 缩进
- 范围：2 - 8 空格
- 默认：2 空格

### 4. 工具偏好

#### 自动复制结果
- 操作完成后自动复制到剪贴板
- 默认：关闭

#### 清空前确认
- 清空输入输出前弹出确认对话框
- 默认：开启

#### 显示工具提示
- 显示功能说明和提示信息
- 默认：开启

#### 历史最大条目数
- 范围：10 - 200
- 默认：50

### 5. 高级设置

#### 自动保存配置
- 配置变更后自动保存到本地
- 默认：开启

#### 导出路径
- 设置文件导出和保存的默认目录
- 默认：空 (使用系统默认)

## 预设配置

提供 4 种快速配置方案:

### 1. 舒适阅读
- 大字体 (18px)
- 宽间距
- 适合长时间阅读

### 2. 紧凑高效
- 小字体 (12px)
- 紧凑布局
- 提高屏幕利用率

### 3. 开发者
- 等宽字体
- 显示行号
- 开启缩略图
- 适合代码编辑

### 4. 无障碍
- 超大字体 (22px)
- 高对比度
- 自动复制结果
- 易于识别

## 配置管理

### 导出配置

将当前所有配置导出为 JSON 字符串:

1. 打开设置页面
2. 点击"配置管理"
3. 点击"导出配置"的"复制"按钮
4. JSON 字符串已复制到剪贴板

导出的 JSON 格式示例:
```json
{
  "language": "zh_CN",
  "font": {
    "name": "默认",
    "family": "MapleFont",
    "baseSize": 14.0
  },
  "layout": {
    "sidebarWidth": 240.0,
    "compactMode": false,
    "cardRadius": 12.0,
    "contentPadding": 16.0
  },
  "editor": {
    "fontSize": 14,
    "wordWrap": true,
    "lineNumbers": true,
    "minimap": false,
    "tabSize": 2,
    "theme": "default"
  },
  "toolPrefs": {
    "autoCopyResult": false,
    "confirmClear": true,
    "maxHistoryItems": 50,
    "showTooltips": true
  },
  "autoSave": true,
  "exportPath": ""
}
```

### 导入配置

从 JSON 字符串导入配置:

1. 打开设置页面
2. 点击"配置管理"
3. 点击"导入配置"的"导入"按钮
4. 粘贴之前导出的 JSON 字符串
5. 点击"确认导入"

导入的配置会立即生效，并标记为"未保存"状态。

### 保存配置

配置变更后:
- 如果开启了"自动保存"，配置会自动保存
- 也可以手动点击"保存配置"按钮
- 保存后会提示"配置已保存"

### 恢复默认

一键恢复所有配置为默认值:
1. 点击"恢复默认"按钮
2. 所有配置项重置为默认值
3. 需要手动保存或等待自动保存

## 配置历史记录

配置页面提供历史记录功能:
- 记录最近的配置变更
- 显示变更类型、详情和时间
- 支持清空历史记录

历史类型图标:
- 📝 字体修改
- 📐 布局修改
- 💻 编辑器修改
- 📥 导入配置
- 📤 导出配置
- ⚙️ 其他设置

## 持久化存储

配置使用 `SharedPreferences` 存储在本地:
- 存储键：`app_config`
- 格式：JSON 字符串
- 自动序列化/反序列化
- 跨会话保持

## 代码集成

### 在代码中访问配置

```dart
import 'package:provider/provider.dart';
import 'package:ctf_tools/shared/providers/config/config_provider.dart';

// 在 Widget 中
Consumer<ConfigProvider>(
  builder: (context, configProvider, _) {
    // 访问配置
    final fontSize = configProvider.font.baseSize;
    final isCompact = configProvider.layout.compactMode;
    
    return Text('当前字号：$fontSize');
  },
)
```

### 修改配置

```dart
// 设置字体
configProvider.setFont(FontConfig.availableFonts[1]);

// 设置字号
configProvider.setFontSize(16.0);

// 切换紧凑模式
configProvider.toggleCompactMode();

// 设置编辑器配置
configProvider.setEditor(const EditorConfig(
  fontSize: 14,
  wordWrap: true,
  lineNumbers: true,
  minimap: false,
  tabSize: 2,
  theme: 'default',
));

// 保存配置
await configProvider.saveConfig();

// 重置为默认
configProvider.resetToDefaults();
```

### 监听配置变更

```dart
@override
Widget build(BuildContext context) {
  return Consumer<ConfigProvider>(
    builder: (context, configProvider, child) {
      // 配置变更时会自动重建
      return Text(
        '字号：${configProvider.font.baseSize}',
        style: TextStyle(
          fontFamily: configProvider.font.family,
          fontSize: configProvider.font.baseSize,
        ),
      );
    },
  );
}
```

## 注意事项

1. **配置保存**: 
   - 修改配置后，如果关闭了自动保存，需要手动保存
   - 未保存的配置在应用重启后会丢失

2. **字体支持**:
   - 使用的字体需要在 pubspec.yaml 中声明
   - 自定义字体需要添加到 assets/fonts 目录

3. **导入验证**:
   - 导入的 JSON 必须符合格式要求
   - 格式错误的 JSON 会提示导入失败

4. **性能**:
   - 频繁修改配置时建议关闭自动保存
   - 修改完成后手动保存一次即可

5. **跨平台**:
   - 配置在不同平台间独立存储
   - 可以通过导入/导出同步配置

## 故障排除

### 配置不生效
1. 检查是否保存了配置
2. 重启应用查看是否持久化成功
3. 查看控制台是否有错误日志

### 导入失败
1. 确保 JSON 格式正确
2. 检查是否复制了完整的 JSON 字符串
3. 尝试使用默认配置导出作为参考

### 字体不显示
1. 确认字体文件存在
2. 检查 pubspec.yaml 中的字体声明
3. 清除构建缓存重新编译

## 扩展配置

如需添加新的配置项:

1. 在 `AppConfig` 模型中添加字段
2. 在 `ConfigProvider` 中添加设置方法
3. 在 `AppConfigScreen` 中添加 UI
4. 更新 `toJson` 和 `fromJson` 方法

## 技术支持

如有问题或建议，请提交 Issue 或在讨论区提问。

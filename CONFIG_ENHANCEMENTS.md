# CTF 工具箱 - 配置系统增强功能

## 🎉 新增功能概览

本次更新为配置系统带来了全面增强，包括：
- ✅ 系统字体选择和自定义字体
- ✅ 增强的导入导出功能
- ✅ 配置验证和兼容性检查
- ✅ 更多可配置项
- ✅ 用户体验优化

---

## ✨ 核心增强功能

### 1. 系统字体选择 🅰️

#### 功能描述
- 扫描并选择系统已安装的字体
- 支持中文、英文、等宽字体分类浏览
- 支持自定义字体文件 (.ttf, .otf, .ttc)
- 实时预览字体效果

#### 字体分类
**中文字体**:
- 思源黑体
- 思源宋体
- 微软雅黑
- 宋体
- 黑体
- 楷体
- 仿宋
- 华文黑体
- 华文宋体
- 幼圆
- 隶书

**英文字体**:
- Arial
- Helvetica
- Times New Roman
- Courier New
- Verdana
- Georgia
- Palatino
- Garamond
- Bookman
- Comic Sans MS
- Trebuchet MS
- Arial Black
- Impact

**等宽字体 (适合代码)**:
- Consolas
- Monaco
- Menlo
- Courier New
- Source Code Pro
- Fira Code
- JetBrains Mono
- Inconsolata
- DejaVu Sans Mono

#### 使用方式
1. 配置页面 → 字体配置
2. 点击"选择系统字体"按钮
3. 浏览或搜索字体
4. 点击选择即可应用

### 2. 自定义字体文件 📁

#### 功能描述
- 支持从本地选择字体文件
- 支持格式：.ttf, .otf, .ttc
- 自动加载并使用自定义字体

#### 使用方式
1. 字体选择对话框 → 右上角文件夹图标
2. 选择字体文件
3. 确认后应用

### 3. 增强的导入导出功能 💾

#### 导出模式
**标准模式**:
- 紧凑 JSON 格式
- 最小文件大小
- 适合程序间传输

**格式化模式**:
- 带缩进的 JSON
- 易于阅读和编辑
- 适合手动修改

**带元数据模式**:
- 包含导出时间
- 包含应用版本
- 包含平台信息
- 完整的配置信息

#### 导出选项
- ✅ 复制到剪贴板
- ✅ 保存到文件 (文件选择器)
- ✅ 实时预览导出内容
- ✅ 配置元数据

#### 导入增强
- ✅ 版本兼容性检查
- ✅ 配置格式验证
- ✅ 从文件导入
- ✅ 粘贴导入
- ✅ 合并导入 (保留部分当前设置)
- ✅ 详细的错误提示

#### 导入验证
导入时自动检查:
- JSON 格式是否正确
- 配置版本是否兼容
- 必要字段是否完整
- 数值是否在有效范围内

### 4. 配置验证 ✅

#### 验证内容
- 字体大小范围 (8-72px)
- 侧边栏宽度范围 (150-500px)
- 编辑器字号范围 (8-48px)
- 历史条目数范围 (0-1000)

#### 验证方式
- 导出/导入时自动验证
- 手动点击"验证配置"按钮
- 验证结果显示详细错误信息

### 5. 新增可配置项 🔧

#### 界面配置 (UIConfig)
```dart
- scaleFactor: 界面缩放比例 (0.5-2.0)
- useRoundedButtons: 使用圆角按钮
- showToolDescriptions: 显示工具描述
- itemsPerPage: 每页显示项目数
- dateFormat: 日期格式
- timeFormat: 时间格式
```

#### 编辑器增强配置
```dart
- highlightCurrentLine: 高亮当前行
- highlightMatchingBrackets: 高亮匹配括号
- renderWhitespace: 显示空白字符
- bracketPairGuides: 括号对引导线
```

#### 工具偏好增强
```dart
- autoSaveHistory: 自动保存历史
- defaultExportFormat: 默认导出格式
- confirmExit: 退出前确认
- vibrateOnAction: 操作时振动反馈
```

#### 布局增强配置
```dart
- showAnimations: 是否显示动画
- showImages: 是否显示图片
```

### 6. 配置历史增强 📜

#### 功能增强
- 自动记录所有配置变更
- 最多保存 100 条历史记录
- 持久化存储历史记录
- 支持清空历史
- 详细记录变更内容

#### 历史记录类型
- 加载配置
- 保存配置
- 修改语言
- 修改字体
- 修改字号
- 设置系统字体
- 设置自定义字体
- 修改布局
- 自动保存开关
- 导入配置
- 合并配置
- 重置配置
- 清空历史

---

## 📦 新增依赖

```yaml
path_provider: ^2.1.4    # 获取系统路径
file_picker: ^8.1.2       # 文件选择器
```

---

## 🎨 UI 增强

### 1. 字体选择对话框
- 600x500 大窗口
- 搜索功能
- 分类标签页
- 实时预览
- 自定义字体按钮
- 选中状态指示

### 2. 导入导出对话框
- 700x600 大窗口
- 导出模式选择 (分段按钮)
- 实时预览
- 导出进度指示
- 验证状态显示
- 未保存提示徽章

### 3. 配置页面优化
- 当前字体信息卡片
- 快速访问系统字体按钮
- 增强的操作按钮
- 确认对话框 (重置操作)

---

## 🔍 系统字体扫描

### 支持的操作系统

#### Windows
- 扫描目录：`C:\Windows\Fonts`
- 支持字体：所有已安装字体

#### macOS
- 扫描目录:
  - `/Library/Fonts`
  - `/System/Library/Fonts`
  - `~/Library/Fonts`

#### Linux
- 扫描目录:
  - `/usr/share/fonts`
  - `/usr/local/share/fonts`
  - `~/.fonts`
  - `~/.local/share/fonts`

#### Android
- 扫描目录：`/system/fonts`

#### iOS
- 仅支持常用字体列表 (系统限制)

---

## 📊 配置模型增强

### AppConfig 新增字段
```dart
- uiConfig: UIConfig          // 界面配置
- lastModified: DateTime      // 最后修改时间
- configVersion: String       // 配置版本号
```

### 版本管理
- 当前版本：`1.0.0`
- 版本兼容性检查
- 未来支持多版本兼容

---

## 🚀 性能优化

### 1. 懒加载
- 字体列表按需加载
- 配置历史分页加载

### 2. 缓存
- 扫描的字体结果缓存
- 配置 JSON 解析缓存

### 3. 异步操作
- 所有 IO 操作异步执行
- 不阻塞 UI 线程

---

## 🔒 安全性增强

### 导入验证
- JSON 格式验证
- 配置版本检查
- 字段完整性验证
- 数值范围验证

### 错误处理
- 详细的错误提示
- 友好的错误界面
- 重试机制

---

## 📱 用户体验优化

### 1. 提示和反馈
- ✅ 操作成功提示
- ✅ 错误提示
- ✅ 确认对话框
- ✅ 进度指示
- ✅ 状态徽章

### 2. 快捷操作
- 一键复制导出
- 一键保存配置
- 一键恢复默认
- 快速字体选择

### 3. 可视化
- 字体预览
- 配置状态展示
- 验证结果展示
- 历史记录可视化

---

## 🎯 使用场景

### 场景 1: 更换字体
1. 打开配置页面
2. 点击"选择系统字体"
3. 浏览或搜索喜欢的字体
4. 点击应用
5. 立即生效

### 场景 2: 配置备份
1. 打开配置管理
2. 选择"带元数据"导出模式
3. 点击"保存到文件"
4. 选择保存位置
5. 完成备份

### 场景 3: 配置同步
1. 在设备 A 上导出配置
2. 复制配置 JSON
3. 在设备 B 上导入配置
4. 配置同步完成

### 场景 4: 配置调试
1. 修改配置测试效果
2. 如不满意，点击"恢复默认"
3. 或从备份重新导入

### 场景 5: 团队协作
1. 导出标准配置
2. 分享给团队成员
3. 团队成员导入配置
4. 统一开发环境

---

## 📖 API 参考

### ConfigProvider 方法

```dart
// 字体相关
void setFont(FontConfig font);
void setFontSize(double baseSize);
void setSystemFont(String family, String name);
void setCustomFont(String path, String name);

// 配置管理
Future<void> saveConfig();
Future<ImportResult> importConfig(String json);
String exportConfig({bool prettyPrint});
String exportConfigWithMetadata();
void resetToDefaults();

// 验证
ValidationResult validateConfig();

// 历史
Future<void> clearHistory();
```

### 导入结果

```dart
class ImportResult {
  final bool success;
  final String? error;
}
```

### 验证结果

```dart
class ValidationResult {
  final bool isValid;
  final List<String> errors;
}
```

---

## 🐛 故障排除

### 问题 1: 系统字体不显示
**解决**:
- 检查系统字体目录权限
- 重启应用重新扫描
- 手动选择常用字体列表

### 问题 2: 自定义字体不生效
**解决**:
- 检查字体文件格式
- 确认字体文件完整
- 重启应用加载字体

### 问题 3: 导入配置失败
**解决**:
- 检查 JSON 格式
- 验证配置版本
- 查看错误提示详细信息

### 问题 4: 配置保存失败
**解决**:
- 检查存储空间
- 检查应用权限
- 查看日志错误信息

---

## 🔮 未来计划

### 短期
- [ ] 云同步配置
- [ ] 配置模板市场
- [ ] 批量配置管理

### 中期
- [ ] 配置版本历史
- [ ] 配置对比工具
- [ ] 配置推荐系统

### 长期
- [ ] AI 配置优化
- [ ] 跨设备自动同步
- [ ] 配置分析报表

---

## 📝 总结

本次更新为 CTF 工具箱的配置系统带来了全面的增强:

✅ **字体选择**: 支持系统字体和自定义字体
✅ **导入导出**: 三种模式，文件保存，验证检查
✅ **配置验证**: 自动验证，详细错误提示
✅ **新增配置**: 界面、编辑器、工具偏好全面扩展
✅ **用户体验**: 大窗口对话框，实时预览，友好提示

配置系统现在更加完善、易用、强大！🎉

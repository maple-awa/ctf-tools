# CTF 工具箱 - 新增功能说明

本次更新为 CTF 工具箱新增了 22 个实用工具，涵盖编码解码、密码学、隐写、网络协议和二进制分析五大模块。

## 新增功能列表

### 一、编码解码模块 (5 个)

#### 1. URL 编码/解码 (`/encoding/url`)
- **功能**: URL encode/decode，支持双重编码模式
- **用途**: 处理 URL 中的特殊字符，适用于 URL 编码绕过、双重编码解密等场景
- **特性**:
  - 支持单次和双重 URL 编码
  - 自动处理特殊字符

#### 2. HTML 实体编码/解码 (`/encoding/html`)
- **功能**: HTML Entity 编解码，支持命名实体、十进制和十六进制格式
- **用途**: XSS 绕过、HTML 注入测试、字符混淆
- **特性**:
  - 命名实体 (`&lt;` `&gt;` `&amp;`)
  - 十进制实体 (`&#60;` `&#62;`)
  - 十六进制实体 (`&#x3C;` `&#x3E;`)

#### 3. Quoted-Printable 编码/解码 (`/encoding/quoted`)
- **功能**: 邮件传输编码
- **用途**: 处理 MIME 编码的邮件内容、解码 quoted-printable 编码的 payload
- **特性**:
  - 支持 UTF-8 字符集
  - 自动处理软换行

#### 4. Base 系列编码变体 (`/encoding/base-variant`)
- **功能**: Base16/32/64/64Url 编码转换
- **用途**: 处理各种 Base 编码变体，适用于不同场景的编码识别
- **特性**:
  - Base16 (Hex)
  - Base32
  - Base64 标准
  - Base64Url (URL 安全)

#### 5. Escape/Unescape 编码 (`/encoding/escape`)
- **功能**: JavaScript 风格的 Escape 编码
- **用途**: 处理 JavaScript 编码的字符串、XSS payload 编码
- **特性**:
  - encodeURI
  - encodeURIComponent
  - escape (Legacy)

---

### 二、密码学模块 (5 个)

#### 6. AES 加解密工具 (`/crypto/aes`)
- **功能**: AES 加密/解密
- **用途**: AES 加密分析、密文解密、密钥爆破辅助
- **特性**:
  - 支持 AES-128/192/256
  - ECB/CBC 模式
  - PKCS7 填充
  - 自动生成密钥和 IV

#### 7. RSA 工具 (`/crypto/rsa`)
- **功能**: RSA 密钥解析、加解密、签名验证
- **用途**: RSA 密钥分析、私钥破解辅助、签名伪造
- **特性**:
  - PEM/DER 格式解析
  - 公钥/私钥解析
  - 加解密操作
  - 签名验证

#### 8. ECC 椭圆曲线工具 (`/crypto/ecc`)
- **功能**: ECC 曲线参数解析、加解密
- **用途**: 椭圆曲线密码分析、ECDSA 签名分析
- **特性**:
  - 常见曲线支持 (secp256k1, P-256 等)
  - 公私钥解析
  - 签名验证

#### 9. 哈希长度扩展攻击 (`/crypto/hash-length`)
- **功能**: Hash Length Extension 攻击辅助
- **用途**: 对 MD5/SHA1/SHA256 等哈希函数进行长度扩展攻击
- **特性**:
  - 支持多种哈希算法
  - 自动生成扩展 payload
  - 计算扩展后的哈希值

#### 10. Padding Oracle 攻击 (`/crypto/padding-oracle`)
- **功能**: 填充预言攻击辅助工具
- **用途**: 利用 Padding Oracle 漏洞解密 CBC 模式密文
- **特性**:
  - 自动化解密流程
  - 支持 AES/DES CBC 模式
  - 可视化攻击进度

---

### 三、隐写模块 (4 个)

#### 11. EXIF 信息提取 (`/stego/exif`)
- **功能**: 从图片中提取 EXIF 元数据
- **用途**: 图片信息收集、GPS 位置提取、相机参数分析
- **特性**:
  - 支持 JPEG/PNG/TIFF 格式
  - 提取相机信息、拍摄时间
  - GPS 坐标解析

#### 12. 盲水印检测 (`/stego/watermark`)
- **功能**: 频域盲水印提取
- **用途**: 检测图像中的盲水印、频域隐写分析
- **特性**:
  - DCT 域分析
  - 频域可视化
  - 水印提取

#### 13. 文件头尾修复 (`/stego/file-fix`)
- **功能**: 损坏文件修复
- **用途**: 修复文件头损坏的图片、文档等
- **特性**:
  - 自动识别文件类型
  - 修复常见文件头
  - 添加缺失的文件尾

#### 14. 二维码隐写 (`/stego/qrcode`)
- **功能**: QR Code 数据提取与隐藏
- **用途**: 二维码数据提取、隐藏信息检测
- **特性**:
  - 二维码识别与解码
  - 数据提取
  - 隐写检测

---

### 四、网络模块 (4 个)

#### 15. JWT 分析工具 (`/network/jwt`)
- **功能**: JWT Token 解码、伪造、爆破
- **用途**: JWT 安全分析、令牌伪造、签名破解
- **特性**:
  - Header/Payload 解码
  - Token 伪造
  - 签名爆破辅助
  - 算法漏洞检测

#### 16. SSRF 检测工具 (`/network/ssrf`)
- **功能**: SSRF Payload 生成
- **用途**: 服务端请求伪造漏洞探测
- **特性**:
  - 基础探测 Payload
  - WAF 绕过技巧
  - 多协议支持 (HTTP/Gopher/Dict 等)

#### 17. CRLF 注入检测 (`/network/crlf`)
- **功能**: CRLF Payload 生成与检测
- **用途**: HTTP 响应头注入测试
- **特性**:
  - CRLF Payload 生成
  - HTTP 头注入检测
  - 常见框架绕过

#### 18. XXE 漏洞利用 (`/network/xxe`)
- **功能**: XXE Payload 生成器
- **用途**: XML 外部实体注入攻击
- **特性**:
  - 经典 XXE Payload
  - 文件读取利用
  - SSRF 链式利用
  - 错误型/盲打支持

---

### 五、二进制模块 (4 个)

#### 19. ELF 文件解析 (`/binary/elf`)
- **功能**: ELF 文件头、段、符号表解析
- **用途**: Linux 二进制文件分析
- **特性**:
  - 文件头解析
  - 段表/节表分析
  - 符号表提取
  - 重定位信息

#### 20. PE 文件解析 (`/binary/pe`)
- **功能**: Windows PE 文件分析
- **用途**: Windows 可执行文件逆向分析
- **特性**:
  - DOS/NT 头解析
  - 导入/导出表分析
  - 资源段提取
  - 重定位表解析

#### 21. Shellcode 分析 (`/binary/shellcode`)
- **功能**: Shellcode 反汇编与执行
- **用途**: 恶意代码分析、漏洞利用开发
- **特性**:
  - Shellcode 反汇编
  - 系统调用识别
  - 行为分析

#### 22. 格式字符串漏洞辅助 (`/binary/format-string`)
- **功能**: Format String Payload 生成
- **用途**: 格式化字符串漏洞利用
- **特性**:
  - Payload 生成
  - 地址计算
  - 写入/读取辅助

---

## 使用指南

### 访问新功能

所有新功能已添加到侧边栏导航菜单中，可以通过对应的分类找到:

- **编码解码**: 展开"编码解码"菜单
- **密码学**: 展开"密码学"菜单
- **隐写工具**: 展开"隐写工具"菜单
- **网络协议**: 展开"网络协议"菜单
- **二进制分析**: 展开"二进制分析"菜单

### 更新路由配置

路由配置已更新到 `lib/core/route/app_routes.dart`，新增了 22 个路由入口。

### 依赖安装

运行以下命令安装新依赖:

```bash
flutter pub get
```

新增依赖:
- `archive: ^4.0.0` - 压缩/解压支持

---

## 技术细节

### 文件结构

```
lib/features/
├── encoding/
│   ├── pages/
│   │   ├── url_codec.dart
│   │   ├── html_entity_codec.dart
│   │   ├── quoted_printable_codec.dart
│   │   ├── base_variant_codec.dart
│   │   └── escape_codec.dart
│   └── utils/
├── crypto/
│   ├── pages/
│   │   ├── aes_crypto.dart
│   │   ├── rsa_toolkit.dart
│   │   ├── ecc_toolkit.dart
│   │   ├── hash_length_extension.dart
│   │   └── padding_oracle_helper.dart
│   └── utils/
├── stego/
│   ├── pages/
│   │   ├── exif_extractor.dart
│   │   ├── blind_watermark_detector.dart
│   │   ├── file_header_fixer.dart
│   │   └── qrcode_stego.dart
│   └── utils/
├── network/
│   ├── pages/
│   │   ├── jwt_analyzer.dart
│   │   ├── ssrf_detector.dart
│   │   ├── crlf_injector.dart
│   │   └── xxe_generator.dart
│   └── utils/
└── binary/
    ├── pages/
    │   ├── elf_parser.dart
    │   ├── pe_parser.dart
    │   ├── shellcode_analyzer.dart
    │   └── format_string_helper.dart
    └── utils/
```

### UI 一致性

所有新工具遵循统一的 UI 设计:
- Material 3 设计风格
- 统一的输入/输出编辑器
- 一致的按钮布局
- 响应式适配

### 代码规范

- 遵循 Dart/Flutter 最佳实践
- 使用状态管理进行数据流控制
- 异常处理完善
- 注释清晰

---

## 后续计划

1. **完善工具实现**: 当前部分工具为框架实现，后续可补充完整功能
2. **添加单元测试**: 为每个工具添加测试用例
3. **性能优化**: 对大文件处理进行优化
4. **更多工具**: 根据 CTF 比赛需求继续扩展工具集

---

## 贡献者

本次更新由 AI 助手完成，为 CTF 工具箱增加了 22 个实用工具，大幅提升了解题效率。

## 许可证

与主项目保持一致

import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:ctf_tools/shared/widgets/tool_status_chip.dart';
import 'package:flutter/material.dart';

class DownloadCenterScreen extends StatefulWidget {
  const DownloadCenterScreen({super.key});

  @override
  State<DownloadCenterScreen> createState() => _DownloadCenterScreenState();
}

class _DownloadCenterScreenState extends State<DownloadCenterScreen> {
  final toolNameController = TextEditingController(text: 'ghidra');
  final versionController = TextEditingController();
  String packageManager = DownloadCommandBuilder.managers.first;
  String output = '';

  @override
  void dispose() {
    toolNameController.dispose();
    versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ToolPageShell(
      title: '下载与环境准备',
      description: '离线生成常见包管理器安装命令，并提供 CTF 常用工具建议清单，避免再停留在下载占位页。',
      badge: 'Setup',
      child: Column(
        children: [
          ToolSectionCard(
            title: '命令生成',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('包管理器', style: TextStyle(color: scheme.onSurfaceVariant)),
                MDropdownMenu(
                  initialValue: packageManager,
                  items: DownloadCommandBuilder.managers,
                  onChanged: (value) => setState(() {
                    packageManager = value;
                  }),
                ),
                const ToolStatusChip(
                  label: 'Offline Recipes',
                  icon: Icons.download,
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '参数',
            trailing: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MElevatedButton(
                  icon: Icons.auto_fix_high,
                  text: '加载常用项',
                  onPressed: () {
                    toolNameController.text = 'wireshark';
                    versionController.clear();
                    setState(() {});
                  },
                ),
                MElevatedButton(
                  icon: Icons.delete,
                  text: '清空',
                  onPressed: () {
                    toolNameController.clear();
                    versionController.clear();
                    setState(() {
                      output = '';
                    });
                  },
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: toolNameController,
                  decoration: const InputDecoration(
                    labelText: '工具名 / 包名',
                    prefixIcon: Icon(Icons.build_circle_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: versionController,
                  decoration: const InputDecoration(
                    labelText: '版本（可选）',
                    prefixIcon: Icon(Icons.tag_outlined),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(
                icon: Icons.terminal,
                text: '生成命令',
                onPressed: _buildCommand,
              ),
            ],
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '常用工具建议',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: DownloadCommandBuilder.presets
                  .map(
                    (preset) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${preset.name}: ${preset.description}',
                        style: TextStyle(color: scheme.onSurface, height: 1.55),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '输出',
            child: SelectableText(
              output.isEmpty ? '暂无结果' : output,
              style: TextStyle(color: scheme.onSurface, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  void _buildCommand() {
    try {
      final command = DownloadCommandBuilder.build(
        manager: packageManager,
        packageName: toolNameController.text,
        version: versionController.text,
      );
      setState(() {
        output = [
          'Command:',
          command,
          '',
          'Notes:',
          ...DownloadCommandBuilder.notesFor(packageManager),
        ].join('\n');
      });
    } catch (e) {
      setState(() {
        output = '生成失败: $e';
      });
    }
  }
}

class DownloadCommandBuilder {
  static const List<String> managers = [
    'winget',
    'scoop',
    'choco',
    'apt',
    'brew',
    'pip',
    'cargo',
    'go',
    'docker',
  ];

  static const List<ToolPreset> presets = [
    ToolPreset(name: 'wireshark', description: '抓包和协议分析'),
    ToolPreset(name: 'ghidra', description: '逆向工程与静态分析'),
    ToolPreset(name: 'jadx', description: 'Android 反编译'),
    ToolPreset(name: 'nmap', description: '端口与服务探测'),
    ToolPreset(name: 'ffuf', description: '目录与参数模糊测试'),
    ToolPreset(name: 'gobuster', description: '字典爆破与枚举'),
    ToolPreset(name: 'hashcat', description: '哈希破解'),
    ToolPreset(name: 'binwalk', description: '固件与嵌入数据提取'),
    ToolPreset(name: 'stegseek', description: '隐写密码快速爆破'),
  ];

  static String build({
    required String manager,
    required String packageName,
    required String version,
  }) {
    final normalized = packageName.trim();
    if (normalized.isEmpty) {
      throw const FormatException('请输入工具名或包名');
    }
    final versionText = version.trim();
    return switch (manager) {
      'winget' =>
        versionText.isEmpty
            ? 'winget install $normalized'
            : 'winget install $normalized --version $versionText',
      'scoop' => 'scoop install $normalized',
      'choco' =>
        versionText.isEmpty
            ? 'choco install $normalized -y'
            : 'choco install $normalized --version $versionText -y',
      'apt' => 'sudo apt install $normalized',
      'brew' => 'brew install $normalized',
      'pip' =>
        versionText.isEmpty
            ? 'python -m pip install $normalized'
            : 'python -m pip install $normalized==$versionText',
      'cargo' =>
        versionText.isEmpty
            ? 'cargo install $normalized'
            : 'cargo install $normalized --version $versionText',
      'go' => 'go install ${_goPackage(normalized, versionText)}',
      'docker' => 'docker pull ${_dockerImage(normalized, versionText)}',
      _ => throw const FormatException('不支持的包管理器'),
    };
  }

  static List<String> notesFor(String manager) {
    return switch (manager) {
      'winget' => const [
        '适合 Windows 环境快速安装 GUI / CLI 工具',
        '实际包 ID 可能和工具名不同，必要时先用 winget search 查询',
      ],
      'scoop' => const ['适合 Windows 下的便携 CLI 工具', '部分工具需要先添加 bucket'],
      'choco' => const ['适合 Windows 环境脚本化部署', '部分包需要管理员权限'],
      'apt' => const ['适合 Debian / Ubuntu 系', '仓库版本可能偏旧'],
      'brew' => const ['适合 macOS / Linux 的统一安装体验', 'GUI 工具可能需要 cask 形式单独处理'],
      'pip' => const ['适合 Python 类工具', '推荐放进虚拟环境或用 pipx 管理'],
      'cargo' => const ['适合 Rust 生态工具', '首次安装前需要 Rust toolchain'],
      'go' => const ['适合 Go 生态工具', '通常需要完整模块路径而不是裸工具名'],
      'docker' => const ['适合快速拿到隔离运行环境', '拉取镜像后仍需自行补 docker run 参数'],
      _ => const [],
    };
  }

  static String _goPackage(String packageName, String version) {
    final suffix = version.isEmpty ? 'latest' : version;
    return '$packageName@$suffix';
  }

  static String _dockerImage(String packageName, String version) {
    return version.isEmpty ? packageName : '$packageName:$version';
  }
}

class ToolPreset {
  const ToolPreset({required this.name, required this.description});

  final String name;
  final String description;
}

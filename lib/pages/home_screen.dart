import 'package:ctf_tools/shared/layout/responsive.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 首页（工具导航与快速入口）。
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kToolPagePadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kToolPageMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(context, scheme, isMobile),
                  const SizedBox(height: kToolSectionGap),
                  _buildSearchBar(scheme),
                  const SizedBox(height: kToolSectionGap),
                  if (isMobile)
                    Column(
                      children: [
                        _buildQuickActionsGrid(
                          context,
                          scheme: scheme,
                          crossAxisCount: 2,
                        ),
                        const SizedBox(height: kToolSectionGap),
                        _buildInsightsPanel(context, scheme),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildQuickActionsGrid(
                            context,
                            scheme: scheme,
                            crossAxisCount: 3,
                          ),
                        ),
                        const SizedBox(width: kToolSectionGap),
                        Expanded(
                          flex: 2,
                          child: _buildInsightsPanel(context, scheme),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, ColorScheme scheme, bool isMobile) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isMobile ? 18 : 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kToolHeroRadius),
          gradient: LinearGradient(
            colors: [
              scheme.primaryContainer,
              scheme.surfaceContainerHigh,
              scheme.tertiaryContainer.withValues(alpha: 0.88),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Chip(
                    label: const Text('Material 3 Control Center'),
                    avatar: Icon(Icons.tune, size: 16, color: scheme.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'CTF Tools 控制台',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: isMobile ? 26 : 34,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '统一的编码、网络、密码学、二进制与隐写工作台，全部页面现在共享 Material 3 风格。',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _moduleShortcuts()
                        .map(
                          (item) => ActionChip(
                            avatar: Icon(
                              item.icon,
                              size: 16,
                              color: scheme.primary,
                            ),
                            label: Text(item.title),
                            onPressed: () => context.go(item.route),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              onPressed: () => context.go('/settings'),
              icon: const Icon(Icons.settings_outlined),
              label: const Text('设置'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme scheme) {
    return SearchBar(
      controller: _searchController,
      hintText: '搜索工具：base64 / protobuf / whois / rsa / png ...',
      leading: Icon(Icons.search, color: scheme.onSurfaceVariant),
      trailing: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
            icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
          ),
      ],
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildQuickActionsGrid(
    BuildContext context, {
    required ColorScheme scheme,
    required int crossAxisCount,
  }) {
    final allActions = _quickActions(scheme);
    final keyword = _searchController.text.trim().toLowerCase();
    final data = keyword.isEmpty
        ? allActions
        : allActions
              .where(
                (item) =>
                    item.title.toLowerCase().contains(keyword) ||
                    item.subtitle.toLowerCase().contains(keyword) ||
                    item.keywords.any(
                      (entry) => entry.toLowerCase().contains(keyword),
                    ),
              )
              .toList();

    if (data.isEmpty) {
      return _panelCard(
        scheme: scheme,
        title: '工具列表',
        child: Text(
          '没有匹配的工具，换个关键词再试。',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: kToolSectionGap,
        crossAxisSpacing: kToolSectionGap,
        childAspectRatio: 1.34,
      ),
      itemBuilder: (context, index) {
        final item = data[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.go(item.route),
            child: Container(
              padding: const EdgeInsets.all(kToolSectionPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    item.color.withValues(alpha: 0.18),
                    scheme.surfaceContainerLow,
                    scheme.surfaceContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: item.color.withValues(alpha: 0.18),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    item.title,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightsPanel(BuildContext context, ColorScheme scheme) {
    return Column(
      children: [
        _panelCard(
          scheme: scheme,
          title: '常用流程',
          child: Column(
            children: [
              _flowTile(
                context,
                scheme,
                title: '编码分析链路',
                subtitle: 'Base → Text → ProtoBuf',
                route: '/encoding/base',
              ),
              const SizedBox(height: 10),
              _flowTile(
                context,
                scheme,
                title: '网络取证链路',
                subtitle: 'HTTP → DNS / WHOIS → 地址转换',
                route: '/network/interaction',
              ),
              const SizedBox(height: 10),
              _flowTile(
                context,
                scheme,
                title: '逆向辅助链路',
                subtitle: '文件头识别 → strings → cyclic offset',
                route: '/binary/info',
              ),
            ],
          ),
        ),
        const SizedBox(height: kToolSectionGap),
        _panelCard(
          scheme: scheme,
          title: '设计状态',
          child: Text(
            '当前首页、设置页、共享按钮、下拉、卡片壳、抽屉和工具页头部已统一到 Material 3 语义样式。',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.65,
            ),
          ),
        ),
      ],
    );
  }

  Widget _panelCard({
    required ColorScheme scheme,
    required String title,
    required Widget child,
  }) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(kToolSectionPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kToolSectionRadius),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            child,
          ],
        ),
      ),
    );
  }

  Widget _flowTile(
    BuildContext context,
    ColorScheme scheme, {
    required String title,
    required String subtitle,
    required String route,
  }) {
    return Card(
      color: scheme.surfaceContainer,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: scheme.primary.withValues(alpha: 0.14),
                child: Icon(
                  Icons.arrow_outward,
                  color: scheme.primary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: scheme.onSurfaceVariant,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_QuickAction> _quickActions(ColorScheme scheme) {
    final accents = [
      scheme.primary,
      scheme.secondary,
      scheme.tertiary,
      scheme.primaryContainer,
      scheme.secondaryContainer,
      scheme.tertiaryContainer,
    ];
    return [
      _QuickAction(
        title: 'Base 系列',
        subtitle: 'Base2/Base16/Base64 等快速转换',
        route: '/encoding/base',
        icon: Icons.tag,
        color: accents[0],
        keywords: ['base32', 'base58', 'base64', 'base85', '编码'],
      ),
      _QuickAction(
        title: '文本编码',
        subtitle: 'URL/HTML/Morse/Quoted-Printable',
        route: '/encoding/text',
        icon: Icons.text_fields,
        color: accents[1],
        keywords: ['url', 'html', 'unicode', 'morse', 'quoted-printable'],
      ),
      _QuickAction(
        title: 'ProtoBuf',
        subtitle: '硬解码 + Schema 编解码',
        route: '/encoding/protobuf',
        icon: Icons.schema,
        color: accents[2],
        keywords: ['protobuf', 'proto', 'wire', 'schema'],
      ),
      _QuickAction(
        title: '数值进制',
        subtitle: '2~64 进制互转 / BCD / Bin-Hex',
        route: '/encoding/number',
        icon: Icons.numbers,
        color: accents[3],
        keywords: ['进制', 'bcd', 'binary', 'hex', 'decimal'],
      ),
      _QuickAction(
        title: '压缩工具',
        subtitle: 'Gzip / Zlib 压缩与解压',
        route: '/encoding/compress',
        icon: Icons.compress,
        color: accents[4],
        keywords: ['gzip', 'zlib', 'compress', 'inflate'],
      ),
      _QuickAction(
        title: '信息收集',
        subtitle: 'DNS / WHOIS 快速查询',
        route: '/network/recon',
        icon: Icons.travel_explore,
        color: accents[5],
        keywords: ['dns', 'whois', 'recon', 'domain'],
      ),
      _QuickAction(
        title: '替换密码',
        subtitle: 'ROT13 / ROT47 / Caesar / Atbash',
        route: '/encoding/replace',
        icon: Icons.swap_horiz,
        color: accents[0],
        keywords: ['rot13', 'rot47', 'caesar', 'atbash'],
      ),
      _QuickAction(
        title: '经典密码',
        subtitle: 'Caesar / Atbash / Vigenere',
        route: '/crypto/classical',
        icon: Icons.history_edu,
        color: accents[1],
        keywords: ['caesar', 'atbash', 'vigenere', 'rail fence'],
      ),
      _QuickAction(
        title: '哈希计算',
        subtitle: 'CRC32 / Adler32 / FNV / 摘要识别',
        route: '/crypto/hash',
        icon: Icons.fingerprint,
        color: accents[2],
        keywords: ['hash', 'md5', 'sha1', 'sha256', 'crc32', 'fnv'],
      ),
      _QuickAction(
        title: '现代密码',
        subtitle: 'AES 多模式 / RSA 推导与攻击辅助',
        route: '/crypto/modern',
        icon: Icons.shield,
        color: accents[3],
        keywords: ['aes', 'rsa', 'ecb', 'cbc', 'pem', 'der', 'jwt'],
      ),
      _QuickAction(
        title: 'XOR 分析',
        subtitle: '文本异或 / HEX 回解',
        route: '/crypto/analysis',
        icon: Icons.analytics,
        color: accents[4],
        keywords: ['xor', 'crib', 'single-byte', 'hex'],
      ),
      _QuickAction(
        title: '文件解析',
        subtitle: 'ELF / PE / Mach-O / PNG / ZIP 识别',
        route: '/binary/info',
        icon: Icons.file_open,
        color: accents[3],
        keywords: ['elf', 'pe', 'macho', 'png', 'zip', 'magic'],
      ),
      _QuickAction(
        title: '字符串提取',
        subtitle: 'ASCII / UTF-16LE strings',
        route: '/binary/strings',
        icon: Icons.text_snippet,
        color: accents[4],
        keywords: ['strings', 'ascii', 'utf16', 'unicode'],
      ),
      _QuickAction(
        title: '漏洞利用',
        subtitle: 'cyclic pattern / offset 查找',
        route: '/binary/exploit',
        icon: Icons.bug_report,
        color: accents[5],
        keywords: ['cyclic', 'pattern', 'offset', 'payload'],
      ),
      _QuickAction(
        title: '反汇编',
        subtitle: 'opcode / shellcode 离线反汇编',
        route: '/binary/disasm',
        icon: Icons.code,
        color: accents[1],
        keywords: ['disasm', 'shellcode', 'opcode', 'x86'],
      ),
      _QuickAction(
        title: '地址扫描',
        subtitle: 'IPv4 与 DEC/HEX/BIN 互转',
        route: '/network/scanning',
        icon: Icons.map,
        color: accents[0],
        keywords: ['ipv4', 'ipv6', 'cidr', 'port', 'scan'],
      ),
      _QuickAction(
        title: '协议交互',
        subtitle: 'HTTP raw request / curl 构造',
        route: '/network/interaction',
        icon: Icons.sync_alt,
        color: accents[1],
        keywords: ['http', 'curl', 'websocket', 'tcp', 'smtp', 'ftp', 'pop3'],
      ),
      _QuickAction(
        title: '流量分析',
        subtitle: 'raw HTTP 与 PCAP 十六进制解析',
        route: '/network/traffic',
        icon: Icons.timeline,
        color: accents[2],
        keywords: ['pcap', 'traffic', 'http', 'packet', 'reassembly'],
      ),
      _QuickAction(
        title: '文本隐写',
        subtitle: '零宽字符检测与解码',
        route: '/stego/text',
        icon: Icons.visibility_off,
        color: accents[3],
        keywords: ['zero width', 'space tab', 'stego', 'text'],
      ),
      _QuickAction(
        title: '图像隐写',
        subtitle: 'PNG chunk / 元数据 / 尾随数据检查',
        route: '/stego/image',
        icon: Icons.image_search,
        color: accents[4],
        keywords: ['png', 'chunk', 'lsb', 'metadata', 'image'],
      ),
      _QuickAction(
        title: '音视频隐写',
        subtitle: 'WAV / MP4 / MP3 容器结构检查',
        route: '/stego/audio_video',
        icon: Icons.music_video,
        color: accents[5],
        keywords: ['wav', 'mp3', 'mp4', 'audio', 'video'],
      ),
      _QuickAction(
        title: '下载中心',
        subtitle: '常用工具安装命令与准备清单',
        route: '/download',
        icon: Icons.download_for_offline,
        color: accents[0],
        keywords: ['download', 'install', 'toolchain', 'setup'],
      ),
    ];
  }

  List<_ModuleShortcut> _moduleShortcuts() {
    return const [
      _ModuleShortcut('编码解码', '/encoding', Icons.data_array),
      _ModuleShortcut('密码学', '/crypto', Icons.lock),
      _ModuleShortcut('网络协议', '/network', Icons.router),
      _ModuleShortcut('二进制分析', '/binary', Icons.developer_mode),
      _ModuleShortcut('隐写工具', '/stego', Icons.hide_image),
      _ModuleShortcut('下载中心', '/download', Icons.download_for_offline),
    ];
  }
}

class _QuickAction {
  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.color,
    this.keywords = const [],
  });

  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;
  final List<String> keywords;
}

class _ModuleShortcut {
  const _ModuleShortcut(this.title, this.route, this.icon);

  final String title;
  final String route;
  final IconData icon;
}

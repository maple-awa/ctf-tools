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

  final List<_QuickAction> _quickActions = const [
    _QuickAction(
      title: 'Base 系列',
      subtitle: 'Base2/Base16/Base64 等快速转换',
      route: '/encoding/base',
      icon: Icons.tag,
      color: Color(0xFF2B64D1),
    ),
    _QuickAction(
      title: '文本编码',
      subtitle: 'URL/HTML/Morse/Quoted-Printable',
      route: '/encoding/text',
      icon: Icons.text_fields,
      color: Color(0xFF0F9F6D),
    ),
    _QuickAction(
      title: 'ProtoBuf',
      subtitle: '硬解码 + Schema 编解码',
      route: '/encoding/protobuf',
      icon: Icons.schema,
      color: Color(0xFFE09E3A),
    ),
    _QuickAction(
      title: '数值进制',
      subtitle: '2~64 进制互转 / BCD / Bin-Hex',
      route: '/encoding/number',
      icon: Icons.numbers,
      color: Color(0xFF7C61FF),
    ),
    _QuickAction(
      title: '压缩工具',
      subtitle: 'Gzip / Zlib 压缩与解压',
      route: '/encoding/compress',
      icon: Icons.compress,
      color: Color(0xFF00A3A3),
    ),
    _QuickAction(
      title: '信息收集',
      subtitle: 'DNS / WHOIS 快速查询',
      route: '/network/recon',
      icon: Icons.travel_explore,
      color: Color(0xFFCE5F6A),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101622),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTopBar(context),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 980) {
                      return _buildNarrowLayout(context);
                    }
                    return _buildWideLayout(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'CTF Tools 控制台',
              style: TextStyle(
                color: Color(0xFFFFE1D4),
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '简洁、高效、顺手的常用工具入口',
              style: TextStyle(color: Color(0xFF9497A0), fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        _pillButton(
          icon: Icons.settings,
          text: '设置',
          onPressed: () => context.go('/settings'),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2A44)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: '搜索工具：base64 / protobuf / whois ...',
          hintStyle: const TextStyle(color: Color(0xFF6B7280)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF8FA4C5)),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF8FA4C5)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildQuickActionsGrid(context, crossAxisCount: 3),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildRightPanel(context)),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 480,
            child: _buildQuickActionsGrid(context, crossAxisCount: 2),
          ),
          const SizedBox(height: 12),
          _buildRightPanel(context),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(
    BuildContext context, {
    required int crossAxisCount,
  }) {
    final keyword = _searchController.text.trim().toLowerCase();
    final data = keyword.isEmpty
        ? _quickActions
        : _quickActions
              .where(
                (item) =>
                    item.title.toLowerCase().contains(keyword) ||
                    item.subtitle.toLowerCase().contains(keyword),
              )
              .toList();

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: data.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemBuilder: (context, index) {
        final item = data[index];
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.go(item.route),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  item.color.withValues(alpha: 0.28),
                  const Color(0xFF0E1628),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: item.color.withValues(alpha: 0.45)),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.icon, color: item.color, size: 22),
                const Spacer(),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFFFFEDE5),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRightPanel(BuildContext context) {
    return Column(
      children: [
        _panelCard(
          title: '常用流程',
          child: Column(
            children: [
              _flowTile(
                title: '编码分析链路',
                subtitle: 'Base → Text → ProtoBuf',
                onTap: () => context.go('/encoding/base'),
              ),
              const SizedBox(height: 8),
              _flowTile(
                title: '网络取证链路',
                subtitle: 'DNS / WHOIS 信息收集',
                onTap: () => context.go('/network/recon'),
              ),
              const SizedBox(height: 8),
              _flowTile(
                title: '快速数值处理',
                subtitle: '2~64 进制转换与 BCD',
                onTap: () => context.go('/encoding/number'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _panelCard(
          title: '使用提示',
          child: const Text(
            '建议优先从“常用入口”进入，遇到二进制 payload 可先做 Base/Hex 归一化，再进 ProtoBuf 或文本工具解析。',
            style: TextStyle(
              color: Color(0xFFB6BDC8),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _panelCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF243042)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFE1D4),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _flowTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF121E34),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF223358)),
        ),
        child: Row(
          children: [
            const Icon(Icons.play_arrow, color: Color(0xFF8FB1FF), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFEDEFF4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9DA8B8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF7C8CA8), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _pillButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF122244),
        foregroundColor: const Color(0xFFBBD3FF),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;
}

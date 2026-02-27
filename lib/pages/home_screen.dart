import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ctf_tools/shared/layout/responsive.dart';

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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTopBar(context, isMobile: isMobile, scheme: scheme),
              const SizedBox(height: 16),
              _buildSearchBar(scheme),
              const SizedBox(height: 16),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 980) {
                      return _buildNarrowLayout(context, scheme);
                    }
                    return _buildWideLayout(context, scheme);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context, {
    required bool isMobile,
    required ColorScheme scheme,
  }) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CTF Tools 控制台',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '简洁、高效、顺手的常用工具入口',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: _pillButton(
              context: context,
              icon: Icons.settings,
              text: '设置',
              onPressed: () => context.go('/settings'),
            ),
          ),
        ],
      );
    }
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CTF Tools 控制台',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '简洁、高效、顺手的常用工具入口',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
            ),
          ],
        ),
        const Spacer(),
        _pillButton(
          context: context,
          icon: Icons.settings,
          text: '设置',
          onPressed: () => context.go('/settings'),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ColorScheme scheme) {
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: scheme.onSurface),
        decoration: InputDecoration(
          hintText: '搜索工具：base64 / protobuf / whois ...',
          hintStyle: TextStyle(color: scheme.onSurfaceVariant),
          prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: scheme.onSurfaceVariant),
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

  Widget _buildWideLayout(BuildContext context, ColorScheme scheme) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildQuickActionsGrid(
            context,
            scheme: scheme,
            crossAxisCount: 3,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(flex: 2, child: _buildRightPanel(context, scheme)),
      ],
    );
  }

  Widget _buildNarrowLayout(BuildContext context, ColorScheme scheme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildQuickActionsGrid(
            context,
            scheme: scheme,
            crossAxisCount: 2,
            shrinkWrap: true,
            scrollable: false,
          ),
          const SizedBox(height: 12),
          _buildRightPanel(context, scheme),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(
    BuildContext context, {
    required ColorScheme scheme,
    required int crossAxisCount,
    bool shrinkWrap = false,
    bool scrollable = true,
  }) {
    final allActions = _quickActions(scheme);
    final keyword = _searchController.text.trim().toLowerCase();
    final data = keyword.isEmpty
        ? allActions
        : allActions
              .where(
                (item) =>
                    item.title.toLowerCase().contains(keyword) ||
                    item.subtitle.toLowerCase().contains(keyword),
              )
              .toList();

    return GridView.builder(
      physics: scrollable
          ? const BouncingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
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
                  scheme.surfaceContainerLow,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: item.color.withValues(alpha: 0.45)),
            ),
            child: LayoutBuilder(
              builder: (context, tileConstraints) {
                final isTight = tileConstraints.maxHeight < 92;
                final innerPadding = isTight ? 10.0 : 14.0;
                return Padding(
                  padding: EdgeInsets.all(innerPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        item.icon,
                        color: item.color,
                        size: isTight ? 18 : 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: isTight ? 14 : 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        item.subtitle,
                        maxLines: isTight ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: isTight ? 11 : 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRightPanel(BuildContext context, ColorScheme scheme) {
    return Column(
      children: [
        _panelCard(
          scheme: scheme,
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
          scheme: scheme,
          title: '使用提示',
          child: Text(
            '建议优先从“常用入口”进入，遇到二进制 payload 可先做 Base/Hex 归一化，再进 ProtoBuf 或文本工具解析。',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 13,
              height: 1.6,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: scheme.onSurface,
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
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.play_arrow, color: scheme.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _pillButton({
    required BuildContext context,
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary.withValues(alpha: 0.2),
        foregroundColor: scheme.onSurface,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text, style: const TextStyle(fontSize: 12)),
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
      ),
      _QuickAction(
        title: '文本编码',
        subtitle: 'URL/HTML/Morse/Quoted-Printable',
        route: '/encoding/text',
        icon: Icons.text_fields,
        color: accents[1],
      ),
      _QuickAction(
        title: 'ProtoBuf',
        subtitle: '硬解码 + Schema 编解码',
        route: '/encoding/protobuf',
        icon: Icons.schema,
        color: accents[2],
      ),
      _QuickAction(
        title: '数值进制',
        subtitle: '2~64 进制互转 / BCD / Bin-Hex',
        route: '/encoding/number',
        icon: Icons.numbers,
        color: accents[3],
      ),
      _QuickAction(
        title: '压缩工具',
        subtitle: 'Gzip / Zlib 压缩与解压',
        route: '/encoding/compress',
        icon: Icons.compress,
        color: accents[4],
      ),
      _QuickAction(
        title: '信息收集',
        subtitle: 'DNS / WHOIS 快速查询',
        route: '/network/recon',
        icon: Icons.travel_explore,
        color: accents[5],
      ),
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
  });

  final String title;
  final String subtitle;
  final String route;
  final IconData icon;
  final Color color;
}

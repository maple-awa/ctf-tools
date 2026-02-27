import 'package:ctf_tools/features/network/widgets/dns_query_screen.dart';
import 'package:ctf_tools/features/network/widgets/whois_screen.dart';
import 'package:flutter/material.dart';
import 'package:ctf_tools/shared/layout/responsive.dart';

/// 网络信息收集页面，提供 WHOIS 与 DNS 查询标签页。
class ReconScreen extends StatelessWidget {
  const ReconScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        title: Text(
          "网络探测与信息收集",
          style: TextStyle(
            fontSize: isMobile ? 22 : 26,
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: scheme.surface,
              child: TabBar(
                isScrollable: isMobile,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language, color: scheme.onSurface),
                        const SizedBox(width: 8),
                        const Text("WHOIS"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.dns, color: scheme.onSurface),
                        const SizedBox(width: 8),
                        const Text("DNS查询"),
                      ],
                    ),
                  ),
                ],
                labelColor: scheme.primary,
                unselectedLabelColor: scheme.onSurfaceVariant,
                indicatorColor: scheme.primary,
              ),
            ),
            Expanded(
              child: TabBarView(children: [WhoisScreen(), DnsQueryScreen()]),
            ),
          ],
        ),
      ),
    );
  }
}

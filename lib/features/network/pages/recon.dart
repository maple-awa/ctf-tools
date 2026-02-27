import 'package:ctf_tools/features/network/widgets/dns_query_screen.dart';
import 'package:ctf_tools/features/network/widgets/whois_screen.dart';
import 'package:flutter/material.dart';

/// 网络信息收集页面，提供 WHOIS 与 DNS 查询标签页。
class ReconScreen extends StatelessWidget {
  const ReconScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101622),
      appBar: AppBar(
        backgroundColor: Color(0xFF101622),
        title: Text(
          "网络探测与信息收集",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFE1D4),
          ),
        ),
        centerTitle: false,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              color: Color(0xFF101622), // 保持背景色一致
              child: TabBar(
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.language, color: Colors.white),
                        SizedBox(width: 8),
                        Text("WHOIS"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.dns, color: Colors.white),
                        SizedBox(width: 8),
                        Text("DNS查询"),
                      ],
                    ),
                  ),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  WhoisScreen(),
                  DnsQueryScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

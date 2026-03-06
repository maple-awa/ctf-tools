import 'package:ctf_tools/features/network/utils/protocol_clients.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:ctf_tools/shared/widgets/tool_status_chip.dart';
import 'package:flutter/material.dart';

class HttpRequestBuilderScreen extends StatefulWidget {
  const HttpRequestBuilderScreen({super.key});

  @override
  State<HttpRequestBuilderScreen> createState() => _HttpRequestBuilderScreenState();
}

class _HttpRequestBuilderScreenState extends State<HttpRequestBuilderScreen> {
  final urlController = TextEditingController(text: 'https://example.com/api');
  final headersController = TextEditingController(text: 'User-Agent: CTF-Tools\nAccept: */*');
  final bodyController = TextEditingController();
  final tcpTargetController = TextEditingController(text: 'example.com:80');
  final tcpPayloadController = TextEditingController(text: 'GET / HTTP/1.1\r\nHost: example.com\r\n\r\n');
  final wsUrlController = TextEditingController(text: 'wss://echo.websocket.events');
  final wsPayloadController = TextEditingController(text: 'flag{ws_demo}');
  final protocolTargetController = TextEditingController(text: 'smtp.example.com:25');
  final protocolScriptController = TextEditingController(text: ProtocolClients.scriptedTemplates['SMTP']!.join('\n'));

  String method = 'GET';
  String scriptedProtocol = 'SMTP';
  String output = '';
  bool sending = false;

  @override
  void dispose() {
    urlController.dispose();
    headersController.dispose();
    bodyController.dispose();
    tcpTargetController.dispose();
    tcpPayloadController.dispose();
    wsUrlController.dispose();
    wsPayloadController.dispose();
    protocolTargetController.dispose();
    protocolScriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: ToolPageShell(
        title: '协议交互',
        description: '统一收纳 HTTP 构造+发送、WebSocket 文本客户端、TCP 文本客户端与 SMTP/FTP/POP3 最小交互。',
        badge: 'Network',
        child: Column(
          children: [
            Card(
              child: TabBar(
                isScrollable: true,
                tabs: const [
                  Tab(icon: Icon(Icons.http), text: 'HTTP'),
                  Tab(icon: Icon(Icons.cable), text: 'TCP'),
                  Tab(icon: Icon(Icons.wifi_tethering), text: 'WebSocket'),
                  Tab(icon: Icon(Icons.alt_route), text: 'SMTP/FTP/POP3'),
                ],
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            SizedBox(
              height: 900,
              child: TabBarView(
                children: [
                  _buildHttpTab(context),
                  _buildTcpTab(context),
                  _buildWebSocketTab(context),
                  _buildScriptTab(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHttpTab(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'HTTP 请求参数',
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Method', style: TextStyle(color: scheme.onSurfaceVariant)),
                    MDropdownMenu(
                      initialValue: method,
                      items: const ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
                      onChanged: (value) => setState(() {
                        method = value;
                      }),
                    ),
                    const ToolStatusChip(label: 'Real Network', icon: Icons.cloud_done_outlined),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(labelText: 'URL', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: headersController,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Headers', hintText: '每行一个 Header: Value', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Body', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(icon: Icons.description, text: '仅构造', onPressed: _buildOnly),
              MElevatedButton(icon: Icons.send, text: sending ? '发送中...' : '发送 HTTP', onPressed: sending ? null : _sendHttp),
            ],
          ),
          const SizedBox(height: kToolSectionGap),
          _outputCard(),
        ],
      ),
    );
  }

  Widget _buildTcpTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'TCP 文本客户端',
            child: Column(
              children: [
                TextField(
                  controller: tcpTargetController,
                  decoration: const InputDecoration(labelText: 'Host:Port', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tcpPayloadController,
                  maxLines: 10,
                  decoration: const InputDecoration(labelText: 'Payload', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          MElevatedButton(icon: Icons.send, text: sending ? '发送中...' : '执行 TCP 会话', onPressed: sending ? null : _runTcp),
          const SizedBox(height: kToolSectionGap),
          _outputCard(),
        ],
      ),
    );
  }

  Widget _buildWebSocketTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'WebSocket 文本客户端',
            child: Column(
              children: [
                TextField(
                  controller: wsUrlController,
                  decoration: const InputDecoration(labelText: 'WebSocket URL', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: wsPayloadController,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: 'Outgoing Message', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          MElevatedButton(icon: Icons.send, text: sending ? '发送中...' : '执行 WebSocket 会话', onPressed: sending ? null : _runWebSocket),
          const SizedBox(height: kToolSectionGap),
          _outputCard(),
        ],
      ),
    );
  }

  Widget _buildScriptTab(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: '协议模板 / 最小交互',
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('协议', style: TextStyle(color: scheme.onSurfaceVariant)),
                    MDropdownMenu(
                      initialValue: scriptedProtocol,
                      items: const ['SMTP', 'FTP', 'POP3'],
                      onChanged: (value) {
                        setState(() {
                          scriptedProtocol = value;
                          protocolScriptController.text = ProtocolClients.scriptedTemplates[value]!.join('\n');
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: protocolTargetController,
                  decoration: const InputDecoration(labelText: 'Host:Port', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: protocolScriptController,
                  maxLines: 12,
                  decoration: const InputDecoration(labelText: '脚本命令', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          MElevatedButton(icon: Icons.play_arrow, text: sending ? '执行中...' : '执行最小交互', onPressed: sending ? null : _runScriptedProtocol),
          const SizedBox(height: kToolSectionGap),
          _outputCard(),
        ],
      ),
    );
  }

  Widget _outputCard() {
    return ToolSectionCard(
      title: '输出',
      child: SelectableText(output.isEmpty ? '暂无结果' : output),
    );
  }

  void _buildOnly() {
    try {
      final result = ProtocolClients.buildHttpRequest(
        method: method,
        url: urlController.text,
        headersText: headersController.text,
        body: bodyController.text,
      );
      setState(() {
        output = result.format();
      });
    } catch (error) {
      showToast('构造失败: $error', context);
    }
  }

  Future<void> _sendHttp() async {
    await _runAsync(() => ProtocolClients.sendHttp(
          method: method,
          url: urlController.text,
          headersText: headersController.text,
          body: bodyController.text,
        ));
  }

  Future<void> _runTcp() async {
    await _runAsync(() => ProtocolClients.tcpRequest(target: tcpTargetController.text, payload: tcpPayloadController.text));
  }

  Future<void> _runWebSocket() async {
    await _runAsync(() => ProtocolClients.webSocketRequest(url: wsUrlController.text, payload: wsPayloadController.text));
  }

  Future<void> _runScriptedProtocol() async {
    await _runAsync(() => ProtocolClients.runScriptedProtocol(
          protocol: scriptedProtocol,
          target: protocolTargetController.text,
          script: protocolScriptController.text,
        ));
  }

  Future<void> _runAsync(Future<ProtocolRunResult> Function() action) async {
    setState(() {
      sending = true;
    });
    try {
      final result = await action();
      if (!mounted) {
        return;
      }
      setState(() {
        output = result.format();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      showToast('执行失败: $error', context);
      setState(() {
        output = '执行失败: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          sending = false;
        });
      }
    }
  }
}

import 'package:ctf_tools/core/route/nav_item.dart';
import 'package:ctf_tools/features/binary/pages/binary_hub.dart';
import 'package:ctf_tools/features/binary/pages/disasm_helper.dart';
import 'package:ctf_tools/features/binary/pages/exploit_helper.dart';
import 'package:ctf_tools/features/binary/pages/file_info.dart';
import 'package:ctf_tools/features/binary/pages/strings_extractor.dart';
import 'package:ctf_tools/features/crypto/pages/classical_cipher.dart';
import 'package:ctf_tools/features/crypto/pages/crypto_hub.dart';
import 'package:ctf_tools/features/crypto/pages/hash_tool.dart';
import 'package:ctf_tools/features/crypto/pages/modern_crypto.dart';
import 'package:ctf_tools/features/crypto/pages/xor_analysis.dart';
import 'package:ctf_tools/features/encoding/pages/base_codec.dart';
import 'package:ctf_tools/features/encoding/pages/compress_coder.dart';
import 'package:ctf_tools/features/encoding/pages/encoding_hub.dart';
import 'package:ctf_tools/features/encoding/pages/number_coder.dart';
import 'package:ctf_tools/features/encoding/pages/protobuf_coder.dart';
import 'package:ctf_tools/features/encoding/pages/replace_cipher.dart';
import 'package:ctf_tools/features/encoding/pages/text_codec.dart';
import 'package:ctf_tools/features/misc/pages/download_center.dart';
import 'package:ctf_tools/features/network/pages/address_tools.dart';
import 'package:ctf_tools/features/network/pages/http_request_builder.dart';
import 'package:ctf_tools/features/network/pages/network_hub.dart';
import 'package:ctf_tools/features/network/pages/recon.dart';
import 'package:ctf_tools/features/network/pages/traffic_analysis.dart';
import 'package:ctf_tools/features/stego/pages/audio_video_stego.dart';
import 'package:ctf_tools/features/stego/pages/image_stego.dart';
import 'package:ctf_tools/features/stego/pages/stego_hub.dart';
import 'package:ctf_tools/features/stego/pages/text_stego.dart';
import 'package:ctf_tools/main_layout.dart';
import 'package:ctf_tools/pages/home_screen.dart';
import 'package:ctf_tools/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final List<NavItem> navItems = [
  NavItem(
    name: '首页',
    route: '/',
    icon: Icons.dashboard,
    builder: (context, state) => const HomeScreen(),
  ),
  NavItem(
    name: '编码解码',
    route: '/encoding',
    icon: Icons.data_array,
    builder: (context, state) => const EncodingHubScreen(),
    isContainerOnly: true,
  ),
  NavItem(
    name: 'Base系列',
    route: '/encoding/base',
    icon: Icons.numbers,
    builder: (context, state) => BaseCodecScreen(),
  ),
  NavItem(
    name: '文本编码',
    route: '/encoding/text',
    icon: Icons.text_format,
    builder: (context, state) => TextEncodingScreen(),
  ),
  NavItem(
    name: 'ProtoBuf',
    route: '/encoding/protobuf',
    icon: Icons.library_books,
    builder: (context, state) => ProtobufCoder(),
  ),
  NavItem(
    name: '压缩/解压',
    route: '/encoding/compress',
    icon: Icons.compress,
    builder: (context, state) => CompressCoderScreen(),
  ),
  NavItem(
    name: '数值/进制',
    route: '/encoding/number',
    icon: Icons.calculate,
    builder: (context, state) => NumberCoder(),
  ),
  NavItem(
    name: '替换密码',
    route: '/encoding/replace',
    icon: Icons.swap_horiz,
    builder: (context, state) => const ReplaceCipherScreen(),
  ),
  NavItem(
    name: '密码学',
    route: '/crypto',
    icon: Icons.lock,
    builder: (context, state) => const CryptoHubScreen(),
    isContainerOnly: true,
  ),
  NavItem(
    name: '经典密码',
    route: '/crypto/classical',
    icon: Icons.history_edu,
    builder: (context, state) => const ClassicalCipherScreen(),
  ),
  NavItem(
    name: '现代密码',
    route: '/crypto/modern',
    icon: Icons.shield,
    builder: (context, state) => const ModernCryptoScreen(),
  ),
  NavItem(
    name: '哈希计算',
    route: '/crypto/hash',
    icon: Icons.fingerprint,
    builder: (context, state) => const HashToolScreen(),
  ),
  NavItem(
    name: '密码分析',
    route: '/crypto/analysis',
    icon: Icons.analytics,
    builder: (context, state) => const XorAnalysisScreen(),
  ),
  NavItem(
    name: '隐写工具',
    route: '/stego',
    icon: Icons.hide_image,
    builder: (context, state) => const StegoHubScreen(),
    isContainerOnly: true,
  ),
  NavItem(
    name: '图像',
    route: '/stego/image',
    icon: Icons.image_search,
    builder: (context, state) => const ImageStegoScreen(),
  ),
  NavItem(
    name: '音视频',
    route: '/stego/audio_video',
    icon: Icons.music_note,
    builder: (context, state) => const AudioVideoStegoScreen(),
  ),
  NavItem(
    name: '文本',
    route: '/stego/text',
    icon: Icons.format_size,
    builder: (context, state) => const TextStegoScreen(),
  ),
  NavItem(
    name: '网络协议',
    route: '/network',
    icon: Icons.router,
    builder: (context, state) => const NetworkHubScreen(),
    isContainerOnly: true,
  ),
  NavItem(
    name: '协议交互',
    route: '/network/interaction',
    icon: Icons.sync_alt,
    builder: (context, state) => const HttpRequestBuilderScreen(),
  ),
  NavItem(
    name: '信息收集',
    route: '/network/recon',
    icon: Icons.explore,
    builder: (context, state) => const ReconScreen(),
  ),
  NavItem(
    name: '流量分析',
    route: '/network/traffic',
    icon: Icons.timeline,
    builder: (context, state) => const TrafficAnalysisScreen(),
  ),
  NavItem(
    name: '地址扫描',
    route: '/network/scanning',
    icon: Icons.map,
    builder: (context, state) => const AddressToolsScreen(),
  ),
  NavItem(
    name: '二进制分析',
    route: '/binary',
    icon: Icons.developer_mode,
    builder: (context, state) => const BinaryHubScreen(),
    isContainerOnly: true,
  ),
  NavItem(
    name: '文件解析',
    route: '/binary/info',
    icon: Icons.file_open,
    builder: (context, state) => const BinaryFileInfoScreen(),
  ),
  NavItem(
    name: '字符串提取',
    route: '/binary/strings',
    icon: Icons.text_snippet,
    builder: (context, state) => const StringsExtractorScreen(),
  ),
  NavItem(
    name: '反汇编',
    route: '/binary/disasm',
    icon: Icons.code_off,
    builder: (context, state) => const BinaryDisasmHelperScreen(),
  ),
  NavItem(
    name: '漏洞利用',
    route: '/binary/exploit',
    icon: Icons.bug_report,
    builder: (context, state) => const BinaryExploitHelperScreen(),
  ),
  NavItem(
    name: '下载',
    route: '/download',
    icon: Icons.download,
    builder: (context, state) => const DownloadCenterScreen(),
  ),
  NavItem(
    name: '设置',
    route: '/settings',
    icon: Icons.settings,
    builder: (context, state) => const SettingsScreen(),
  ),
];

GoRouter get getRoute => GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        ...navItems.map(
          (item) => GoRoute(
            name: item.name,
            path: item.route,
            builder: item.builder,
            pageBuilder: (context, state) {
              return CustomTransitionPage<void>(
                key: state.pageKey,
                child: item.builder(context, state),
                transitionDuration: const Duration(milliseconds: 170),
                reverseTransitionDuration: const Duration(milliseconds: 130),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      final fade = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      );
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.015),
                        end: Offset.zero,
                      ).animate(fade);
                      return FadeTransition(
                        opacity: fade,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
              );
            },
          ),
        ),
      ],
    ),
  ],
);

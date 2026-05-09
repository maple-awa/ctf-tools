import 'package:ctf_tools/core/route/nav_item.dart';
import 'package:ctf_tools/features/binary/pages/disasm_helper.dart';
import 'package:ctf_tools/features/binary/pages/exploit_helper.dart';
import 'package:ctf_tools/features/binary/pages/file_info.dart';
import 'package:ctf_tools/features/binary/pages/strings_extractor.dart';
import 'package:ctf_tools/features/binary/pages/elf_parser.dart';
import 'package:ctf_tools/features/binary/pages/pe_parser.dart';
import 'package:ctf_tools/features/binary/pages/shellcode_analyzer.dart';
import 'package:ctf_tools/features/binary/pages/format_string_helper.dart';
import 'package:ctf_tools/features/crypto/pages/classical_cipher.dart';
import 'package:ctf_tools/features/crypto/pages/hash_tool.dart';
import 'package:ctf_tools/features/crypto/pages/modern_crypto.dart';
import 'package:ctf_tools/features/crypto/pages/xor_analysis.dart';
import 'package:ctf_tools/features/crypto/pages/aes_crypto.dart';
import 'package:ctf_tools/features/crypto/pages/rsa_toolkit.dart';
import 'package:ctf_tools/features/crypto/pages/ecc_toolkit.dart';
import 'package:ctf_tools/features/crypto/pages/hash_length_extension.dart';
import 'package:ctf_tools/features/crypto/pages/padding_oracle_helper.dart';
import 'package:ctf_tools/features/encoding/pages/base_codec.dart';
import 'package:ctf_tools/features/encoding/pages/compress_coder.dart';
import 'package:ctf_tools/features/encoding/pages/number_coder.dart';
import 'package:ctf_tools/features/encoding/pages/protobuf_coder.dart';
import 'package:ctf_tools/features/encoding/pages/replace_cipher.dart';
import 'package:ctf_tools/features/encoding/pages/text_codec.dart';
import 'package:ctf_tools/features/encoding/pages/url_codec.dart';
import 'package:ctf_tools/features/encoding/pages/html_entity_codec.dart';
import 'package:ctf_tools/features/encoding/pages/quoted_printable_codec.dart';
import 'package:ctf_tools/features/encoding/pages/base_variant_codec.dart';
import 'package:ctf_tools/features/encoding/pages/escape_codec.dart';
import 'package:ctf_tools/features/misc/pages/download_center.dart';
import 'package:ctf_tools/pages/app_config_screen.dart';
import 'package:ctf_tools/features/network/pages/address_tools.dart';
import 'package:ctf_tools/features/network/pages/http_request_builder.dart';
import 'package:ctf_tools/features/network/pages/recon.dart';
import 'package:ctf_tools/features/network/pages/traffic_analysis.dart';
import 'package:ctf_tools/features/network/pages/jwt_analyzer.dart';
import 'package:ctf_tools/features/network/pages/ssrf_detector.dart';
import 'package:ctf_tools/features/network/pages/crlf_injector.dart';
import 'package:ctf_tools/features/network/pages/xxe_generator.dart';
import 'package:ctf_tools/features/stego/pages/audio_video_stego.dart';
import 'package:ctf_tools/features/stego/pages/image_stego.dart';
import 'package:ctf_tools/features/stego/pages/text_stego.dart';
import 'package:ctf_tools/features/stego/pages/exif_extractor.dart';
import 'package:ctf_tools/features/stego/pages/blind_watermark_detector.dart';
import 'package:ctf_tools/features/stego/pages/file_header_fixer.dart';
import 'package:ctf_tools/features/stego/pages/qrcode_stego.dart';
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
    redirectTo: '/encoding/base',
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
    name: 'URL 编码',
    route: '/encoding/url',
    icon: Icons.link,
    builder: (context, state) => const UrlCodecScreen(),
  ),
  NavItem(
    name: 'HTML 实体',
    route: '/encoding/html',
    icon: Icons.code,
    builder: (context, state) => const HtmlEntityCodecScreen(),
  ),
  NavItem(
    name: 'Quoted-Printable',
    route: '/encoding/quoted',
    icon: Icons.print,
    builder: (context, state) => const QuotedPrintableCodecScreen(),
  ),
  NavItem(
    name: 'Base 变体',
    route: '/encoding/base-variant',
    icon: Icons.layers,
    builder: (context, state) => const BaseVariantCodecScreen(),
  ),
  NavItem(
    name: 'Escape 编码',
    route: '/encoding/escape',
    icon: Icons.forward,
    builder: (context, state) => const EscapeCodecScreen(),
  ),
  NavItem(
    name: '密码学',
    route: '/crypto',
    icon: Icons.lock,
    redirectTo: '/crypto/classical',
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
    name: 'AES 工具',
    route: '/crypto/aes',
    icon: Icons.security,
    builder: (context, state) => const AesCryptoScreen(),
  ),
  NavItem(
    name: 'RSA 工具',
    route: '/crypto/rsa',
    icon: Icons.key,
    builder: (context, state) => const RSAToolkitScreen(),
  ),
  NavItem(
    name: 'ECC 工具',
    route: '/crypto/ecc',
    icon: Icons.all_inclusive,
    builder: (context, state) => const ECCToolkitScreen(),
  ),
  NavItem(
    name: '哈希长度扩展',
    route: '/crypto/hash-length',
    icon: Icons.straighten,
    builder: (context, state) => const HashLengthExtensionScreen(),
  ),
  NavItem(
    name: 'Padding Oracle',
    route: '/crypto/padding-oracle',
    icon: Icons.warning,
    builder: (context, state) => const PaddingOracleHelperScreen(),
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
    redirectTo: '/stego/image',
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
    name: 'EXIF 提取',
    route: '/stego/exif',
    icon: Icons.info,
    builder: (context, state) => const ExifExtractorScreen(),
  ),
  NavItem(
    name: '盲水印',
    route: '/stego/watermark',
    icon: Icons.water_drop,
    builder: (context, state) => const BlindWatermarkDetectorScreen(),
  ),
  NavItem(
    name: '文件修复',
    route: '/stego/file-fix',
    icon: Icons.build,
    builder: (context, state) => const FileHeaderFixerScreen(),
  ),
  NavItem(
    name: '二维码隐写',
    route: '/stego/qrcode',
    icon: Icons.qr_code,
    builder: (context, state) => const QRCodeStegoScreen(),
  ),
  NavItem(
    name: '网络协议',
    route: '/network',
    icon: Icons.router,
    redirectTo: '/network/interaction',
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
    name: 'JWT 分析',
    route: '/network/jwt',
    icon: Icons.assignment,
    builder: (context, state) => const JWTAnalyzerScreen(),
  ),
  NavItem(
    name: 'SSRF 检测',
    route: '/network/ssrf',
    icon: Icons.public,
    builder: (context, state) => const SSRFDetectorScreen(),
  ),
  NavItem(
    name: 'CRLF 注入',
    route: '/network/crlf',
    icon: Icons.input,
    builder: (context, state) => const CRLFInjectorScreen(),
  ),
  NavItem(
    name: 'XXE 利用',
    route: '/network/xxe',
    icon: Icons.xml,
    builder: (context, state) => const XXEGeneratorScreen(),
  ),
  NavItem(
    name: '二进制分析',
    route: '/binary',
    icon: Icons.developer_mode,
    redirectTo: '/binary/info',
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
    name: 'ELF 解析',
    route: '/binary/elf',
    icon: Icons.description,
    builder: (context, state) => const ELFParserScreen(),
  ),
  NavItem(
    name: 'PE 解析',
    route: '/binary/pe',
    icon: Icons.window,
    builder: (context, state) => const PEParserScreen(),
  ),
  NavItem(
    name: 'Shellcode',
    route: '/binary/shellcode',
    icon: Icons.memory,
    builder: (context, state) => const ShellcodeAnalyzerScreen(),
  ),
  NavItem(
    name: '格式字符串',
    route: '/binary/format-string',
    icon: Icons.format_quote,
    builder: (context, state) => const FormatStringHelperScreen(),
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
  NavItem(
    name: '应用配置',
    route: '/settings/config',
    icon: Icons.tune,
    builder: (context, state) => const AppConfigScreen(),
  ),
  NavItem(
    name: '下载',
    route: '/download',
    icon: Icons.download,
    builder: (context, state) => const DownloadCenterScreen(),
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
          (item) => item.builder != null
              ? GoRoute(
                  name: item.name,
                  path: item.route,
                  builder: item.builder,
                  pageBuilder: (context, state) {
                    return CustomTransitionPage<void>(
                      key: state.pageKey,
                      child: item.builder!(context, state),
                      transitionDuration: const Duration(milliseconds: 170),
                      reverseTransitionDuration: const Duration(
                        milliseconds: 130,
                      ),
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
                              child: SlideTransition(
                                position: slide,
                                child: child,
                              ),
                            );
                          },
                    );
                  },
                )
              : GoRoute(
                  name: item.name,
                  path: item.route,
                  redirect: (context, state) => item.redirectTo ?? '/',
                ),
        ),
      ],
    ),
  ],
);

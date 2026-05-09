import 'package:flutter/material.dart';
import 'package:ctf_tools/shared/widgets/code_editor.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:pointycastle/export.dart';

class AesCryptoScreen extends StatefulWidget {
  const AesCryptoScreen({super.key});

  @override
  State<AesCryptoScreen> createState() => _AesCryptoScreenState();
}

class _AesCryptoScreenState extends State<AesCryptoScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  final TextEditingController _ivController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  
  String _mode = 'CBC';
  String _padding = 'PKCS7';
  String _keySize = '128';
  String _operation = 'encrypt';

  List<int> _padData(List<int> data, int blockSize) {
    final paddingLength = blockSize - (data.length % blockSize);
    return data + List.filled(paddingLength, paddingLength);
  }

  List<int> _unpadData(List<int> data) {
    if (data.isEmpty) return data;
    final paddingLength = data.last;
    if (paddingLength > data.length || paddingLength == 0) {
      throw Exception('Invalid padding');
    }
    return data.sublist(0, data.length - paddingLength);
  }

  List<int> _generateKey() {
    final keyBytes = utf8.encode(_keyController.text);
    final keySize = int.parse(_keySize);
    
    if (keyBytes.length >= keySize ~/ 8) {
      return keyBytes.sublist(0, keySize ~/ 8);
    }
    
    // 如果密钥太短，用 SHA256 扩展
    final hash = sha256.convert(keyBytes).bytes;
    return hash.sublist(0, keySize ~/ 8);
  }

  List<int> _generateIV() {
    if (_ivController.text.isNotEmpty) {
      final ivBytes = utf8.encode(_ivController.text);
      if (ivBytes.length >= 16) {
        return ivBytes.sublist(0, 16);
      }
      return ivBytes + List.filled(16 - ivBytes.length, 0);
    }
    // 生成随机 IV
    final random = Random.secure();
    return List<int>.generate(16, (_) => random.nextInt(256));
  }

  List<int> _aesEncrypt(List<int> data, List<int> key, List<int> iv) {
    final paddedData = _padData(data, 16);
    
    final cipher = PaddedBlockCipher(
      BlockCipher('AES/${_mode.toUpperCase()}'),
      BlockCipherPadding('PKCS7'),
    );
    
    cipher.init(true, KeyParameter(key), ParametersWithIV(null, iv));
    
    final output = <int>[];
    var offset = 0;
    while (offset < paddedData.length) {
      final processed = cipher.process(paddedData.sublist(offset, offset + 16));
    offset += 16;
      output.addAll(processed);
    }
    
    return output;
  }

  List<int> _aesDecrypt(List<int> data, List<int> key, List<int> iv) {
    final cipher = PaddedBlockCipher(
      BlockCipher('AES/${_mode.toUpperCase()}'),
      BlockCipherPadding('PKCS7'),
    );
    
    cipher.init(false, KeyParameter(key), ParametersWithIV(null, iv));
    
    final output = <int>[];
    var offset = 0;
    while (offset < data.length) {
      final chunkSize = (data.length - offset < 16) ? data.length - offset : 16;
      final processed = cipher.process(data.sublist(offset, offset + chunkSize));
      offset += chunkSize;
      output.addAll(processed);
    }
    
    return _unpadData(output);
  }

  void _process() {
    try {
      final inputData = utf8.encode(_inputController.text);
      final key = _generateKey();
      final iv = _generateIV();
      
      List<int> result;
      if (_operation == 'encrypt') {
        result = _aesEncrypt(inputData, key, iv);
        setState(() {
          _outputController.text = 'IV: ${_bytesToHex(iv)}\n${_bytesToBase64(result)}';
        });
      } else {
        result = _aesDecrypt(inputData, key, iv);
        setState(() {
          _outputController.text = utf8.decode(result);
        });
      }
    } catch (e) {
      setState(() {
        _outputController.text = '操作失败：${e.toString()}';
      });
    }
  }

  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  String _bytesToBase64(List<int> bytes) {
    return base64.encode(bytes);
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
    });
  }

  void _copyOutput() {
    if (_outputController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AES 加解密工具',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '支持 AES-128/192/256，ECB/CBC 模式，PKCS7 填充。',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _operation,
                          decoration: const InputDecoration(
                            labelText: '操作',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'encrypt', child: Text('加密')),
                            DropdownMenuItem(value: 'decrypt', child: Text('解密')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _operation = value!;
                              if (value == 'encrypt') {
                                _mode = 'CBC';
                              }
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _keySize,
                          decoration: const InputDecoration(
                            labelText: '密钥长度',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: '128', child: Text('AES-128')),
                            DropdownMenuItem(value: '192', child: Text('AES-192')),
                            DropdownMenuItem(value: '256', child: Text('AES-256')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _keySize = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _mode,
                          decoration: const InputDecoration(
                            labelText: '模式',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'CBC', child: Text('CBC')),
                            DropdownMenuItem(value: 'ECB', child: Text('ECB')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _mode = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _padding,
                          decoration: const InputDecoration(
                            labelText: '填充',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'PKCS7', child: Text('PKCS7')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _padding = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _keyController,
                    decoration: const InputDecoration(
                      labelText: '密钥 (Key)',
                      border: OutlineInputBorder(),
                      helperText: '留空则自动生成',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ivController,
                    decoration: InputDecoration(
                      labelText: '初始化向量 (IV)',
                      border: const OutlineInputBorder(),
                      helperText: _operation == 'decrypt' ? '解密时必填' : '留空则自动生成',
                    ),
                    enabled: _operation == 'decrypt' || _mode == 'CBC',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _clear,
                        icon: const Icon(Icons.clear),
                        label: const Text('清空'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _copyOutput,
                        icon: const Icon(Icons.content_copy),
                        label: const Text('复制'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CodeEditor(
            controller: _inputController,
            label: _operation == 'encrypt' ? '明文' : '密文 (Base64)',
            height: 150,
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _process,
              icon: Icon(_operation == 'encrypt' ? Icons.lock : Icons.lock_open),
              label: Text(_operation == 'encrypt' ? '加密' : '解密'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CodeEditor(
            controller: _outputController,
            label: _operation == 'encrypt' ? '密文' : '明文',
            height: 150,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _keyController.dispose();
    _ivController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}

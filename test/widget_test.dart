// 基础冒烟测试：验证解密逻辑与占位组件可构建。
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:recall_admin/core/audio/myenc_audio_service.dart';

void main() {
  test('myenc decrypt 还原 XOR 明文', () {
    // encryptedKey = 0x00 -> realKey = 0x97；body 每字节 ^ 0x97。
    final input = Uint8List.fromList(<int>[0x00, 0x97, 0x00, 0xFF]);
    final out = MyencAudioService.decrypt(input);
    expect(out, equals(<int>[0x00, 0x97, 0x68]));
  });
}

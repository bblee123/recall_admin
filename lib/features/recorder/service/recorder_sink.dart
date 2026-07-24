import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 录音转存目标抽象：把临时录音文件保存到最终位置。
///
/// 当前提供 [LocalFileSink]（本地目录）。将来接 Cloudflare R2
/// 时新增 `R2Sink implements RecorderSink` 即可，无需改动 UI / Cubit。
abstract class RecorderSink {
  /// 将 [tempFile] 保存为最终产物，返回最终定位（本地路径或远端 URL/key）。
  ///
  /// [preferredName] 为期望文件名（不含目录），实现可据此命名。
  Future<String> save(File tempFile, {String? preferredName});
}

/// 本地文件转存：复制到指定目录（null 时用系统文档目录）。
class LocalFileSink implements RecorderSink {
  const LocalFileSink({this.directory});

  /// 目标目录；null 时落到系统文档目录下的 `recordings/`。
  final String? directory;

  @override
  Future<String> save(File tempFile, {String? preferredName}) async {
    final dirPath = directory ?? await _defaultDir();
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final ext = p.extension(tempFile.path);
    final baseName = preferredName != null && preferredName.isNotEmpty
        ? _ensureExt(preferredName, ext)
        : p.basename(tempFile.path);
    final target = _uniquePath(dirPath, baseName);

    final saved = await tempFile.copy(target);
    return saved.path;
  }

  Future<String> _defaultDir() async {
    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, 'recordings');
  }

  String _ensureExt(String name, String ext) {
    if (ext.isEmpty) return name;
    return p.extension(name).toLowerCase() == ext.toLowerCase()
        ? name
        : '$name$ext';
  }

  /// 避免覆盖：若同名存在则追加 `_1`、`_2`…
  String _uniquePath(String dirPath, String fileName) {
    final ext = p.extension(fileName);
    final stem = p.basenameWithoutExtension(fileName);
    var candidate = p.join(dirPath, fileName);
    var i = 1;
    while (File(candidate).existsSync()) {
      candidate = p.join(dirPath, '${stem}_$i$ext');
      i++;
    }
    return candidate;
  }
}

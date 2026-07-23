import 'dart:io';

import 'package:file_picker/file_picker.dart';

export 'package:file_picker/file_picker.dart' show FileType;

/// 选择单个文件（桌面走 NSOpenPanel）。返回 null 表示取消。
Future<File?> pickSingleFile({
  FileType type = FileType.any,
  List<String>? allowedExtensions,
}) async {
  final result = await FilePicker.pickFiles(
    type: type,
    allowedExtensions: allowedExtensions,
    withData: false,
  );
  final path = result?.files.single.path;
  if (path == null) return null;
  return File(path);
}

/// 选择单张图片文件。
Future<File?> pickImageFile() => pickSingleFile(
      type: FileType.custom,
      allowedExtensions: const <String>['jpg', 'jpeg', 'png', 'webp'],
    );

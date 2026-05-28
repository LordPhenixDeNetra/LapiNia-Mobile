import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileShareService {
  Future<String> saveBytes({
    required List<int> bytes,
    required String filename,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}$filename');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<void> shareFile({
    required String path,
    String? mimeType,
  }) async {
    await Share.shareXFiles(
      [XFile(path, mimeType: mimeType)],
    );
  }
}


import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'drm.dart';

class BookCache {
  Future<File?> storeEncrypted(String bookId, Uint8List encrypted) async {
    if (kIsWeb) return null;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/book_$bookId.enc');
    await file.writeAsBytes(encrypted, flush: true);
    return file;
  }

  Future<Uint8List?> readDecrypted(String bookId) async {
    if (kIsWeb) return null;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/book_$bookId.enc');
    if (!await file.exists()) return null;
    final encrypted = await file.readAsBytes();
    final decrypted = drmXor(encrypted);
    return Uint8List.fromList(decrypted);
  }
}

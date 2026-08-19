import 'dart:io';
import 'package:hive/hive.dart';

class HiveService {
  Box get recentBox {
    if (Hive.isBoxOpen('recent_pdfs')) {
      return Hive.box('recent_pdfs');
    }
    throw StateError('recent_pdfs box is not open. Ensure Hive.openBox is called.');
  }

  Future<void> savePdf(String path, String name) async {
    int fileSize = 0;
    try {
      final file = File(path);
      if (file.existsSync()) {
        fileSize = file.lengthSync();
      }
    } catch (_) {}

    await recentBox.put(path, {
      'name': name,
      'path': path,
      'lastOpened': DateTime.now().toIso8601String(),
      'size': fileSize,
    });
  }

  List<Map<String, dynamic>> getRecentPdfs() {
    final List<Map<String, dynamic>> list = [];
    for (var key in recentBox.keys) {
      final val = recentBox.get(key);
      if (val is Map) {
        list.add(Map<String, dynamic>.from(val));
      }
    }

    list.sort((a, b) {
      final aDate =
          DateTime.tryParse(a['lastOpened']?.toString() ?? '') ??
          DateTime(1970);
      final bDate =
          DateTime.tryParse(b['lastOpened']?.toString() ?? '') ??
          DateTime(1970);
      return bDate.compareTo(aDate);
    });

    return list;
  }

  Future<void> deletePdf(String path) async {
    await recentBox.delete(path);
  }

  Future<void> clearRecentPdfs() async {
    await recentBox.clear();
  }
}

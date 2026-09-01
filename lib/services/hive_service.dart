import 'dart:io';
import 'package:hive/hive.dart';

class HiveService {
  Box? get recentBox {
    if (Hive.isBoxOpen('recent_pdfs')) {
      return Hive.box('recent_pdfs');
    }
    return null;
  }

  Future<void> savePdf(String path, String name) async {
    try {
      if (!Hive.isBoxOpen('recent_pdfs')) {
        return;
      }

      int fileSize = 0;
      try {
        final file = File(path);
        if (file.existsSync()) {
          fileSize = file.lengthSync();
        }
      } catch (_) {}

      await Hive.box('recent_pdfs').put(path, {
        'name': name,
        'path': path,
        'lastOpened': DateTime.now().toIso8601String(),
        'size': fileSize,
      });
    } catch (_) {}
  }

  List<Map<String, dynamic>> getRecentPdfs() {
    try {
      if (!Hive.isBoxOpen('recent_pdfs')) {
        return [];
      }
      final box = Hive.box('recent_pdfs');
      final List<Map<String, dynamic>> list = [];
      for (var key in box.keys) {
        final val = box.get(key);
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
    } catch (_) {
      return [];
    }
  }

  Future<void> deletePdf(String path) async {
    try {
      if (!Hive.isBoxOpen('recent_pdfs')) return;
      await Hive.box('recent_pdfs').delete(path);
    } catch (_) {}
  }

  Future<void> clearRecentPdfs() async {
    try {
      if (!Hive.isBoxOpen('recent_pdfs')) return;
      await Hive.box('recent_pdfs').clear();
    } catch (_) {}
  }
}

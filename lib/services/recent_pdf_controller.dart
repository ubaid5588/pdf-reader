import 'dart:io';
import 'package:file_reader/services/hive_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class RecentPdfController extends GetxController {
  final HiveService hiveService = HiveService();

  final RxList<Map<String, dynamic>> recentPdfs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentPdfs();
  }

  Future<void> loadRecentPdfs() async {
    // If Hive is not initialized (e.g. unit tests), preserve the
    // current in-memory state set by addRecentPdf()
    if (!Hive.isBoxOpen('recent_pdfs')) {
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final rawList = hiveService.getRecentPdfs();
      final validList = <Map<String, dynamic>>[];

      for (var item in rawList) {
        final path = item['path'] as String?;
        if (path != null) {
          final file = File(path);
          if (await file.exists()) {
            validList.add(item);
          }
        }
      }

      recentPdfs.assignAll(validList);
    } catch (e) {
      debugPrint('Error loading recent PDFs: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addRecentPdf(String path, [String? name]) async {
    try {
      final fileName = name ?? path.split(Platform.pathSeparator).last;

      // Optimistic in-memory update so the UI reflects the change immediately
      // and tests work without Hive being initialized.
      int fileSize = 0;
      try {
        final f = File(path);
        if (f.existsSync()) {
          fileSize = f.lengthSync();
        }
      } catch (_) {}

      final entry = <String, dynamic>{
        'name': fileName,
        'path': path,
        'lastOpened': DateTime.now().toIso8601String(),
        'size': fileSize,
      };

      recentPdfs.removeWhere((item) => item['path'] == path);
      recentPdfs.insert(0, entry);

      // Persist to Hive (no-op if Hive is not initialized)
      await hiveService.savePdf(path, fileName);

      // Reload from Hive to get any other changes (no-op if Hive not open)
      await loadRecentPdfs();
    } catch (e) {
      debugPrint('Error saving recent PDF: $e');
    }
  }

  Future<void> removeRecentPdf(String path) async {
    try {
      recentPdfs.removeWhere((item) => item['path'] == path);
      await hiveService.deletePdf(path);
      loadRecentPdfs();
    } catch (e) {
      debugPrint('Error removing recent PDF: $e');
    }
  }

  Future<void> clearRecentPdfs() async {
    try {
      await hiveService.clearRecentPdfs();
      recentPdfs.clear();
    } catch (e) {
      debugPrint('Error clearing recent PDFs: $e');
    }
  }

  static String formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double count = bytes.toDouble();
    while (count >= 1024 && i < suffixes.length - 1) {
      count /= 1024;
      i++;
    }
    return '${count.toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}

import 'dart:io';
import 'package:file_reader/services/hive_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class RecentPdfController extends GetxController {
  final HiveService hiveService = HiveService();

  final RxList<Map<String, dynamic>> recentPdfs = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRecentPdfs();
  }

  void loadRecentPdfs() {
    try {
      isLoading.value = true;
      final rawList = hiveService.getRecentPdfs();
      final validList = <Map<String, dynamic>>[];

      for (var item in rawList) {
        final path = item['path'] as String?;
        if (path != null) {
          final file = File(path);
          if (file.existsSync()) {
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
      await hiveService.savePdf(path, fileName);
      loadRecentPdfs();
    } catch (e) {
      debugPrint('Error saving recent PDF: $e');
    }
  }

  Future<void> removeRecentPdf(String path) async {
    try {
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

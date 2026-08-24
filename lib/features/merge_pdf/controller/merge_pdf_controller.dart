import 'dart:io';
import 'dart:ui';
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class MergePdfController extends GetxController {
  RxList<File> pdfFiles = <File>[].obs;
  RxBool isLoading = false.obs;
  RxBool isMerging = false.obs;

  RxList<File> selectedForMerge = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPdfs();
  }

  Future<void> loadPdfs() async {
    try {
      isLoading.value = true;
      if (Get.isRegistered<FilePageController>()) {
        final fileController = Get.find<FilePageController>();
        if (fileController.pdfFiles.isNotEmpty) {
          pdfFiles.value = fileController.pdfFiles.where((f) => f.existsSync()).toList();
          return;
        }
      }

      final searchPaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0',
      ];
      final List<File> loaded = [];

      for (var path in searchPaths) {
        final dir = Directory(path);
        if (await dir.exists()) {
          try {
            final files = dir
                .listSync(recursive: false)
                .whereType<File>()
                .where((f) => f.path.toLowerCase().endsWith('.pdf') && f.existsSync());
            loaded.addAll(files);
          } catch (_) {}
        }
      }

      final unique = <String, File>{};
      for (var f in loaded) {
        unique[f.path] = f;
      }
      pdfFiles.value = unique.values.toList();
    } catch (e) {
      print("PDF load error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSelection(File file) {
    if (selectedForMerge.any((f) => f.path == file.path)) {
      selectedForMerge.removeWhere((f) => f.path == file.path);
    } else {
      selectedForMerge.add(file);
    }
  }

  void clearSelection() => selectedForMerge.clear();

  Future<File> mergeSelectedPdfs({
    String? outputName,
    void Function(double progress, String status)? onProgress,
  }) async {
    if (selectedForMerge.length < 2) {
      throw Exception('Please select at least 2 PDF files to merge.');
    }

    try {
      isMerging.value = true;
      onProgress?.call(0.1, 'Preparing merge workspace...');

      final PdfDocument finalDocument = PdfDocument();
      finalDocument.pageSettings.margins.all = 0;

      final total = selectedForMerge.length;
      int successfulPages = 0;

      for (int fIndex = 0; fIndex < total; fIndex++) {
        final file = selectedForMerge[fIndex];
        final fileName = file.path.split(Platform.pathSeparator).last;

        if (!file.existsSync()) {
          throw Exception('The file "$fileName" could not be found or was moved.');
        }

        final progressPct = 0.15 + (0.65 * ((fIndex + 1) / total));
        onProgress?.call(
          progressPct,
          'Merging document ${fIndex + 1} of $total ($fileName)...',
        );

        final bytes = await file.readAsBytes();
        if (bytes.isEmpty) {
          throw Exception('The file "$fileName" is empty (0 bytes).');
        }

        PdfDocument sourceDoc;
        try {
          sourceDoc = PdfDocument(inputBytes: bytes);
        } catch (e) {
          final errorStr = e.toString().toLowerCase();
          if (errorStr.contains('password') || errorStr.contains('encrypted')) {
            throw Exception('"$fileName" is password protected. Please unlock it first.');
          }
          throw Exception('Failed to read "$fileName". The file may be corrupted or unsupported.');
        }

        final pageCount = sourceDoc.pages.count;
        if (pageCount == 0) {
          sourceDoc.dispose();
          throw Exception('"$fileName" contains no pages.');
        }

        for (int i = 0; i < pageCount; i++) {
          final PdfPage sourcePage = sourceDoc.pages[i];
          final Size pageSize = sourcePage.size;

          final PdfPage newPage = finalDocument.pages.add();
          newPage.graphics.drawPdfTemplate(
            sourcePage.createTemplate(),
            const Offset(0, 0),
            pageSize,
          );
          successfulPages++;
        }

        sourceDoc.dispose();
      }

      if (successfulPages == 0) {
        finalDocument.dispose();
        throw Exception('No pages were found to merge.');
      }

      onProgress?.call(0.85, 'Encoding merged document...');
      final List<int> bytes = await finalDocument.save();
      finalDocument.dispose();

      onProgress?.call(0.92, 'Saving to device storage...');
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final name = outputName ?? 'merged-pdf-$dateStr.pdf';

      final savedPath = await PdfStorageService.savePdfToDownloads(
        pdfBytes: bytes,
        fileName: name,
      );

      onProgress?.call(1.0, 'Finalizing...');

      selectedForMerge.clear();

      if (savedPath == null) {
        throw Exception('Failed to save merged PDF to storage');
      }

      try {
        final recentController = Get.isRegistered<RecentPdfController>()
            ? Get.find<RecentPdfController>()
            : Get.put(RecentPdfController());
        await recentController.addRecentPdf(savedPath, name);

        if (Get.isRegistered<FilePageController>()) {
          await Get.find<FilePageController>().refreshPdfs();
        }
      } catch (_) {}

      return File(savedPath);
    } catch (e) {
      rethrow;
    } finally {
      isMerging.value = false;
    }
  }
}

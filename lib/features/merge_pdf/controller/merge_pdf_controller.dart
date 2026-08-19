import 'dart:io';
import 'dart:ui';
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:get/get.dart';
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
          pdfFiles.value = fileController.pdfFiles;
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
                .where((f) => f.path.toLowerCase().endsWith('.pdf'));
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
      onProgress?.call(0.15, 'Preparing merge workspace...');

      final PdfDocument finalDocument = PdfDocument();
      final total = selectedForMerge.length;

      for (int fIndex = 0; fIndex < total; fIndex++) {
        final file = selectedForMerge[fIndex];
        final fileName = file.path.split(Platform.pathSeparator).last;
        final progressPct = 0.2 + (0.6 * ((fIndex + 1) / total));

        onProgress?.call(
          progressPct,
          'Merging document ${fIndex + 1} of $total ($fileName)...',
        );

        final bytes = await file.readAsBytes();
        final PdfDocument sourceDoc = PdfDocument(inputBytes: bytes);

        for (int i = 0; i < sourceDoc.pages.count; i++) {
          final PdfPage sourcePage = sourceDoc.pages[i];
          final Size pageSize = sourcePage.size;

          finalDocument.pageSettings.size = pageSize;
          finalDocument.pageSettings.margins.all = 0;

          final PdfTemplate template = sourcePage.createTemplate();
          final PdfPage newPage = finalDocument.pages.add();

          newPage.graphics.drawPdfTemplate(
            template,
            const Offset(0, 0),
            pageSize,
          );
        }

        sourceDoc.dispose();
      }

      onProgress?.call(0.85, 'Finalizing merged document...');
      final List<int> bytes = await finalDocument.save();
      finalDocument.dispose();

      onProgress?.call(0.92, 'Saving to device storage...');
      final name =
          outputName ?? 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final savedPath = await PdfStorageService.savePdfToDownloads(
        pdfBytes: bytes,
        fileName: name,
      );

      onProgress?.call(1.0, 'Finalizing...');

      selectedForMerge.clear();

      try {
        if (Get.isRegistered<FilePageController>()) {
          await Get.find<FilePageController>().refreshPdfs();
        }
      } catch (_) {}

      if (savedPath != null) {
        return File(savedPath);
      }
      throw Exception('Failed to save merged PDF');
    } catch (e) {
      rethrow;
    } finally {
      isMerging.value = false;
    }
  }
}

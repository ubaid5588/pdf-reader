import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class SplitPdfController extends GetxController {
  RxBool isLoading = false.obs;

  Future<File?> pickPdfFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;
      final path = result.files.single.path;
      if (path == null) return null;
      return File(path);
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e');
      return null;
    }
  }

  Future<File> splitPdf(
    File sourceFile, {
    void Function(double progress, String status)? onProgress,
  }) async {
    try {
      isLoading.value = true;
      onProgress?.call(0.2, 'Analyzing PDF document pages...');

      final bytes = await sourceFile.readAsBytes();
      final PdfDocument sourceDoc = PdfDocument(inputBytes: bytes);
      final int totalPages = sourceDoc.pages.count;

      if (totalPages == 0) {
        throw Exception('The PDF contains no pages.');
      }

      final baseName = sourceFile.path
          .split(Platform.pathSeparator)
          .last
          .replaceAll('.pdf', '');

      File? firstOutputFile;

      for (int i = 0; i < totalPages; i++) {
        final progressPct = 0.25 + (0.6 * ((i + 1) / totalPages));
        onProgress?.call(
          progressPct,
          'Splitting page ${i + 1} of $totalPages...',
        );

        final PdfDocument newDoc = PdfDocument();
        final PdfPage sourcePage = sourceDoc.pages[i];
        final Size pageSize = sourcePage.size;

        newDoc.pageSettings.size = pageSize;
        newDoc.pageSettings.margins.all = 0;

        final PdfTemplate template = sourcePage.createTemplate();
        final PdfPage newPage = newDoc.pages.add();
        newPage.graphics.drawPdfTemplate(
          template,
          const Offset(0, 0),
          pageSize,
        );

        final splitBytes = await newDoc.save();
        newDoc.dispose();

        final splitFileName = '${baseName}_page_${i + 1}.pdf';
        final savedPath = await PdfStorageService.savePdfToDownloads(
          pdfBytes: splitBytes,
          fileName: splitFileName,
        );

        if (savedPath != null && firstOutputFile == null) {
          firstOutputFile = File(savedPath);
        }
      }

      sourceDoc.dispose();

      onProgress?.call(1.0, 'Finalizing $totalPages pages...');

      try {
        if (Get.isRegistered<FilePageController>()) {
          await Get.find<FilePageController>().refreshPdfs();
        }
      } catch (_) {}

      if (firstOutputFile != null) {
        return firstOutputFile;
      }
      throw Exception('Failed to split PDF');
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}

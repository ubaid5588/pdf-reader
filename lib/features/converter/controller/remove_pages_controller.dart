import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class RemovePagesController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<File?> selectedFile = Rx<File?>(null);
  RxInt totalPages = 0.obs;
  RxSet<int> pagesToRemove = <int>{}.obs; // 1-based page numbers
  String? pdfPassword;

  int get remainingPagesCount => totalPages.value - pagesToRemove.length;

  /// Pick a PDF file
  Future<File?> pickPdfFile() async {
    try {
      final result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;
      final path = result.files.single.path;
      if (path == null) return null;

      final file = File(path);
      if (!await file.exists()) {
        Get.snackbar('Error', 'Selected file not found');
        return null;
      }

      return file;
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e');
      return null;
    }
  }

  /// Inspects PDF and loads page count
  Future<int> inspectPdf(File file, {String? password}) async {
    isLoading.value = true;
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Selected PDF is empty (0 bytes).');
      }

      PdfDocument document;
      try {
        document = PdfDocument(inputBytes: bytes, password: password);
      } catch (e) {
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('password') || errorStr.contains('encrypted')) {
          throw Exception('PASSWORD_REQUIRED');
        }
        throw Exception('Failed to read PDF. The document may be corrupted or unsupported.');
      }

      final count = document.pages.count;
      document.dispose();

      if (count == 0) {
        throw Exception('The PDF contains no pages.');
      }

      selectedFile.value = file;
      totalPages.value = count;
      pagesToRemove.clear();
      pdfPassword = password;

      return count;
    } finally {
      isLoading.value = false;
    }
  }

  void togglePageRemoval(int pageNumber) {
    if (pagesToRemove.contains(pageNumber)) {
      pagesToRemove.remove(pageNumber);
    } else {
      if (pagesToRemove.length >= totalPages.value - 1) {
        Get.snackbar(
          'Cannot Remove All Pages',
          'At least one page must remain in the document.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      pagesToRemove.add(pageNumber);
    }
  }

  void clearSelection() {
    pagesToRemove.clear();
  }

  /// Removes selected pages and creates a new PDF with the remaining pages
  Future<File> generatePdfWithoutRemovedPages({
    void Function(double progress, String status)? onProgress,
  }) async {
    final file = selectedFile.value;
    if (file == null || !file.existsSync()) {
      throw Exception('Source PDF file not found.');
    }

    if (pagesToRemove.isEmpty) {
      throw Exception('Please select at least one page to remove.');
    }

    if (remainingPagesCount <= 0) {
      throw Exception('Cannot remove all pages. At least one page must remain.');
    }

    try {
      isLoading.value = true;
      onProgress?.call(0.15, 'Reading source PDF document...');

      final bytes = await file.readAsBytes();
      final PdfDocument sourceDoc = PdfDocument(
        inputBytes: bytes,
        password: pdfPassword,
      );

      final PdfDocument newDoc = PdfDocument();
      newDoc.pageSettings.margins.all = 0;

      final total = sourceDoc.pages.count;
      int copiedCount = 0;

      for (int i = 0; i < total; i++) {
        final pageNum = i + 1;
        if (pagesToRemove.contains(pageNum)) {
          continue; // Skip removed pages
        }

        copiedCount++;
        final progressPct = 0.2 + (0.65 * (copiedCount / remainingPagesCount));
        onProgress?.call(
          progressPct,
          'Writing page $pageNum ($copiedCount of $remainingPagesCount)...',
        );

        final PdfPage sourcePage = sourceDoc.pages[i];
        final Size pageSize = sourcePage.size;

        final PdfPage newPage = newDoc.pages.add();
        newPage.graphics.drawPdfTemplate(
          sourcePage.createTemplate(),
          const Offset(0, 0),
          pageSize,
        );
      }

      sourceDoc.dispose();

      onProgress?.call(0.88, 'Encoding updated document...');
      final resultBytes = await newDoc.save();
      newDoc.dispose();

      onProgress?.call(0.93, 'Saving to device storage...');
      final originalName = file.path.split(Platform.pathSeparator).last;
      final fileName = PdfStorageService.generateRemovePagesPdfFileName(
        originalFileName: originalName,
      );

      final savedPath = await PdfStorageService.savePdfToDownloads(
        pdfBytes: resultBytes,
        fileName: fileName,
      );

      onProgress?.call(1.0, 'Finalizing...');

      if (savedPath == null) {
        throw Exception('Failed to save PDF to storage');
      }

      try {
        final recentController = Get.isRegistered<RecentPdfController>()
            ? Get.find<RecentPdfController>()
            : Get.put(RecentPdfController());
        await recentController.addRecentPdf(savedPath, fileName);

        if (Get.isRegistered<FilePageController>()) {
          await Get.find<FilePageController>().refreshPdfs();
        }
      } catch (_) {}

      return File(savedPath);
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class CompressPdfController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString compressionStatus = ''.obs;

  Future<File?> pickPdfFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
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

  Future<File> compressPdf(
    File sourceFile, {
    void Function(double progress, String status)? onProgress,
  }) async {
    isLoading.value = true;
    try {
      onProgress?.call(0.2, 'Analyzing document structure...');
      final bytes = await sourceFile.readAsBytes();

      onProgress?.call(0.45, 'Optimizing images and fonts...');
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      document.compressionLevel = PdfCompressionLevel.best;

      onProgress?.call(0.75, 'Rebuilding compressed document...');
      final List<int> compressedBytes = await document.save();
      document.dispose();

      onProgress?.call(0.9, 'Saving to device storage...');
      final fileName = sourceFile.path.split(Platform.pathSeparator).last;
      final savedPath = await PdfStorageService.savePdfToDownloads(
        pdfBytes: compressedBytes,
        fileName: 'compressed_$fileName',
      );

      onProgress?.call(1.0, 'Finalizing...');

      if (savedPath == null) {
        throw Exception('Failed to save compressed PDF');
      }

      try {
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

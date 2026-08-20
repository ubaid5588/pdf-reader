import 'dart:io';
import 'dart:ui';

import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ImageToPdfController extends GetxController {
  final ImagePicker imagePicker = ImagePicker();

  RxList<String> imagePaths = <String>[].obs;
  RxBool isProcessing = false.obs;
  RxString processingStatus = ''.obs;

  Future<List<String>?> pickImageFiles() async {
    try {
      final images = await imagePicker.pickMultiImage();
      if (images.isEmpty) return null;
      final paths = images.map((e) => e.path).toList();
      imagePaths.value = paths;
      return paths;
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick images: $e');
      return null;
    }
  }

  Future<File> createPdfFromImages(
    List<String> paths, {
    void Function(double progress, String status)? onProgress,
  }) async {
    if (paths.isEmpty) {
      throw Exception('No images selected to convert');
    }

    try {
      isProcessing.value = true;
      final PdfDocument document = PdfDocument();
      final total = paths.length;

      for (int i = 0; i < total; i++) {
        final progressPct = 0.2 + (0.6 * ((i + 1) / total));
        onProgress?.call(
          progressPct,
          'Processing image ${i + 1} of $total...',
        );

        final bytes = await File(paths[i]).readAsBytes();
        final page = document.pages.add();
        final image = PdfBitmap(bytes);

        page.graphics.drawImage(
          image,
          Rect.fromLTWH(
            0,
            0,
            page.getClientSize().width,
            page.getClientSize().height,
          ),
        );
      }

      onProgress?.call(0.85, 'Finalizing and encoding PDF...');
      final pdfBytes = await document.save();
      document.dispose();

      onProgress?.call(0.92, 'Saving to device Downloads...');
      final fileName = PdfStorageService.generateConversionFileName(
        imagePaths: paths,
      );

      final savedPath = await PdfStorageService.savePdfToDownloads(
        pdfBytes: pdfBytes,
        fileName: fileName,
      );

      if (savedPath == null) {
        throw Exception('Failed to save PDF to storage');
      }

      onProgress?.call(1.0, 'Finalizing...');

      try {
        if (Get.isRegistered<FilePageController>()) {
          await Get.find<FilePageController>().refreshPdfs();
        }
      } catch (_) {}

      return File(savedPath);
    } catch (e) {
      rethrow;
    } finally {
      isProcessing.value = false;
    }
  }

  void clearImages() {
    imagePaths.clear();
  }
}

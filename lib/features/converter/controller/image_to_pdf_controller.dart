import 'dart:io';
import 'dart:ui';

import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ImageToPdfController extends GetxController {
  final ImagePicker imagePicker = ImagePicker();

  RxList<String> imagePaths = <String>[].obs;
  RxBool isProcessing = false.obs;
  RxString processingStatus = ''.obs;

  Future<void> pickImages() async {
    try {
      isProcessing.value = true;
      processingStatus.value = 'Picking images...';

      final images = await imagePicker.pickMultiImage();
      if (images.isEmpty) {
        return;
      }

      imagePaths.value = images.map((e) => e.path).toList();
      processingStatus.value =
          'Creating PDF from ${imagePaths.length} image(s)...';

      final pdfFile = await createPdfFromImages(imagePaths);

      processingStatus.value = 'Saving to Downloads...';

      Get.back(result: pdfFile);
      Get.to(() => PdfViewer(filePath: pdfFile));

      Get.snackbar(
        'Success',
        'PDF created from ${imagePaths.length} image(s) and saved',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to create PDF: $e');
    } finally {
      isProcessing.value = false;
      processingStatus.value = '';
    }
  }

  Future<File> createPdfFromImages(List<String> imagePaths) async {
    try {
      final PdfDocument document = PdfDocument();

      for (int i = 0; i < imagePaths.length; i++) {
        processingStatus.value =
            'Processing image ${i + 1}/${imagePaths.length}...';

        final bytes = await File(imagePaths[i]).readAsBytes();

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

      processingStatus.value = 'Finalizing PDF...';

      final pdfBytes = await document.save();
      document.dispose();

      processingStatus.value = 'Saving to Downloads folder...';

      final fileName =
          'images_to_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final savedPath = await PdfStorageService.savePdfToDownloads(
        pdfBytes: pdfBytes,
        fileName: fileName,
      );

      if (savedPath == null) {
        throw Exception('Failed to save PDF');
      }

      processingStatus.value = 'Updating file list...';

      try {
        final fileController = Get.find<FilePageController>();
        await fileController.refreshPdfs();
      } catch (_) {}

      return File(savedPath);
    } catch (e) {
      rethrow;
    }
  }

  Future<File> createPdfWithCustomPages(List<String> imagePaths) async {
    try {
      final PdfDocument document = PdfDocument();

      for (String path in imagePaths) {
        final bytes = await File(path).readAsBytes();
        final image = PdfBitmap(bytes);
        final page = document.pages.add();

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

      final pdfBytes = await document.save();
      document.dispose();

      final fileName =
          'images_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final savedPath = await PdfStorageService.savePdfToDownloads(
        pdfBytes: pdfBytes,
        fileName: fileName,
      );

      if (savedPath == null) {
        throw Exception('Failed to save PDF');
      }

      try {
        final fileController = Get.find<FilePageController>();
        await fileController.refreshPdfs();
      } catch (e) {
        return File(savedPath);
      }

      return File(savedPath);
    } catch (e) {
      rethrow;
    }
  }

  void clearImages() {
    imagePaths.clear();
  }
}

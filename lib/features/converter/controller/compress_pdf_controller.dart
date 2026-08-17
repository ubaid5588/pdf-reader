import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/converter/view/selected_tool.dart';
import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class CompressPdfController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString compressionStatus = ''.obs;
  final Rx<File?> compressedFile = Rx<File?>(null);

  Future<void> pickAndCompressPdf() async {
    SelectedTool.isProcessing = true;
    try {
      isLoading.value = true;
      compressionStatus.value = 'Picking PDF file...';

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) {
        return;
      }

      final pdfFile = File(result.files.single.path!);
      final fileName = result.files.single.name;
      final originalSize = pdfFile.lengthSync() / 1024 / 1024;

      compressionStatus.value = 'Compressing PDF...';
      print('📄 Original file size: ${originalSize.toStringAsFixed(2)} MB');

      // Simple compression: Just copy the file
      // In production, you might use system tools or a working compression library
      final dir = await getApplicationDocumentsDirectory();
      final compressedFilePath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Copy file (this is a placeholder - real compression would happen here)
      // For actual compression, you'd need a working compression tool/package
      final compressedFile = await pdfFile.copy(compressedFilePath);

      compressionStatus.value = 'Saving to device storage...';

      final compressedSize = compressedFile.lengthSync() / 1024 / 1024;

      print('✅ Processed file size: ${compressedSize.toStringAsFixed(2)} MB');

      // Read compressed file bytes
      final compressedBytes = await compressedFile.readAsBytes();

      // Save to device Downloads folder
      await PdfStorageService.savePdfToDownloads(
        pdfBytes: compressedBytes,
        fileName: 'compressed_$fileName',
      );

      // Refresh file list in FilePage
      final fileController = Get.find<FilePageController>();
      await fileController.refreshPdfs();

      this.compressedFile.value = compressedFile;

      compressionStatus.value = 'Opening PDF...';

      // Show the PDF in viewer
      Get.to(() => PdfViewer(filePath: compressedFile));

      Get.snackbar(
        'Success',
        'PDF processed and saved to Downloads',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error: $e');
      Get.snackbar('Error', 'Failed to process PDF: $e');
    } finally {
      isLoading.value = false;
      compressionStatus.value = '';
      SelectedTool.isProcessing = false;
    }
  }
}

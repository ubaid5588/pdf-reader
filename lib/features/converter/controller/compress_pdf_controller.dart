import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_reader/features/converter/view/selected_tool.dart';
import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_pdf_compression/simple_pdf_compression.dart';

class CompressPdfController extends GetxController {
  final RxBool isLoading = false.obs;

  final Rx<File?> compressedFile = Rx<File?>(null);

  Future<void> pickAndCompressPdf() async {
    SelectedTool.isProcessing = true;
    try {
      isLoading.value = true;

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result == null) {
        return;
      }

      final pdfFile = File(result.files.single.path!);
      final compressor = PDFCompression();
      final output = await compressor.compressPdf(
        pdfFile,
        thresholdSize: 5 * 1024 * 1024,
        quality: 50,
      );

      final savedFile = await _saveCompressedPdf(output);
      compressedFile.value = savedFile;

      Get.snackbar('Success', 'PDF compressed successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<File> _saveCompressedPdf(File compressedOutput) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    final bytes = await compressedOutput.readAsBytes();
    await file.writeAsBytes(bytes);
    SelectedTool.isProcessing = false;
    Get.to(() => PdfViewer(filePath: bytes));
    return file;
  }
}

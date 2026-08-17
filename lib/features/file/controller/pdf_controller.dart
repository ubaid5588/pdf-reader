import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class PdfController extends GetxController {
  final RxList<File> pdfFiles = <File>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> pickPdfs() async {
    try {
      isLoading.value = true;

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        allowCompression: false,
      );

      if (result == null || result.files.isEmpty) {
        print("No files selected");
        return;
      }

      final List<File> picked = result.files
          .where((f) => f.path != null)
          .map((f) => File(f.path!))
          .toList();

      pdfFiles.value = picked;
      print("Selected ${picked.length} PDF(s)");
    } catch (e) {
      print("PDF pick error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void clearPdfs() {
    pdfFiles.clear();
  }
}

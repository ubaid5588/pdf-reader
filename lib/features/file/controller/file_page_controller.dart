import 'dart:io';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class FilePageController extends GetxController {
  RxList<File> pdfFiles = <File>[].obs;
  RxBool isLoading = false.obs;

  Future<void> loadPdfs() async {
    try {
      isLoading.value = true;
      final dir = await getApplicationDocumentsDirectory();

      final files = dir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.pdf'))
          .toList();
      print(files);
      pdfFiles.value = files;
    } catch (e) {
      print("PDF load error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

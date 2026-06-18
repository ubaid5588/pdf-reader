import 'dart:io';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
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
      final dir = await getApplicationDocumentsDirectory();
      final files = dir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.pdf'))
          .toList();
      pdfFiles.value = files;
    } catch (e) {
      print("PDF load error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSelection(File file) {
    if (selectedForMerge.contains(file)) {
      selectedForMerge.remove(file);
    } else {
      selectedForMerge.add(file);
    }
  }

  void clearSelection() => selectedForMerge.clear();

  Future<File?> mergeSelectedPdfs({String? outputName}) async {
    if (selectedForMerge.length < 2) {
      Get.snackbar("Merge PDF", "Select at least 2 PDFs to merge");
      return null;
    }

    try {
      isMerging.value = true;

      final PdfDocument finalDocument = PdfDocument();

      for (final file in selectedForMerge) {
        final bytes = await file.readAsBytes();
        final PdfDocument sourceDoc = PdfDocument(inputBytes: bytes);

        for (int i = 0; i < sourceDoc.pages.count; i++) {
          final PdfPage sourcePage = sourceDoc.pages[i];
          final Size pageSize = sourcePage.size;

          // Set page settings BEFORE adding the page — size is applied at creation time
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

      final dir = await getApplicationDocumentsDirectory();
      final name =
          outputName ?? 'merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final outputFile = File('${dir.path}/$name');

      final List<int> bytes = await finalDocument.save();
      await outputFile.writeAsBytes(bytes);
      finalDocument.dispose();

      selectedForMerge.clear();
      await loadPdfs();

      return outputFile;
    } catch (e) {
      print("Merge error: $e");
      Get.snackbar("Merge PDF", "Failed to merge: $e");
      return null;
    } finally {
      isMerging.value = false;
    }
  }
}

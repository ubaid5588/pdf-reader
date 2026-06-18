import 'dart:io';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:file_reader/features/file/view/file_page.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class SplitPdfController extends GetxController {
  RxBool isLoading = false.obs;

  Future<void> pickFileAndSplit() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      isLoading.value = true;

      final platFormFile = result!.files.first;

      final File file = File(platFormFile.path!);

      await splitIntoSinglePages(file);

      Get.to(() => FilePage());
    } catch (e) {
      Get.snackbar("Error", "Could not create PDF: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<File>> splitIntoSinglePages(File sourceFile) async {
    final List<File> outputFiles = [];

    try {
      isLoading.value = true;

      final bytes = await sourceFile.readAsBytes();
      final PdfDocument sourceDoc = PdfDocument(inputBytes: bytes);
      final dir = await getApplicationDocumentsDirectory();
      final baseName = sourceFile.path.split('/').last.replaceAll('.pdf', '');

      for (int i = 0; i < sourceDoc.pages.count; i++) {
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

        final outputFile = File('${dir.path}/${baseName}_page${i + 1}.pdf');
        await outputFile.writeAsBytes(await newDoc.save());
        newDoc.dispose();

        outputFiles.add(outputFile);
      }

      sourceDoc.dispose();
      Get.snackbar("Split complete", "${outputFiles.length} pages created");
    } catch (e) {
      Get.snackbar("Error", "Could not split PDF: $e");
    } finally {
      isLoading.value = false;
    }

    return outputFiles;
  }
}

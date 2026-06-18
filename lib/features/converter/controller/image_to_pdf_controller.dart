import 'dart:io';
import 'dart:ui';

import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ImageToPdfController extends GetxController {
  final ImagePicker imagePicker = ImagePicker();

  RxList<String> imagePaths = <String>[].obs;

  Future<void> pickImages() async {
    final images = await imagePicker.pickMultiImage();
    if (images.isEmpty) return;
    imagePaths.value = images.map((e) => e.path).toList();
    final pdfFile = await createPdfFromImages(imagePaths);
    Get.back(result: pdfFile);
    Get.to(() => PdfViewer(filePath: pdfFile));
  }

  Future<File> createPdfFromImages(List<String> imagePaths) async {
    final PdfDocument document = PdfDocument();
    for (String path in imagePaths) {
      final bytes = await File(path).readAsBytes();
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

    final pdfBytes = await document.save();
    document.dispose();
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/images_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(pdfBytes);

    return file;
  }
}

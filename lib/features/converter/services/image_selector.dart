import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ImageSelector extends StatefulWidget {
  final String title;
  const ImageSelector({super.key, required this.title});

  @override
  State<ImageSelector> createState() => _ImageSelectorState();
}

class _ImageSelectorState extends State<ImageSelector> {
  final ImagePicker imagePickers = ImagePicker();

  List<String> imagesPaths = [];

  Future<void> pickImages() async {
    final images = await imagePickers.pickMultiImage();
    imagesPaths = images.map((e) => e.path).toList();
    createPdfFromImages(imagesPaths);
    Get.back();
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
    final file = File('${dir.path}/images${DateTime.now()}.pdf');
    await file.writeAsBytes(pdfBytes);
    // Get.to(() => PdfViewer(pdfBytes: file));
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        alignment: Alignment.center,
        child: SizedBox(
          width: double.infinity * 0.5,
          height: 52,
          child: ElevatedButton(
            onPressed: () => pickImages(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B4EE8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              'Selcet Images',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

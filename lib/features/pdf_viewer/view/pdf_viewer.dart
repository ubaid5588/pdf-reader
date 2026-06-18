import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatelessWidget {
  final dynamic filePath;

  const PdfViewer({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: filePath is Uint8List
          ? SfPdfViewer.memory(
              filePath as Uint8List,
              canShowPaginationDialog: true,
              maxZoomLevel: 10,
            )
          : SfPdfViewer.file(
              filePath as File,
              canShowPaginationDialog: true,
              maxZoomLevel: 10,
            ),
    );
  }
}

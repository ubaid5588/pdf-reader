import 'dart:io';
import 'dart:typed_data';

import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewer extends StatefulWidget {
  final dynamic filePath;

  const PdfViewer({super.key, required this.filePath});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  @override
  void initState() {
    super.initState();
    _recordRecent();
  }

  void _recordRecent() {
    try {
      if (widget.filePath is File) {
        final File file = widget.filePath as File;
        final recentController = Get.isRegistered<RecentPdfController>()
            ? Get.find<RecentPdfController>()
            : Get.put(RecentPdfController());
        recentController.addRecentPdf(
          file.path,
          file.path.split(Platform.pathSeparator).last,
        );
      } else if (widget.filePath is String) {
        final String path = widget.filePath as String;
        final recentController = Get.isRegistered<RecentPdfController>()
            ? Get.find<RecentPdfController>()
            : Get.put(RecentPdfController());
        recentController.addRecentPdf(
          path,
          path.split(Platform.pathSeparator).last,
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    String title = 'PDF Viewer';
    if (widget.filePath is File) {
      title = (widget.filePath as File).path.split(Platform.pathSeparator).last;
    } else if (widget.filePath is String) {
      title = (widget.filePath as String).split(Platform.pathSeparator).last;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: widget.filePath is Uint8List
          ? SfPdfViewer.memory(
              widget.filePath as Uint8List,
              canShowPaginationDialog: true,
              maxZoomLevel: 10,
            )
          : SfPdfViewer.file(
              widget.filePath is File
                  ? (widget.filePath as File)
                  : File(widget.filePath as String),
              canShowPaginationDialog: true,
              maxZoomLevel: 10,
            ),
    );
  }
}

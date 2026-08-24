import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

enum DocumentStyleType {
  body,
  heading1,
  heading2,
  bullet,
  quote,
}

class CreatePdfController extends GetxController {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();

  Rx<DocumentStyleType> currentStyle = DocumentStyleType.body.obs;
  RxBool isBold = false.obs;
  RxBool isItalic = false.obs;
  Rx<TextAlign> textAlignment = TextAlign.left.obs;
  RxDouble fontSize = 14.0.obs;
  Rx<Color> textColor = Colors.black.obs;
  RxInt wordCount = 0.obs;
  RxInt charCount = 0.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    bodyController.addListener(_updateCounts);
  }

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    super.onClose();
  }

  void _updateCounts() {
    final text = bodyController.text;
    charCount.value = text.length;
    final words = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    wordCount.value = words.length;
  }

  void setStyle(DocumentStyleType style) {
    currentStyle.value = style;
    switch (style) {
      case DocumentStyleType.heading1:
        fontSize.value = 22.0;
        isBold.value = true;
        break;
      case DocumentStyleType.heading2:
        fontSize.value = 18.0;
        isBold.value = true;
        break;
      case DocumentStyleType.body:
        fontSize.value = 14.0;
        isBold.value = false;
        break;
      case DocumentStyleType.bullet:
        fontSize.value = 14.0;
        isBold.value = false;
        break;
      case DocumentStyleType.quote:
        fontSize.value = 14.0;
        isItalic.value = true;
        break;
    }
  }

  void insertTextAtCursor(String inserted) {
    final text = bodyController.text;
    final selection = bodyController.selection;
    if (selection.start < 0 || selection.end < 0) {
      bodyController.text = '$text$inserted';
      bodyController.selection = TextSelection.collapsed(
        offset: bodyController.text.length,
      );
    } else {
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        inserted,
      );
      bodyController.text = newText;
      bodyController.selection = TextSelection.collapsed(
        offset: selection.start + inserted.length,
      );
    }
  }

  void insertDate() {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    insertTextAtCursor(dateStr);
  }

  void insertBullet() {
    insertTextAtCursor('\n• ');
  }

  void insertDivider() {
    insertTextAtCursor('\n────────────────────────\n');
  }

  /// Generates the PDF document and saves it
  Future<File?> generateAndSavePdf({
    void Function(double progress, String status)? onProgress,
  }) async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    if (body.isEmpty && title.isEmpty) {
      Get.snackbar(
        'Empty Document',
        'Please enter some text before saving.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    isLoading.value = true;
    try {
      onProgress?.call(0.2, 'Creating document pages...');

      final PdfDocument document = PdfDocument();
      document.pageSettings.size = PdfPageSize.a4;
      document.pageSettings.margins.all = 36; // 0.5 inch margins

      final double pageWidth = PdfPageSize.a4.width - 72;
      final double pageHeight = PdfPageSize.a4.height - 72;

      PdfPage currentPage = document.pages.add();
      double currentY = 10;

      // 1. Draw Document Title (if present)
      if (title.isNotEmpty) {
        final PdfFont titleFont = PdfStandardFont(
          PdfFontFamily.helvetica,
          22,
          style: PdfFontStyle.bold,
        );
        final titleBounds = ui.Rect.fromLTWH(0, currentY, pageWidth, 30);
        currentPage.graphics.drawString(
          title,
          titleFont,
          brush: PdfSolidBrush(PdfColor(20, 30, 50)),
          bounds: titleBounds,
          format: PdfStringFormat(alignment: PdfTextAlignment.left),
        );
        currentY += 36;

        // Title separator line
        final pen = PdfPen(PdfColor(200, 210, 225), width: 1.5);
        currentPage.graphics.drawLine(
          pen,
          ui.Offset(0, currentY),
          ui.Offset(pageWidth, currentY),
        );
        currentY += 16;
      }

      onProgress?.call(0.5, 'Formatting text content...');

      // 2. Process paragraphs & layout
      final PdfFont bodyFont = PdfStandardFont(
        PdfFontFamily.helvetica,
        fontSize.value,
        style: isBold.value && isItalic.value
            ? PdfFontStyle.bold
            : isBold.value
            ? PdfFontStyle.bold
            : isItalic.value
            ? PdfFontStyle.italic
            : PdfFontStyle.regular,
      );

      final brush = PdfSolidBrush(
        PdfColor(
          (textColor.value.r * 255.0).round() & 0xff,
          (textColor.value.g * 255.0).round() & 0xff,
          (textColor.value.b * 255.0).round() & 0xff,
        ),
      );

      PdfTextAlignment alignment = PdfTextAlignment.left;
      if (textAlignment.value == TextAlign.center) {
        alignment = PdfTextAlignment.center;
      } else if (textAlignment.value == TextAlign.right) {
        alignment = PdfTextAlignment.right;
      } else if (textAlignment.value == TextAlign.justify) {
        alignment = PdfTextAlignment.justify;
      }

      final PdfTextElement textElement = PdfTextElement(
        text: body,
        font: bodyFont,
        brush: brush,
        format: PdfStringFormat(
          alignment: alignment,
          lineSpacing: 4,
          wordWrap: PdfWordWrapType.word,
        ),
      );

      final PdfLayoutFormat layoutFormat = PdfLayoutFormat(
        layoutType: PdfLayoutType.paginate,
        breakType: PdfLayoutBreakType.fitPage,
      );

      final bounds = ui.Rect.fromLTWH(
        0,
        currentY,
        pageWidth,
        pageHeight - currentY,
      );

      textElement.draw(
        page: currentPage,
        bounds: bounds,
        format: layoutFormat,
      );

      // Add page numbers in footer
      for (int i = 0; i < document.pages.count; i++) {
        final p = document.pages[i];
        final footerFont = PdfStandardFont(
          PdfFontFamily.helvetica,
          9,
          style: PdfFontStyle.regular,
        );
        p.graphics.drawString(
          'Page ${i + 1} of ${document.pages.count}',
          footerFont,
          brush: PdfSolidBrush(PdfColor(130, 140, 155)),
          bounds: ui.Rect.fromLTWH(0, pageHeight + 10, pageWidth, 20),
          format: PdfStringFormat(alignment: PdfTextAlignment.center),
        );
      }

      onProgress?.call(0.8, 'Encoding PDF document...');
      final List<int> pdfBytes = await document.save();
      document.dispose();

      onProgress?.call(0.9, 'Saving document to storage...');
      final fileName = PdfStorageService.generateCreatedPdfFileName();

      final savedPath = await PdfStorageService.savePdfToDownloads(
        pdfBytes: pdfBytes,
        fileName: fileName,
      );

      onProgress?.call(1.0, 'Finalizing...');

      if (savedPath == null) {
        throw Exception('Failed to save created PDF to storage');
      }

      // Record in recent
      try {
        final recentController = Get.isRegistered<RecentPdfController>()
            ? Get.find<RecentPdfController>()
            : Get.put(RecentPdfController());
        await recentController.addRecentPdf(savedPath, fileName);

        if (Get.isRegistered<FilePageController>()) {
          await Get.find<FilePageController>().refreshPdfs();
        }
      } catch (_) {}

      return File(savedPath);
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}

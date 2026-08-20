import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart' as fp;
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/edit_pdf/view/pdf_editor_page.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfTextOverlay {
  final int pageIndex;
  final String text;
  final double fontSize;
  final Color color;
  final Alignment alignment;
  final Offset? customOffset;

  PdfTextOverlay({
    required this.pageIndex,
    required this.text,
    this.fontSize = 14,
    this.color = Colors.black,
    this.alignment = Alignment.topCenter,
    this.customOffset,
  });
}

class DrawingStroke {
  final int pageIndex;
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  DrawingStroke({
    required this.pageIndex,
    required this.points,
    this.color = Colors.blue,
    this.strokeWidth = 3.0,
  });
}

class EditPdfController extends GetxController {
  Rx<File?> sourceFile = Rx<File?>(null);
  RxInt currentPageIndex = 0.obs;
  RxInt totalPages = 0.obs;
  RxBool isLoading = false.obs;

  // Extracted original & modified text per page
  RxMap<int, String> pageTexts = <int, String>{}.obs;
  RxMap<int, String> originalPageTexts = <int, String>{}.obs;

  // Page rotations in degrees (0, 90, 180, 270)
  RxMap<int, int> pageRotations = <int, int>{}.obs;

  // Deleted pages set
  RxSet<int> deletedPages = <int>{}.obs;

  // Custom text overlays per page
  RxList<PdfTextOverlay> textOverlays = <PdfTextOverlay>[].obs;

  // Freehand drawing / signature strokes per page
  RxList<DrawingStroke> drawingStrokes = <DrawingStroke>[].obs;

  /// Inspect and pick PDF file
  Future<void> pickAndInspectPdf(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cantEditTitle = l10n?.pdfCantBeEditedTitle ?? "This PDF can't be edited";
    final cantEditMsg = l10n?.pdfCantBeEditedMessage ??
        "This file contains image-based or unsupported content that cannot be edited. Please choose an editable PDF.";
    final unableOpenTitle = l10n?.unableToOpenPdfTitle ?? "Unable to open PDF";
    final unableOpenMsg = l10n?.unableToOpenPdfMessage ??
        "This PDF appears to be invalid or corrupted.";

    try {
      final result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;
      final selectedPath = result.files.single.path;
      if (selectedPath == null) return;

      final file = File(selectedPath);
      if (!await file.exists()) {
        _showErrorDialog(unableOpenTitle, unableOpenMsg);
        return;
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        _showErrorDialog(unableOpenTitle, unableOpenMsg);
        return;
      }

      // Step 1: Validate PDF structure
      PdfDocument document;
      try {
        document = PdfDocument(inputBytes: bytes);
      } catch (e) {
        _showErrorDialog(unableOpenTitle, unableOpenMsg);
        return;
      }

      // Step 2: Check page count
      if (document.pages.count == 0) {
        document.dispose();
        _showErrorDialog(cantEditTitle, cantEditMsg);
        return;
      }

      // Step 3: Check extractable text (detect image-only / scanned PDFs)
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String allText = extractor.extractText();

      if (allText.trim().isEmpty) {
        document.dispose();
        _showErrorDialog(cantEditTitle, cantEditMsg);
        return;
      }

      // Step 4: Extract text per page for the editor
      final count = document.pages.count;
      final extractedMap = <int, String>{};

      for (int i = 0; i < count; i++) {
        final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        extractedMap[i] = pageText;
      }

      document.dispose();

      // Step 5: Initialize editor state
      sourceFile.value = file;
      totalPages.value = count;
      currentPageIndex.value = 0;
      originalPageTexts.assignAll(extractedMap);
      pageTexts.assignAll(extractedMap);
      pageRotations.clear();
      deletedPages.clear();
      textOverlays.clear();
      drawingStrokes.clear();

      // Step 6: Navigate to PDF Editor
      Get.to(() => const PdfEditorPage());
    } catch (e) {
      _showErrorDialog(unableOpenTitle, unableOpenMsg);
    }
  }

  void _showErrorDialog(String title, String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFEF5350), size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'OK',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- Editor Actions ---

  void updateCurrentPageText(String newText) {
    final page = currentPageIndex.value;
    pageTexts[page] = newText;
  }

  void rotateCurrentPage() {
    final page = currentPageIndex.value;
    final currentRotation = pageRotations[page] ?? 0;
    final nextRotation = (currentRotation + 90) % 360;
    pageRotations[page] = nextRotation;
  }

  void deleteCurrentPage(BuildContext context) {
    if (activePageCount <= 1) {
      Get.snackbar(
        'Cannot Delete',
        'The document must have at least one page.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final page = currentPageIndex.value;
    deletedPages.add(page);

    // Move to next available page
    for (int i = 0; i < totalPages.value; i++) {
      if (!deletedPages.contains(i)) {
        currentPageIndex.value = i;
        break;
      }
    }
  }

  int get activePageCount => totalPages.value - deletedPages.length;

  void addTextOverlay(PdfTextOverlay overlay) {
    textOverlays.add(overlay);
  }

  void removeTextOverlay(int index) {
    if (index >= 0 && index < textOverlays.length) {
      textOverlays.removeAt(index);
    }
  }

  void addDrawingStroke(DrawingStroke stroke) {
    drawingStrokes.add(stroke);
  }

  void clearCurrentPageDrawings() {
    final page = currentPageIndex.value;
    drawingStrokes.removeWhere((s) => s.pageIndex == page);
  }

  // --- Save Edited PDF ---

  Future<File?> saveEditedPdf({
    void Function(double progress, String status)? onProgress,
  }) async {
    if (sourceFile.value == null) return null;

    isLoading.value = true;
    try {
      onProgress?.call(0.15, 'Reading original PDF...');
      final bytes = await sourceFile.value!.readAsBytes();
      final PdfDocument sourceDoc = PdfDocument(inputBytes: bytes);
      final PdfDocument newDoc = PdfDocument();

      final totalSrcPages = sourceDoc.pages.count;
      int processedPages = 0;
      final validPagesCount = activePageCount;

      for (int i = 0; i < totalSrcPages; i++) {
        if (deletedPages.contains(i)) continue;

        processedPages++;
        final progressPct = 0.2 + (0.55 * (processedPages / (validPagesCount > 0 ? validPagesCount : 1)));
        onProgress?.call(
          progressPct,
          'Processing page $processedPages of $validPagesCount...',
        );

        final PdfPage sourcePage = sourceDoc.pages[i];
        final ui.Size pageSize = sourcePage.size;

        newDoc.pageSettings.size = pageSize;
        newDoc.pageSettings.margins.all = 0;

        final PdfPage newPage = newDoc.pages.add();

        // 1. Draw base page content
        final PdfTemplate template = sourcePage.createTemplate();
        newPage.graphics.drawPdfTemplate(
          template,
          const ui.Offset(0, 0),
          pageSize,
        );

        // 2. Apply page rotation if modified
        final rotation = pageRotations[i] ?? 0;
        if (rotation == 90) {
          newPage.rotation = PdfPageRotateAngle.rotateAngle90;
        } else if (rotation == 180) {
          newPage.rotation = PdfPageRotateAngle.rotateAngle180;
        } else if (rotation == 270) {
          newPage.rotation = PdfPageRotateAngle.rotateAngle270;
        }

        // 3. Apply Text modifications if page text was edited
        final origText = originalPageTexts[i] ?? '';
        final editedText = pageTexts[i] ?? origText;
        if (editedText != origText && editedText.trim().isNotEmpty) {
          // Add edited content overlay at the bottom of the page
          final PdfFont bannerFont = PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.italic);
          final String stampText = 'Edited: ${editedText.replaceAll('\n', ' ')}';
          final truncatedStamp = stampText.length > 120 ? '${stampText.substring(0, 117)}...' : stampText;

          newPage.graphics.drawRectangle(
            brush: PdfSolidBrush(PdfColor(245, 247, 250, 220)),
            bounds: ui.Rect.fromLTWH(10, pageSize.height - 24, pageSize.width - 20, 18),
          );
          newPage.graphics.drawString(
            truncatedStamp,
            bannerFont,
            brush: PdfSolidBrush(PdfColor(40, 50, 70)),
            bounds: ui.Rect.fromLTWH(14, pageSize.height - 21, pageSize.width - 28, 14),
          );
        }

        // 4. Draw Custom Text Overlays for this page
        final pageOverlays = textOverlays.where((o) => o.pageIndex == i).toList();
        for (final overlay in pageOverlays) {
          final font = PdfStandardFont(PdfFontFamily.helvetica, overlay.fontSize, style: PdfFontStyle.bold);
          final brush = PdfSolidBrush(PdfColor(
            (overlay.color.r * 255.0).round() & 0xff,
            (overlay.color.g * 255.0).round() & 0xff,
            (overlay.color.b * 255.0).round() & 0xff,
          ));

          ui.Rect textBounds;
          if (overlay.customOffset != null) {
            textBounds = ui.Rect.fromLTWH(
              overlay.customOffset!.dx,
              overlay.customOffset!.dy,
              pageSize.width - 40,
              40,
            );
          } else if (overlay.alignment == Alignment.topCenter) {
            textBounds = ui.Rect.fromLTWH(20, 20, pageSize.width - 40, 30);
          } else if (overlay.alignment == Alignment.bottomCenter) {
            textBounds = ui.Rect.fromLTWH(20, pageSize.height - 50, pageSize.width - 40, 30);
          } else {
            textBounds = ui.Rect.fromLTWH(20, pageSize.height / 2 - 15, pageSize.width - 40, 30);
          }

          newPage.graphics.drawString(
            overlay.text,
            font,
            brush: brush,
            bounds: textBounds,
            format: PdfStringFormat(alignment: PdfTextAlignment.center),
          );
        }

        // 5. Draw Signatures & Freehand Strokes for this page
        final pageStrokes = drawingStrokes.where((s) => s.pageIndex == i).toList();
        for (final stroke in pageStrokes) {
          if (stroke.points.length < 2) continue;

          final pen = PdfPen(
            PdfColor(
              (stroke.color.r * 255.0).round() & 0xff,
              (stroke.color.g * 255.0).round() & 0xff,
              (stroke.color.b * 255.0).round() & 0xff,
            ),
            width: stroke.strokeWidth,
          );

          for (int p = 0; p < stroke.points.length - 1; p++) {
            final p1 = stroke.points[p];
            final p2 = stroke.points[p + 1];
            newPage.graphics.drawLine(
              pen,
              ui.Offset(p1.dx, p1.dy),
              ui.Offset(p2.dx, p2.dy),
            );
          }
        }
      }

      onProgress?.call(0.8, 'Encoding updated PDF document...');
      final List<int> savedBytes = await newDoc.save();

      newDoc.dispose();
      sourceDoc.dispose();

      onProgress?.call(0.9, 'Saving to device storage...');
      final originalBase = sourceFile.value!.path
          .split(Platform.pathSeparator)
          .last
          .replaceAll('.pdf', '');
      final fileName = '${originalBase}_edited_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final savedPath = await PdfStorageService.savePdfToDownloads(
        pdfBytes: savedBytes,
        fileName: fileName,
      );

      onProgress?.call(1.0, 'Finalizing...');

      if (savedPath != null) {
        final savedFile = File(savedPath);

        // Record in recent controller
        try {
          final recentController = Get.isRegistered<RecentPdfController>()
              ? Get.find<RecentPdfController>()
              : Get.put(RecentPdfController());
          recentController.addRecentPdf(savedPath, fileName);
        } catch (_) {}

        // Refresh file list
        try {
          if (Get.isRegistered<FilePageController>()) {
            await Get.find<FilePageController>().refreshPdfs();
          }
        } catch (_) {}

        return savedFile;
      }

      throw Exception('Failed to save edited PDF to storage');
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart' as fp;
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

enum EditorTool { select, text, draw, highlight, shape, whiteout }

enum ShapeType { rectangle, circle, line }

/// Model for text extracted directly from the underlying PDF pages
class ExtractedPdfTextItem {
  final String id;
  final int pageIndex; // 0-based page index
  final String originalText;
  String currentText;
  final ui.Rect originalBounds; // In PDF page points
  ui.Offset? customPosition; // In PDF page points (if user repositioned)
  double fontSize;
  Color textColor;
  bool isBold;
  bool isItalic;
  bool isEdited;
  bool isDeleted;

  ExtractedPdfTextItem({
    required this.id,
    required this.pageIndex,
    required this.originalText,
    required this.currentText,
    required this.originalBounds,
    this.customPosition,
    this.fontSize = 14,
    this.textColor = Colors.black,
    this.isBold = false,
    this.isItalic = false,
    this.isEdited = false,
    this.isDeleted = false,
  });

  ExtractedPdfTextItem copyWith({
    String? currentText,
    ui.Offset? customPosition,
    double? fontSize,
    Color? textColor,
    bool? isBold,
    bool? isItalic,
    bool? isEdited,
    bool? isDeleted,
  }) {
    return ExtractedPdfTextItem(
      id: id,
      pageIndex: pageIndex,
      originalText: originalText,
      currentText: currentText ?? this.currentText,
      originalBounds: originalBounds,
      customPosition: customPosition ?? this.customPosition,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

class VisualTextElement {
  final String id;
  final int pageIndex;
  String text;
  ui.Offset position;
  double fontSize;
  Color color;
  bool isBold;
  bool isItalic;
  Color? backgroundColor; // e.g. Colors.white for whiteout-text

  VisualTextElement({
    required this.id,
    required this.pageIndex,
    required this.text,
    required this.position,
    this.fontSize = 15,
    this.color = Colors.black,
    this.isBold = false,
    this.isItalic = false,
    this.backgroundColor,
  });

  VisualTextElement copyWith({
    String? text,
    ui.Offset? position,
    double? fontSize,
    Color? color,
    bool? isBold,
    bool? isItalic,
    Color? backgroundColor,
  }) {
    return VisualTextElement(
      id: id,
      pageIndex: pageIndex,
      text: text ?? this.text,
      position: position ?? this.position,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}

class VisualDrawStroke {
  final int pageIndex;
  final List<ui.Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isHighlighter;

  VisualDrawStroke({
    required this.pageIndex,
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.isHighlighter = false,
  });
}

class VisualShapeElement {
  final String id;
  final int pageIndex;
  final ShapeType shapeType;
  final ui.Rect rect;
  final Color color;
  final double strokeWidth;
  final bool isFilled;

  VisualShapeElement({
    required this.id,
    required this.pageIndex,
    required this.shapeType,
    required this.rect,
    required this.color,
    this.strokeWidth = 2.5,
    this.isFilled = false,
  });
}

class VisualImageElement {
  final String id;
  final int pageIndex;
  final Uint8List imageBytes;
  ui.Offset position;
  ui.Size size;

  VisualImageElement({
    required this.id,
    required this.pageIndex,
    required this.imageBytes,
    required this.position,
    required this.size,
  });
}

class VisualWhiteoutElement {
  final String id;
  final int pageIndex;
  final ui.Rect rect;

  VisualWhiteoutElement({
    required this.id,
    required this.pageIndex,
    required this.rect,
  });
}

class EditPdfController extends GetxController {
  Rx<File?> sourceFile = Rx<File?>(null);
  RxInt currentPageIndex = 0.obs;
  RxInt totalPages = 0.obs;
  RxBool isLoading = false.obs;
  RxBool hasScannedContentWarning = false.obs;

  PdfViewerController? pdfViewerController;

  // Active Tool & Tool Settings
  Rx<EditorTool> activeTool = EditorTool.select.obs;
  Rx<Color> selectedColor = const Color(0xFF2563EB).obs;
  RxDouble strokeWidth = 3.0.obs;
  Rx<ShapeType> selectedShape = ShapeType.rectangle.obs;

  // Extracted interactive text elements per PDF page
  RxList<ExtractedPdfTextItem> extractedTextItems =
      <ExtractedPdfTextItem>[].obs;
  RxMap<int, ui.Size> originalPageSizes = <int, ui.Size>{}.obs;

  // Overlays per page
  RxList<VisualTextElement> textElements = <VisualTextElement>[].obs;
  RxList<VisualDrawStroke> drawStrokes = <VisualDrawStroke>[].obs;
  RxList<VisualShapeElement> shapeElements = <VisualShapeElement>[].obs;
  RxList<VisualImageElement> imageElements = <VisualImageElement>[].obs;
  RxList<VisualWhiteoutElement> whiteoutElements =
      <VisualWhiteoutElement>[].obs;

  // Page rotations & deletions
  RxMap<int, int> pageRotations = <int, int>{}.obs;
  RxSet<int> deletedPages = <int>{}.obs;

  // History stack for Undo / Redo
  final List<List<dynamic>> _undoStack = [];
  final List<List<dynamic>> _redoStack = [];

  int get activePageCount => totalPages.value - deletedPages.length;

  /// Inspect and pick PDF file for visual editing
  Future<bool> pickAndInspectPdf(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cantEditTitle =
        l10n?.pdfCantBeEditedTitle ?? "This PDF can't be edited";
    final cantEditMsg =
        l10n?.pdfCantBeEditedMessage ??
        "This file contains image-based or unsupported content that cannot be edited. Please choose an editable PDF.";
    final unableOpenTitle = l10n?.unableToOpenPdfTitle ?? "Unable to open PDF";
    final unableOpenMsg =
        l10n?.unableToOpenPdfMessage ??
        "This PDF appears to be invalid or corrupted.";

    try {
      final result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return false;
      final selectedPath = result.files.single.path;
      if (selectedPath == null) return false;

      final file = File(selectedPath);
      if (!await file.exists()) {
        _showErrorDialog(unableOpenTitle, unableOpenMsg);
        return false;
      }

      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        _showErrorDialog(unableOpenTitle, unableOpenMsg);
        return false;
      }

      // Step 1: Validate PDF structure
      PdfDocument document;
      try {
        document = PdfDocument(inputBytes: bytes);
      } catch (e) {
        _showErrorDialog(
          cantEditTitle,
          "This PDF is password protected or uses an unsupported format.",
        );
        return false;
      }

      final count = document.pages.count;
      if (count == 0) {
        document.dispose();
        _showErrorDialog(cantEditTitle, cantEditMsg);
        return false;
      }

      // Step 2: Extract text lines across ALL pages of the PDF
      final List<ExtractedPdfTextItem> extracted = [];
      final Map<int, ui.Size> pageSizes = {};

      try {
        final PdfTextExtractor extractor = PdfTextExtractor(document);
        for (int p = 0; p < count; p++) {
          final page = document.pages[p];
          pageSizes[p] = page.size;

          try {
            final List<TextLine> textLines = extractor.extractTextLines(
              startPageIndex: p,
              endPageIndex: p,
            );
            int lineIndex = 0;
            for (final line in textLines) {
              final textContent = line.text.trim();
              if (textContent.isNotEmpty) {
                final calcFontSize =
                    (line.bounds.height * 0.78).clamp(9.0, 48.0);
                extracted.add(
                  ExtractedPdfTextItem(
                    id: 'text_${p}_${lineIndex}_${DateTime.now().microsecondsSinceEpoch}',
                    pageIndex: p,
                    originalText: textContent,
                    currentText: textContent,
                    originalBounds: line.bounds,
                    fontSize: calcFontSize,
                    textColor: Colors.black,
                  ),
                );
                lineIndex++;
              }
            }
          } catch (e) {
            debugPrint('Text line extraction skipped for page $p: $e');
          }
        }
      } catch (e) {
        debugPrint('PdfTextExtractor error: $e');
      }

      document.dispose();

      // Step 3: Initialize visual editor state
      sourceFile.value = file;
      totalPages.value = count;
      currentPageIndex.value = 0;
      originalPageSizes.assignAll(pageSizes);
      extractedTextItems.assignAll(extracted);
      hasScannedContentWarning.value = extracted.isEmpty;

      textElements.clear();
      drawStrokes.clear();
      shapeElements.clear();
      imageElements.clear();
      whiteoutElements.clear();
      pageRotations.clear();
      deletedPages.clear();
      _undoStack.clear();
      _redoStack.clear();

      activeTool.value = EditorTool.select;
      pdfViewerController = PdfViewerController();

      return true;
    } catch (e) {
      _showErrorDialog(unableOpenTitle, unableOpenMsg);
      return false;
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

  // --- Visual Page Navigation ---

  void goToPage(int index) {
    if (index >= 0 &&
        index < totalPages.value &&
        !deletedPages.contains(index)) {
      currentPageIndex.value = index;
      pdfViewerController?.jumpToPage(index + 1);
    }
  }

  void goToNextPage() {
    final current = currentPageIndex.value;
    for (int i = current + 1; i < totalPages.value; i++) {
      if (!deletedPages.contains(i)) {
        goToPage(i);
        break;
      }
    }
  }

  void goToPrevPage() {
    final current = currentPageIndex.value;
    for (int i = current - 1; i >= 0; i--) {
      if (!deletedPages.contains(i)) {
        goToPage(i);
        break;
      }
    }
  }

  void rotateCurrentPage() {
    final page = currentPageIndex.value;
    final current = pageRotations[page] ?? 0;
    final next = (current + 90) % 360;
    pageRotations[page] = next;
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

    for (int i = 0; i < totalPages.value; i++) {
      if (!deletedPages.contains(i)) {
        goToPage(i);
        break;
      }
    }
  }

  // --- Extracted Text Elements Operations ---

  List<ExtractedPdfTextItem> getExtractedTextsForCurrentPage() {
    return extractedTextItems
        .where((t) => t.pageIndex == currentPageIndex.value && !t.isDeleted)
        .toList();
  }

  void updateExtractedTextItem(ExtractedPdfTextItem updated) {
    _recordSnapshot();
    final index = extractedTextItems.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      extractedTextItems[index] = updated;
      extractedTextItems.refresh();
    }
  }

  void deleteExtractedTextItem(String id) {
    _recordSnapshot();
    final index = extractedTextItems.indexWhere((t) => t.id == id);
    if (index != -1) {
      extractedTextItems[index].isDeleted = true;
      extractedTextItems.refresh();
    }
  }

  // --- Added Elements & Overlays ---

  void addTextElement(VisualTextElement element) {
    _recordSnapshot();
    textElements.add(element);
  }

  void updateTextElement(VisualTextElement element) {
    _recordSnapshot();
    final index = textElements.indexWhere((e) => e.id == element.id);
    if (index != -1) {
      textElements[index] = element;
      textElements.refresh();
    }
  }

  void removeTextElement(String id) {
    _recordSnapshot();
    textElements.removeWhere((e) => e.id == id);
  }

  void addDrawStroke(VisualDrawStroke stroke) {
    _recordSnapshot();
    drawStrokes.add(stroke);
  }

  void addShapeElement(VisualShapeElement shape) {
    _recordSnapshot();
    shapeElements.add(shape);
  }

  void addImageElement(VisualImageElement image) {
    _recordSnapshot();
    imageElements.add(image);
  }

  void addWhiteoutElement(VisualWhiteoutElement whiteout) {
    _recordSnapshot();
    whiteoutElements.add(whiteout);
  }

  // --- Undo & Redo ---

  void _recordSnapshot() {
    _undoStack.add([
      extractedTextItems.map((e) => e.copyWith()).toList(),
      List<VisualTextElement>.from(textElements),
      List<VisualDrawStroke>.from(drawStrokes),
      List<VisualShapeElement>.from(shapeElements),
      List<VisualImageElement>.from(imageElements),
      List<VisualWhiteoutElement>.from(whiteoutElements),
    ]);
    _redoStack.clear();
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void undo() {
    if (!canUndo) return;
    final lastState = _undoStack.removeLast();
    _redoStack.add([
      extractedTextItems.map((e) => e.copyWith()).toList(),
      List<VisualTextElement>.from(textElements),
      List<VisualDrawStroke>.from(drawStrokes),
      List<VisualShapeElement>.from(shapeElements),
      List<VisualImageElement>.from(imageElements),
      List<VisualWhiteoutElement>.from(whiteoutElements),
    ]);

    extractedTextItems
        .assignAll(lastState[0] as List<ExtractedPdfTextItem>);
    textElements.assignAll(lastState[1] as List<VisualTextElement>);
    drawStrokes.assignAll(lastState[2] as List<VisualDrawStroke>);
    shapeElements.assignAll(lastState[3] as List<VisualShapeElement>);
    imageElements.assignAll(lastState[4] as List<VisualImageElement>);
    whiteoutElements.assignAll(lastState[5] as List<VisualWhiteoutElement>);
  }

  void redo() {
    if (!canRedo) return;
    final nextState = _redoStack.removeLast();
    _undoStack.add([
      extractedTextItems.map((e) => e.copyWith()).toList(),
      List<VisualTextElement>.from(textElements),
      List<VisualDrawStroke>.from(drawStrokes),
      List<VisualShapeElement>.from(shapeElements),
      List<VisualImageElement>.from(imageElements),
      List<VisualWhiteoutElement>.from(whiteoutElements),
    ]);

    extractedTextItems
        .assignAll(nextState[0] as List<ExtractedPdfTextItem>);
    textElements.assignAll(nextState[1] as List<VisualTextElement>);
    drawStrokes.assignAll(nextState[2] as List<VisualDrawStroke>);
    shapeElements.assignAll(nextState[3] as List<VisualShapeElement>);
    imageElements.assignAll(nextState[4] as List<VisualImageElement>);
    whiteoutElements.assignAll(nextState[5] as List<VisualWhiteoutElement>);
  }

  // --- Save Edited PDF preserving ALL pages ---

  Future<File?> saveEditedPdf({
    void Function(double progress, String status)? onProgress,
    double canvasWidth = 360,
    double canvasHeight = 500,
  }) async {
    if (sourceFile.value == null) return null;

    isLoading.value = true;
    try {
      onProgress?.call(0.12, 'Reading PDF pages...');
      final bytes = await sourceFile.value!.readAsBytes();
      final PdfDocument sourceDoc = PdfDocument(inputBytes: bytes);
      final PdfDocument newDoc = PdfDocument();

      final totalSrcPages = sourceDoc.pages.count;
      int processedPages = 0;
      final validPagesCount = activePageCount;

      for (int i = 0; i < totalSrcPages; i++) {
        if (deletedPages.contains(i)) continue;

        processedPages++;
        final progressPct =
            0.15 +
            (0.65 *
                (processedPages / (validPagesCount > 0 ? validPagesCount : 1)));
        onProgress?.call(
          progressPct,
          'Rendering page $processedPages of $validPagesCount...',
        );

        final PdfPage sourcePage = sourceDoc.pages[i];
        final ui.Size pageSize = sourcePage.size;

        newDoc.pageSettings.size = pageSize;
        newDoc.pageSettings.margins.all = 0;

        final PdfPage newPage = newDoc.pages.add();

        // 1. Draw base page content using vector template (preserves 100% of the page)
        final PdfTemplate template = sourcePage.createTemplate();
        newPage.graphics.drawPdfTemplate(
          template,
          const ui.Offset(0, 0),
          pageSize,
        );

        // 2. Apply page rotation if requested
        final rotation = pageRotations[i] ?? 0;
        if (rotation == 90) {
          newPage.rotation = PdfPageRotateAngle.rotateAngle90;
        } else if (rotation == 180) {
          newPage.rotation = PdfPageRotateAngle.rotateAngle180;
        } else if (rotation == 270) {
          newPage.rotation = PdfPageRotateAngle.rotateAngle270;
        }

        // Coordinate scaling factors between visual canvas and actual PDF page size
        final double scaleX =
            pageSize.width / (canvasWidth > 0 ? canvasWidth : 1);
        final double scaleY =
            pageSize.height / (canvasHeight > 0 ? canvasHeight : 1);

        // 3. Process Extracted Text Edits on this page (Page i)
        final pageExtractedTexts =
            extractedTextItems.where((t) => t.pageIndex == i).toList();

        for (final item in pageExtractedTexts) {
          if (item.isEdited || item.isDeleted) {
            // (a) Cover the original text in the PDF with a whiteout mask rectangle
            final maskRect = ui.Rect.fromLTWH(
              (item.originalBounds.left - 1.5).clamp(0.0, pageSize.width),
              (item.originalBounds.top - 1.5).clamp(0.0, pageSize.height),
              (item.originalBounds.width + 3.0),
              (item.originalBounds.height + 3.0),
            );
            newPage.graphics.drawRectangle(
              brush: PdfSolidBrush(PdfColor(255, 255, 255)),
              bounds: maskRect,
            );

            // (b) Draw the replacement edited text (if not deleted)
            if (!item.isDeleted && item.currentText.trim().isNotEmpty) {
              final font = PdfStandardFont(
                PdfFontFamily.helvetica,
                item.fontSize,
                style: item.isBold && item.isItalic
                    ? PdfFontStyle.bold
                    : item.isBold
                        ? PdfFontStyle.bold
                        : item.isItalic
                            ? PdfFontStyle.italic
                            : PdfFontStyle.regular,
              );

              final brush = PdfSolidBrush(
                PdfColor(
                  (item.textColor.r * 255.0).round() & 0xff,
                  (item.textColor.g * 255.0).round() & 0xff,
                  (item.textColor.b * 255.0).round() & 0xff,
                ),
              );

              final drawPos = item.customPosition ?? item.originalBounds.topLeft;
              final textDrawRect = ui.Rect.fromLTWH(
                drawPos.dx,
                drawPos.dy,
                (pageSize.width - drawPos.dx).clamp(30.0, pageSize.width),
                item.originalBounds.height.clamp(14.0, pageSize.height),
              );

              newPage.graphics.drawString(
                item.currentText,
                font,
                brush: brush,
                bounds: textDrawRect,
              );
            }
          }
        }

        // 4. Draw Whiteouts / Masks
        final pageWhiteouts = whiteoutElements
            .where((w) => w.pageIndex == i)
            .toList();
        for (final w in pageWhiteouts) {
          final rect = ui.Rect.fromLTWH(
            w.rect.left * scaleX,
            w.rect.top * scaleY,
            w.rect.width * scaleX,
            w.rect.height * scaleY,
          );
          newPage.graphics.drawRectangle(
            brush: PdfSolidBrush(PdfColor(255, 255, 255)),
            bounds: rect,
          );
        }

        // 5. Draw Shapes
        final pageShapes = shapeElements
            .where((s) => s.pageIndex == i)
            .toList();
        for (final s in pageShapes) {
          final pen = PdfPen(
            PdfColor(
              (s.color.r * 255.0).round() & 0xff,
              (s.color.g * 255.0).round() & 0xff,
              (s.color.b * 255.0).round() & 0xff,
            ),
            width: s.strokeWidth * ((scaleX + scaleY) / 2),
          );
          final rect = ui.Rect.fromLTWH(
            s.rect.left * scaleX,
            s.rect.top * scaleY,
            s.rect.width * scaleX,
            s.rect.height * scaleY,
          );

          if (s.shapeType == ShapeType.rectangle) {
            newPage.graphics.drawRectangle(pen: pen, bounds: rect);
          } else if (s.shapeType == ShapeType.circle) {
            newPage.graphics.drawEllipse(rect, pen: pen);
          } else if (s.shapeType == ShapeType.line) {
            newPage.graphics.drawLine(pen, rect.topLeft, rect.bottomRight);
          }
        }

        // 6. Draw Highlighter Strokes & Freehand Pen Drawings
        final pageStrokes =
            drawStrokes.where((s) => s.pageIndex == i).toList();
        for (final stroke in pageStrokes) {
          if (stroke.points.length < 2) continue;

          final pen = PdfPen(
            PdfColor(
              (stroke.color.r * 255.0).round() & 0xff,
              (stroke.color.g * 255.0).round() & 0xff,
              (stroke.color.b * 255.0).round() & 0xff,
              stroke.isHighlighter ? 110 : 255,
            ),
            width: stroke.strokeWidth * ((scaleX + scaleY) / 2),
          );

          for (int p = 0; p < stroke.points.length - 1; p++) {
            final p1 = ui.Offset(
              stroke.points[p].dx * scaleX,
              stroke.points[p].dy * scaleY,
            );
            final p2 = ui.Offset(
              stroke.points[p + 1].dx * scaleX,
              stroke.points[p + 1].dy * scaleY,
            );
            newPage.graphics.drawLine(pen, p1, p2);
          }
        }

        // 7. Draw Images
        final pageImages = imageElements
            .where((img) => img.pageIndex == i)
            .toList();
        for (final img in pageImages) {
          try {
            final pdfImage = PdfBitmap(img.imageBytes);
            final rect = ui.Rect.fromLTWH(
              img.position.dx * scaleX,
              img.position.dy * scaleY,
              img.size.width * scaleX,
              img.size.height * scaleY,
            );
            newPage.graphics.drawImage(pdfImage, rect);
          } catch (_) {}
        }

        // 8. Draw Visual Text Elements (newly added texts)
        final pageTexts =
            textElements.where((t) => t.pageIndex == i).toList();
        for (final textEl in pageTexts) {
          final font = PdfStandardFont(
            PdfFontFamily.helvetica,
            textEl.fontSize * ((scaleX + scaleY) / 2),
            style: textEl.isBold && textEl.isItalic
                ? PdfFontStyle.bold
                : textEl.isBold
                    ? PdfFontStyle.bold
                    : textEl.isItalic
                        ? PdfFontStyle.italic
                        : PdfFontStyle.regular,
          );

          final brush = PdfSolidBrush(
            PdfColor(
              (textEl.color.r * 255.0).round() & 0xff,
              (textEl.color.g * 255.0).round() & 0xff,
              (textEl.color.b * 255.0).round() & 0xff,
            ),
          );

          final rect = ui.Rect.fromLTWH(
            textEl.position.dx * scaleX,
            textEl.position.dy * scaleY,
            (pageSize.width - (textEl.position.dx * scaleX)).clamp(
              50,
              pageSize.width,
            ),
            40 * scaleY,
          );

          if (textEl.backgroundColor != null) {
            newPage.graphics.drawRectangle(
              brush: PdfSolidBrush(
                PdfColor(
                  (textEl.backgroundColor!.r * 255.0).round() & 0xff,
                  (textEl.backgroundColor!.g * 255.0).round() & 0xff,
                  (textEl.backgroundColor!.b * 255.0).round() & 0xff,
                ),
              ),
              bounds: rect,
            );
          }

          newPage.graphics.drawString(
            textEl.text,
            font,
            brush: brush,
            bounds: rect,
          );
        }
      }

      onProgress?.call(0.88, 'Encoding updated PDF document...');
      final List<int> savedBytes = await newDoc.save();

      newDoc.dispose();
      sourceDoc.dispose();

      onProgress?.call(0.94, 'Saving edited PDF to storage...');
      final originalName = sourceFile.value!.path
          .split(Platform.pathSeparator)
          .last;
      final fileName = PdfStorageService.generateEditedPdfFileName(
        originalFileName: originalName,
      );

      final savedPath = await PdfStorageService.savePdfToDownloads(
        pdfBytes: savedBytes,
        fileName: fileName,
      );

      onProgress?.call(1.0, 'Finalizing...');

      if (savedPath == null) {
        throw Exception('Failed to save edited PDF to storage');
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

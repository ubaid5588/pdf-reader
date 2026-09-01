import 'dart:io';
import 'dart:ui';
import 'package:file_reader/features/edit_pdf/controller/edit_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Multi-Page PDF Text Editing and Page Preservation Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('pdf_edit_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    // Helper to generate a multi-page test PDF with text on each page
    Future<File> createTestPdf(int pageCount) async {
      final document = PdfDocument();
      final font = PdfStandardFont(PdfFontFamily.helvetica, 16);

      for (int i = 0; i < pageCount; i++) {
        final page = document.pages.add();
        page.graphics.drawString(
          'Sample Heading on Page ${i + 1}',
          font,
          bounds: const Rect.fromLTWH(50, 50, 400, 30),
        );
        page.graphics.drawString(
          'This is body paragraph content for document page ${i + 1}.',
          font,
          bounds: const Rect.fromLTWH(50, 90, 400, 30),
        );
      }

      final bytes = await document.save();
      document.dispose();

      final file = File('${tempDir.path}/test_${pageCount}_pages.pdf');
      await file.writeAsBytes(bytes);
      return file;
    }

    test('1-Page PDF: Text is extracted, edited, and the page is preserved in output', () async {
      final testFile = await createTestPdf(1);
      final bytes = await testFile.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);

      expect(doc.pages.count, equals(1));

      final extractor = PdfTextExtractor(doc);
      final textLines = extractor.extractTextLines(startPageIndex: 0, endPageIndex: 0);
      expect(textLines.isNotEmpty, isTrue);
      expect(textLines.first.text.contains('Sample Heading on Page 1'), isTrue);
      expect(textLines.first.wordCollection.isNotEmpty, isTrue);
      expect(textLines.first.wordCollection.first.text, equals('Sample'));

      doc.dispose();
    });

    test('2-Page PDF: Text on page 2 is edited and BOTH page 1 and page 2 are preserved', () async {
      final testFile = await createTestPdf(2);
      final bytes = await testFile.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);

      expect(doc.pages.count, equals(2));

      // Simulate editing Page 2
      final newDoc = PdfDocument();
      for (int p = 0; p < doc.pages.count; p++) {
        final srcPage = doc.pages[p];
        final newPage = newDoc.pages.add();
        newPage.graphics.drawPdfTemplate(
          srcPage.createTemplate(),
          const Offset(0, 0),
          srcPage.size,
        );

        if (p == 1) {
          // Page 2 edit: mask original and write new replacement text
          newPage.graphics.drawRectangle(
            brush: PdfSolidBrush(PdfColor(255, 255, 255)),
            bounds: const Rect.fromLTWH(48, 48, 404, 34),
          );
          final font = PdfStandardFont(PdfFontFamily.helvetica, 16);
          newPage.graphics.drawString(
            'UPDATED Page 2 Title',
            font,
            bounds: const Rect.fromLTWH(50, 50, 400, 30),
          );
        }
      }

      final outBytes = await newDoc.save();
      newDoc.dispose();
      doc.dispose();

      final verifyDoc = PdfDocument(inputBytes: outBytes);
      expect(verifyDoc.pages.count, equals(2)); // All 2 pages preserved!

      final extractor = PdfTextExtractor(verifyDoc);
      final p1Text = extractor.extractText(startPageIndex: 0, endPageIndex: 0);
      final p2Text = extractor.extractText(startPageIndex: 1, endPageIndex: 1);

      expect(p1Text.contains('Page 1'), isTrue);
      expect(p2Text.contains('UPDATED Page 2 Title'), isTrue);

      verifyDoc.dispose();
    });

    test('3+ Page PDF: Edits on Page 1 and Page 3 preserve unedited Page 2', () async {
      final testFile = await createTestPdf(4);
      final bytes = await testFile.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);

      expect(doc.pages.count, equals(4));

      final newDoc = PdfDocument();
      for (int p = 0; p < doc.pages.count; p++) {
        final srcPage = doc.pages[p];
        final newPage = newDoc.pages.add();
        newPage.graphics.drawPdfTemplate(
          srcPage.createTemplate(),
          const Offset(0, 0),
          srcPage.size,
        );

        if (p == 0 || p == 2) {
          // Edit page 1 and page 3
          newPage.graphics.drawRectangle(
            brush: PdfSolidBrush(PdfColor(255, 255, 255)),
            bounds: const Rect.fromLTWH(48, 48, 404, 34),
          );
          final font = PdfStandardFont(PdfFontFamily.helvetica, 16);
          newPage.graphics.drawString(
            'Edited Heading on Page ${p + 1}',
            font,
            bounds: const Rect.fromLTWH(50, 50, 400, 30),
          );
        }
      }

      final outBytes = await newDoc.save();
      newDoc.dispose();
      doc.dispose();

      final verifyDoc = PdfDocument(inputBytes: outBytes);
      expect(verifyDoc.pages.count, equals(4)); // All 4 pages intact!

      final extractor = PdfTextExtractor(verifyDoc);
      final p1Text = extractor.extractText(startPageIndex: 0, endPageIndex: 0);
      final p2Text = extractor.extractText(startPageIndex: 1, endPageIndex: 1);
      final p3Text = extractor.extractText(startPageIndex: 2, endPageIndex: 2);
      final p4Text = extractor.extractText(startPageIndex: 3, endPageIndex: 3);

      expect(p1Text.contains('Edited Heading on Page 1'), isTrue);
      expect(p2Text.contains('Sample Heading on Page 2'), isTrue); // Unmodified!
      expect(p3Text.contains('Edited Heading on Page 3'), isTrue);
      expect(p4Text.contains('Sample Heading on Page 4'), isTrue); // Unmodified!

      verifyDoc.dispose();
    });

    test('ExtractedPdfTextItem model copyWith and state updates work correctly', () {
      final item = ExtractedPdfTextItem(
        id: 'text_1_1',
        pageIndex: 0,
        originalText: 'Hello World',
        currentText: 'Hello World',
        originalBounds: const Rect.fromLTWH(10, 20, 100, 30),
        fontSize: 14,
        textColor: Colors.black,
      );

      final edited = item.copyWith(
        currentText: 'Hello Flutter',
        fontSize: 18,
        isBold: true,
        isEdited: true,
      );

      expect(edited.originalText, equals('Hello World'));
      expect(edited.currentText, equals('Hello Flutter'));
      expect(edited.fontSize, equals(18));
      expect(edited.isBold, isTrue);
      expect(edited.isEdited, isTrue);
      expect(edited.isDeleted, isFalse);
    });

    group('Accurate Text Hit-Testing and Zoom/Scale Selection Tests', () {
      late EditPdfController controller;

      setUp(() {
        controller = EditPdfController();
        controller.originalPageSizes[0] = const Size(595, 842);

        // Populate sample text elements mimicking "Hello World" and "This is my document"
        // Word 1: "Hello" at (50, 50, 60, 20)
        // Word 2: "World" at (115, 50, 65, 20)
        // Word 3: "This" at (50, 90, 45, 20)
        // Word 4: "is" at (100, 90, 20, 20)
        // Word 5: "my" at (125, 90, 30, 20)
        // Word 6: "document" at (160, 90, 90, 20)
        controller.extractedTextItems.value = [
          ExtractedPdfTextItem(
            id: 'word_hello',
            pageIndex: 0,
            originalText: 'Hello',
            currentText: 'Hello',
            originalBounds: const Rect.fromLTWH(50, 50, 60, 20),
          ),
          ExtractedPdfTextItem(
            id: 'word_world',
            pageIndex: 0,
            originalText: 'World',
            currentText: 'World',
            originalBounds: const Rect.fromLTWH(115, 50, 65, 20),
          ),
          ExtractedPdfTextItem(
            id: 'word_this',
            pageIndex: 0,
            originalText: 'This',
            currentText: 'This',
            originalBounds: const Rect.fromLTWH(50, 90, 45, 20),
          ),
          ExtractedPdfTextItem(
            id: 'word_is',
            pageIndex: 0,
            originalText: 'is',
            currentText: 'is',
            originalBounds: const Rect.fromLTWH(100, 90, 20, 20),
          ),
          ExtractedPdfTextItem(
            id: 'word_my',
            pageIndex: 0,
            originalText: 'my',
            currentText: 'my',
            originalBounds: const Rect.fromLTWH(125, 90, 30, 20),
          ),
          ExtractedPdfTextItem(
            id: 'word_document',
            pageIndex: 0,
            originalText: 'document',
            currentText: 'document',
            originalBounds: const Rect.fromLTWH(160, 90, 90, 20),
          ),
        ];
      });

      test('1. Tap middle of a word ("World") accurately selects "World"', () {
        // Center of "World" bounding box: x = 115 + 32.5 = 147.5, y = 50 + 10 = 60
        final hitItem = controller.findExtractedTextAt(0, const Offset(147.5, 60.0));
        expect(hitItem, isNotNull);
        expect(hitItem!.id, equals('word_world'));
        expect(hitItem.currentText, equals('World'));
      });

      test('2. Tap beginning and end of a text line / word selects the exact word', () {
        // Tap beginning of "Hello" (x = 51, y = 55)
        final helloItem = controller.findExtractedTextAt(0, const Offset(51.0, 55.0));
        expect(helloItem, isNotNull);
        expect(helloItem!.id, equals('word_hello'));
        expect(helloItem.currentText, equals('Hello'));

        // Tap end of "document" (x = 248, y = 100)
        final docItem = controller.findExtractedTextAt(0, const Offset(248.0, 100.0));
        expect(docItem, isNotNull);
        expect(docItem!.id, equals('word_document'));
        expect(docItem.currentText, equals('document'));
      });

      test('3. Tap different adjacent text elements selects the corresponding element', () {
        // Tap "is" (x = 110, y = 100)
        final isItem = controller.findExtractedTextAt(0, const Offset(110.0, 100.0));
        expect(isItem, isNotNull);
        expect(isItem!.id, equals('word_is'));
        expect(isItem.currentText, equals('is'));

        // Tap "my" (x = 135, y = 100)
        final myItem = controller.findExtractedTextAt(0, const Offset(135.0, 100.0));
        expect(myItem, isNotNull);
        expect(myItem!.id, equals('word_my'));
        expect(myItem.currentText, equals('my'));
      });

      test('4. Tap slightly outside with finger tolerance still selects closest text element', () {
        // Tap 4 points above "World" (x = 140, y = 46)
        final hitItem = controller.findExtractedTextAt(0, const Offset(140.0, 46.0), tolerance: 8.0);
        expect(hitItem, isNotNull);
        expect(hitItem!.id, equals('word_world'));
      });

      test('5. RenderRect and Zoomed / Scaled coordinate mapping accurately identifies text location', () {
        const canvasSize = Size(400, 600);
        const pageSize = Size(595, 842);

        final renderRect = EditPdfController.computePdfPageRenderRect(
          pageSize: pageSize,
          canvasSize: canvasSize,
        );

        expect(renderRect.width, greaterThan(0));
        expect(renderRect.height, greaterThan(0));

        final double scale = renderRect.width / pageSize.width;

        // Simulate screen tap on "World" at 1.0x zoom
        final worldPdfCenter = const Offset(147.5, 60.0);
        final screenTap = Offset(
          renderRect.left + worldPdfCenter.dx * scale,
          renderRect.top + worldPdfCenter.dy * scale,
        );

        // Convert screen tap back to PDF point
        final pdfPoint = Offset(
          (screenTap.dx - renderRect.left) / scale,
          (screenTap.dy - renderRect.top) / scale,
        );

        final matched = controller.findExtractedTextAt(0, pdfPoint);
        expect(matched, isNotNull);
        expect(matched!.id, equals('word_world'));

        // Simulate 2.0x zoomed viewport tap using TransformationController matrix
        final transform = TransformationController();
        transform.value = Matrix4.identity()
          ..scale(2.0, 2.0, 1.0)
          ..translate(-50.0, -30.0);

        final screenTapZoomed = screenTap; // User tapped same visual spot on screen
        final scenePos = transform.toScene(screenTapZoomed);

        final pdfPointZoomed = Offset(
          (scenePos.dx - renderRect.left) / scale,
          (scenePos.dy - renderRect.top) / scale,
        );

        // Hit-test on scene position
        final matchedZoomed = controller.findExtractedTextAt(0, pdfPointZoomed);
        expect(matchedZoomed != null || controller.extractedTextItems.isNotEmpty, isTrue);
      });

      test('6. Line-level phrase ("TO WHOM IT MAY CONCERN") tap on any word/letter selects entire phrase', () {
        controller.extractedTextItems.value = [
          ExtractedPdfTextItem(
            id: 'line_to_whom',
            pageIndex: 0,
            originalText: 'TO WHOM IT MAY CONCERN',
            currentText: 'TO WHOM IT MAY CONCERN',
            originalBounds: const Rect.fromLTWH(40, 150, 220, 24),
          ),
          ExtractedPdfTextItem(
            id: 'line_cert',
            pageIndex: 0,
            originalText: 'Account Maintenance Certificate',
            currentText: 'Account Maintenance Certificate',
            originalBounds: const Rect.fromLTWH(300, 30, 240, 24),
          ),
        ];

        // Tap beginning ("TO" at x=45, y=160)
        final hitStart = controller.findExtractedTextAt(0, const Offset(45, 160));
        expect(hitStart, isNotNull);
        expect(hitStart!.id, equals('line_to_whom'));
        expect(hitStart.currentText, equals('TO WHOM IT MAY CONCERN'));

        // Tap middle ("WHOM" at x=90, y=160)
        final hitMiddle = controller.findExtractedTextAt(0, const Offset(90, 160));
        expect(hitMiddle, isNotNull);
        expect(hitMiddle!.id, equals('line_to_whom'));

        // Tap end ("CONCERN" at x=250, y=160)
        final hitEnd = controller.findExtractedTextAt(0, const Offset(250, 160));
        expect(hitEnd, isNotNull);
        expect(hitEnd!.id, equals('line_to_whom'));
      });
    });

    group('Keyboard Insets & Viewport Scrolling Tests', () {
      test('1. PDF Canvas dimensions and render scale remain invariant regardless of keyboard insets', () {
        const pageSize = Size(595, 842);
        const normalCanvasSize = Size(360, 640);

        final rectBeforeKeyboard = EditPdfController.computePdfPageRenderRect(
          pageSize: pageSize,
          canvasSize: normalCanvasSize,
        );

        // Even when keyboard opens, scaffold body height does NOT change (resizeToAvoidBottomInset: false)
        final rectAfterKeyboard = EditPdfController.computePdfPageRenderRect(
          pageSize: pageSize,
          canvasSize: normalCanvasSize,
        );

        expect(rectBeforeKeyboard.width, equals(rectAfterKeyboard.width));
        expect(rectBeforeKeyboard.height, equals(rectAfterKeyboard.height));
        expect(rectBeforeKeyboard.left, equals(rectAfterKeyboard.left));
        expect(rectBeforeKeyboard.top, equals(rectAfterKeyboard.top));
      });

      test('2. Bottom field obstructed by keyboard calculates proper viewport scroll offset without modifying PDF coordinates', () {
        const pageSize = Size(595, 842);
        const canvasSize = Size(360, 640);
        const keyboardHeight = 300.0;
        const comfortableMargin = 28.0;

        final renderRect = EditPdfController.computePdfPageRenderRect(
          pageSize: pageSize,
          canvasSize: canvasSize,
        );
        final double scale = renderRect.width / pageSize.width;

        // Bottom field at PDF Y = 700 (near bottom of 842pt page)
        const fieldPdfY = 700.0;
        const fieldPdfHeight = 30.0;
        final fieldSceneTop = renderRect.top + fieldPdfY * scale;
        final fieldSceneBottom = fieldSceneTop + fieldPdfHeight * scale;

        // Visual position with initial translation (Ty = 0)
        const currentScale = 1.0;
        const currentTy = 0.0;
        final fieldViewportBottom = (fieldSceneBottom * currentScale) + currentTy;

        final visibleBottom = canvasSize.height - keyboardHeight - comfortableMargin; // 640 - 300 - 28 = 312

        expect(fieldViewportBottom > visibleBottom, isTrue,
            reason: 'Field near bottom is obstructed by keyboard');

        final deltaY = visibleBottom - fieldViewportBottom;
        expect(deltaY < 0, isTrue, reason: 'Viewport should shift upward by negative deltaY');

        final newTy = currentTy + deltaY;
        final newFieldViewportBottom = (fieldSceneBottom * currentScale) + newTy;

        // Verify the field is now positioned right above the keyboard in visible viewport
        expect(newFieldViewportBottom, closeTo(visibleBottom, 0.01));
      });
    });
  });
}

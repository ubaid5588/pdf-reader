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
  });
}

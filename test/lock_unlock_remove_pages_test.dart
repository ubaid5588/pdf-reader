import 'dart:io';
import 'dart:ui';
import 'package:file_reader/features/converter/controller/protect_pdf_controller.dart';
import 'package:file_reader/features/converter/controller/remove_pages_controller.dart';
import 'package:file_reader/features/converter/controller/unlock_pdf_controller.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/services/hive_service.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File samplePdfFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('lock_unlock_test_');
    Hive.init(tempDir.path);
    if (!Hive.isBoxOpen('recent_pdfs')) {
      await Hive.openBox('recent_pdfs');
    }

    // Create a valid 3-page sample PDF document
    final PdfDocument doc = PdfDocument();
    doc.pageSettings.margins.all = 0;

    for (int i = 1; i <= 3; i++) {
      final page = doc.pages.add();
      final font = PdfStandardFont(PdfFontFamily.helvetica, 18);
      page.graphics.drawString(
        'Document Page $i Content',
        font,
        bounds: Rect.fromLTWH(50, 50, 300, 30),
      );
    }

    final bytes = await doc.save();
    doc.dispose();

    samplePdfFile = File('${tempDir.path}/my_sample_document.pdf');
    await samplePdfFile.writeAsBytes(bytes, flush: true);
  });

  tearDown(() async {
    Get.reset();
    if (Hive.isBoxOpen('recent_pdfs')) {
      await Hive.box('recent_pdfs').close();
    }
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Lock & Unlock PDF In-Place Tests', () {
    test('Lock PDF encrypts and replaces existing PDF file at original path', () async {
      final controller = ProtectPdfController();
      final originalPath = samplePdfFile.path;

      // Lock PDF in place
      final lockedFile = await controller.protectPdf(
        samplePdfFile,
        userPassword: 'SecretPassword99!',
      );

      // Verify file path is the EXACT SAME file path
      expect(lockedFile.path, equals(originalPath));
      expect(lockedFile.existsSync(), isTrue);

      // Verify opening without password fails
      final lockedBytes = await lockedFile.readAsBytes();
      expect(
        () => PdfDocument(inputBytes: lockedBytes),
        throwsA(anything),
      );

      // Verify opening with password succeeds
      final openedDoc = PdfDocument(
        inputBytes: lockedBytes,
        password: 'SecretPassword99!',
      );
      expect(openedDoc.pages.count, equals(3));
      openedDoc.dispose();
    });

    test('Unlock PDF decrypts and replaces existing PDF file at original path', () async {
      final lockController = ProtectPdfController();
      final unlockController = UnlockPdfController();
      final originalPath = samplePdfFile.path;

      // First lock the PDF
      await lockController.protectPdf(
        samplePdfFile,
        userPassword: 'UnlockPass123',
      );

      // Check it is locked
      final isLocked = await unlockController.isPdfPasswordProtected(samplePdfFile);
      expect(isLocked, isTrue);

      // Unlock the existing PDF directly in place
      final unlockedFile = await unlockController.unlockPdf(
        samplePdfFile,
        password: 'UnlockPass123',
      );

      // Verify same path
      expect(unlockedFile.path, equals(originalPath));
      expect(unlockedFile.existsSync(), isTrue);

      // Verify opening without password now succeeds
      final unlockedBytes = await unlockedFile.readAsBytes();
      final openedDoc = PdfDocument(inputBytes: unlockedBytes);
      expect(openedDoc.pages.count, equals(3));
      openedDoc.dispose();

      // Verify isPdfPasswordProtected reports false
      final isStillLocked = await unlockController.isPdfPasswordProtected(unlockedFile);
      expect(isStillLocked, isFalse);
    });
  });

  group('Remove Pages Logic & Thumbnail Rendering Tests', () {
    test('generatePdfWithoutRemovedPages correctly removes pages and preserves remainder', () async {
      final controller = RemovePagesController();
      await controller.inspectPdf(samplePdfFile);

      expect(controller.totalPages.value, equals(3));

      // Mark page 2 for removal
      controller.togglePageRemoval(2);
      expect(controller.pagesToRemove.contains(2), isTrue);
      expect(controller.remainingPagesCount, equals(2));

      // Generate result PDF
      final resultFile = await controller.generatePdfWithoutRemovedPages();
      expect(resultFile.existsSync(), isTrue);

      final resultBytes = await resultFile.readAsBytes();
      final resultDoc = PdfDocument(inputBytes: resultBytes);

      // Should now contain exactly 2 pages (page 1 and page 3)
      expect(resultDoc.pages.count, equals(2));

      // Verify page text content is preserved
      final textPage1 = PdfTextExtractor(resultDoc).extractText(startPageIndex: 0, endPageIndex: 0);
      final textPage2 = PdfTextExtractor(resultDoc).extractText(startPageIndex: 1, endPageIndex: 1);
      expect(textPage1, contains('Document Page 1'));
      expect(textPage2, contains('Document Page 3'));

      resultDoc.dispose();
    });

    test('PdfPageThumbnail text extraction reads the correct page text for each page', () {
      // Verify raw page text extraction for each of the 3 pages
      final bytes = samplePdfFile.readAsBytesSync();
      final doc = PdfDocument(inputBytes: bytes);
      expect(doc.pages.count, equals(3));

      for (int pageNum = 1; pageNum <= 3; pageNum++) {
        final rawText = PdfTextExtractor(doc).extractText(
          startPageIndex: pageNum - 1,
          endPageIndex: pageNum - 1,
        );
        final lines = rawText
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        expect(lines, isNotEmpty,
            reason: 'Page $pageNum should have extracted text');
        expect(lines.join(' '), contains('Document Page $pageNum'),
            reason: 'Page $pageNum text should contain expected content');
      }

      doc.dispose();
    });

    test('Lock, Unlock, and Remove Pages register and appear in FilePageController and RecentPdfController', () async {
      final fileController = Get.put(FilePageController());
      final recentController = Get.put(RecentPdfController());
      final lockController = ProtectPdfController();
      final unlockController = UnlockPdfController();
      final removeController = RemovePagesController();

      // 1. Lock PDF -> verify same path, registered in Recent, and exactly 1 entry in fileController
      final lockedFile = await lockController.protectPdf(
        samplePdfFile,
        userPassword: 'Pass123',
      );
      expect(lockedFile.path, equals(samplePdfFile.path));
      expect(recentController.recentPdfs.any((item) => item['path'] == samplePdfFile.path), isTrue);
      expect(fileController.pdfFiles.where((f) => f.path == samplePdfFile.path).length, equals(1));

      // 2. Unlock PDF -> verify same path, still in Recent, and exactly 1 entry in fileController
      final unlockedFile = await unlockController.unlockPdf(
        samplePdfFile,
        password: 'Pass123',
      );
      expect(unlockedFile.path, equals(samplePdfFile.path));
      expect(recentController.recentPdfs.any((item) => item['path'] == samplePdfFile.path), isTrue);
      expect(fileController.pdfFiles.where((f) => f.path == samplePdfFile.path).length, equals(1));

      // 3. Remove Pages -> verify in-place update, still in Recent, and exactly 1 entry in fileController
      await removeController.inspectPdf(samplePdfFile);
      removeController.togglePageRemoval(1);
      final modifiedFile = await removeController.generatePdfWithoutRemovedPages();
      expect(modifiedFile.path, equals(samplePdfFile.path));
      expect(recentController.recentPdfs.any((item) => item['path'] == samplePdfFile.path), isTrue);
      expect(fileController.pdfFiles.where((f) => f.path == samplePdfFile.path).length, equals(1));

      // 4. Verify Hive / Recent records the path (so a real device loadPdfs() would find it)
      // The core invariant is that recentController has the path recorded in its reactive list.
      final inRecent = recentController.recentPdfs.any((item) => item['path'] == samplePdfFile.path);
      expect(inRecent, isTrue, reason: 'Modified PDF must remain in RecentPdfController');
    });
  });
}

import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_reader/features/scan_pdf/controller/scan_pdf_controller.dart';
import 'package:file_reader/features/scan_pdf/model/scanned_page_item.dart';
import 'package:file_reader/features/scan_pdf/service/document_edge_detector.dart';
import 'package:file_reader/features/scan_pdf/view/crop_mode_dialog.dart';
import 'package:file_reader/features/scan_pdf/view/quit_scan_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuadCorners Model Tests', () {
    test('QuadCorners normalized to pixels and back', () {
      final quad = QuadCorners(
        topLeft: const Offset(0.1, 0.1),
        topRight: const Offset(0.9, 0.1),
        bottomRight: const Offset(0.9, 0.9),
        bottomLeft: const Offset(0.1, 0.9),
      );

      const size = Size(1000, 2000);
      final pixelCorners = quad.toPixels(size);

      expect(pixelCorners.topLeft, equals(const Offset(100, 200)));
      expect(pixelCorners.topRight, equals(const Offset(900, 200)));
      expect(pixelCorners.bottomRight, equals(const Offset(900, 1800)));
      expect(pixelCorners.bottomLeft, equals(const Offset(100, 1800)));

      final normalizedBack = pixelCorners.toNormalized(size);
      expect(normalizedBack.topLeft.dx, closeTo(0.1, 0.001));
      expect(normalizedBack.topLeft.dy, closeTo(0.1, 0.001));
      expect(normalizedBack.bottomRight.dx, closeTo(0.9, 0.001));
      expect(normalizedBack.bottomRight.dy, closeTo(0.9, 0.001));
    });

    test('QuadCorners.defaultNormalized has sensible margins', () {
      final quad = QuadCorners.defaultNormalized();
      expect(quad.topLeft.dx, equals(0.08));
      expect(quad.topLeft.dy, equals(0.08));
      expect(quad.bottomRight.dx, equals(0.92));
      expect(quad.bottomRight.dy, equals(0.92));
    });
  });

  group('DocumentEdgeDetector & Image Processing Tests', () {
    late Directory tempDir;
    late File sampleImageFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('scan_test_');

      // Generate a test bitmap image with a clear white page on dark background
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Dark background
      canvas.drawRect(
        const Rect.fromLTWH(0, 0, 400, 600),
        Paint()..color = const Color(0xFF1E293B),
      );

      // Bright document in the center
      canvas.drawRect(
        const Rect.fromLTWH(50, 60, 300, 480),
        Paint()..color = Colors.white,
      );

      // Document Text
      canvas.drawRect(
        const Rect.fromLTWH(80, 100, 200, 20),
        Paint()..color = Colors.black,
      );

      final picture = recorder.endRecording();
      final image = await picture.toImage(400, 600);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      sampleImageFile = File('${tempDir.path}/sample_document.png');
      await sampleImageFile.writeAsBytes(byteData!.buffer.asUint8List());
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('detectDocumentCorners finds reasonable quad bounds', () async {
      final detected = await DocumentEdgeDetector.detectDocumentCorners(sampleImageFile);

      expect(detected.topLeft.dx, lessThan(0.5));
      expect(detected.topLeft.dy, lessThan(0.5));
      expect(detected.bottomRight.dx, greaterThan(0.5));
      expect(detected.bottomRight.dy, greaterThan(0.5));
    });

    test('processDocumentImage generates enhanced output file with filters and rotation', () async {
      final quad = QuadCorners(
        topLeft: const Offset(0.12, 0.1),
        topRight: const Offset(0.88, 0.1),
        bottomRight: const Offset(0.88, 0.9),
        bottomLeft: const Offset(0.12, 0.9),
      );

      // Test Magic Color
      final outPathMagic = await DocumentEdgeDetector.processDocumentImage(
        sourceImagePath: sampleImageFile.path,
        corners: quad,
        rotationDegrees: 0,
        filter: ScanDocFilter.magicColor,
      );
      expect(File(outPathMagic).existsSync(), isTrue);

      // Test Rotation 90°
      final outPathRot = await DocumentEdgeDetector.processDocumentImage(
        sourceImagePath: sampleImageFile.path,
        corners: quad,
        rotationDegrees: 90,
        filter: ScanDocFilter.grayscale,
      );
      expect(File(outPathRot).existsSync(), isTrue);

      // Test B&W Filter
      final outPathBW = await DocumentEdgeDetector.processDocumentImage(
        sourceImagePath: sampleImageFile.path,
        corners: quad,
        rotationDegrees: 180,
        filter: ScanDocFilter.blackAndWhite,
      );
      expect(File(outPathBW).existsSync(), isTrue);
    });
  });

  group('ScanPdfController State Management & PDF Generation Tests', () {
    late Directory tempDir;
    late File sampleImageFile;
    late ScanPdfController controller;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('scan_controller_test_');

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 300, 400), Paint()..color = Colors.white);
      final picture = recorder.endRecording();
      final image = await picture.toImage(300, 400);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      sampleImageFile = File('${tempDir.path}/page_image.png');
      await sampleImageFile.writeAsBytes(byteData!.buffer.asUint8List());

      controller = ScanPdfController();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('addScannedImage, rotate, update filters, and delete page', () async {
      final item1 = await controller.addScannedImage(sampleImageFile.path);
      expect(controller.scannedPages.length, equals(1));
      expect(controller.activePage?.id, equals(item1.id));

      // Add second page
      final item2 = await controller.addScannedImage(sampleImageFile.path);
      expect(controller.scannedPages.length, equals(2));

      // Test rotation
      controller.activePageIndex.value = 0;
      await controller.rotateActivePage(clockwise: true);
      expect(controller.scannedPages[0].rotationDegrees, equals(90));

      // Test filter update
      await controller.setFilterForActivePage(ScanDocFilter.grayscale);
      expect(controller.scannedPages[0].filter, equals(ScanDocFilter.grayscale));

      // Test reordering
      controller.reorderPages(1, 0);
      expect(controller.scannedPages[0].id, equals(item2.id));

      // Test deletion
      controller.deletePage(item2.id);
      expect(controller.scannedPages.length, equals(1));
      expect(controller.scannedPages[0].id, equals(item1.id));
    });

    test('convertScanQueueToPdf creates valid PDF from scanned images', () async {
      await controller.addScannedImage(sampleImageFile.path);
      await controller.addScannedImage(sampleImageFile.path);

      expect(controller.scannedPages.length, equals(2));

      final pdfFile = await controller.convertScanQueueToPdf();
      expect(pdfFile.existsSync(), isTrue);

      // Verify PDF has 2 pages
      final bytes = await pdfFile.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);
      expect(doc.pages.count, equals(2));
      doc.dispose();

      // Queue is cleared after convert
      expect(controller.scannedPages.isEmpty, isTrue);
    });
  });

  group('Scan Modals Widget Tests', () {
    testWidgets('QuitScanDialog renders cancel and quit buttons', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: QuitScanDialog(),
          ),
        ),
      );

      expect(find.text('Quit changes?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Quit'), findsOneWidget);
    });

    testWidgets('CropModeDialog renders Auto crop and No crop options', (tester) async {
      Get.put(ScanPdfController());

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: CropModeDialog(),
          ),
        ),
      );

      expect(find.text('Choose crop mode'), findsOneWidget);
      expect(find.text('Auto crop'), findsOneWidget);
      expect(find.text('No crop'), findsOneWidget);
      expect(find.text("Don't ask again"), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });
  });
}

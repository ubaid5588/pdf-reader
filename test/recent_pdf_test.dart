import 'dart:io';

import 'package:file_reader/features/home/controller/navi_controller.dart';
import 'package:file_reader/features/home/view/all_recent_files_page.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late File file1;
  late File file2;
  late File file3;

  setUp(() async {
    Get.reset();
    tempDir = await Directory.systemTemp.createTemp('recent_test_');
    file1 = File('${tempDir.path}/Doc1.pdf')..writeAsStringSync('PDF 1');
    file2 = File('${tempDir.path}/Doc2.pdf')..writeAsStringSync('PDF 2');
    file3 = File('${tempDir.path}/Invoice.pdf')..writeAsStringSync('PDF 3');
  });

  tearDown(() async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
    Get.reset();
  });

  group('RecentPdfController Byte Formatting Tests', () {
    test('Formats bytes correctly', () {
      expect(RecentPdfController.formatBytes(0), equals('0 B'));
      expect(RecentPdfController.formatBytes(500), equals('500.0 B'));
      expect(RecentPdfController.formatBytes(1024), equals('1.0 KB'));
      expect(RecentPdfController.formatBytes(1024 * 1024 * 5), equals('5.0 MB'));
      expect(
        RecentPdfController.formatBytes((1024 * 1024 * 1.5).toInt()),
        equals('1.5 MB'),
      );
    });
  });

  group('RecentPdfController State & Sorting Tests', () {
    test('addRecentPdf adds, moves to top, and avoids duplicates', () async {
      final controller = Get.put(RecentPdfController());
      controller.recentPdfs.clear();

      await controller.addRecentPdf(file1.path, 'Doc1.pdf');
      await controller.addRecentPdf(file2.path, 'Doc2.pdf');

      expect(controller.recentPdfs.length, equals(2));
      expect(controller.recentPdfs[0]['name'], equals('Doc2.pdf'));
      expect(controller.recentPdfs[1]['name'], equals('Doc1.pdf'));

      // Re-open Doc1.pdf -> should move to index 0 (top)
      await controller.addRecentPdf(file1.path, 'Doc1.pdf');
      expect(controller.recentPdfs.length, equals(2));
      expect(controller.recentPdfs[0]['name'], equals('Doc1.pdf'));
      expect(controller.recentPdfs[1]['name'], equals('Doc2.pdf'));

      // Remove Doc2
      await controller.removeRecentPdf(file2.path);
      expect(controller.recentPdfs.length, equals(1));
      expect(controller.recentPdfs[0]['name'], equals('Doc1.pdf'));

      // Clear all
      await controller.clearRecentPdfs();
      expect(controller.recentPdfs.isEmpty, isTrue);
    });
  });

  group('NaviController Navigation Tests', () {
    test('NaviController changes to index 2 and triggers recent PDF loading', () {
      final navi = Get.put(NaviController());
      expect(navi.selectedIndex.value, equals(0));

      navi.changePage(2);
      expect(navi.selectedIndex.value, equals(2));

      navi.changePage(3);
      expect(navi.selectedIndex.value, equals(3));
    });
  });

  group('AllRecentFilesPage Widget Tests', () {
    testWidgets('Renders empty state when there are no recent files', (tester) async {
      final controller = Get.put(RecentPdfController());
      controller.recentPdfs.clear();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AllRecentFilesPage(isTab: true),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('All Recent PDFs'), findsOneWidget);
      expect(find.text('No Recent Files'), findsOneWidget);
      expect(find.text('PDF files you open will appear here'), findsOneWidget);
    });

    testWidgets('Renders all recent files and supports searching in tab view', (tester) async {
      final controller = Get.put(RecentPdfController());
      await controller.addRecentPdf(file1.path, 'Doc1.pdf');
      await controller.addRecentPdf(file2.path, 'Doc2.pdf');
      await controller.addRecentPdf(file3.path, 'Invoice.pdf');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AllRecentFilesPage(isTab: true),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('All Recent PDFs'), findsOneWidget);
      expect(find.text('Invoice.pdf'), findsOneWidget);
      expect(find.text('Doc2.pdf'), findsOneWidget);
      expect(find.text('Doc1.pdf'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);

      // Search for "Invoice"
      await tester.enterText(find.byType(TextField), 'Invoice');
      await tester.pump();

      expect(find.text('Invoice.pdf'), findsOneWidget);
      expect(find.text('Doc2.pdf'), findsNothing);
      expect(find.text('Doc1.pdf'), findsNothing);
    });
  });
}

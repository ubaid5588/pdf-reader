import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
}

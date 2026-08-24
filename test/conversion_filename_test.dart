import 'dart:io';
import 'package:file_reader/features/converter/controller/file_to_pdf_controller.dart';
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Conversion Filename Generation Tests', () {
    final fixedDate = DateTime(2026, 8, 20);

    test('Word to PDF generates word-to-pdf-YYYY-MM-DD.pdf', () {
      final fileNameFromEnum = PdfStorageService.generateConversionFileName(
        officeFileType: OfficeFileType.word,
        date: fixedDate,
      );
      expect(fileNameFromEnum, 'word-to-pdf-2026-08-20.pdf');

      final fileNameFromPath = PdfStorageService.generateConversionFileName(
        sourceFilePath: '/path/to/my_report.docx',
        date: fixedDate,
      );
      expect(fileNameFromPath, 'word-to-pdf-2026-08-20.pdf');
    });

    test('PowerPoint to PDF generates powerpoint-to-pdf-YYYY-MM-DD.pdf', () {
      final fileNameFromEnum = PdfStorageService.generateConversionFileName(
        officeFileType: OfficeFileType.powerpoint,
        date: fixedDate,
      );
      expect(fileNameFromEnum, 'powerpoint-to-pdf-2026-08-20.pdf');

      final fileNameFromPath = PdfStorageService.generateConversionFileName(
        sourceFilePath: '/path/to/deck.pptx',
        date: fixedDate,
      );
      expect(fileNameFromPath, 'powerpoint-to-pdf-2026-08-20.pdf');
    });

    test('Excel to PDF generates excel-to-pdf-YYYY-MM-DD.pdf', () {
      final fileNameFromEnum = PdfStorageService.generateConversionFileName(
        officeFileType: OfficeFileType.excel,
        date: fixedDate,
      );
      expect(fileNameFromEnum, 'excel-to-pdf-2026-08-20.pdf');

      final fileNameFromPath = PdfStorageService.generateConversionFileName(
        sourceFilePath: '/path/to/finances.xlsx',
        date: fixedDate,
      );
      expect(fileNameFromPath, 'excel-to-pdf-2026-08-20.pdf');
    });

    test('JPG image to PDF generates jpg-to-pdf-YYYY-MM-DD.pdf', () {
      final fileNameJpg = PdfStorageService.generateConversionFileName(
        imagePaths: ['/storage/images/photo.jpg'],
        date: fixedDate,
      );
      expect(fileNameJpg, 'jpg-to-pdf-2026-08-20.pdf');

      final fileNameJpeg = PdfStorageService.generateConversionFileName(
        imagePaths: ['/storage/images/photo.jpeg'],
        date: fixedDate,
      );
      expect(fileNameJpeg, 'jpg-to-pdf-2026-08-20.pdf');
    });

    test('PNG image to PDF generates png-to-pdf-YYYY-MM-DD.pdf', () {
      final fileNamePng = PdfStorageService.generateConversionFileName(
        imagePaths: ['/storage/images/screenshot.png'],
        date: fixedDate,
      );
      expect(fileNamePng, 'png-to-pdf-2026-08-20.pdf');
    });

    test('WEBP image to PDF generates webp-to-pdf-YYYY-MM-DD.pdf', () {
      final fileNameWebp = PdfStorageService.generateConversionFileName(
        imagePaths: ['/storage/images/graphic.webp'],
        date: fixedDate,
      );
      expect(fileNameWebp, 'webp-to-pdf-2026-08-20.pdf');
    });

    test('Duplicate naming sequence on same date creates -2, -3 files', () async {
      final tempDir = await Directory.systemTemp.createTemp('pdf_name_test_');
      try {
        final dummyBytes = [1, 2, 3, 4, 5];
        final baseFileName = 'word-to-pdf-2026-08-20.pdf';

        // 1st file
        final file1 = File('${tempDir.path}/$baseFileName');
        await file1.writeAsBytes(dummyBytes);

        // Deduplication helper test
        String resolveUniqueName(String dirPath, String name) {
          String finalPath = '$dirPath/$name';
          int counter = 2;
          while (File(finalPath).existsSync()) {
            final nameWithoutExt = name.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
            final newName = '$nameWithoutExt-$counter.pdf';
            finalPath = '$dirPath/$newName';
            counter++;
          }
          return finalPath.split(Platform.pathSeparator).last;
        }

        final secondName = resolveUniqueName(tempDir.path, baseFileName);
        expect(secondName, 'word-to-pdf-2026-08-20-2.pdf');
        await File('${tempDir.path}/$secondName').writeAsBytes(dummyBytes);

        final thirdName = resolveUniqueName(tempDir.path, baseFileName);
        expect(thirdName, 'word-to-pdf-2026-08-20-3.pdf');
        await File('${tempDir.path}/$thirdName').writeAsBytes(dummyBytes);

        final fourthName = resolveUniqueName(tempDir.path, baseFileName);
        expect(fourthName, 'word-to-pdf-2026-08-20-4.pdf');
      } finally {
        await tempDir.delete(recursive: true);
      }
    });

    test('Create PDF generates created-pdf-YYYY-MM-DD.pdf', () {
      final name = PdfStorageService.generateCreatedPdfFileName(date: fixedDate);
      expect(name, 'created-pdf-2026-08-20.pdf');
    });

    test('Unlock PDF generates unlocked-pdf-YYYY-MM-DD.pdf', () {
      final name = PdfStorageService.generateUnlockedPdfFileName(date: fixedDate);
      expect(name, 'unlocked-pdf-2026-08-20.pdf');
    });

    test('Edited PDF generates edited-pdf-YYYY-MM-DD.pdf or with base name', () {
      final name = PdfStorageService.generateEditedPdfFileName(date: fixedDate);
      expect(name, 'edited-pdf-2026-08-20.pdf');

      final nameWithBase = PdfStorageService.generateEditedPdfFileName(
        originalFileName: 'contract.pdf',
        date: fixedDate,
      );
      expect(nameWithBase, 'contract_edited_2026-08-20.pdf');
    });

    test('Split PDF generates correct range and individual page filenames', () {
      final rangeName = PdfStorageService.generateSplitPdfFileName(
        originalFileName: 'document.pdf',
        selectedPages: [2, 3, 4],
        date: fixedDate,
      );
      expect(rangeName, 'document-split-2-4-2026-08-20.pdf');

      final discreteName = PdfStorageService.generateSplitPdfFileName(
        originalFileName: 'document.pdf',
        selectedPages: [2, 5, 8],
        date: fixedDate,
      );
      expect(discreteName, 'document-split-pages-2-5-8-2026-08-20.pdf');

      final singleName = PdfStorageService.generateSplitPdfFileName(
        originalFileName: 'document.pdf',
        selectedPages: [3],
        date: fixedDate,
      );
      expect(singleName, 'document-split-page-3-2026-08-20.pdf');
    });

    test('Remove Pages PDF generates document-remove-pages-YYYY-MM-DD.pdf', () {
      final name = PdfStorageService.generateRemovePagesPdfFileName(
        originalFileName: 'document.pdf',
        date: fixedDate,
      );
      expect(name, 'document-remove-pages-2026-08-20.pdf');
    });

    test('Sanitization strips illegal OS characters', () {
      final nameWithInvalidChars = PdfStorageService.generateConversionFileName(
        sourceExtension: 'doc/x:?<|>',
        date: fixedDate,
      );
      expect(nameWithInvalidChars, 'docx-to-pdf-2026-08-20.pdf');
      expect(nameWithInvalidChars.contains('/'), isFalse);
      expect(nameWithInvalidChars.contains(':'), isFalse);
      expect(nameWithInvalidChars.contains('?'), isFalse);
      expect(nameWithInvalidChars.contains('<'), isFalse);
      expect(nameWithInvalidChars.contains('>'), isFalse);
      expect(nameWithInvalidChars.contains('|'), isFalse);
    });
  });
}

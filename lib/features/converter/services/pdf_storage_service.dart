import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class PdfStorageService {
  /// Generates standardized output filename: `<source-format>-to-pdf-<date>.pdf`
  /// Examples:
  /// - Word -> `word-to-pdf-2026-08-20.pdf`
  /// - PowerPoint -> `powerpoint-to-pdf-2026-08-20.pdf`
  /// - Excel -> `excel-to-pdf-2026-08-20.pdf`
  /// - JPG -> `jpg-to-pdf-2026-08-20.pdf`
  /// - PNG -> `png-to-pdf-2026-08-20.pdf`
  static String generateConversionFileName({
    String? sourceExtension,
    dynamic officeFileType,
    List<String>? imagePaths,
    String? sourceFilePath,
    DateTime? date,
  }) {
    final now = date ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    String prefix = 'file';

    if (officeFileType != null) {
      final typeStr = officeFileType.toString().toLowerCase();
      if (typeStr.contains('word')) {
        prefix = 'word';
      } else if (typeStr.contains('powerpoint') || typeStr.contains('ppt')) {
        prefix = 'powerpoint';
      } else if (typeStr.contains('excel')) {
        prefix = 'excel';
      }
    } else if (imagePaths != null && imagePaths.isNotEmpty) {
      final ext = imagePaths.first
          .split('.')
          .last
          .toLowerCase()
          .replaceAll('.', '');
      if (ext == 'jpg' || ext == 'jpeg') {
        prefix = 'jpg';
      } else if (ext == 'png') {
        prefix = 'png';
      } else if (ext == 'webp') {
        prefix = 'webp';
      } else if (ext.isNotEmpty) {
        prefix = ext;
      } else {
        prefix = 'image';
      }
    } else {
      final extToParse = sourceExtension ??
          (sourceFilePath != null ? sourceFilePath.split('.').last : null);
      if (extToParse != null && extToParse.isNotEmpty) {
        final clean = extToParse.replaceAll('.', '').toLowerCase().trim();
        if (clean == 'doc' || clean == 'docx') {
          prefix = 'word';
        } else if (clean == 'ppt' || clean == 'pptx') {
          prefix = 'powerpoint';
        } else if (clean == 'xls' || clean == 'xlsx') {
          prefix = 'excel';
        } else if (clean == 'jpg' || clean == 'jpeg') {
          prefix = 'jpg';
        } else if (clean == 'png') {
          prefix = 'png';
        } else if (clean == 'webp') {
          prefix = 'webp';
        } else {
          prefix = clean;
        }
      }
    }

    // Sanitize prefix for Windows, macOS, Linux (alphanumeric and dashes only)
    prefix = prefix.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '').toLowerCase();
    if (prefix.isEmpty) prefix = 'file';

    return '$prefix-to-pdf-$dateStr.pdf';
  }

  /// Generates filename for newly created PDFs: `created-pdf-YYYY-MM-DD.pdf`
  static String generateCreatedPdfFileName({DateTime? date}) {
    final now = date ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    return 'created-pdf-$dateStr.pdf';
  }

  /// Generates filename for unlocked PDFs: `unlocked-pdf-YYYY-MM-DD.pdf`
  static String generateUnlockedPdfFileName({DateTime? date}) {
    final now = date ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    return 'unlocked-pdf-$dateStr.pdf';
  }

  /// Generates filename for edited PDFs: `edited-pdf-YYYY-MM-DD.pdf`
  static String generateEditedPdfFileName({DateTime? date, String? originalFileName}) {
    final now = date ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    if (originalFileName != null && originalFileName.isNotEmpty) {
      final cleanBase = originalFileName
          .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      return '${cleanBase}_edited_$dateStr.pdf';
    }
    return 'edited-pdf-$dateStr.pdf';
  }

  /// Generates filename for split PDFs:
  /// Continuous range (e.g. 2, 3, 4) -> `document-split-2-4-2026-08-21.pdf`
  /// Individual pages (e.g. 2, 5, 8) -> `document-split-pages-2-5-8-2026-08-21.pdf`
  /// Single page (e.g. 3) -> `document-split-page-3-2026-08-21.pdf`
  static String generateSplitPdfFileName({
    String? originalFileName,
    required List<int> selectedPages,
    DateTime? date,
  }) {
    final now = date ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    String baseName = 'document';
    if (originalFileName != null && originalFileName.trim().isNotEmpty) {
      baseName = originalFileName
          .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      if (baseName.isEmpty) baseName = 'document';
    }

    final sorted = List<int>.from(selectedPages)..sort();
    String pagePart;
    if (sorted.isEmpty) {
      pagePart = 'split';
    } else if (sorted.length == 1) {
      pagePart = 'split-page-${sorted.first}';
    } else {
      bool isContinuous = true;
      for (int i = 0; i < sorted.length - 1; i++) {
        if (sorted[i + 1] != sorted[i] + 1) {
          isContinuous = false;
          break;
        }
      }
      if (isContinuous) {
        pagePart = 'split-${sorted.first}-${sorted.last}';
      } else {
        pagePart = 'split-pages-${sorted.join('-')}';
      }
    }

    return '$baseName-$pagePart-$dateStr.pdf';
  }

  /// Generates filename for remove pages PDFs: `document-remove-pages-2026-08-21.pdf`
  static String generateRemovePagesPdfFileName({
    String? originalFileName,
    DateTime? date,
  }) {
    final now = date ?? DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    String baseName = 'document';
    if (originalFileName != null && originalFileName.trim().isNotEmpty) {
      baseName = originalFileName
          .replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '')
          .replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      if (baseName.isEmpty) baseName = 'document';
    }

    return '$baseName-remove-pages-$dateStr.pdf';
  }

  /// Saves a PDF file to device Downloads folder (with fallback to app documents)
  /// Returns the path if successful, null if failed
  static Future<String?> savePdfToDownloads({
    required List<int> pdfBytes,
    required String fileName,
  }) async {
    try {
      print('💾 Saving PDF to storage...');

      // Validate inputs
      if (pdfBytes.isEmpty) {
        throw Exception('PDF data is empty');
      }

      var sanitizedName = fileName.trim();
      // Remove invalid OS characters: < > : " / \ | ? * \0
      sanitizedName = sanitizedName.replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '');
      sanitizedName = sanitizedName.trim().replaceAll(RegExp(r'^\.+|\.+$'), '');

      if (sanitizedName.isEmpty) {
        sanitizedName = 'Document_${DateTime.now().millisecondsSinceEpoch}';
      }

      // Ensure .pdf extension
      if (!sanitizedName.toLowerCase().endsWith('.pdf')) {
        sanitizedName = '$sanitizedName.pdf';
      }

      // Get Downloads directory or fallback
      Directory downloadsDir = Directory('/storage/emulated/0/Download');

      if (!await downloadsDir.exists()) {
        try {
          downloadsDir = await getApplicationDocumentsDirectory();
        } catch (_) {
          try {
            downloadsDir = await getTemporaryDirectory();
          } catch (_) {
            downloadsDir = Directory.systemTemp;
          }
        }
      }

      // Create unique filename if file exists: format -2.pdf, -3.pdf
      String finalPath = '${downloadsDir.path}/$sanitizedName';
      int counter = 2;

      while (await File(finalPath).exists()) {
        final nameWithoutExt = sanitizedName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
        final newName = '$nameWithoutExt-$counter.pdf';
        finalPath = '${downloadsDir.path}/$newName';
        counter++;
      }

      // Write file to storage
      final file = File(finalPath);
      await file.writeAsBytes(pdfBytes);

      print('✅ PDF saved successfully');
      print('📍 Path: $finalPath');
      print('📊 Size: ${(pdfBytes.length / 1024).toStringAsFixed(2)} KB');

      return finalPath;
    } catch (e) {
      print('❌ Error saving PDF: $e');
      Get.snackbar(
        'Save Failed',
        'Error saving PDF: $e',
        duration: const Duration(seconds: 3),
      );
      return null;
    }
  }

  /// Saves a PDF file (if it's already a File object)
  static Future<String?> savePdfFileToDownloads({
    required File pdfFile,
    required String fileName,
  }) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      return await savePdfToDownloads(pdfBytes: bytes, fileName: fileName);
    } catch (e) {
      print('❌ Error reading PDF file: $e');
      Get.snackbar('Error', 'Failed to read PDF file');
      return null;
    }
  }

  /// Save PDF with timestamp
  static Future<String?> savePdfWithTimestamp({
    required List<int> pdfBytes,
    required String baseFileName,
  }) async {
    final timestamp = DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
    final fileName = '${baseFileName}_$timestamp.pdf';

    return await savePdfToDownloads(pdfBytes: pdfBytes, fileName: fileName);
  }

  /// Save PDF and refresh file list
  static Future<String?> savePdfAndRefresh({
    required List<int> pdfBytes,
    required String fileName,
    required Function? onRefresh,
  }) async {
    final savedPath = await savePdfToDownloads(
      pdfBytes: pdfBytes,
      fileName: fileName,
    );

    if (savedPath != null) {
      // Refresh file list if callback provided
      if (onRefresh != null) {
        print('🔄 Refreshing file list...');
        await onRefresh();
        Get.snackbar(
          'Success',
          'PDF saved and refreshed',
          duration: const Duration(seconds: 2),
        );
      }
    }

    return savedPath;
  }

  /// Get Downloads directory path
  static Future<String?> getDownloadsPath() async {
    try {
      final dir = Directory('/storage/emulated/0/Download');
      if (await dir.exists()) {
        return dir.path;
      }
      return null;
    } catch (e) {
      print('Error getting downloads path: $e');
      return null;
    }
  }

  /// Get Documents directory path
  static Future<String?> getDocumentsPath() async {
    try {
      final dir = Directory('/storage/emulated/0/Documents');
      if (await dir.exists()) {
        return dir.path;
      }
      return null;
    } catch (e) {
      print('Error getting documents path: $e');
      return null;
    }
  }

  /// Check if file exists in Downloads
  static Future<bool> fileExistsInDownloads(String fileName) async {
    try {
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final filePath = '${downloadsDir.path}/$fileName';
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }
}

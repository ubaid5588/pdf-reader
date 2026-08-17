import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PdfStorageService {
  /// Saves a PDF file to device Downloads folder
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
      if (sanitizedName.isEmpty) {
        sanitizedName = 'Document_${DateTime.now().millisecondsSinceEpoch}';
      }

      // Ensure .pdf extension
      if (!sanitizedName.toLowerCase().endsWith('.pdf')) {
        sanitizedName = '$sanitizedName.pdf';
      }

      // Get Downloads directory
      final downloadsDir = Directory('/storage/emulated/0/Download');

      if (!await downloadsDir.exists()) {
        print('❌ Downloads folder does not exist');
        throw Exception('Downloads folder not found');
      }

      // Create unique filename if file exists
      String finalPath = '${downloadsDir.path}/$sanitizedName';
      int counter = 1;

      while (await File(finalPath).exists()) {
        final nameWithoutExt = sanitizedName.replaceAll('.pdf', '');
        final newName = '${nameWithoutExt}_(${counter}).pdf';
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

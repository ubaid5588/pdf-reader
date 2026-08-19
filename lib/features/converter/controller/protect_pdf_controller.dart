import 'dart:io';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ProtectPdfController extends GetxController {
  RxBool isLoading = false.obs;

  Future<File?> pickPdfFile() async {
    try {
      final result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;
      final path = result.files.single.path;
      if (path == null) return null;
      return File(path);
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e');
      return null;
    }
  }

  Future<String?> promptPassword() async {
    final passwordController = TextEditingController();
    return await Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Set Password Protection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter a password to encrypt and secure this PDF:',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B5CFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Get.back(result: passwordController.text.trim()),
            child: const Text('Protect'),
          ),
        ],
      ),
    );
  }

  Future<File> protectPdf(
    File sourceFile, {
    required String userPassword,
    String? ownerPassword,
    void Function(double progress, String status)? onProgress,
  }) async {
    try {
      isLoading.value = true;
      onProgress?.call(0.2, 'Loading PDF document...');
      final bytes = await sourceFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      onProgress?.call(0.5, 'Applying 256-bit AES encryption...');
      final PdfSecurity security = document.security;

      if (userPassword.isNotEmpty) {
        security.userPassword = userPassword;
      }
      if (ownerPassword != null && ownerPassword.isNotEmpty) {
        security.ownerPassword = ownerPassword;
      } else {
        security.ownerPassword = userPassword;
      }

      security.algorithm = PdfEncryptionAlgorithm.aesx256Bit;

      onProgress?.call(0.75, 'Saving protected PDF...');
      final List<int> protectedBytes = await document.save();
      document.dispose();

      onProgress?.call(0.9, 'Saving to device storage...');
      final baseName = sourceFile.path
          .split(Platform.pathSeparator)
          .last
          .replaceAll('.pdf', '');
      final fileName = '${baseName}_protected.pdf';

      final savedPath = await PdfStorageService.savePdfToDownloads(
        pdfBytes: protectedBytes,
        fileName: fileName,
      );

      onProgress?.call(1.0, 'Finalizing...');

      if (savedPath == null) {
        throw Exception('Failed to save protected PDF to storage');
      }

      try {
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

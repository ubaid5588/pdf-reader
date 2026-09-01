import 'dart:io';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
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

      final pickedFile = File(path);
      return await PdfStorageService.resolveOriginalStorageFile(pickedFile);
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e');
      return null;
    }
  }

  Future<String?> promptPassword() async {
    final passwordController = TextEditingController();
    final RxBool obscureText = true.obs;

    final result = await Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: Color(0xFF5B5CFF), size: 24),
            SizedBox(width: 10),
            Text(
              'Lock PDF with Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter a password to encrypt and lock this PDF:',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 14),
              Obx(
                () => TextField(
                  controller: passwordController,
                  autofocus: true,
                  obscureText: obscureText.value,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                      onPressed: () => obscureText.toggle(),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (val) {
                    final pwd = val.trim();
                    if (pwd.isNotEmpty) {
                      Get.back(result: pwd);
                    }
                  },
                ),
              ),
            ],
          ),
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
            onPressed: () {
              final password = passwordController.text.trim();

              if (password.isEmpty) {
                Get.snackbar(
                  'Password required',
                  'Please enter a password',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back(result: password);
            },
            child: const Text('Lock'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result;
  }

  /// Locks/encrypts the existing [sourceFile] in-place with [userPassword].
  /// Does NOT create a new duplicate PDF. Keeps the same path and location.
  Future<File> protectPdf(
    File sourceFile, {
    required String userPassword,
    String? ownerPassword,
    void Function(double progress, String status)? onProgress,
  }) async {
    final realFile = await PdfStorageService.resolveOriginalStorageFile(sourceFile);

    try {
      isLoading.value = true;
      onProgress?.call(0.2, 'Loading PDF document...');
      final bytes = await realFile.readAsBytes();
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

      onProgress?.call(0.75, 'Applying encryption lock...');
      final List<int> protectedBytes = await document.save();
      document.dispose();

      if (protectedBytes.isEmpty) {
        throw Exception('Failed to generate locked PDF data');
      }

      onProgress?.call(0.9, 'Locking existing PDF file...');

      // Safe atomic replacement: write to temp file first
      final tempPath = '${realFile.path}.tmp_protect';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(protectedBytes, flush: true);

      // Atomically replace original file
      try {
        await tempFile.rename(realFile.path);
      } catch (_) {
        await tempFile.copy(realFile.path);
        await tempFile.delete();
      }

      onProgress?.call(1.0, 'Finalizing...');

      // Clean up cached copy if picked from file picker cache
      if (sourceFile.path != realFile.path) {
        try {
          if (await sourceFile.exists()) {
            await sourceFile.delete();
          }
        } catch (_) {}
      }

      // Update Recent and Files controllers
      try {
        final recentController = Get.isRegistered<RecentPdfController>()
            ? Get.find<RecentPdfController>()
            : Get.put(RecentPdfController());
        await recentController.addRecentPdf(realFile.path);

        if (Get.isRegistered<FilePageController>()) {
          final fc = Get.find<FilePageController>();
          final stat = await realFile.stat();
          fc.ensureFileInList(
            realFile,
            size: stat.size,
            modified: stat.modified,
          );
          fc.refreshPdfs();
        }
      } catch (_) {}

      return realFile;
    } catch (e) {
      // Clean up temp file on error so original file is never corrupted
      try {
        final tempFile = File('${realFile.path}.tmp_protect');
        if (await tempFile.exists()) await tempFile.delete();
      } catch (_) {}
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}

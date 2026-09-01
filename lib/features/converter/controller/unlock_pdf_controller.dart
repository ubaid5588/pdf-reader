import 'dart:io';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart' as fp;
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class UnlockPdfController extends GetxController {
  RxBool isLoading = false.obs;

  /// Pick a PDF file
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

  /// Inspects whether the PDF requires a password to open.
  /// Returns `true` if locked/encrypted, `false` if already openable.
  Future<bool> isPdfPasswordProtected(File file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return false;
      final doc = PdfDocument(inputBytes: bytes);
      final pageCount = doc.pages.count;
      doc.dispose();
      return pageCount < 0; // If successfully opened, it's not locked
    } catch (e) {
      // Failed to open without password -> PDF requires password
      return true;
    }
  }

  /// Prompts user to enter the PDF password
  Future<String?> promptPassword({String? errorMessage}) async {
    final passwordController = TextEditingController();
    final RxBool obscureText = true.obs;

    return await Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_open_rounded, color: Color(0xFF2563EB), size: 24),
            SizedBox(width: 10),
            Text(
              'Enter PDF Password',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This document is locked with a password. Enter the password to unlock it:',
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 14),
              Obx(
                () => TextField(
                  controller: passwordController,
                  obscureText: obscureText.value,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.key_rounded),
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
              if (errorMessage != null && errorMessage.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
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
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              final text = passwordController.text.trim();
              if (text.isNotEmpty) {
                Get.back(result: text);
              }
            },
            child: const Text(
              'Unlock',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Verifies password and decrypts PDF, generating an unlocked copy
  Future<File> unlockPdf(
    File sourceFile, {
    required String password,
    void Function(double progress, String status)? onProgress,
  }) async {
    isLoading.value = true;
    try {
      onProgress?.call(0.2, 'Verifying password...');
      final bytes = await sourceFile.readAsBytes();

      PdfDocument sourceDoc;
      try {
        sourceDoc = PdfDocument(inputBytes: bytes, password: password);
      } catch (e) {
        throw Exception('Incorrect password. Please try again.');
      }

      onProgress?.call(0.5, 'Decrypting and removing lock...');
      final PdfDocument unlockedDoc = PdfDocument();

      final int pageCount = sourceDoc.pages.count;
      for (int i = 0; i < pageCount; i++) {
        final PdfPage sourcePage = sourceDoc.pages[i];
        final ui.Size size = sourcePage.size;

        unlockedDoc.pageSettings.size = size;
        unlockedDoc.pageSettings.margins.all = 0;

        final PdfPage newPage = unlockedDoc.pages.add();
        final PdfTemplate template = sourcePage.createTemplate();
        newPage.graphics.drawPdfTemplate(
          template,
          const ui.Offset(0, 0),
          size,
        );
      }

      onProgress?.call(0.8, 'Encoding unlocked document...');
      final List<int> unlockedBytes = await unlockedDoc.save();

      unlockedDoc.dispose();
      sourceDoc.dispose();

      if (unlockedBytes.isEmpty) {
        throw Exception('Failed to generate unlocked PDF data');
      }

      onProgress?.call(0.9, 'Unlocking existing PDF file...');
      await sourceFile.writeAsBytes(unlockedBytes, flush: true);

      onProgress?.call(1.0, 'Finalizing...');

      // Refresh recent and file list
      try {
        final recentController = Get.isRegistered<RecentPdfController>()
            ? Get.find<RecentPdfController>()
            : Get.put(RecentPdfController());
        await recentController.addRecentPdf(sourceFile.path);

        if (Get.isRegistered<FilePageController>()) {
          final fc = Get.find<FilePageController>();
          fc.ensureFileInList(sourceFile);
          fc.refreshPdfs();
        }
      } catch (_) {}

      return sourceFile;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ProtectPdfController extends GetxController {
  RxBool isLoading = false.obs;

  /// Full flow: pick a PDF from storage -> ask for password -> protect it
  Future<void> pickAndProtectPdf() async {
    try {
      final result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) return;

      final sourceFile = File(path);

      // Ask the user for a password before protecting
      final passwordController = TextEditingController();
      final password = await Get.dialog<String>(
        AlertDialog(
          title: const Text("Set Password"),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(hintText: "Enter password"),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Get.back(result: passwordController.text),
              child: const Text("Protect"),
            ),
          ],
        ),
      );

      if (password == null || password.isEmpty) return;

      isLoading.value = true;

      final protectedFile = await protectPdf(
        sourceFile,
        userPassword: password,
      );

      if (protectedFile != null) {
        Get.snackbar(
          "Protected",
          "Saved as ${protectedFile.path.split('/').last}",
        );
        // Optional: navigate to viewer
        // Get.to(() => PdfViewer(filePath: protectedFile.path));
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Adds a password to an existing PDF. Returns the new protected file.
  Future<File?> protectPdf(
    File sourceFile, {
    String? userPassword,
    String? ownerPassword,
  }) async {
    try {
      final bytes = await sourceFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);

      final PdfSecurity security = document.security;

      if (userPassword != null && userPassword.isNotEmpty) {
        security.userPassword = userPassword;
      }
      if (ownerPassword != null && ownerPassword.isNotEmpty) {
        security.ownerPassword = ownerPassword;
      }

      security.algorithm = PdfEncryptionAlgorithm.aesx256Bit;

      final dir = await getApplicationDocumentsDirectory();
      final baseName = sourceFile.path.split('/').last.replaceAll('.pdf', '');
      final outputFile = File('${dir.path}/${baseName}_protected.pdf');

      await outputFile.writeAsBytes(await document.save());
      document.dispose();

      return outputFile;
    } catch (e) {
      Get.snackbar("Error", "Could not protect PDF: $e");
      return null;
    }
  }
}

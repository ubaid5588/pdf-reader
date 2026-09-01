import 'dart:io';
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/features/scan_pdf/model/scanned_page_item.dart';
import 'package:file_reader/features/scan_pdf/service/document_edge_detector.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ScanPdfController extends GetxController {
  final ImagePicker _picker = ImagePicker();

  final RxList<ScannedPageItem> scannedPages = <ScannedPageItem>[].obs;
  final RxInt activePageIndex = 0.obs;

  final RxBool autoCropPreference = true.obs;
  final RxBool dontAskCropModeAgain = false.obs;

  final RxBool isProcessing = false.obs;
  final RxString processingMessage = ''.obs;

  ScannedPageItem? get activePage {
    if (scannedPages.isEmpty) return null;
    final index = activePageIndex.value.clamp(0, scannedPages.length - 1);
    return scannedPages[index];
  }

  /// Capture document image directly from device camera
  Future<String?> captureFromCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (photo != null) {
        return photo.path;
      }
    } catch (e) {
      debugPrint('Camera capture error: $e');
    }
    return null;
  }

  /// Select multiple images from device gallery
  Future<List<String>> pickImagesFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 100);
      return images.map((x) => x.path).toList();
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
    return [];
  }

  /// Process newly captured or imported image
  Future<ScannedPageItem> addScannedImage(String imagePath) async {
    isProcessing.value = true;
    processingMessage.value = 'Detecting document boundaries...';

    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final file = File(imagePath);

    QuadCorners corners;
    if (autoCropPreference.value) {
      corners = await DocumentEdgeDetector.detectDocumentCorners(file);
    } else {
      corners = QuadCorners(
        topLeft: const Offset(0.0, 0.0),
        topRight: const Offset(1.0, 0.0),
        bottomRight: const Offset(1.0, 1.0),
        bottomLeft: const Offset(0.0, 1.0),
      );
    }

    processingMessage.value = 'Enhancing document clarity...';
    final processedPath = await DocumentEdgeDetector.processDocumentImage(
      sourceImagePath: imagePath,
      corners: corners,
      rotationDegrees: 0,
      filter: ScanDocFilter.magicColor,
    );

    final item = ScannedPageItem(
      id: id,
      originalImagePath: imagePath,
      croppedImagePath: processedPath,
      processedImagePath: processedPath,
      corners: corners,
      rotationDegrees: 0,
      filter: ScanDocFilter.magicColor,
    );

    scannedPages.add(item);
    activePageIndex.value = scannedPages.length - 1;
    isProcessing.value = false;

    return item;
  }

  /// Recalculate crop & filter for a page
  Future<void> updatePageProcessing(
    String pageId, {
    QuadCorners? corners,
    int? rotationDegrees,
    ScanDocFilter? filter,
  }) async {
    final index = scannedPages.indexWhere((p) => p.id == pageId);
    if (index == -1) return;

    final current = scannedPages[index];
    final newCorners = corners ?? current.corners ?? QuadCorners.defaultNormalized();
    final newRotation = rotationDegrees ?? current.rotationDegrees;
    final newFilter = filter ?? current.filter;

    isProcessing.value = true;
    processingMessage.value = 'Applying enhancements...';

    try {
      final processedPath = await DocumentEdgeDetector.processDocumentImage(
        sourceImagePath: current.originalImagePath,
        corners: newCorners,
        rotationDegrees: newRotation,
        filter: newFilter,
      );

      scannedPages[index] = current.copyWith(
        croppedImagePath: processedPath,
        processedImagePath: processedPath,
        corners: newCorners,
        rotationDegrees: newRotation,
        filter: newFilter,
      );
      scannedPages.refresh();
    } catch (e) {
      debugPrint('Error updating page: $e');
    } finally {
      isProcessing.value = false;
    }
  }

  /// Auto crop trigger on an existing page
  Future<QuadCorners> autoDetectPageCorners(String pageId) async {
    final index = scannedPages.indexWhere((p) => p.id == pageId);
    if (index == -1) return QuadCorners.defaultNormalized();

    final item = scannedPages[index];
    final detected = await DocumentEdgeDetector.detectDocumentCorners(
      File(item.originalImagePath),
    );
    return detected;
  }

  /// Rotate current page by 90 degrees
  Future<void> rotateActivePage({required bool clockwise}) async {
    final page = activePage;
    if (page == null) return;

    int newRot = page.rotationDegrees + (clockwise ? 90 : -90);
    if (newRot < 0) newRot += 360;
    if (newRot >= 360) newRot -= 360;

    await updatePageProcessing(page.id, rotationDegrees: newRot);
  }

  /// Apply filter to active page
  Future<void> setFilterForActivePage(ScanDocFilter filter) async {
    final page = activePage;
    if (page == null) return;
    await updatePageProcessing(page.id, filter: filter);
  }

  /// Delete page from scan queue
  void deletePage(String pageId) {
    final index = scannedPages.indexWhere((p) => p.id == pageId);
    if (index != -1) {
      scannedPages.removeAt(index);
      if (activePageIndex.value >= scannedPages.length && scannedPages.isNotEmpty) {
        activePageIndex.value = scannedPages.length - 1;
      }
    }
  }

  /// Reorder pages in queue
  void reorderPages(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = scannedPages.removeAt(oldIndex);
    scannedPages.insert(newIndex, item);
  }

  /// Clear entire scan queue
  void clearQueue() {
    scannedPages.clear();
    activePageIndex.value = 0;
  }

  /// Convert all scanned pages into a standard PDF document
  Future<File> convertScanQueueToPdf({
    void Function(double progress, String status)? onProgress,
  }) async {
    if (scannedPages.isEmpty) {
      throw Exception('No scanned pages to convert.');
    }

    try {
      onProgress?.call(0.1, 'Preparing document pages...');
      final PdfDocument document = PdfDocument();
      document.pageSettings.margins.all = 0;

      for (int i = 0; i < scannedPages.length; i++) {
        final progress = 0.1 + (0.7 * (i / scannedPages.length));
        onProgress?.call(progress, 'Processing page ${i + 1} of ${scannedPages.length}...');

        final pageItem = scannedPages[i];
        final file = File(pageItem.displayPath);
        final bytes = await file.readAsBytes();

        final PdfBitmap bitmap = PdfBitmap(bytes);
        final Size pageSize = Size(bitmap.width.toDouble(), bitmap.height.toDouble());

        document.pageSettings.size = pageSize;
        final PdfPage page = document.pages.add();

        page.graphics.drawImage(
          bitmap,
          Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        );
      }

      onProgress?.call(0.85, 'Saving PDF document...');
      final List<int> pdfBytes = await document.save();
      document.dispose();

      onProgress?.call(0.92, 'Saving to device storage...');
      final fileName = PdfStorageService.generateConversionFileName(
        sourceExtension: 'scan',
      );

      final savedPath = await PdfStorageService.savePdfToDownloads(
        pdfBytes: pdfBytes,
        fileName: fileName,
      );

      if (savedPath == null) {
        throw Exception('Failed to save scanned PDF to storage');
      }

      // Add to recent files
      try {
        final recentController = Get.isRegistered<RecentPdfController>()
            ? Get.find<RecentPdfController>()
            : Get.put(RecentPdfController());
        await recentController.addRecentPdf(savedPath, fileName);

        if (Get.isRegistered<FilePageController>()) {
          await Get.find<FilePageController>().refreshPdfs();
        }
      } catch (_) {}

      onProgress?.call(1.0, 'Finalizing...');
      clearQueue();

      return File(savedPath);
    } catch (e) {
      rethrow;
    }
  }
}

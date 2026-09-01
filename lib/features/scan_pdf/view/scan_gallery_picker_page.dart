import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/scan_pdf/controller/scan_pdf_controller.dart';
import 'package:file_reader/features/scan_pdf/view/crop_mode_dialog.dart';
import 'package:file_reader/features/scan_pdf/view/document_camera_page.dart';
import 'package:file_reader/features/scan_pdf/view/document_crop_page.dart';
import 'package:file_reader/features/scan_pdf/view/scan_queue_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScanGalleryPickerPage extends StatefulWidget {
  const ScanGalleryPickerPage({super.key});

  @override
  State<ScanGalleryPickerPage> createState() => _ScanGalleryPickerPageState();
}

class _ScanGalleryPickerPageState extends State<ScanGalleryPickerPage> {
  final ScanPdfController controller = Get.find<ScanPdfController>();
  final List<String> _selectedPaths = [];

  void _onPickFromDeviceGallery() async {
    final paths = await controller.pickImagesFromGallery();
    if (paths.isNotEmpty) {
      _processImportedImages(paths);
    }
  }

  void _onCaptureFromCameraShortcut() {
    Get.off(() => const DocumentCameraPage(returnToQueue: true));
  }

  Future<void> _processImportedImages(List<String> paths) async {
    if (paths.isEmpty) return;

    // Show Crop Mode Dialog if not opted out
    if (!controller.dontAskCropModeAgain.value) {
      await CropModeDialog.show(context);
    }

    // Process all images
    for (final p in paths) {
      await controller.addScannedImage(p);
    }

    if (paths.length == 1) {
      final last = controller.scannedPages.last;
      Get.off(() => DocumentCropPage(pageId: last.id));
    } else {
      Get.off(() => const ScanQueuePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'All images',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Gallery Shortcuts & Tiles
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(16),
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: [
                // Camera Shortcut Card
                GestureDetector(
                  onTap: _onCaptureFromCameraShortcut,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF2563EB).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Camera',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Take a photo',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Gallery File Picker Card
                GestureDetector(
                  onTap: _onPickFromDeviceGallery,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_library_rounded,
                            color: Color(0xFF10B981),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Device Gallery',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pick multiple images',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Import Button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _onPickFromDeviceGallery,
                child: Text(
                  'Import (${_selectedPaths.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

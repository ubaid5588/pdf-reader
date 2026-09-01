import 'dart:io';
import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/converter/view/conversion_processing_page.dart';
import 'package:file_reader/features/scan_pdf/controller/scan_pdf_controller.dart';
import 'package:file_reader/features/scan_pdf/view/document_preview_edit_page.dart';
import 'package:file_reader/features/scan_pdf/view/quit_scan_dialog.dart';
import 'package:file_reader/features/scan_pdf/view/scan_gallery_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScanQueuePage extends StatefulWidget {
  const ScanQueuePage({super.key});

  @override
  State<ScanQueuePage> createState() => _ScanQueuePageState();
}

class _ScanQueuePageState extends State<ScanQueuePage> {
  final ScanPdfController controller = Get.find<ScanPdfController>();
  bool _showNoticeBanner = true;

  void _onAddPages() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Pages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF2563EB)),
              ),
              title: const Text('Capture with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Take photos of more document pages', style: TextStyle(fontSize: 12)),
              onTap: () async {
                Get.back();
                final path = await controller.captureFromCamera();
                if (path != null) {
                  await controller.addScannedImage(path);
                }
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library_rounded, color: Color(0xFF2563EB)),
              ),
              title: const Text('Import from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Select images from your device photos', style: TextStyle(fontSize: 12)),
              onTap: () {
                Get.back();
                Get.to(() => const ScanGalleryPickerPage());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onConvert() {
    if (controller.scannedPages.isEmpty) {
      Get.snackbar(
        'Empty Document',
        'Please add at least one page to generate PDF.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.to(
      () => ConversionProcessingPage(
        title: 'Image to PDF',
        initialMessage: 'Compiling scanned pages into PDF document...',
        isEditOrganize: true,
        completedTitle: 'PDF Ready',
        completedSubtitle: 'Your scanned PDF has been created successfully.',
        processOperation: (onProgress) => controller.convertScanQueueToPdf(
          onProgress: onProgress,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldQuit = await QuitScanDialog.show(context);
        if (shouldQuit) {
          controller.clearQueue();
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary, size: 20),
            onPressed: () async {
              final shouldQuit = await QuitScanDialog.show(context);
              if (shouldQuit) {
                controller.clearQueue();
                Get.back();
              }
            },
          ),
          title: Text(
            'Image to PDF',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.add_rounded, color: colors.primary, size: 26),
              tooltip: 'Add Pages',
              onPressed: _onAddPages,
            ),
          ],
        ),
        body: Column(
          children: [
            // Notice Banner: "Long press to sort manually"
            if (_showNoticeBanner)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Long press to sort manually',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showNoticeBanner = false),
                      child: const Icon(Icons.close_rounded, color: Color(0xFF2563EB), size: 16),
                    ),
                  ],
                ),
              ),

            // Main Queue Grid
            Expanded(
              child: Obx(() {
                final pages = controller.scannedPages;
                final totalCards = pages.length + 1; // Includes "Add pages" card

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: totalCards,
                  itemBuilder: (context, index) {
                    // Last item: "Add pages" card
                    if (index == pages.length) {
                      return _buildAddPagesCard(colors);
                    }

                    final page = pages[index];
                    final String sequenceNumber = (index + 1).toString().padLeft(2, '0');

                    return _buildPageCard(
                      context,
                      page: page,
                      sequenceNumber: sequenceNumber,
                      onDelete: () => controller.deletePage(page.id),
                      onTap: () {
                        controller.activePageIndex.value = index;
                        Get.to(() => DocumentPreviewEditPage(pageId: page.id));
                      },
                    );
                  },
                );
              }),
            ),

            // Sticky Bottom Primary Button: "Convert"
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
              child: Obx(() {
                final count = controller.scannedPages.length;

                return SizedBox(
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
                    onPressed: _onConvert,
                    child: Text(
                      count > 0 ? 'Convert ($count)' : 'Convert',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageCard(
    BuildContext context, {
    required dynamic page,
    required String sequenceNumber,
    required VoidCallback onDelete,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border.withOpacity(0.7), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: colors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Page Thumbnail Image
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(page.displayPath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Top Left Sequence Badge (e.g. 01, 02)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sequenceNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Top Right Deletion Indicator (-)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.remove_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPagesCard(AppColors colors) {
    return GestureDetector(
      onTap: _onAddPages,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceElevated.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2563EB).withOpacity(0.4),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Color(0xFF2563EB),
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Add pages',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

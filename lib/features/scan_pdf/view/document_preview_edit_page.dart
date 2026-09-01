import 'dart:io';
import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/scan_pdf/controller/scan_pdf_controller.dart';
import 'package:file_reader/features/scan_pdf/model/scanned_page_item.dart';
import 'package:file_reader/features/scan_pdf/view/document_crop_page.dart';
import 'package:file_reader/features/scan_pdf/view/quit_scan_dialog.dart';
import 'package:file_reader/features/scan_pdf/view/scan_queue_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentPreviewEditPage extends StatefulWidget {
  final String pageId;

  const DocumentPreviewEditPage({super.key, required this.pageId});

  @override
  State<DocumentPreviewEditPage> createState() => _DocumentPreviewEditPageState();
}

class _DocumentPreviewEditPageState extends State<DocumentPreviewEditPage> {
  final ScanPdfController controller = Get.find<ScanPdfController>();

  void _onNext() {
    Get.to(() => const ScanQueuePage());
  }

  void _onRetake() async {
    final newPath = await controller.captureFromCamera();
    if (newPath != null) {
      final index = controller.scannedPages.indexWhere((p) => p.id == widget.pageId);
      if (index != -1) {
        controller.scannedPages.removeAt(index);
      }
      final item = await controller.addScannedImage(newPath);
      Get.off(() => DocumentPreviewEditPage(pageId: item.id));
    }
  }

  void _showFilterModal(BuildContext context) {
    final colors = context.colors;
    final page = controller.scannedPages.firstWhereOrNull((p) => p.id == widget.pageId);
    if (page == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Document Enhancements',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFilterOption(
                    title: 'Original',
                    filter: ScanDocFilter.original,
                    isSelected: page.filter == ScanDocFilter.original,
                    icon: Icons.image_outlined,
                  ),
                  _buildFilterOption(
                    title: 'Magic Color',
                    filter: ScanDocFilter.magicColor,
                    isSelected: page.filter == ScanDocFilter.magicColor,
                    icon: Icons.auto_awesome_rounded,
                  ),
                  _buildFilterOption(
                    title: 'Grayscale',
                    filter: ScanDocFilter.grayscale,
                    isSelected: page.filter == ScanDocFilter.grayscale,
                    icon: Icons.gradient_rounded,
                  ),
                  _buildFilterOption(
                    title: 'B&W',
                    filter: ScanDocFilter.blackAndWhite,
                    isSelected: page.filter == ScanDocFilter.blackAndWhite,
                    icon: Icons.contrast_rounded,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption({
    required String title,
    required ScanDocFilter filter,
    required bool isSelected,
    required IconData icon,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.of(context).pop();
        controller.updatePageProcessing(widget.pageId, filter: filter);
      },
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2563EB).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? const Color(0xFF2563EB) : Colors.grey,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? const Color(0xFF2563EB) : Colors.grey,
              ),
            ),
          ],
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
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () async {
              final shouldQuit = await QuitScanDialog.show(context);
              if (shouldQuit) {
                controller.clearQueue();
                Get.back();
              }
            },
          ),
          title: const Text(
            'Preview Document',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          centerTitle: true,
          actions: [
            // Top Right Next Button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
                label: const Text(
                  'Next',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                onPressed: _onNext,
              ),
            ),
          ],
        ),
        body: Obx(() {
          final page = controller.scannedPages.firstWhereOrNull((p) => p.id == widget.pageId);
          if (page == null) {
            return const Center(
              child: Text('Page not found', style: TextStyle(color: Colors.white)),
            );
          }

          if (controller.isProcessing.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF38BDF8)),
                  const SizedBox(height: 16),
                  Text(
                    controller.processingMessage.value,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Main High-Contrast Viewport
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.file(
                        File(page.displayPath),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Toolbar: Retake, Left, Filters, Crop
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToolbarButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Retake',
                      onTap: _onRetake,
                    ),
                    _buildToolbarButton(
                      icon: Icons.rotate_left_rounded,
                      label: 'Left',
                      onTap: () {
                        final currentRot = page.rotationDegrees;
                        final nextRot = (currentRot - 90 + 360) % 360;
                        controller.updatePageProcessing(page.id, rotationDegrees: nextRot);
                      },
                    ),
                    _buildToolbarButton(
                      icon: Icons.filter_vintage_rounded,
                      label: 'Filters',
                      onTap: () => _showFilterModal(context),
                    ),
                    _buildToolbarButton(
                      icon: Icons.crop_rounded,
                      label: 'Crop',
                      onTap: () {
                        Get.to(() => DocumentCropPage(pageId: page.id));
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

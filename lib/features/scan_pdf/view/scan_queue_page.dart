import 'dart:io';
import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/converter/view/conversion_processing_page.dart';
import 'package:file_reader/features/scan_pdf/controller/scan_pdf_controller.dart';
import 'package:file_reader/features/scan_pdf/view/document_camera_page.dart';
import 'package:file_reader/features/scan_pdf/view/document_preview_edit_page.dart';
import 'package:file_reader/features/scan_pdf/view/quit_scan_dialog.dart';
import 'package:file_reader/features/scan_pdf/view/scan_gallery_picker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ScanQueuePage extends StatefulWidget {
  const ScanQueuePage({super.key});

  @override
  State<ScanQueuePage> createState() => _ScanQueuePageState();
}

class _ScanQueuePageState extends State<ScanQueuePage> {
  late final ScanPdfController controller;
  bool _showNoticeBanner = true;
  int? _draggedIndex;
  int? _hoveredTargetIndex;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ScanPdfController>()
        ? Get.find<ScanPdfController>()
        : Get.put(ScanPdfController());
  }

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
              onTap: () {
                Get.back();
                Get.to(() => const DocumentCameraPage(returnToQueue: true));
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
            // Notice Banner: "Long press and drag to reorder pages"
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
                    const Icon(Icons.swap_vert_rounded, color: Color(0xFF2563EB), size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Tap & hold to drag and reorder pages',
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

            // Main Queue Grid with Drag & Drop Reordering
            Expanded(
              child: Obx(() {
                final pages = controller.scannedPages;
                final totalCards = pages.length + 1; // Includes "Add pages" card

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final double gridPadding = 16.0;
                    final double spacing = 14.0;
                    final double availableWidth = constraints.maxWidth - (gridPadding * 2) - spacing;
                    final double cardWidth = availableWidth / 2;
                    final double cardHeight = cardWidth / 0.72;

                    return GridView.builder(
                      padding: EdgeInsets.fromLTRB(gridPadding, 12, gridPadding, 20),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: totalCards,
                      itemBuilder: (context, index) {
                        // Last item: "Add pages" card with DragTarget support
                        if (index == pages.length) {
                          return DragTarget<int>(
                            onWillAcceptWithDetails: (details) {
                              if (details.data != pages.length - 1) {
                                setState(() => _hoveredTargetIndex = index);
                                return true;
                              }
                              return false;
                            },
                            onLeave: (_) {
                              if (_hoveredTargetIndex == index) {
                                setState(() => _hoveredTargetIndex = null);
                              }
                            },
                            onAcceptWithDetails: (details) {
                              final fromIndex = details.data;
                              setState(() {
                                _draggedIndex = null;
                                _hoveredTargetIndex = null;
                              });
                              if (fromIndex != pages.length - 1) {
                                controller.movePage(fromIndex, pages.length - 1);
                                HapticFeedback.mediumImpact();
                              }
                            },
                            builder: (context, candidateData, rejectedData) {
                              final isHovered = _hoveredTargetIndex == index;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                transform: isHovered
                                    ? (Matrix4.identity()..scale(1.03))
                                    : Matrix4.identity(),
                                child: _buildAddPagesCard(colors, isHovered: isHovered),
                              );
                            },
                          );
                        }

                        final page = pages[index];
                        final String sequenceNumber = (index + 1).toString().padLeft(2, '0');
                        final bool isBeingDragged = _draggedIndex == index;
                        final bool isTargetHovered = _hoveredTargetIndex == index && !isBeingDragged;

                        return DragTarget<int>(
                          onWillAcceptWithDetails: (details) {
                            if (details.data != index) {
                              setState(() => _hoveredTargetIndex = index);
                              return true;
                            }
                            return false;
                          },
                          onLeave: (_) {
                            if (_hoveredTargetIndex == index) {
                              setState(() => _hoveredTargetIndex = null);
                            }
                          },
                          onAcceptWithDetails: (details) {
                            final fromIndex = details.data;
                            setState(() {
                              _draggedIndex = null;
                              _hoveredTargetIndex = null;
                            });
                            if (fromIndex != index) {
                              controller.movePage(fromIndex, index);
                              HapticFeedback.mediumImpact();
                            }
                          },
                          builder: (context, candidateData, rejectedData) {
                            return LongPressDraggable<int>(
                              data: index,
                              hapticFeedbackOnStart: true,
                              delay: const Duration(milliseconds: 250),
                              onDragStarted: () {
                                setState(() {
                                  _draggedIndex = index;
                                  _hoveredTargetIndex = null;
                                });
                                HapticFeedback.selectionClick();
                              },
                              onDragEnd: (_) {
                                setState(() {
                                  _draggedIndex = null;
                                  _hoveredTargetIndex = null;
                                });
                              },
                              onDraggableCanceled: (_, __) {
                                setState(() {
                                  _draggedIndex = null;
                                  _hoveredTargetIndex = null;
                                });
                              },
                              feedback: Material(
                                color: Colors.transparent,
                                child: _buildCardFeedback(
                                  context,
                                  page: page,
                                  sequenceNumber: sequenceNumber,
                                  width: cardWidth,
                                  height: cardHeight,
                                ),
                              ),
                              childWhenDragging: _buildPlaceholderCard(
                                colors,
                                sequenceNumber: sequenceNumber,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                                transform: isTargetHovered
                                    ? (Matrix4.identity()..scale(1.03))
                                    : Matrix4.identity(),
                                child: _buildPageCard(
                                  context,
                                  page: page,
                                  sequenceNumber: sequenceNumber,
                                  isTargetHovered: isTargetHovered,
                                  onDelete: () => controller.deletePage(page.id),
                                  onTap: () {
                                    controller.activePageIndex.value = index;
                                    Get.to(() => DocumentPreviewEditPage(pageId: page.id));
                                  },
                                ),
                              ),
                            );
                          },
                        );
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
    bool isTargetHovered = false,
    required VoidCallback onDelete,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isTargetHovered
                ? const Color(0xFF2563EB)
                : colors.border.withOpacity(0.7),
            width: isTargetHovered ? 2.5 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isTargetHovered
                  ? const Color(0xFF2563EB).withOpacity(0.35)
                  : colors.cardShadow,
              blurRadius: isTargetHovered ? 14 : 8,
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
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.image_outlined, color: Colors.white54),
                    ),
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
                  color: isTargetHovered
                      ? const Color(0xFF2563EB)
                      : Colors.black.withOpacity(0.7),
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

            // Drag handle hint icon on bottom-right
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.drag_indicator_rounded,
                  color: Colors.white70,
                  size: 14,
                ),
              ),
            ),

            // Target Hover Insertion Overlay
            if (isTargetHovered)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Move here',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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

  /// Visual placeholder when an item is currently being dragged
  Widget _buildPlaceholderCard(AppColors colors, {required String sequenceNumber}) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceElevated.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2563EB).withOpacity(0.4),
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.drag_indicator_rounded,
              color: const Color(0xFF2563EB).withOpacity(0.5),
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              'Page $sequenceNumber',
              style: TextStyle(
                color: colors.textSecondary.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Floating feedback card under the user's touch during drag
  Widget _buildCardFeedback(
    BuildContext context, {
    required dynamic page,
    required String sequenceNumber,
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF38BDF8),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 22,
            spreadRadius: 3,
            offset: const Offset(0, 10),
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
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(page.displayPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.image_outlined, color: Colors.white54),
                  ),
                ),
              ),
            ),
          ),

          // Top Left Page Badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.open_with_rounded, color: Colors.white, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'Page $sequenceNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPagesCard(AppColors colors, {bool isHovered = false}) {
    return GestureDetector(
      onTap: _onAddPages,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: isHovered
              ? const Color(0xFF2563EB).withOpacity(0.18)
              : colors.surfaceElevated.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered
                ? const Color(0xFF2563EB)
                : const Color(0xFF2563EB).withOpacity(0.4),
            width: isHovered ? 2.5 : 1.5,
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
              child: Icon(
                isHovered ? Icons.add_to_photos_rounded : Icons.add_rounded,
                color: const Color(0xFF2563EB),
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isHovered ? 'Move to end' : 'Add pages',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isHovered ? const Color(0xFF2563EB) : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'dart:io';

import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/converter/controller/remove_pages_controller.dart';
import 'package:file_reader/features/converter/view/conversion_processing_page.dart';
import 'package:file_reader/features/converter/view/pdf_page_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RemovePagesPage extends StatefulWidget {
  final File file;
  final int totalPages;

  const RemovePagesPage({
    super.key,
    required this.file,
    required this.totalPages,
  });

  @override
  State<RemovePagesPage> createState() => _RemovePagesPageState();
}

class _RemovePagesPageState extends State<RemovePagesPage> {
  late final RemovePagesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<RemovePagesController>()
        ? Get.find<RemovePagesController>()
        : Get.put(RemovePagesController());
  }

  void _handleRemove(BuildContext context) {
    if (controller.pagesToRemove.isEmpty) {
      Get.snackbar(
        'No Pages Selected',
        'Please select at least one page to remove.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (controller.remainingPagesCount <= 0) {
      Get.snackbar(
        'Cannot Remove All Pages',
        'At least one page must remain in the document.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final removeCount = controller.pagesToRemove.length;
    final remainCount = controller.remainingPagesCount;

    Get.to(
      () => ConversionProcessingPage(
        title: 'Remove Pages',
        initialMessage:
            'Removing $removeCount pages (keeping $remainCount pages)...',
        isEditOrganize: true,
        completedTitle: 'PDF Updated',
        completedSubtitle:
            'The selected pages have been removed from your PDF.',
        processOperation: (onProgress) =>
            controller.generatePdfWithoutRemovedPages(
          onProgress: onProgress,
        ),
      ),
    );
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
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Obx(
          () => Text(
            '${controller.pagesToRemove.length} to Remove',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          Obx(
            () => controller.pagesToRemove.isNotEmpty
                ? TextButton(
                    onPressed: () => controller.clearSelection(),
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Informational Helper Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEF4444).withOpacity(0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.delete_sweep_rounded,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(
                    () => Text(
                      'Tap pages to mark them for removal. ${controller.remainingPagesCount} of ${widget.totalPages} pages will remain.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2-Column Grid of Pages
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
              ),
              itemCount: widget.totalPages,
              itemBuilder: (context, index) {
                final pageNumber = index + 1;

                return Obx(() {
                  final isMarkedForRemoval =
                      controller.pagesToRemove.contains(pageNumber);

                  return GestureDetector(
                    onTap: () => controller.togglePageRemoval(pageNumber),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isMarkedForRemoval
                              ? const Color(0xFFEF4444)
                              : colors.border.withOpacity(0.6),
                          width: isMarkedForRemoval ? 2.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isMarkedForRemoval
                                ? const Color(0xFFEF4444).withOpacity(0.2)
                                : colors.cardShadow,
                            blurRadius: isMarkedForRemoval ? 10 : 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            // Real PDF Page Thumbnail Content
                            Positioned.fill(
                              child: PdfPageThumbnail(
                                file: widget.file,
                                pageNumber: pageNumber,
                                password: controller.pdfPassword,
                                isMarkedForRemoval: isMarkedForRemoval,
                              ),
                            ),

                            // Bottom-Left Page Number Badge
                            Positioned(
                              left: 8,
                              bottom: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isMarkedForRemoval
                                      ? const Color(0xFFEF4444)
                                      : Colors.black.withOpacity(0.65),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '$pageNumber',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            // Bottom-Right Trash/Removal Indicator
                            Positioned(
                              right: 8,
                              bottom: 8,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isMarkedForRemoval
                                      ? const Color(0xFFEF4444)
                                      : Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isMarkedForRemoval
                                        ? const Color(0xFFEF4444)
                                        : Colors.white38,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isMarkedForRemoval
                                      ? Icons.delete_outline_rounded
                                      : Icons.check_rounded,
                                  size: 17,
                                  color: isMarkedForRemoval
                                      ? Colors.white
                                      : Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: [
                BoxShadow(
                  color: colors.cardShadow,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Obx(() {
              final hasSelection = controller.pagesToRemove.isNotEmpty;

              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasSelection
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFEF4444).withOpacity(0.35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: hasSelection ? 2 : 0,
                  ),
                  onPressed:
                      hasSelection ? () => _handleRemove(context) : null,
                  child: Text(
                    hasSelection
                        ? 'REMOVE ${controller.pagesToRemove.length} PAGES'
                        : 'SELECT PAGES TO REMOVE',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

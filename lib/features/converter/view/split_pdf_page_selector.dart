import 'dart:io';

import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/converter/controller/split_pdf_controller.dart';
import 'package:file_reader/features/converter/view/conversion_processing_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplitPdfPageSelectorPage extends StatefulWidget {
  final File file;
  final int totalPages;

  const SplitPdfPageSelectorPage({
    super.key,
    required this.file,
    required this.totalPages,
  });

  @override
  State<SplitPdfPageSelectorPage> createState() =>
      _SplitPdfPageSelectorPageState();
}

class _SplitPdfPageSelectorPageState extends State<SplitPdfPageSelectorPage> {
  late final SplitPdfController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<SplitPdfController>()
        ? Get.find<SplitPdfController>()
        : Get.put(SplitPdfController());
  }

  void _showRangeDialog(BuildContext context) {
    final colors = context.colors;
    final startController = TextEditingController();
    final endController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Select Page Range',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter range between 1 and ${widget.totalPages}:',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'From',
                      hintText: '1',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: endController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'To',
                      hintText: '${widget.totalPages}',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final start = int.tryParse(startController.text.trim());
              final end = int.tryParse(endController.text.trim());
              if (start != null && end != null) {
                controller.selectRange(start, end);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Apply Range'),
          ),
        ],
      ),
    );
  }

  void _handleContinue(BuildContext context) {
    if (controller.selectedPages.isEmpty) {
      Get.snackbar(
        'No Pages Selected',
        'Please select at least one page to split.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final count = controller.selectedPages.length;
    Get.to(
      () => ConversionProcessingPage(
        title: 'Split PDF',
        initialMessage: 'Extracting $count selected pages...',
        isEditOrganize: true,
        completedTitle: 'PDF Ready',
        completedSubtitle: 'Your split PDF is ready to view and share.',
        processOperation: (onProgress) => controller.splitSelectedPages(
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
            '${controller.selectedPages.length} Selected',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          // Range Selector Button
          IconButton(
            icon: const Icon(Icons.linear_scale_rounded),
            color: colors.textPrimary,
            tooltip: 'Select Page Range',
            onPressed: () => _showRangeDialog(context),
          ),
          // Select All / Deselect All Button
          IconButton(
            icon: const Icon(Icons.select_all_rounded),
            color: colors.textPrimary,
            tooltip: 'Select / Deselect All',
            onPressed: () => controller.selectAllPages(),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // 2-Column Grid of Pages
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  final isSelected =
                      controller.selectedPages.contains(pageNumber);

                  return GestureDetector(
                    onTap: () => controller.togglePageSelection(pageNumber),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.border.withOpacity(0.6),
                          width: isSelected ? 2.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? colors.primary.withOpacity(0.2)
                                : colors.cardShadow,
                            blurRadius: isSelected ? 10 : 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            // Document Page Skeleton / Preview
                            Positioned.fill(
                              child: Container(
                                color: colors.isDark
                                    ? const Color(0xFF1E2438)
                                    : Colors.white,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Simulated Header
                                    Container(
                                      width: 60,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: colors.textSecondary.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    // Simulated Document Lines
                                    for (int l = 0; l < 8; l++) ...[
                                      Container(
                                        width: double.infinity,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: (l % 2 == 0)
                                              ? colors.textSecondary.withOpacity(0.18)
                                              : colors.textSecondary.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                    ],
                                    const Spacer(),
                                    // Simulated Table/Blocks
                                    Container(
                                      width: double.infinity,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: colors.textSecondary.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: colors.textSecondary.withOpacity(0.15),
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                  ],
                                ),
                              ),
                            ),

                            // Bottom-Left Page Number Badge (Matching Reference Screenshot)
                            Positioned(
                              left: 10,
                              bottom: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFF94A3B8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$pageNumber',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            // Bottom-Right Checkbox Indicator (Matching Reference Screenshot)
                            Positioned(
                              right: 10,
                              bottom: 10,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors.primary
                                      : (colors.isDark
                                          ? const Color(0xFF334155).withOpacity(0.8)
                                          : const Color(0xFFCBD5E1)),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? colors.primary
                                        : (colors.isDark
                                            ? Colors.white24
                                            : Colors.black12),
                                    width: 1,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      )
                                    : null,
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

          // Bottom Action Bar with Prominent CONTINUE Button
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
              final hasSelection = controller.selectedPages.isNotEmpty;

              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasSelection
                        ? colors.primary
                        : colors.primary.withOpacity(0.35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: hasSelection ? 2 : 0,
                  ),
                  onPressed:
                      hasSelection ? () => _handleContinue(context) : null,
                  child: Text(
                    hasSelection
                        ? 'CONTINUE (${controller.selectedPages.length})'
                        : 'CONTINUE',
                    style: const TextStyle(
                      fontSize: 16,
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

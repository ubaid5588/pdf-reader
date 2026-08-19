import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/converter/view/conversion_processing_page.dart';
import 'package:file_reader/features/merge_pdf/controller/merge_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MergePdfPage extends StatelessWidget {
  MergePdfPage({super.key});

  final MergePdfController controller = Get.put(MergePdfController());

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text(
          "Select PDFs to Merge",
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(
            () => controller.selectedForMerge.isNotEmpty
                ? TextButton(
                    onPressed: () => controller.clearSelection(),
                    child: Text(
                      "Clear (${controller.selectedForMerge.length})",
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: colors.primary),
          );
        }

        if (controller.pdfFiles.isEmpty) {
          return Center(
            child: Text(
              "No PDFs found on device",
              style: TextStyle(color: colors.textSecondary, fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: controller.pdfFiles.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: colors.divider,
          ),
          itemBuilder: (context, index) {
            final file = controller.pdfFiles[index];

            return Obx(() {
              final isSelected = controller.selectedForMerge.any(
                (f) => f.path == file.path,
              );
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.isDark
                          ? const Color(0xFF3B1E1E)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: colors.isDark
                          ? const Color(0xFFF87171)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                  title: Text(
                    file.path.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colors.primary : colors.textPrimary,
                    ),
                  ),
                  trailing: Checkbox(
                    value: isSelected,
                    activeColor: colors.primary,
                    checkColor: Colors.white,
                    side: BorderSide(color: colors.border, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (_) => controller.toggleSelection(file),
                  ),
                  onTap: () => controller.toggleSelection(file),
                ),
              );
            });
          },
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.selectedForMerge.length < 2) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          backgroundColor: colors.primary,
          foregroundColor: Colors.white,
          onPressed: () {
            final count = controller.selectedForMerge.length;
            Get.to(
              () => ConversionProcessingPage(
                title: 'Merge PDF',
                initialMessage: 'Merging $count documents into one...',
                processOperation: (onProgress) async {
                  return await controller.mergeSelectedPdfs(
                    onProgress: onProgress,
                  );
                },
              ),
            );
          },
          icon: const Icon(Icons.merge_type_rounded),
          label: Text("Merge (${controller.selectedForMerge.length})"),
        );
      }),
    );
  }
}

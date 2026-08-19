import 'package:file_reader/features/converter/view/conversion_processing_page.dart';
import 'package:file_reader/features/merge_pdf/controller/merge_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MergePdfPage extends StatelessWidget {
  MergePdfPage({super.key});

  final MergePdfController controller = Get.put(MergePdfController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select PDFs to Merge"),
        actions: [
          Obx(
            () => controller.selectedForMerge.isNotEmpty
                ? TextButton(
                    onPressed: () => controller.clearSelection(),
                    child: Text(
                      "Clear (${controller.selectedForMerge.length})",
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.pdfFiles.isEmpty) {
          return const Center(
            child: Text(
              "No PDFs found on device",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.pdfFiles.length,
          itemBuilder: (context, index) {
            final file = controller.pdfFiles[index];

            return Obx(() {
              final isSelected = controller.selectedForMerge.any(
                (f) => f.path == file.path,
              );
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Color(0xFFEF4444),
                  ),
                ),
                title: Text(
                  file.path.split('/').last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: Checkbox(
                  value: isSelected,
                  activeColor: const Color(0xFF5B5CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (_) => controller.toggleSelection(file),
                ),
                onTap: () => controller.toggleSelection(file),
                selected: isSelected,
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
          backgroundColor: const Color(0xFF5B5CFF),
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

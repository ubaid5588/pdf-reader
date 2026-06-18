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
        title: const Text("My PDFs"),
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
          return const Center(child: Text("No PDFs found"));
        }

        return ListView.builder(
          itemCount: controller.pdfFiles.length,
          itemBuilder: (context, index) {
            final file = controller.pdfFiles[index];

            return Obx(() {
              final isSelected = controller.selectedForMerge.contains(file);
              return ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(file.path.split('/').last),
                trailing: Checkbox(
                  value: isSelected,
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
        if (controller.selectedForMerge.length < 2)
          return const SizedBox.shrink();

        return FloatingActionButton.extended(
          onPressed: controller.isMerging.value
              ? null
              : () async {
                  final merged = await controller.mergeSelectedPdfs();
                  if (merged != null) {
                    Get.snackbar(
                      "Success",
                      "Merged into ${merged.path.split('/').last}",
                    );
                  }
                },
          icon: controller.isMerging.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.merge_type),
          label: const Text("Merge"),
        );
      }),
    );
  }
}

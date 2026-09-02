import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:get/get.dart';

class NaviController extends GetxController {
  late final FilePageController fileController;
  late final RecentPdfController recentPdfController;
  RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fileController = Get.isRegistered<FilePageController>()
        ? Get.find<FilePageController>()
        : Get.put(FilePageController());
    recentPdfController = Get.isRegistered<RecentPdfController>()
        ? Get.find<RecentPdfController>()
        : Get.put(RecentPdfController());
  }

  void changePage(int index) {
    selectedIndex.value = index;
    if (index == 1) {
      if (fileController.pdfFiles.isEmpty) {
        fileController.loadPdfs();
      }
    } else if (index == 2) {
      recentPdfController.loadRecentPdfs();
    }
  }
}

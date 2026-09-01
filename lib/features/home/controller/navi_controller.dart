import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:get/get.dart';

class NaviController extends GetxController {
  late final FilePageController fileController;
  RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fileController = Get.isRegistered<FilePageController>()
        ? Get.find<FilePageController>()
        : Get.put(FilePageController());
  }

  void changePage(int index) {
    selectedIndex.value = index;
    if (index == 1) {
      if (fileController.pdfFiles.isEmpty) {
        fileController.loadPdfs();
      }
    }
  }
}

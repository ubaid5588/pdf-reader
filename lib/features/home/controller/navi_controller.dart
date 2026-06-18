import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:get/get.dart';

class NaviController extends GetxController {
  final FilePageController fileController = Get.put(FilePageController());
  RxInt selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
    if (index == 1) {
      fileController.loadPdfs();
    }
  }
}

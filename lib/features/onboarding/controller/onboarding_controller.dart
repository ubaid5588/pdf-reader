import 'package:file_reader/features/home/view/home_page.dart';
import 'package:file_reader/features/language_selection/controller/language_controller.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class OnboardingController extends GetxController {
  final LanguageController languageController = Get.find();

  RxInt currentPage = 0.obs;

  Future<void> saveSetting() async {
    var box = Hive.box('settings');
    box.put('settings', [
      {'login': true},
      {'localization': languageController.selectedCode.value},
    ]);
    print(box.get('settings'));
  }

  void onComplete() {
    if (currentPage < 2) {
      currentPage += 1;
    } else {
      saveSetting();
      Get.offAll(HomePage());
    }
  }

  void onSkip() {
    saveSetting();
    Get.offAll(HomePage());
  }
}

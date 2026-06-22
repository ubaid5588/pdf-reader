import 'package:file_reader/features/language_selection/controller/language_controller.dart';
import 'package:file_reader/features/language_selection/view/language_selection_screen.dart';
import 'package:file_reader/features/home/view/home_page.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SplashController extends GetxController {
  final LanguageController languageController = Get.put(LanguageController());

  @override
  void onReady() {
    super.onReady();
    _navigatorToHome();
  }

  void _navigatorToHome() async {
    await Future.delayed(Duration(seconds: 5));
    var box = Hive.box('settings');
    if (box.containsKey('settings')) {
      if (box.get('settings')[0]['login'] == true) {
        languageController.selectedCode ==
            box.get('settings')[0]['localization'];

        Get.offAll(() => HomePage());
        return;
      } else {
        Get.off(() => LanguageSelectionScreen());
        return;
      }
    }
    Get.off(() => LanguageSelectionScreen());
    return;
  }
}

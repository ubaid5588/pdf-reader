import 'dart:ui';

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
    final box = Hive.box('settings');

    if (box.get('login') == true) {
      final String savedCode = box.get('localization') ?? 'en';
      languageController.selectedCode.value = savedCode;
      Get.updateLocale(Locale(savedCode));

      Get.offAll(() => HomePage());
    } else {
      Get.off(() => LanguageSelectionScreen());
    }
  }
}

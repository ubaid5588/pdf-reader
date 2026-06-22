import 'dart:ui';

import 'package:file_reader/features/home/view/home_page.dart';
import 'package:file_reader/features/language_selection/model/language.dart';
import 'package:file_reader/features/onboarding/view/onboarding.dart';
import 'package:file_reader/features/setting/view/setting_page.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LanguageController extends GetxController {
  final List<Language> languages = const [
    Language(name: 'English', nativeName: 'English', flag: '🇬🇧', code: 'en'),
    Language(name: 'Urdu', nativeName: 'اردو', flag: '🇵🇰', code: 'ur'),
    Language(name: 'Spanish', nativeName: 'Español', flag: '🇪🇸', code: 'es'),
    Language(name: 'French', nativeName: 'Français', flag: '🇫🇷', code: 'fr'),
    Language(name: 'German', nativeName: 'Deutsch', flag: '🇩🇪', code: 'de'),
    Language(name: 'Italian', nativeName: 'Italiano', flag: '🇮🇹', code: 'it'),
    Language(
      name: 'Portuguese',
      nativeName: 'Português',
      flag: '🇵🇹',
      code: 'pt',
    ),
    Language(name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦', code: 'ar'),
    Language(name: 'Chinese', nativeName: '中文', flag: '🇨🇳', code: 'zh'),
    Language(name: 'Japanese', nativeName: '日本語', flag: '🇯🇵', code: 'ja'),
    Language(name: 'Korean', nativeName: '한국어', flag: '🇰🇷', code: 'ko'),
  ];

  RxString selectedCode = 'en'.obs;

  Language get isSelected =>
      languages.firstWhere((e) => e.code == selectedCode.value);

  void changeSelectedCode(String languageCode) {
    selectedCode.value = languageCode;
    Get.updateLocale(Locale(languageCode));
  }

  void onContinue() {
    final box = Hive.box('settings');

    box.put('localization', selectedCode.value);

    if (box.get('login') == true) {
      Get.offAll(() => HomePage());
    } else {
      Get.to(() => Onboarding());
    }
  }
}

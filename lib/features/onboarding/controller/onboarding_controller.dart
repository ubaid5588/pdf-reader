import 'package:file_reader/features/home/view/home_page.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../model/onboarding_model.dart';

class OnboardingController extends GetxController {
  final List<OnboardingModel> onboardingPages = const [
    OnboardingModel(
      title: 'Read PDF Files Instantly',
      subtitle:
          'Open, view, and manage all your PDF documents with a smooth and fast reading experience.',
      image: 'assets/images/pdf.png',
    ),
    OnboardingModel(
      title: 'Access Word Documents',
      subtitle:
          'View DOC and DOCX files anytime, keeping your important documents organized in one place.',
      image: 'assets/images/doc.png',
    ),
    OnboardingModel(
      title: 'Presentations Made Simple',
      subtitle:
          'Open and browse PPT and PPTX slides effortlessly for work, study, and presentations.',
      image: 'assets/images/ppt.png',
    ),
  ];

  RxInt currentPage = 0.obs;

  Future<void> saveSetting() async {
    var box = Hive.box('settings');
    box.put('settings', [
      {'login': true},
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

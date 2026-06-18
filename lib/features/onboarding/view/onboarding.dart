import 'package:file_reader/core/widgets/custom_button.dart';
import 'package:file_reader/features/onboarding/controller/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Onboarding extends StatelessWidget {
  Onboarding({super.key});

  final OnboardingController controller = Get.put(OnboardingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 22),
                    child: Obx(
                      () => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            controller
                                .onboardingPages[controller.currentPage.value]
                                .image,
                            width: 180,
                          ),
                          SizedBox(height: 20),
                          Text(
                            controller
                                .onboardingPages[controller.currentPage.value]
                                .title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 21,
                              color: Color(0xFF444466),
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 20),

                          Text(
                            controller
                                .onboardingPages[controller.currentPage.value]
                                .subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 19,
                              color: Color(0xFF444466),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 230, 229, 229),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 5, 24, 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: controller.onSkip,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 25,
                        horizontal: 4,
                      ),
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (index) {
                        final isActive = index == controller.currentPage.value;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.blue
                                : const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ),
                  Obx(
                    () => CustomButton(
                      text: controller.currentPage.value != 2 ? 'Next' : 'Done',
                      onPressed: controller.onComplete,
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

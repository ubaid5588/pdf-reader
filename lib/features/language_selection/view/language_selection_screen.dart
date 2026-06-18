import 'package:file_reader/core/widgets/custom_button.dart';
import 'package:file_reader/features/language_selection/controller/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSelectionScreen extends StatelessWidget {
  LanguageSelectionScreen({super.key});

  static const Color _blue = Color(0xFF2563EB);
  final LanguageController controller = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
              child: Column(
                children: [
                  Container(
                    width: screenSize.width * 0.14,
                    height: screenSize.height * 0.06,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _blue,
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: Color.fromARGB(255, 15, 5, 5),
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Choose your preferred language to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                itemCount: controller.languages.length,

                separatorBuilder: (_, __) => const SizedBox(height: 10),

                itemBuilder: (context, index) {
                  return Obx(() {
                    final lang = controller.languages[index];

                    final isSelected =
                        lang.code == controller.selectedCode.value;

                    return GestureDetector(
                      onTap: () => controller.changeSelectedCode(lang.code),

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),

                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEFF6FF)
                              : Colors.white,

                          borderRadius: BorderRadius.circular(12),

                          border: Border.all(
                            color: isSelected ? _blue : const Color(0xFFE5E7EB),

                            width: 1.5,
                          ),
                        ),

                        child: Row(
                          children: [
                            Text(
                              lang.flag,
                              style: const TextStyle(fontSize: 28),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    lang.nativeName,

                                    style: TextStyle(
                                      fontSize: 16,

                                      fontWeight: FontWeight.w600,

                                      color: isSelected
                                          ? _blue
                                          : const Color(0xFF111827),
                                    ),
                                  ),
                                  Text(
                                    lang.name,

                                    style: TextStyle(
                                      fontSize: 13,

                                      color: isSelected ? _blue : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (isSelected)
                              const Icon(Icons.check, color: _blue, size: 20),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),

              child: CustomButton(
                text: 'Continue',

                onPressed: controller.onContinue,

                width: screenSize.width * 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

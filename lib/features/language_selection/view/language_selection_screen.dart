import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/core/widgets/custom_button.dart';
import 'package:file_reader/features/language_selection/controller/language_controller.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LanguageSelectionScreen extends StatelessWidget {
  LanguageSelectionScreen({super.key});

  final LanguageController controller = Get.put(LanguageController());

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final colors = context.colors;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colors.background,
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary,
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    lang.selectLanguage,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang.preferredLangauge,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: colors.textSecondary),
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
                    final langItem = controller.languages[index];
                    final isSelected =
                        langItem.code == controller.selectedCode.value;
                    return GestureDetector(
                      onTap: () => controller.changeSelectedCode(langItem.code),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withOpacity(0.12)
                              : colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? colors.primary : colors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              langItem.flag,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    langItem.nativeName,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? colors.primary
                                          : colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    langItem.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isSelected
                                          ? colors.primary
                                          : colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded,
                                  color: colors.primary, size: 22),
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
                text: lang.languageSelection,
                onPressed: controller.onContinue,
                width: screenSize.width * 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:file_reader/features/language_selection/controller/language_controller.dart';
import 'package:file_reader/features/language_selection/view/language_selection_screen.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final lang = AppLocalizations.of(context)!;
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: screenSize.height * 0.17,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7B5EA7), Color(0xFF5B4FCF), Color(0xFF8B6FD4)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 18, 18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(230, 26, 26, 46),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Text('👑', style: TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang.settingsUpgrade,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              lang.settingsPremiumSutitle,
                              style: TextStyle(
                                color: Color(0xFFAAAAAA),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          lang.upgrade,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [const SizedBox(height: 6)],
            // ),
          ),
        ),
        // Transform.translate(
        //   offset: const Offset(0, -22),
        //   child:
        // ),
        const SizedBox(width: 14, height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildMenuTile(
                  icon: Icons.language,
                  label: lang.settingsLabel1,
                  isFirst: true,
                  onTap: () => Get.to(() => LanguageSelectionScreen()),
                ),
                const Divider(height: 1, indent: 52, endIndent: 16),

                _buildMenuTile(
                  icon: Icons.chat_bubble_outline,
                  label: lang.settingsLabel2,
                  isFirst: true,
                ),
                const Divider(height: 1, indent: 52, endIndent: 16),
                _buildMenuTile(
                  icon: Icons.headset_mic_outlined,
                  label: lang.settingsLabel3,
                ),
                const Divider(height: 1, indent: 52, endIndent: 16),
                _buildMenuTile(
                  icon: Icons.star_outline,
                  label: lang.settingsLabel4,
                ),
                const Divider(height: 1, indent: 52, endIndent: 16),
                _buildMenuTile(
                  icon: Icons.info_outline,
                  label: lang.settingsLabel5,
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 220),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE8453C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                lang.settingsLogout,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    bool isFirst = false,
    bool isLast = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF888888), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFBBBBBB), size: 22),
          ],
        ),
      ),
    );
  }
}

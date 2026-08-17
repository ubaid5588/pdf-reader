import 'package:file_reader/features/about/aout_screen.dart';
import 'package:file_reader/features/help_support/help_support.dart';
import 'package:file_reader/features/language_selection/view/language_selection_screen.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isSmall = width < 360;
        final bool isTablet = width >= 600;

        final double horizontalPadding = isSmall
            ? 10
            : isTablet
            ? 24
            : 16;

        final double headerPadding = isSmall
            ? 10
            : isTablet
            ? 18
            : 16;

        final double crownSize = isSmall
            ? 24
            : isTablet
            ? 32
            : 28;

        final double titleSize = isSmall
            ? 14
            : isTablet
            ? 18
            : 16;

        final double subtitleSize = isSmall
            ? 10
            : isTablet
            ? 14
            : 13;

        final double buttonFontSize = isSmall
            ? 11
            : isTablet
            ? 15
            : 14;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: isSmall ? 20 : 30),
          child: Column(
            children: [
              // Container(
              //   width: double.infinity,
              //   decoration: const BoxDecoration(
              //     gradient: LinearGradient(
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //       colors: [
              //         Color(0xFF7B5EA7),
              //         Color(0xFF5B4FCF),
              //         Color(0xFF8B6FD4),
              //       ],
              //     ),
              //   ),
              //   child: Padding(
              //     padding: EdgeInsets.fromLTRB(
              //       headerPadding,
              //       headerPadding,
              //       headerPadding,
              //       headerPadding,
              //     ),
              //     child: Container(
              //       padding: EdgeInsets.all(
              //         isSmall
              //             ? 12
              //             : isTablet
              //             ? 20
              //             : 16,
              //       ),
              //       decoration: BoxDecoration(
              //         color: const Color.fromARGB(230, 26, 26, 46),
              //         borderRadius: BorderRadius.circular(16),
              //       ),
              //       child: Row(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         children: [
              //           Text('👑', style: TextStyle(fontSize: crownSize)),
              //           SizedBox(width: isSmall ? 7 : 12),
              //           Expanded(
              //             child: Column(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               mainAxisSize: MainAxisSize.min,
              //               children: [
              //                 Text(
              //                   lang.settingsUpgrade,
              //                   maxLines: 2,
              //                   overflow: TextOverflow.ellipsis,
              //                   style: TextStyle(
              //                     color: Colors.white,
              //                     fontSize: titleSize,
              //                     fontWeight: FontWeight.bold,
              //                   ),
              //                 ),
              //                 const SizedBox(height: 3),
              //                 Text(
              //                   lang.settingsPremiumSutitle,
              //                   maxLines: isSmall ? 2 : 3,
              //                   overflow: TextOverflow.ellipsis,
              //                   style: TextStyle(
              //                     color: const Color(0xFFAAAAAA),
              //                     fontSize: subtitleSize,
              //                     height: 1.3,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //           SizedBox(width: isSmall ? 6 : 12),
              //           ElevatedButton(
              //             onPressed: () {},
              //             style: ElevatedButton.styleFrom(
              //               backgroundColor: const Color(0xFF6C5CE7),
              //               foregroundColor: Colors.white,
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(12),
              //               ),
              //               padding: EdgeInsets.symmetric(
              //                 horizontal: isSmall ? 10 : 20,
              //                 vertical: isSmall ? 8 : 12,
              //               ),
              //               minimumSize: Size.zero,
              //               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //               elevation: 0,
              //             ),
              //             child: Text(
              //               lang.upgrade,
              //               maxLines: 1,
              //               overflow: TextOverflow.ellipsis,
              //               style: TextStyle(
              //                 fontSize: buttonFontSize,
              //                 fontWeight: FontWeight.w600,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              SizedBox(height: isSmall ? 12 : 18),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Container(
                  width: double.infinity,
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
                        isSmall: isSmall,
                      ),
                      const Divider(height: 1, indent: 52, endIndent: 16),
                      _buildMenuTile(
                        icon: Icons.chat_bubble_outline,
                        label: lang.settingsLabel2,
                        isSmall: isSmall,
                      ),
                      const Divider(height: 1, indent: 52, endIndent: 16),
                      _buildMenuTile(
                        icon: Icons.headset_mic_outlined,
                        label: lang.settingsLabel3,
                        onTap: () => Get.to(() => HelpAndSupportScreen()),
                        isSmall: isSmall,
                      ),
                      const Divider(height: 1, indent: 52, endIndent: 16),
                      _buildMenuTile(
                        icon: Icons.star_outline,
                        label: lang.settingsLabel4,
                        isSmall: isSmall,
                      ),
                      const Divider(height: 1, indent: 52, endIndent: 16),
                      _buildMenuTile(
                        icon: Icons.info_outline,
                        label: lang.settingsLabel5,
                        isLast: true,
                        onTap: () => Get.to(() => AboutScreen()),
                        isSmall: isSmall,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: isSmall
                    ? 30
                    : isTablet
                    ? 60
                    : 40,
              ),
              // Padding(
              //   padding: EdgeInsets.fromLTRB(
              //     horizontalPadding,
              //     0,
              //     horizontalPadding,
              //     20,
              //   ),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: isSmall ? 48 : 54,
              //     child: ElevatedButton(
              //       onPressed: () {},
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: const Color(0xFFE8453C),
              //         foregroundColor: Colors.white,
              //         shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(16),
              //         ),
              //         elevation: 0,
              //       ),
              //       child: Text(
              //         lang.settingsLogout,
              //         maxLines: 1,
              //         overflow: TextOverflow.ellipsis,
              //         style: TextStyle(
              //           fontSize: isSmall ? 14 : 16,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String label,
    bool isFirst = false,
    bool isLast = false,
    VoidCallback? onTap,
    bool isSmall = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 13 : 16,
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF888888), size: isSmall ? 20 : 22),
            SizedBox(width: isSmall ? 10 : 14),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isSmall ? 13 : 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1A1A1A),
                ),
              ),
            ),
            SizedBox(width: isSmall ? 4 : 8),
            const Icon(Icons.chevron_right, color: Color(0xFFBBBBBB), size: 22),
          ],
        ),
      ),
    );
  }
}

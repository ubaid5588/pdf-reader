import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/core/theme/theme_controller.dart';
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
    final colors = context.colors;
    final themeController = Get.find<ThemeController>();

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

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: isSmall ? 20 : 30),
          child: Column(
            children: [
              SizedBox(height: isSmall ? 12 : 18),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.border, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: colors.cardShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Theme Switcher Tile
                      Obx(() {
                        String currentModeLabel = lang.systemTheme;
                        IconData modeIcon = Icons.brightness_auto_outlined;
                        if (themeController.themeMode.value ==
                            ThemeMode.light) {
                          currentModeLabel = lang.lightTheme;
                          modeIcon = Icons.light_mode_outlined;
                        } else if (themeController.themeMode.value ==
                            ThemeMode.dark) {
                          currentModeLabel = lang.darkTheme;
                          modeIcon = Icons.dark_mode_outlined;
                        }

                        return _buildMenuTile(
                          context: context,
                          icon: modeIcon,
                          label: lang.theme,
                          trailingText: currentModeLabel,
                          isFirst: true,
                          onTap: () =>
                              _showThemeSelectionDialog(context, lang, themeController),
                          isSmall: isSmall,
                        );
                      }),
                      Divider(
                        height: 1,
                        indent: 52,
                        endIndent: 16,
                        color: colors.divider,
                      ),
                      _buildMenuTile(
                        context: context,
                        icon: Icons.language,
                        label: lang.settingsLabel1,
                        onTap: () => Get.to(() => LanguageSelectionScreen()),
                        isSmall: isSmall,
                      ),
                      Divider(
                        height: 1,
                        indent: 52,
                        endIndent: 16,
                        color: colors.divider,
                      ),
                      _buildMenuTile(
                        context: context,
                        icon: Icons.chat_bubble_outline,
                        label: lang.settingsLabel2,
                        isSmall: isSmall,
                      ),
                      Divider(
                        height: 1,
                        indent: 52,
                        endIndent: 16,
                        color: colors.divider,
                      ),
                      _buildMenuTile(
                        context: context,
                        icon: Icons.headset_mic_outlined,
                        label: lang.settingsLabel3,
                        onTap: () => Get.to(() => HelpAndSupportScreen()),
                        isSmall: isSmall,
                      ),
                      Divider(
                        height: 1,
                        indent: 52,
                        endIndent: 16,
                        color: colors.divider,
                      ),
                      _buildMenuTile(
                        context: context,
                        icon: Icons.star_outline,
                        label: lang.settingsLabel4,
                        isSmall: isSmall,
                      ),
                      Divider(
                        height: 1,
                        indent: 52,
                        endIndent: 16,
                        color: colors.divider,
                      ),
                      _buildMenuTile(
                        context: context,
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    String? trailingText,
    bool isFirst = false,
    bool isLast = false,
    VoidCallback? onTap,
    bool isSmall = false,
  }) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 12 : 16,
          vertical: isSmall ? 13 : 16,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: colors.primary,
              size: isSmall ? 20 : 22,
            ),
            SizedBox(width: isSmall ? 10 : 14),
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isSmall ? 13 : 15,
                  fontWeight: FontWeight.w500,
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: isSmall ? 12 : 13,
                  fontWeight: FontWeight.w500,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
            ],
            SizedBox(width: isSmall ? 4 : 8),
            Icon(
              Icons.chevron_right,
              color: colors.textSecondary.withOpacity(0.5),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelectionDialog(
    BuildContext context,
    AppLocalizations lang,
    ThemeController themeController,
  ) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.textSecondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lang.chooseTheme,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildThemeOption(
                  context: ctx,
                  icon: Icons.brightness_auto_rounded,
                  title: lang.systemTheme,
                  subtitle: 'Match system theme settings',
                  isSelected: themeController.themeMode.value == ThemeMode.system,
                  onTap: () {
                    themeController.setThemeMode(ThemeMode.system);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  context: ctx,
                  icon: Icons.light_mode_rounded,
                  title: lang.lightTheme,
                  subtitle: 'Crisp, bright appearance',
                  isSelected: themeController.themeMode.value == ThemeMode.light,
                  onTap: () {
                    themeController.setThemeMode(ThemeMode.light);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  context: ctx,
                  icon: Icons.dark_mode_rounded,
                  title: lang.darkTheme,
                  subtitle: 'Modern, soft contrast dark palette',
                  isSelected: themeController.themeMode.value == ThemeMode.dark,
                  onTap: () {
                    themeController.setThemeMode(ThemeMode.dark);
                    Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withOpacity(0.2)
                    : colors.surfaceSecondary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? colors.primary : colors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? colors.primary : colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: colors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

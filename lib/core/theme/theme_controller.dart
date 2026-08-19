import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

enum AppThemeMode { system, light, dark }

class ThemeController extends GetxController {
  static const String _boxName = 'settings';
  static const String _key = 'theme_mode';

  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedTheme();
  }

  void _loadSavedTheme() {
    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box(_boxName);
        final String? saved = box.get(_key) as String?;
        if (saved != null) {
          switch (saved) {
            case 'light':
              themeMode.value = ThemeMode.light;
              break;
            case 'dark':
              themeMode.value = ThemeMode.dark;
              break;
            default:
              themeMode.value = ThemeMode.system;
              break;
          }
        }
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);

    try {
      if (Hive.isBoxOpen(_boxName)) {
        final box = Hive.box(_boxName);
        String value = 'system';
        if (mode == ThemeMode.light) {
          value = 'light';
        } else if (mode == ThemeMode.dark) {
          value = 'dark';
        }
        await box.put(_key, value);
      }
    } catch (_) {}
  }

  String get currentThemeName {
    switch (themeMode.value) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

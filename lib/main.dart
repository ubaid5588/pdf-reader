import 'package:file_reader/core/theme/app_theme.dart';
import 'package:file_reader/core/theme/theme_controller.dart';
import 'package:file_reader/features/splash/view/splash_page.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  await Hive.openBox('recent_pdfs');
  final settings = Hive.box('settings');
  final String languageCode = settings.get('localization') ?? 'en';
  Get.put(ThemeController());
  runApp(Main(languageCode: languageCode));
}

class Main extends StatelessWidget {
  final String languageCode;
  Main({super.key, required this.languageCode});

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'File Reader',
        locale: Locale(languageCode),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode.value,
        initialRoute: '/',
        getPages: [GetPage(name: '/', page: () => SplashPage())],
        unknownRoute: GetPage(name: '/', page: () => SplashPage()),
      );
    });
  }
}

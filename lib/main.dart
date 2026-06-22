import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_reader/features/splash/view/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  final settings = Hive.box('settings');
  final String languageCode = settings.get('localization') ?? 'en';
  runApp(Main(languageCode: languageCode));
}

class Main extends StatelessWidget {
  final String languageCode;
  Main({super.key, required this.languageCode});

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'File Reader',
      locale: Locale(languageCode),
      supportedLocales: const [Locale('en'), Locale('ur')],

      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF2F3F7),
      ),
      initialRoute: '/',
      getPages: [GetPage(name: '/', page: () => SplashPage())],
      unknownRoute: GetPage(name: '/', page: () => SplashPage()),
      // home: SplashPage(),
    );
  }
}

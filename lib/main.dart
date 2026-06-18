import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:file_reader/features/splash/view/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
  runApp(Main());
}

class Main extends StatelessWidget {
  Main({super.key});

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'File Reader',
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

import 'package:file_reader/features/splash/controller/splash_controller.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Get.put(SplashController());
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(40, 217, 0, 255),
              const Color.fromARGB(40, 0, 17, 255),
            ],
            begin: AlignmentGeometry.topLeft,
            end: AlignmentGeometry.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        height: screenSize.height,
        width: screenSize.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenSize.height * 0.34),
            Image.asset(
              'assets/images/logo.png',
              width: screenSize.width * 0.2,
            ),
            SizedBox(height: screenSize.height * 0.01),

            Text(
              'Pdf Reader',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),

            Text(
              AppLocalizations.of(context)!.splashAppTitle,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: Colors.black,
              ),
            ),
            Spacer(),
            SizedBox(child: LinearProgressIndicator()),
            SizedBox(height: screenSize.height * 0.01),
          ],
        ),
      ),
    );
  }
}

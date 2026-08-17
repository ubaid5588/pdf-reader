import 'package:file_reader/features/splash/controller/splash_controller.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _loadingProgress;

  @override
  void initState() {
    super.initState();
    Get.put(SplashController());

    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    // Logo animation: scale and fade in
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Title slide down animation
    _titleSlide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
          ),
        );

    // Subtitle slide down animation (delayed)
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
          ),
        );

    // Loading progress animation
    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 0, 42, 168),
              const Color.fromARGB(255, 44, 88, 210), // Deep blue
              const Color(0xFF7C3AED), // Purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        width: screenSize.width,
        height: screenSize.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenSize.height * 0.35),

            // Animated Logo
            ScaleTransition(
              scale: _logoScale,
              child: FadeTransition(
                opacity: _logoOpacity,
                child: Container(
                  width: screenSize.width * 0.25,
                  height: screenSize.width * 0.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7C3AED).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            SizedBox(height: screenSize.height * 0.02),

            // Animated Title
            SlideTransition(
              position: _titleSlide,
              child: FadeTransition(
                opacity: _logoOpacity,
                child: Text(
                  'Pdf Reader',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: screenSize.width * 0.08,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            SizedBox(height: screenSize.height * 0.005),

            // Animated Subtitle
            SlideTransition(
              position: _subtitleSlide,
              child: FadeTransition(
                opacity: _logoOpacity,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.width * 0.1,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.splashAppTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: screenSize.width * 0.045,
                      color: Colors.white.withOpacity(0.85),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Animated Loading Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.20,
                vertical: screenSize.height * 0.05,
              ),
              child: AnimatedBuilder(
                animation: _loadingProgress,
                builder: (context, child) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _loadingProgress.value,
                          minHeight: 6,

                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                      // SizedBox(height: screenSize.height * 0.02),
                      // Text(
                      //   '${(_loadingProgress.value * 100).toInt()}%',
                      //   style: TextStyle(
                      //     fontSize: screenSize.width * 0.03,
                      //     color: Colors.white.withOpacity(0.6),
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

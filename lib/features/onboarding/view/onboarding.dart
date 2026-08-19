import 'package:file_reader/core/widgets/custom_button.dart';
import 'package:file_reader/features/onboarding/controller/onboarding_controller.dart';
import 'package:file_reader/features/onboarding/model/onboarding_model.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late OnboardingController controller;

  @override
  void initState() {
    super.initState();

    controller = Get.put(OnboardingController());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    // Restart animation whenever page changes
    controller.currentPage.listen((_) {
      if (mounted) {
        _animationController.forward(from: 0.0);
      }
    });

    // Initial animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = AppLocalizations.of(context)!;
    // final screenSize = MediaQuery.of(context).size;/

    final List<OnboardingModel> onboardingPages = [
      OnboardingModel(
        title: language.onBoardingTitle1,
        subtitle: language.onBoardingSubtitle1,
        image: 'assets/images/Onboarding.png',
      ),
      OnboardingModel(
        title: language.onBoardingTitle2,
        subtitle: language.onBoardingSubtitle2,
        image: 'assets/images/Onboarding2.png',
      ),
      OnboardingModel(
        title: language.onBoardingTitle3,
        subtitle: language.onBoardingSubtitle3,
        image: 'assets/images/Onboarding3.png',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Spacer(),
                GestureDetector(
                  onTap: controller.onSkip,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 0.2,
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                        ),
                      ],
                    ),

                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        language.onBoardingSkip,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF5B5CFF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // =========================
            // ONBOARDING CONTENT
            // =========================
            Expanded(
              child: Obx(() {
                final currentIndex = controller.currentPage.value;

                return AnimatedContent(
                  animationController: _animationController,
                  model: onboardingPages[currentIndex],
                );
              }),
            ),

            // =========================
            // BOTTOM NAVIGATION & BUTTON
            // =========================
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: Colors.white),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        child: Column(
          children: [
            // =========================
            // DOT INDICATOR
            // =========================
            Obx(() {
              final currentPage = controller.currentPage.value;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  final isActive = index == currentPage;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 25 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF5B5CFF)
                          : const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              );
            }),

            const SizedBox(height: 32),

            // =========================
            // NEXT / GET STARTED BUTTON
            // =========================
            Obx(() {
              final isLastPage = controller.currentPage.value == 2;
              return CustomButton(
                text: isLastPage ? 'Get Started' : 'Next',
                width: MediaQuery.of(context).size.width * 0.85,
                onPressed: controller.onComplete,
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ANIMATED ONBOARDING CONTENT
// ============================================================

class AnimatedContent extends StatelessWidget {
  final AnimationController animationController;
  final OnboardingModel model;

  const AnimatedContent({
    super.key,
    required this.animationController,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        // ======================================================
        // IMAGE ANIMATION
        // ======================================================

        final imageScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(
            parent: animationController,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
          ),
        );

        final imageOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
            .animate(
              CurvedAnimation(
                parent: animationController,
                curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
              ),
            );

        final glowAnimation = Tween<double>(begin: 0.0, end: 20.0).animate(
          CurvedAnimation(
            parent: animationController,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
          ),
        );

        // ======================================================
        // TITLE ANIMATION
        // ======================================================

        final titleOffsetAnimation =
            Tween<Offset>(
              begin: const Offset(0, -0.8),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animationController,
                curve: const Interval(0.25, 0.70, curve: Curves.easeOut),
              ),
            );

        final titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
            .animate(
              CurvedAnimation(
                parent: animationController,
                curve: const Interval(0.25, 0.65, curve: Curves.easeIn),
              ),
            );

        // ======================================================
        // SUBTITLE ANIMATION
        // ======================================================

        final subtitleOffsetAnimation =
            Tween<Offset>(
              begin: const Offset(0, -0.6),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animationController,
                curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
              ),
            );

        final subtitleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
            .animate(
              CurvedAnimation(
                parent: animationController,
                curve: const Interval(0.45, 0.90, curve: Curves.easeIn),
              ),
            );

        // ======================================================
        // CONTENT
        // ======================================================

        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: height * 0.13),

              // ==================================================
              // IMAGE WITH GLOW CONTAINER
              // ==================================================
              AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  final glowProgress = (glowAnimation.value / 20.0).clamp(
                    0.0,
                    1.0,
                  );

                  return Opacity(
                    opacity: imageOpacityAnimation.value,
                    child: Transform.scale(
                      scale: imageScaleAnimation.value,
                      child: Container(
                        width: width * 0.75,
                        height: height * 0.483,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(
                                0xFF5B5CFF,
                              ).withOpacity(0.15 * glowProgress),
                              const Color(
                                0xFF8B5CF6,
                              ).withOpacity(0.12 * glowProgress),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF5B5CFF,
                              ).withOpacity(0.25 * glowProgress),
                              blurRadius: glowAnimation.value * 1.5,
                              spreadRadius: glowAnimation.value * 0.5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.asset(
                              model.image,
                              width: width * 0.68,
                              height: height * 0.44,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: height * 0.04),

              // ==================================================
              // TITLE
              // ==================================================
              AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: titleOpacityAnimation.value,
                    child: SlideTransition(
                      position: titleOffsetAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          model.title,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: "Archivo",
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: height * 0.02),

              // ==================================================
              // SUBTITLE
              // ==================================================
              AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: subtitleOpacityAnimation.value,
                    child: SlideTransition(
                      position: subtitleOffsetAnimation,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: width * 0.88),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),

                          child: Text(
                            model.subtitle,
                            textAlign: TextAlign.center,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: "Archivo",
                              fontSize: 15,
                              color: Color(0xFF6B7280),
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: height * 0.06),
            ],
          ),
        );
      },
    );
  }
}

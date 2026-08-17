import 'dart:async';
import 'dart:io';

import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/features/file/view/file_page.dart';
import 'package:file_reader/features/pdf_viewer/controller/file_view_controller.dart';
import 'package:file_reader/features/home/controller/navi_controller.dart';
import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:file_reader/features/setting/view/setting_page.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:file_reader/features/home/view/home_page_view.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FileViewController _controller = Get.put(FileViewController());
  final NaviController naviController = Get.put(NaviController());
  final FilePageController fileController = Get.put(FilePageController());

  StreamSubscription<List<SharedFile>>? _intentSub;

  static const MethodChannel _fileChannel = MethodChannel('app/openfile');

  @override
  void initState() {
    super.initState();

    _fileChannel.setMethodCallHandler((call) async {
      if (call.method == 'openFile') {
        final path = call.arguments as String;
        await _openFile(path);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _handleIntent();

      try {
        final initialPath = await _fileChannel.invokeMethod<String>(
          'getInitialFile',
        );

        if (mounted && initialPath != null) {
          await _openFile(initialPath);
        }
      } catch (e) {
        debugPrint('getInitialFile error: $e');
      }
    });

    _intentSub = FlutterSharingIntent.instance.getMediaStream().listen((
      files,
    ) async {
      if (!mounted || files.isEmpty) return;

      final uri = files.first.value;

      if (uri == null || uri.isEmpty) return;

      await _openFile(uri);
    });
  }

  Future<void> _handleIntent() async {
    try {
      final files = await _controller.getInitialFiles();

      if (!mounted || files.isEmpty) return;

      final uri = files.first.value;

      if (uri == null || uri.isEmpty) return;

      await _openFile(uri);
    } catch (e) {
      debugPrint('Handle intent error: $e');
    }
  }

  Future<void> _openFile(String uri) async {
    try {
      final Uint8List bytes = await _controller.getPdfBytes(uri);

      if (!mounted) return;

      Get.to(() => PdfViewer(filePath: bytes));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _intentSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        final bool isSmallPhone = width < 360;
        final bool isTablet = width >= 600;

        final double topBarHeight = isSmallPhone
            ? 58
            : isTablet
            ? 72
            : 64;

        final double bottomBarHeight = Platform.isIOS
            ? (isSmallPhone ? 68 : 76)
            : (isSmallPhone ? 60 : 66);

        final double horizontalMargin = isSmallPhone
            ? 8
            : isTablet
            ? 24
            : 10;

        final double bottomMargin = isSmallPhone ? 8 : 16;

        return Scaffold(
          body: SafeArea(
            top: true,
            bottom: false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: topBarHeight,
                      bottom: bottomBarHeight + bottomMargin + 8,
                    ),
                    child: Obx(() {
                      final List<Widget> screens = [
                        const HomePageView(),
                        FilePage(),
                        const SettingPage(),
                      ];

                      return IndexedStack(
                        index: naviController.selectedIndex.value,
                        children: screens,
                      );
                    }),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: buildTopBar(context, width, lang.upgrade),
                ),

                Positioned(
                  bottom: bottomMargin,
                  left: horizontalMargin,
                  right: horizontalMargin,
                  child: _buildBottomNavigation(
                    context,
                    width,
                    bottomBarHeight,
                    lang,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    double width,
    double height,
    AppLocalizations lang,
  ) {
    final bool isSmallPhone = width < 360;
    final bool isTablet = width >= 600;

    final double iconSize = isSmallPhone
        ? 21
        : isTablet
        ? 25
        : 23;

    final double fontSize = isSmallPhone
        ? 10
        : isTablet
        ? 12
        : 11;

    return Container(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.symmetric(
        horizontal: isSmallPhone ? 6 : 10,
        vertical: isSmallPhone ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Platform.isIOS
            ? const Color.fromARGB(235, 252, 252, 252)
            : const Color.fromARGB(235, 252, 252, 252),
        borderRadius: BorderRadius.circular(isSmallPhone ? 28 : 35),
        border: Border.all(
          color: const Color.fromARGB(20, 101, 92, 92),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: navItem(
              Icons.home_rounded,
              lang.home,
              0,
              iconSize,
              fontSize,
            ),
          ),
          Expanded(
            child: navItem(Icons.folder, lang.files, 1, iconSize, fontSize),
          ),
          Expanded(
            child: navItem(
              Icons.settings,
              lang.settings,
              2,
              iconSize,
              fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget navItem(
    IconData icon,
    String label,
    int index,
    double iconSize,
    double fontSize,
  ) {
    return Obx(() {
      final bool isSelected = naviController.selectedIndex.value == index;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          naviController.changePage(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          constraints: const BoxConstraints(minHeight: 45),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color.fromARGB(35, 108, 78, 245)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isSelected ? iconSize + 1 : iconSize,
                color: isSelected
                    ? const Color(0xFF6C4EF5)
                    : const Color(0xFFAAAAAA),
              ),

              const SizedBox(height: 1),

              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF6C4EF5)
                        : const Color(0xFFAAAAAA),
                    fontSize: fontSize,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildTopBar(BuildContext context, double width, String upgrade) {
    final bool isSmallPhone = width < 360;
    final bool isTablet = width >= 600;

    final double logoSize = isSmallPhone
        ? 28
        : isTablet
        ? 38
        : 32;

    final double titleSize = isSmallPhone
        ? 18
        : isTablet
        ? 24
        : 22;

    final double horizontalPadding = isSmallPhone
        ? 10
        : isTablet
        ? 24
        : 16;

    return Container(
      width: double.infinity,
      color: const Color.fromARGB(120, 255, 246, 246),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isSmallPhone ? 8 : 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: logoSize,
                  height: logoSize,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),

                SizedBox(width: isSmallPhone ? 5 : 8),

                Flexible(
                  child: Text(
                    'Pdf Reader',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // const SizedBox(width: 8),

          // Flexible(
          //   flex: 0,
          //   child: Container(
          //     constraints: BoxConstraints(
          //       maxWidth: isSmallPhone
          //           ? 105
          //           : isTablet
          //           ? 150
          //           : 125,
          //     ),
          //     padding: EdgeInsets.symmetric(
          //       horizontal: isSmallPhone ? 8 : 12,
          //       vertical: isSmallPhone ? 5 : 6,
          //     ),
          //     decoration: BoxDecoration(
          //       color: const Color.fromARGB(64, 255, 255, 255),
          //       borderRadius: BorderRadius.circular(20),
          //       border: Border.all(color: const Color(0xFFFFD700), width: 1),
          //     ),
          //     child: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         const Icon(Icons.star, color: Color(0xFFFFC107), size: 14),

          //         // const SizedBox(width: 4),

          //         // Flexible(
          //         //   child: Text(
          //         //     upgrade,
          //         //     maxLines: 1,
          //         //     overflow: TextOverflow.ellipsis,
          //         //     style: TextStyle(
          //         //       color: const Color(0xFFB8860B),
          //         //       fontWeight: FontWeight.w600,
          //         //       fontSize: isSmallPhone ? 10 : 12,
          //         //     ),
          //         //   ),
          //         // ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

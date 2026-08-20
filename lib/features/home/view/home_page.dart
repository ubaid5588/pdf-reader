import 'dart:async';
import 'dart:ui' as ui;

import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/features/file/view/file_page.dart';
import 'package:file_reader/features/home/controller/navi_controller.dart';
import 'package:file_reader/features/home/view/home_page_view.dart';
import 'package:file_reader/features/pdf_viewer/controller/file_view_controller.dart';
import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:file_reader/features/setting/view/setting_page.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
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
  final RecentPdfController recentPdfController = Get.put(
    RecentPdfController(),
  );

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
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isSmallPhone = width < 360;
        final bool isTablet = width >= 600;

        final double topBarHeight = isSmallPhone
            ? 78
            : isTablet
            ? 88
            : 52;
        final double bottomBarHeight = isSmallPhone
            ? 64
            : isTablet
            ? 72
            : 68;

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            top: true,
            bottom: false,
            child: Stack(
              children: [
                // Content - extends full height under navigation
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(top: topBarHeight),
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

                // Top Bar
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: buildTopBar(context, width, lang),
                ),

                // Bottom Navigation - Overlay on top with center positioning
                Positioned(
                  bottom: isSmallPhone ? 16 : 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _buildBottomNavigation(
                      context,
                      width,
                      bottomBarHeight,
                      lang,
                    ),
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
    final colors = context.colors;
    final bool isSmallPhone = width < 360;
    final bool isTablet = width >= 600;

    final double navWidth = width * 0.7;

    final double iconSize = isSmallPhone
        ? 22
        : isTablet
        ? 26
        : 24;
    final double fontSize = isSmallPhone
        ? 9.5
        : isTablet
        ? 11.5
        : 10.5;
    final double horizontalPadding = isSmallPhone ? 10 : 4;
    final double verticalPadding = isSmallPhone ? 8 : 2;

    return ClipRRect(
      borderRadius: BorderRadius.circular(isSmallPhone ? 24 : 35),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: navWidth,
          height: height,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: colors.bottomNavBg,
            borderRadius: BorderRadius.circular(isSmallPhone ? 24 : 50),
            border: Border.all(color: colors.bottomNavBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: colors.cardShadow,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: navItem(
                  context,
                  Icons.home_rounded,
                  lang.home,
                  0,
                  iconSize,
                  fontSize,
                  isSmallPhone,
                ),
              ),
              Expanded(
                child: navItem(
                  context,
                  Icons.folder_outlined,
                  lang.files,
                  1,
                  iconSize,
                  fontSize,
                  isSmallPhone,
                ),
              ),
              Expanded(
                child: navItem(
                  context,
                  Icons.settings_outlined,
                  lang.settings,
                  2,
                  iconSize,
                  fontSize,
                  isSmallPhone,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget navItem(
    BuildContext context,
    IconData icon,
    String label,
    int index,
    double iconSize,
    double fontSize,
    bool isSmallPhone,
  ) {
    final colors = context.colors;

    return Obx(() {
      final bool isSelected = naviController.selectedIndex.value == index;

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          naviController.changePage(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallPhone ? 6 : 8,
            vertical: isSmallPhone ? 4 : 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: isSelected
                ? Border.all(color: colors.primary.withOpacity(0.4), width: 1.2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: isSelected ? colors.primary : colors.textSecondary,
              ),
              SizedBox(height: isSmallPhone ? 2 : 3),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? colors.primary : colors.textSecondary,
                    fontSize: fontSize,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildTopBar(
    BuildContext context,
    double width,
    AppLocalizations lang,
  ) {
    final colors = context.colors;
    final bool isSmallPhone = width < 360;
    final bool isTablet = width >= 600;

    final double logoSize = isSmallPhone
        ? 34
        : isTablet
        ? 42
        : 38;
    final double titleSize = isSmallPhone
        ? 16.5
        : isTablet
        ? 22
        : 19;
    final double subtitleSize = isSmallPhone
        ? 10.5
        : isTablet
        ? 12.5
        : 11.5;
    final double horizontalPadding = isSmallPhone
        ? 10
        : isTablet
        ? 24
        : 14;
    final double verticalPadding = isSmallPhone ? 8 : 10;

    return Container(
      width: double.infinity,
      color: colors.topBarBg,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Row(
        children: [
          // Logo
          SizedBox(
            width: logoSize,
            height: logoSize,
            child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
          ),

          SizedBox(width: isSmallPhone ? 6 : 10),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PDF Reader',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),

                Text(
                  'Your document hub',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: subtitleSize,
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/features/file/view/file_page.dart';
import 'package:file_reader/features/pdf_viewer/controller/file_view_controller.dart';
import 'package:file_reader/features/home/controller/navi_controller.dart';
import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:file_reader/features/setting/view/setting_paage.dart';
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
      if (uri == null) return;
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
      Uint8List bytes = await _controller.getPdfBytes(uri);

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
    final Size screenSize = MediaQuery.of(context).size;
    final List<Widget> screens = [HomePageView(), FilePage(), SettingPaage()];
    final lang = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: Stack(
          children: [
            Obx(
              (() => Column(
                children: [
                  SizedBox(height: 70),
                  Expanded(child: screens[naviController.selectedIndex.value]),
                ],
              )),
            ),

            buildTopBar(screenSize, lang.upgrade),
            Positioned(
              bottom: 16,
              left: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(12),
                width: screenSize.width,
                height: Platform.isIOS ? 76 : 64,
                decoration: BoxDecoration(
                  color: Platform.isIOS
                      ? const Color.fromARGB(120, 252, 252, 252)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(
                    color: Color.fromARGB(9, 101, 92, 92),
                    width: 1.3,
                  ),
                  // Border(

                  //   top: BorderSide(color: Color(0xFFEEEEEE), width: 4.5),
                  // ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    navItem(Icons.home_rounded, lang.home, 0),
                    navItem(Icons.folder, lang.files, 1),
                    navItem(Icons.settings, lang.settings, 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget navItem(IconData icon, String label, int index) {
    return Obx(() {
      final isSelected = naviController.selectedIndex.value == index;

      return GestureDetector(
        onTap: () => naviController.changePage(index),
        child: Container(
          decoration: isSelected
              ? BoxDecoration(
                  color: const Color.fromARGB(50, 253, 240, 240),
                  borderRadius: BorderRadius.circular(30),
                )
              : BoxDecoration(),
          child: Column(
            children: [
              Icon(
                icon,
                size: isSelected ? 25 : 23,
                color: isSelected
                    ? const Color(0xFF6C4EF5)
                    : const Color(0xFFAAAAAA),
              ),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF6C4EF5)
                      : const Color(0xFFAAAAAA),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildTopBar(Size screenSize, String upgrade) {
    return Column(
      children: [
        Container(
          color: const Color.fromARGB(120, 255, 246, 246),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: screenSize.width * 0.1,
                      child: Image.asset('assets/images/logo.png'),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Pdf Reader',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(64, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Color(0xFFFFC107), size: 14),
                      SizedBox(width: 4),
                      Text(
                        upgrade,
                        style: TextStyle(
                          color: Color(0xFFB8860B),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

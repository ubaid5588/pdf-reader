import 'dart:io';
import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/scan_pdf/controller/scan_pdf_controller.dart';
import 'package:file_reader/features/scan_pdf/view/crop_mode_dialog.dart';
import 'package:file_reader/features/scan_pdf/view/document_crop_page.dart';
import 'package:file_reader/features/scan_pdf/view/quit_scan_dialog.dart';
import 'package:file_reader/features/scan_pdf/view/scan_gallery_picker_page.dart';
import 'package:file_reader/features/scan_pdf/view/scan_queue_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentCameraPage extends StatefulWidget {
  const DocumentCameraPage({super.key});

  @override
  State<DocumentCameraPage> createState() => _DocumentCameraPageState();
}

class _DocumentCameraPageState extends State<DocumentCameraPage>
    with SingleTickerProviderStateMixin {
  late final ScanPdfController controller;
  bool _isBatchMode = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ScanPdfController>()
        ? Get.find<ScanPdfController>()
        : Get.put(ScanPdfController());
  }

  Future<void> _handleCapture() async {
    final imagePath = await controller.captureFromCamera();
    if (imagePath == null) return;

    // Check crop mode dialog if first time and not opted out
    if (!controller.dontAskCropModeAgain.value) {
      await CropModeDialog.show(context);
    }

    final item = await controller.addScannedImage(imagePath);

    if (!_isBatchMode) {
      Get.to(() => DocumentCropPage(pageId: item.id));
    }
  }

  void _onOpenGallery() async {
    final paths = await controller.pickImagesFromGallery();
    if (paths.isNotEmpty) {
      if (!controller.dontAskCropModeAgain.value) {
        await CropModeDialog.show(context);
      }
      for (final p in paths) {
        await controller.addScannedImage(p);
      }
      if (paths.length == 1) {
        final last = controller.scannedPages.last;
        Get.to(() => DocumentCropPage(pageId: last.id));
      } else {
        Get.to(() => const ScanQueuePage());
      }
    }
  }

  void _proceedToQueue() {
    if (controller.scannedPages.isNotEmpty) {
      Get.to(() => const ScanQueuePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (controller.scannedPages.isNotEmpty) {
          final shouldQuit = await QuitScanDialog.show(context);
          if (shouldQuit) {
            controller.clearQueue();
            Get.back();
          }
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Camera Viewfinder & Document Corner Framing Guides
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F172A),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Viewfinder Center Overlay
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1,
                          ),
                        ),
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: _DocumentFramingGuidePainter(),
                        ),
                      ),

                      // Hint Text
                      Positioned(
                        top: 70,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.crop_free_rounded, color: Color(0xFF38BDF8), size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Align document inside the frame',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Top Bar Controls
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.black.withOpacity(0.4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                        onPressed: () async {
                          if (controller.scannedPages.isNotEmpty) {
                            final shouldQuit = await QuitScanDialog.show(context);
                            if (shouldQuit) {
                              controller.clearQueue();
                              Get.back();
                            }
                          } else {
                            Get.back();
                          }
                        },
                      ),

                      // Single / Batch Mode Toggle Switch
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => setState(() => _isBatchMode = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: !_isBatchMode
                                      ? const Color(0xFF2563EB)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Single',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: !_isBatchMode ? Colors.white : Colors.white60,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _isBatchMode = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: _isBatchMode
                                      ? const Color(0xFF2563EB)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Batch',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _isBatchMode ? Colors.white : Colors.white60,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        icon: Icon(
                          _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          color: _isFlashOn ? const Color(0xFFFACC15) : Colors.white,
                          size: 24,
                        ),
                        onPressed: () => setState(() => _isFlashOn = !_isFlashOn),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Bottom Control Bar (Gallery, Shutter Button, Batch Queue Badge)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                  color: Colors.black.withOpacity(0.65),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left: Device Gallery Shortcut
                      GestureDetector(
                        onTap: _onOpenGallery,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.photo_library_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),

                      // Center: Prominent Circular Shutter Button
                      GestureDetector(
                        onTap: _handleCapture,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),

                      // Right: Queue Counter Badge or Done
                      Obx(() {
                        final count = controller.scannedPages.length;
                        final lastPage = controller.scannedPages.isNotEmpty
                            ? controller.scannedPages.last
                            : null;

                        if (count == 0) {
                          return const SizedBox(width: 50, height: 50);
                        }

                        return GestureDetector(
                          onTap: _proceedToQueue,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF38BDF8), width: 2),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              children: [
                                if (lastPage != null)
                                  Positioned.fill(
                                    child: Image.file(
                                      File(lastPage.displayPath),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2563EB),
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(8)),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentFramingGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 28.0;

    // Top Left
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top Right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom Right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);

    // Bottom Left
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

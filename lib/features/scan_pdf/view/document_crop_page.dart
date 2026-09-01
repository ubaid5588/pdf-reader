import 'dart:io';
import 'dart:math' as math;
import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/scan_pdf/controller/scan_pdf_controller.dart';
import 'package:file_reader/features/scan_pdf/model/scanned_page_item.dart';
import 'package:file_reader/features/scan_pdf/view/document_preview_edit_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DocumentCropPage extends StatefulWidget {
  final String pageId;

  const DocumentCropPage({super.key, required this.pageId});

  @override
  State<DocumentCropPage> createState() => _DocumentCropPageState();
}

class _DocumentCropPageState extends State<DocumentCropPage> {
  final ScanPdfController controller = Get.find<ScanPdfController>();

  late QuadCorners _corners;
  int _rotationDegrees = 0;
  Size? _imageNaturalSize;

  @override
  void initState() {
    super.initState();
    final page = controller.scannedPages.firstWhereOrNull((p) => p.id == widget.pageId);
    if (page != null) {
      _corners = page.corners?.copyWith() ?? QuadCorners.defaultNormalized();
      _rotationDegrees = page.rotationDegrees;
    } else {
      _corners = QuadCorners.defaultNormalized();
    }
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    final page = controller.scannedPages.firstWhereOrNull((p) => p.id == widget.pageId);
    if (page == null) return;

    final image = Image.file(File(page.originalImagePath));
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((info, _) {
        if (mounted) {
          setState(() {
            _imageNaturalSize = Size(
              info.image.width.toDouble(),
              info.image.height.toDouble(),
            );
          });
        }
      }),
    );
  }

  Future<void> _onAutoCrop() async {
    final detected = await controller.autoDetectPageCorners(widget.pageId);
    setState(() {
      _corners = detected;
    });
  }

  void _rotateClockwise() {
    setState(() {
      _rotationDegrees = (_rotationDegrees + 90) % 360;
    });
  }

  void _rotateCounterClockwise() {
    setState(() {
      _rotationDegrees = (_rotationDegrees - 90 + 360) % 360;
    });
  }

  Future<void> _saveAndProceed() async {
    await controller.updatePageProcessing(
      widget.pageId,
      corners: _corners,
      rotationDegrees: _rotationDegrees,
    );

    Get.off(
      () => DocumentPreviewEditPage(pageId: widget.pageId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final pageIndex = controller.scannedPages.indexWhere((p) => p.id == widget.pageId);
    final totalPages = controller.scannedPages.length;
    final page = controller.scannedPages.firstWhereOrNull((p) => p.id == widget.pageId);

    if (page == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(title: const Text('Crop Page')),
        body: const Center(child: Text('Page not found')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Crop Document',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded, color: Color(0xFF38BDF8), size: 26),
            tooltip: 'Confirm Crop',
            onPressed: _saveAndProceed,
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Interactive Crop Viewport
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final viewportWidth = constraints.maxWidth;
                final viewportHeight = constraints.maxHeight;

                if (_imageNaturalSize == null) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                  );
                }

                // Aspect ratio calculation with rotation
                final bool isRotated = _rotationDegrees == 90 || _rotationDegrees == 270;
                final double imgWidth = isRotated ? _imageNaturalSize!.height : _imageNaturalSize!.width;
                final double imgHeight = isRotated ? _imageNaturalSize!.width : _imageNaturalSize!.height;

                final double imgAspect = imgWidth / imgHeight;
                final double viewAspect = viewportWidth / viewportHeight;

                double displayWidth;
                double displayHeight;

                if (imgAspect > viewAspect) {
                  displayWidth = viewportWidth * 0.92;
                  displayHeight = displayWidth / imgAspect;
                } else {
                  displayHeight = viewportHeight * 0.92;
                  displayWidth = displayHeight * imgAspect;
                }

                final double offsetX = (viewportWidth - displayWidth) / 2;
                final double offsetY = (viewportHeight - displayHeight) / 2;
                final Rect imageDisplayRect = Rect.fromLTWH(offsetX, offsetY, displayWidth, displayHeight);

                return Stack(
                  children: [
                    // Render Image with Rotation
                    Positioned.fromRect(
                      rect: imageDisplayRect,
                      child: RotatedBox(
                        quarterTurns: _rotationDegrees ~/ 90,
                        child: Image.file(
                          File(page.originalImagePath),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),

                    // Interactive 8-point overlay
                    Positioned.fromRect(
                      rect: imageDisplayRect,
                      child: _EightPointCropOverlay(
                        corners: _corners,
                        size: Size(displayWidth, displayHeight),
                        onCornersChanged: (newCorners) {
                          setState(() {
                            _corners = newCorners;
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom Page Indicator
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chevron_left_rounded,
                  color: pageIndex > 0 ? Colors.white70 : Colors.white24,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '< ${pageIndex + 1}/$totalPages >',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: pageIndex < totalPages - 1 ? Colors.white70 : Colors.white24,
                  size: 20,
                ),
              ],
            ),
          ),

          // Bottom Toolbar: Left, Right, Auto crop
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.rotate_left_rounded,
                  label: 'Left',
                  onTap: _rotateCounterClockwise,
                ),
                _buildActionButton(
                  icon: Icons.rotate_right_rounded,
                  label: 'Right',
                  onTap: _rotateClockwise,
                ),
                _buildActionButton(
                  icon: Icons.auto_fix_high_rounded,
                  label: 'Auto crop',
                  isHighlighted: true,
                  onTap: _onAutoCrop,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isHighlighted ? const Color(0xFF38BDF8) : Colors.white70,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isHighlighted ? const Color(0xFF38BDF8) : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EightPointCropOverlay extends StatelessWidget {
  final QuadCorners corners;
  final Size size;
  final ValueChanged<QuadCorners> onCornersChanged;

  const _EightPointCropOverlay({
    required this.corners,
    required this.size,
    required this.onCornersChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pixelCorners = corners.toPixels(size);

    // Compute side midpoints
    final topMid = (pixelCorners.topLeft + pixelCorners.topRight) / 2;
    final rightMid = (pixelCorners.topRight + pixelCorners.bottomRight) / 2;
    final bottomMid = (pixelCorners.bottomLeft + pixelCorners.bottomRight) / 2;
    final leftMid = (pixelCorners.topLeft + pixelCorners.bottomLeft) / 2;

    const double nodeRadius = 14.0;
    const double pillWidth = 28.0;
    const double pillHeight = 12.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Custom Painter for bounding box lines, grid, and outer dimming
        Positioned.fill(
          child: CustomPaint(
            painter: _CropBoundingBoxPainter(corners: pixelCorners, size: size),
          ),
        ),

        // 1. Top-Left Corner Anchor
        _buildCornerHandle(
          center: pixelCorners.topLeft,
          radius: nodeRadius,
          onPanUpdate: (delta) {
            final next = (pixelCorners.topLeft + delta);
            final clamped = Offset(
              next.dx.clamp(0.0, pixelCorners.topRight.dx - 30),
              next.dy.clamp(0.0, pixelCorners.bottomLeft.dy - 30),
            );
            pixelCorners.topLeft = clamped;
            onCornersChanged(pixelCorners.toNormalized(size));
          },
        ),

        // 2. Top-Right Corner Anchor
        _buildCornerHandle(
          center: pixelCorners.topRight,
          radius: nodeRadius,
          onPanUpdate: (delta) {
            final next = (pixelCorners.topRight + delta);
            final clamped = Offset(
              next.dx.clamp(pixelCorners.topLeft.dx + 30, size.width),
              next.dy.clamp(0.0, pixelCorners.bottomRight.dy - 30),
            );
            pixelCorners.topRight = clamped;
            onCornersChanged(pixelCorners.toNormalized(size));
          },
        ),

        // 3. Bottom-Right Corner Anchor
        _buildCornerHandle(
          center: pixelCorners.bottomRight,
          radius: nodeRadius,
          onPanUpdate: (delta) {
            final next = (pixelCorners.bottomRight + delta);
            final clamped = Offset(
              next.dx.clamp(pixelCorners.bottomLeft.dx + 30, size.width),
              next.dy.clamp(pixelCorners.topRight.dy + 30, size.height),
            );
            pixelCorners.bottomRight = clamped;
            onCornersChanged(pixelCorners.toNormalized(size));
          },
        ),

        // 4. Bottom-Left Corner Anchor
        _buildCornerHandle(
          center: pixelCorners.bottomLeft,
          radius: nodeRadius,
          onPanUpdate: (delta) {
            final next = (pixelCorners.bottomLeft + delta);
            final clamped = Offset(
              next.dx.clamp(0.0, pixelCorners.bottomRight.dx - 30),
              next.dy.clamp(pixelCorners.topLeft.dy + 30, size.height),
            );
            pixelCorners.bottomLeft = clamped;
            onCornersChanged(pixelCorners.toNormalized(size));
          },
        ),

        // 5. Top Side Pill Drag Bar
        _buildSidePillHandle(
          center: topMid,
          width: pillWidth,
          height: pillHeight,
          isHorizontal: true,
          onPanUpdate: (delta) {
            final double nextY = (pixelCorners.topLeft.dy + delta.dy).clamp(0.0, pixelCorners.bottomLeft.dy - 30);
            final double shiftY = nextY - pixelCorners.topLeft.dy;
            pixelCorners.topLeft = Offset(pixelCorners.topLeft.dx, pixelCorners.topLeft.dy + shiftY);
            pixelCorners.topRight = Offset(pixelCorners.topRight.dx, pixelCorners.topRight.dy + shiftY);
            onCornersChanged(pixelCorners.toNormalized(size));
          },
        ),

        // 6. Right Side Pill Drag Bar
        _buildSidePillHandle(
          center: rightMid,
          width: pillHeight,
          height: pillWidth,
          isHorizontal: false,
          onPanUpdate: (delta) {
            final double nextX = (pixelCorners.topRight.dx + delta.dx).clamp(pixelCorners.topLeft.dx + 30, size.width);
            final double shiftX = nextX - pixelCorners.topRight.dx;
            pixelCorners.topRight = Offset(pixelCorners.topRight.dx + shiftX, pixelCorners.topRight.dy);
            pixelCorners.bottomRight = Offset(pixelCorners.bottomRight.dx + shiftX, pixelCorners.bottomRight.dy);
            onCornersChanged(pixelCorners.toNormalized(size));
          },
        ),

        // 7. Bottom Side Pill Drag Bar
        _buildSidePillHandle(
          center: bottomMid,
          width: pillWidth,
          height: pillHeight,
          isHorizontal: true,
          onPanUpdate: (delta) {
            final double nextY = (pixelCorners.bottomLeft.dy + delta.dy).clamp(pixelCorners.topLeft.dy + 30, size.height);
            final double shiftY = nextY - pixelCorners.bottomLeft.dy;
            pixelCorners.bottomLeft = Offset(pixelCorners.bottomLeft.dx, pixelCorners.bottomLeft.dy + shiftY);
            pixelCorners.bottomRight = Offset(pixelCorners.bottomRight.dx, pixelCorners.bottomRight.dy + shiftY);
            onCornersChanged(pixelCorners.toNormalized(size));
          },
        ),

        // 8. Left Side Pill Drag Bar
        _buildSidePillHandle(
          center: leftMid,
          width: pillHeight,
          height: pillWidth,
          isHorizontal: false,
          onPanUpdate: (delta) {
            final double nextX = (pixelCorners.topLeft.dx + delta.dx).clamp(0.0, pixelCorners.topRight.dx - 30);
            final double shiftX = nextX - pixelCorners.topLeft.dx;
            pixelCorners.topLeft = Offset(pixelCorners.topLeft.dx + shiftX, pixelCorners.topLeft.dy);
            pixelCorners.bottomLeft = Offset(pixelCorners.bottomLeft.dx + shiftX, pixelCorners.bottomLeft.dy);
            onCornersChanged(pixelCorners.toNormalized(size));
          },
        ),
      ],
    );
  }

  Widget _buildCornerHandle({
    required Offset center,
    required double radius,
    required ValueChanged<Offset> onPanUpdate,
  }) {
    return Positioned(
      left: center.dx - radius - 10,
      top: center.dy - radius - 10,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) => onPanUpdate(details.delta),
        child: Container(
          width: (radius + 10) * 2,
          height: (radius + 10) * 2,
          alignment: Alignment.center,
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2563EB), width: 3.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidePillHandle({
    required Offset center,
    required double width,
    required double height,
    required bool isHorizontal,
    required ValueChanged<Offset> onPanUpdate,
  }) {
    return Positioned(
      left: center.dx - width / 2 - 10,
      top: center.dy - height / 2 - 10,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) => onPanUpdate(details.delta),
        child: Container(
          width: width + 20,
          height: height + 20,
          alignment: Alignment.center,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CropBoundingBoxPainter extends CustomPainter {
  final QuadCorners corners;
  final Size size;

  _CropBoundingBoxPainter({required this.corners, required this.size});

  @override
  void paint(Canvas canvas, Size size) {
    final Path quadPath = Path()
      ..moveTo(corners.topLeft.dx, corners.topLeft.dy)
      ..lineTo(corners.topRight.dx, corners.topRight.dy)
      ..lineTo(corners.bottomRight.dx, corners.bottomRight.dy)
      ..lineTo(corners.bottomLeft.dx, corners.bottomLeft.dy)
      ..close();

    // 1. Dimmed background outside crop area
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path dimPath = Path.combine(PathOperation.difference, backgroundPath, quadPath);

    final Paint dimPaint = Paint()..color = Colors.black.withOpacity(0.55);
    canvas.drawPath(dimPath, dimPaint);

    // 2. Glowing Boundary stroke
    final Paint borderPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(quadPath, borderPaint);

    // 3. Rule-of-thirds guideline grid inside crop quad
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 2; i++) {
      final double t = i / 3.0;
      final Offset top = Offset.lerp(corners.topLeft, corners.topRight, t)!;
      final Offset bottom = Offset.lerp(corners.bottomLeft, corners.bottomRight, t)!;
      canvas.drawLine(top, bottom, gridPaint);

      final Offset left = Offset.lerp(corners.topLeft, corners.bottomLeft, t)!;
      final Offset right = Offset.lerp(corners.topRight, corners.bottomRight, t)!;
      canvas.drawLine(left, right, gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CropBoundingBoxPainter oldDelegate) => true;
}

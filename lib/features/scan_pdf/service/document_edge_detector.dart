import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_reader/features/scan_pdf/model/scanned_page_item.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DocumentEdgeDetector {
  /// Detects document boundary corners in a captured image using edge gradient analysis
  static Future<QuadCorners> detectDocumentCorners(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 200, // Downscale for sub-50ms fast edge analysis
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );

      if (byteData == null) {
        return QuadCorners.defaultNormalized();
      }

      final int width = image.width;
      final int height = image.height;
      final Uint8List pixels = byteData.buffer.asUint8List();

      // Step 1: Compute Grayscale Luminance Buffer
      final List<int> gray = List<int>.filled(width * height, 0);
      for (int i = 0; i < width * height; i++) {
        final int r = pixels[i * 4];
        final int g = pixels[i * 4 + 1];
        final int b = pixels[i * 4 + 2];
        gray[i] = (0.299 * r + 0.587 * g + 0.114 * b).round();
      }

      // Step 2: Search for document boundary contrasts from the four quadrants
      // Center reference
      final int cx = width ~/ 2;
      final int cy = height ~/ 2;

      // Scan outwards along diagonal rays from center to find highest gradient contrast
      Offset findEdgeAlongRay(double angleRad) {
        double maxGrad = 0;
        int bestX = (cx + math.cos(angleRad) * (width * 0.4)).round();
        int bestY = (cy + math.sin(angleRad) * (height * 0.4)).round();

        const int steps = 40;
        for (int s = 5; s < steps; s++) {
          final double t = s / steps;
          final int x = (cx + math.cos(angleRad) * (width * 0.48) * t).round().clamp(1, width - 2);
          final int y = (cy + math.sin(angleRad) * (height * 0.48) * t).round().clamp(1, height - 2);

          // Sobel / difference gradient
          final int left = gray[y * width + (x - 1)];
          final int right = gray[y * width + (x + 1)];
          final int top = gray[(y - 1) * width + x];
          final int bottom = gray[(y + 1) * width + x];

          final double grad = math.sqrt((right - left) * (right - left) + (bottom - top) * (bottom - top));

          if (grad > maxGrad && grad > 35) {
            maxGrad = grad;
            bestX = x;
            bestY = y;
          }
        }

        return Offset(bestX / width, bestY / height);
      }

      // 4 quadrant corners
      final Offset tl = findEdgeAlongRay(-3 * math.pi / 4);
      final Offset tr = findEdgeAlongRay(-math.pi / 4);
      final Offset br = findEdgeAlongRay(math.pi / 4);
      final Offset bl = findEdgeAlongRay(3 * math.pi / 4);

      // Validate that the detected quad forms a reasonable document box (> 30% of total area)
      final double widthTop = (tr.dx - tl.dx).abs();
      final double widthBottom = (br.dx - bl.dx).abs();
      final double heightLeft = (bl.dy - tl.dy).abs();
      final double heightRight = (br.dy - tr.dy).abs();

      if (widthTop > 0.4 && widthBottom > 0.4 && heightLeft > 0.4 && heightRight > 0.4) {
        return QuadCorners(
          topLeft: Offset(tl.dx.clamp(0.02, 0.35), tl.dy.clamp(0.02, 0.35)),
          topRight: Offset(tr.dx.clamp(0.65, 0.98), tr.dy.clamp(0.02, 0.35)),
          bottomRight: Offset(br.dx.clamp(0.65, 0.98), br.dy.clamp(0.65, 0.98)),
          bottomLeft: Offset(bl.dx.clamp(0.02, 0.35), bl.dy.clamp(0.65, 0.98)),
        );
      }

      return QuadCorners.defaultNormalized();
    } catch (e) {
      return QuadCorners.defaultNormalized();
    }
  }

  /// Crops, rectifies perspective, applies rotation and filters, then saves to temporary file
  static Future<String> processDocumentImage({
    required String sourceImagePath,
    required QuadCorners corners,
    required int rotationDegrees,
    required ScanDocFilter filter,
  }) async {
    final file = File(sourceImagePath);
    final bytes = await file.readAsBytes();

    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image srcImage = frameInfo.image;

    final srcWidth = srcImage.width.toDouble();
    final srcHeight = srcImage.height.toDouble();

    // Pixel corners
    final pixelCorners = corners.toPixels(Size(srcWidth, srcHeight));

    // Calculate output width and height based on quad dimensions
    final double topWidth = (pixelCorners.topRight - pixelCorners.topLeft).distance;
    final double bottomWidth = (pixelCorners.bottomRight - pixelCorners.bottomLeft).distance;
    final double leftHeight = (pixelCorners.bottomLeft - pixelCorners.topLeft).distance;
    final double rightHeight = (pixelCorners.bottomRight - pixelCorners.topRight).distance;

    final int targetWidth = math.max(topWidth, bottomWidth).round().clamp(300, 4000);
    final int targetHeight = math.max(leftHeight, rightHeight).round().clamp(300, 4000);

    // Apply rotation swap if 90 or 270 degrees
    final bool swapDimensions = rotationDegrees == 90 || rotationDegrees == 270;
    final int finalCanvasWidth = swapDimensions ? targetHeight : targetWidth;
    final int finalCanvasHeight = swapDimensions ? targetWidth : targetHeight;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // 1. Rotation Transform
    if (rotationDegrees != 0) {
      canvas.translate(finalCanvasWidth / 2, finalCanvasHeight / 2);
      canvas.rotate(rotationDegrees * math.pi / 180);
      canvas.translate(-targetWidth / 2, -targetHeight / 2);
    }

    // 2. Color Filter Setup
    final Paint paint = Paint()..isAntiAlias = true;

    if (filter == ScanDocFilter.magicColor) {
      // Magic Color: Enhance document brightness, high contrast, remove shadows
      paint.colorFilter = const ColorFilter.matrix([
        1.35, -0.05, -0.05, 0, 15,
        -0.05, 1.35, -0.05, 0, 15,
        -0.05, -0.05, 1.35, 0, 15,
        0, 0, 0, 1, 0,
      ]);
    } else if (filter == ScanDocFilter.grayscale) {
      // Clean Grayscale
      paint.colorFilter = const ColorFilter.matrix([
        0.299, 0.587, 0.114, 0, 0,
        0.299, 0.587, 0.114, 0, 0,
        0.299, 0.587, 0.114, 0, 0,
        0, 0, 0, 1, 0,
      ]);
    } else if (filter == ScanDocFilter.blackAndWhite) {
      // High-contrast B&W document thresholding
      paint.colorFilter = const ColorFilter.matrix([
        1.8, 1.8, 1.8, 0, -180,
        1.8, 1.8, 1.8, 0, -180,
        1.8, 1.8, 1.8, 0, -180,
        0, 0, 0, 1, 0,
      ]);
    }

    // 3. Perspective Quad Warping with Bilinear Mesh
    // Draw quad mesh mapped to target rectangle
    const int subdivisions = 8;
    final List<ui.VertexMode> modes = [];
    final List<Offset> positions = [];
    final List<Offset> texCoords = [];
    final List<int> indices = [];

    for (int y = 0; y <= subdivisions; y++) {
      final double v = y / subdivisions;
      for (int x = 0; x <= subdivisions; x++) {
        final double u = x / subdivisions;

        // Destination rectangular grid
        positions.add(Offset(u * targetWidth, v * targetHeight));

        // Source quad interpolated coordinates
        final Offset topPoint = Offset.lerp(pixelCorners.topLeft, pixelCorners.topRight, u)!;
        final Offset bottomPoint = Offset.lerp(pixelCorners.bottomLeft, pixelCorners.bottomRight, u)!;
        final Offset srcPoint = Offset.lerp(topPoint, bottomPoint, v)!;

        texCoords.add(srcPoint);
      }
    }

    for (int y = 0; y < subdivisions; y++) {
      for (int x = 0; x < subdivisions; x++) {
        final int i0 = y * (subdivisions + 1) + x;
        final int i1 = i0 + 1;
        final int i2 = (y + 1) * (subdivisions + 1) + x;
        final int i3 = i2 + 1;

        indices.addAll([i0, i1, i2, i1, i3, i2]);
      }
    }

    final ui.Vertices vertices = ui.Vertices(
      ui.VertexMode.triangles,
      positions,
      textureCoordinates: texCoords,
      indices: indices,
    );

    // Apply texture shader with filter
    final ImageShader shader = ImageShader(
      srcImage,
      TileMode.clamp,
      TileMode.clamp,
      Float64List.fromList([
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
      ]),
    );

    paint.shader = shader;
    canvas.drawVertices(vertices, BlendMode.srcOver, paint);

    final ui.Picture picture = recorder.endRecording();
    final ui.Image outputImage = await picture.toImage(finalCanvasWidth, finalCanvasHeight);
    final ByteData? pngBytes = await outputImage.toByteData(format: ui.ImageByteFormat.png);

    Directory tempDir;
    try {
      tempDir = await getTemporaryDirectory();
    } catch (_) {
      tempDir = Directory.systemTemp;
    }
    final outPath = '${tempDir.path}/scan_${DateTime.now().microsecondsSinceEpoch}.png';
    final outFile = File(outPath);
    await outFile.writeAsBytes(pngBytes!.buffer.asUint8List());

    return outPath;
  }
}

import 'dart:ui';

enum ScanDocFilter {
  original,
  magicColor,
  grayscale,
  blackAndWhite,
}

class QuadCorners {
  Offset topLeft;
  Offset topRight;
  Offset bottomRight;
  Offset bottomLeft;

  QuadCorners({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  QuadCorners copyWith({
    Offset? topLeft,
    Offset? topRight,
    Offset? bottomRight,
    Offset? bottomLeft,
  }) {
    return QuadCorners(
      topLeft: topLeft ?? this.topLeft,
      topRight: topRight ?? this.topRight,
      bottomRight: bottomRight ?? this.bottomRight,
      bottomLeft: bottomLeft ?? this.bottomLeft,
    );
  }

  /// Default 8% inset quad for a given normalized bounding box
  factory QuadCorners.defaultNormalized() {
    return QuadCorners(
      topLeft: const Offset(0.08, 0.08),
      topRight: const Offset(0.92, 0.08),
      bottomRight: const Offset(0.92, 0.92),
      bottomLeft: const Offset(0.08, 0.92),
    );
  }

  /// Convert normalized 0.0-1.0 coordinates to pixel coordinates for a specific size
  QuadCorners toPixels(Size size) {
    return QuadCorners(
      topLeft: Offset(topLeft.dx * size.width, topLeft.dy * size.height),
      topRight: Offset(topRight.dx * size.width, topRight.dy * size.height),
      bottomRight: Offset(bottomRight.dx * size.width, bottomRight.dy * size.height),
      bottomLeft: Offset(bottomLeft.dx * size.width, bottomLeft.dy * size.height),
    );
  }

  /// Convert pixel coordinates to normalized 0.0-1.0 coordinates for a specific size
  QuadCorners toNormalized(Size size) {
    if (size.width == 0 || size.height == 0) return this;
    return QuadCorners(
      topLeft: Offset(
        (topLeft.dx / size.width).clamp(0.0, 1.0),
        (topLeft.dy / size.height).clamp(0.0, 1.0),
      ),
      topRight: Offset(
        (topRight.dx / size.width).clamp(0.0, 1.0),
        (topRight.dy / size.height).clamp(0.0, 1.0),
      ),
      bottomRight: Offset(
        (bottomRight.dx / size.width).clamp(0.0, 1.0),
        (bottomRight.dy / size.height).clamp(0.0, 1.0),
      ),
      bottomLeft: Offset(
        (bottomLeft.dx / size.width).clamp(0.0, 1.0),
        (bottomLeft.dy / size.height).clamp(0.0, 1.0),
      ),
    );
  }
}

class ScannedPageItem {
  final String id;
  final String originalImagePath;
  String? croppedImagePath;
  String? processedImagePath;
  QuadCorners? corners;
  int rotationDegrees; // 0, 90, 180, 270
  ScanDocFilter filter;

  ScannedPageItem({
    required this.id,
    required this.originalImagePath,
    this.croppedImagePath,
    this.processedImagePath,
    this.corners,
    this.rotationDegrees = 0,
    this.filter = ScanDocFilter.magicColor,
  });

  String get displayPath =>
      processedImagePath ?? croppedImagePath ?? originalImagePath;

  ScannedPageItem copyWith({
    String? croppedImagePath,
    String? processedImagePath,
    QuadCorners? corners,
    int? rotationDegrees,
    ScanDocFilter? filter,
  }) {
    return ScannedPageItem(
      id: id,
      originalImagePath: originalImagePath,
      croppedImagePath: croppedImagePath ?? this.croppedImagePath,
      processedImagePath: processedImagePath ?? this.processedImagePath,
      corners: corners ?? this.corners,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      filter: filter ?? this.filter,
    );
  }
}

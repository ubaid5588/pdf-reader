import 'dart:io';
import 'package:file_reader/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Renders a high-fidelity thumbnail for a single PDF page.
/// Combines embedded vector SfPdfViewer rendering with instant extracted
/// document text layout so pages are NEVER blank.
class PdfPageThumbnail extends StatefulWidget {
  final File file;
  final int pageNumber; // 1-based
  final String? password;
  final bool isMarkedForRemoval;
  final bool isSelected;
  final double aspectRatio;

  const PdfPageThumbnail({
    super.key,
    required this.file,
    required this.pageNumber,
    this.password,
    this.isMarkedForRemoval = false,
    this.isSelected = false,
    this.aspectRatio = 0.72,
  });

  @override
  State<PdfPageThumbnail> createState() => _PdfPageThumbnailState();
}

class _PdfPageThumbnailState extends State<PdfPageThumbnail> {
  List<String>? _extractedLines;
  bool _isLoadingText = true;
  bool _pdfViewerLoaded = false;
  static final Map<String, List<String>> _textCache = {};

  @override
  void initState() {
    super.initState();
    _loadPageText();
  }

  @override
  void didUpdateWidget(covariant PdfPageThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.path != widget.file.path ||
        oldWidget.pageNumber != widget.pageNumber) {
      _pdfViewerLoaded = false;
      _loadPageText();
    }
  }

  Future<void> _loadPageText() async {
    final cacheKey =
        '${widget.file.path}_${widget.pageNumber}_${widget.password ?? ''}';
    if (_textCache.containsKey(cacheKey)) {
      if (mounted) {
        setState(() {
          _extractedLines = _textCache[cacheKey];
          _isLoadingText = false;
        });
      }
      return;
    }

    try {
      if (!widget.file.existsSync()) {
        if (mounted) setState(() => _isLoadingText = false);
        return;
      }

      final bytes = widget.file.readAsBytesSync();
      if (bytes.isEmpty) {
        if (mounted) setState(() => _isLoadingText = false);
        return;
      }

      final doc = PdfDocument(
        inputBytes: bytes,
        password: widget.password,
      );

      if (widget.pageNumber <= doc.pages.count) {
        final zeroIndex = widget.pageNumber - 1;
        final rawText = PdfTextExtractor(doc).extractText(
          startPageIndex: zeroIndex,
          endPageIndex: zeroIndex,
        );

        final lines = rawText
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .take(16)
            .toList();

        _textCache[cacheKey] = lines;

        if (mounted) {
          setState(() {
            _extractedLines = lines;
            _isLoadingText = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoadingText = false);
      }
      doc.dispose();
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingText = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = colors.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2438) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Vector PDF Viewer Render (in production/emulator)
          if (!Platform.environment.containsKey('FLUTTER_TEST'))
            Positioned.fill(
              child: IgnorePointer(
                child: SfPdfViewer.file(
                  widget.file,
                  key: ValueKey(
                    'thumb_${widget.file.path}_p${widget.pageNumber}',
                  ),
                  password: widget.password,
                  initialPageNumber: widget.pageNumber,
                  pageLayoutMode: PdfPageLayoutMode.single,
                  canShowScrollHead: false,
                  canShowScrollStatus: false,
                  canShowPaginationDialog: false,
                  enableDoubleTapZooming: false,
                  enableTextSelection: false,
                  onDocumentLoaded: (details) {
                    if (mounted && !_pdfViewerLoaded) {
                      setState(() => _pdfViewerLoaded = true);
                    }
                  },
                  onDocumentLoadFailed: (details) {
                    if (mounted && !_pdfViewerLoaded) {
                      setState(() => _pdfViewerLoaded = false);
                    }
                  },
                ),
              ),
            ),

          // 2. High-fidelity extracted text fallback / underlay if viewer is loading or plain text
          if (!_pdfViewerLoaded &&
              _extractedLines != null &&
              _extractedLines!.isNotEmpty)
            Positioned.fill(
              child: Container(
                color: isDark ? const Color(0xFF1E2438) : Colors.white,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header / Title text
                    Text(
                      _extractedLines!.first,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Divider(height: 4, thickness: 0.5),
                    const SizedBox(height: 4),
                    // Body text lines
                    Expanded(
                      child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _extractedLines!.length - 1,
                        itemBuilder: (context, idx) {
                          final line = _extractedLines![idx + 1];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 2.5),
                            child: Text(
                              line,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 7.5,
                                color: isDark
                                    ? Colors.white54
                                    : const Color(0xFF475569),
                                height: 1.1,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Subtle fallback placeholder while extracting
          if (!_pdfViewerLoaded &&
              _isLoadingText &&
              (_extractedLines == null || _extractedLines!.isEmpty))
            Positioned.fill(
              child: Container(
                color: isDark ? const Color(0xFF1E2438) : Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 6,
                      decoration: BoxDecoration(
                        color: colors.textSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (int i = 0; i < 5; i++) ...[
                      Container(
                        width: double.infinity,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: colors.textSecondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          // 4. Removal Overlay (if marked for removal)
          if (widget.isMarkedForRemoval)
            Positioned.fill(
              child: Container(
                color: const Color(0xFFEF4444).withOpacity(0.35),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

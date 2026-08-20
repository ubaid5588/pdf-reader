import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/core/widgets/custom_button.dart';
import 'package:file_reader/features/converter/view/conversion_processing_page.dart';
import 'package:file_reader/features/edit_pdf/controller/edit_pdf_controller.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PdfEditorPage extends StatefulWidget {
  const PdfEditorPage({super.key});

  @override
  State<PdfEditorPage> createState() => _PdfEditorPageState();
}

class _PdfEditorPageState extends State<PdfEditorPage>
    with SingleTickerProviderStateMixin {
  late final EditPdfController controller;
  late final TabController _tabController;
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _overlayTextController = TextEditingController();

  // Overlay options
  Alignment _selectedAlignment = Alignment.topCenter;
  Color _selectedOverlayColor = const Color(0xFF2563EB);
  final double _overlayFontSize = 14.0;

  // Drawing state
  Color _selectedDrawingColor = const Color(0xFF2563EB);
  final double _drawingStrokeWidth = 3.0;
  List<Offset> _currentPoints = [];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EditPdfController>()
        ? Get.find<EditPdfController>()
        : Get.put(EditPdfController());

    _tabController = TabController(length: 4, vsync: this);

    _syncCurrentPageText();

    // Listen to page changes
    ever(controller.currentPageIndex, (_) {
      _syncCurrentPageText();
    });
  }

  void _syncCurrentPageText() {
    final page = controller.currentPageIndex.value;
    final text = controller.pageTexts[page] ?? '';
    _textEditingController.text = text;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textEditingController.dispose();
    _overlayTextController.dispose();
    super.dispose();
  }

  void _handleSave(BuildContext context, AppLocalizations l10n) {
    // Save any pending text edits
    controller.updateCurrentPageText(_textEditingController.text);

    Get.to(
      () => ConversionProcessingPage(
        title: l10n.editPdf,
        initialMessage: 'Applying edits and generating PDF...',
        processOperation: (onProgress) =>
            controller.saveEditedPdf(onProgress: onProgress),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          l10n.editPdf,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check, size: 16, color: Colors.white),
              label: Text(
                l10n.savePdf,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              onPressed: () => _handleSave(context, l10n),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final total = controller.totalPages.value;
        final current = controller.currentPageIndex.value;
        final rotation = controller.pageRotations[current] ?? 0;

        return Column(
          children: [
            // Page Navigator Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: colors.cardShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                    color: current > 0 ? colors.primary : colors.textSecondary.withValues(alpha: 0.3),
                    onPressed: current > 0
                        ? () {
                            controller.updateCurrentPageText(_textEditingController.text);
                            // Find previous non-deleted page
                            for (int i = current - 1; i >= 0; i--) {
                              if (!controller.deletedPages.contains(i)) {
                                controller.currentPageIndex.value = i;
                                break;
                              }
                            }
                          }
                        : null,
                  ),
                  Row(
                    children: [
                      Text(
                        'Page ${current + 1} of $total',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      if (rotation > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$rotation°',
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    color: current < total - 1
                        ? colors.primary
                        : colors.textSecondary.withValues(alpha: 0.3),
                    onPressed: current < total - 1
                        ? () {
                            controller.updateCurrentPageText(_textEditingController.text);
                            // Find next non-deleted page
                            for (int i = current + 1; i < total; i++) {
                              if (!controller.deletedPages.contains(i)) {
                                controller.currentPageIndex.value = i;
                                break;
                              }
                            }
                          }
                        : null,
                  ),
                ],
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: colors.textSecondary,
                indicator: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                tabs: const [
                  Tab(text: 'Text'),
                  Tab(text: 'Add Text'),
                  Tab(text: 'Draw'),
                  Tab(text: 'Page'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Edit Page Text
                  _buildTextEditTab(colors),

                  // Tab 2: Add Custom Text / Header / Watermark
                  _buildAddTextTab(colors),

                  // Tab 3: Freehand Draw / Signature Canvas
                  _buildDrawingTab(colors),

                  // Tab 4: Page Management (Rotate, Delete)
                  _buildPageOpsTab(colors, l10n),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- Tab 1: Text Editing ---
  Widget _buildTextEditTab(AppColors colors) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page Text Content',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              TextButton.icon(
                icon: const Icon(Icons.refresh, size: 15),
                label: const Text('Reset', style: TextStyle(fontSize: 12)),
                onPressed: () {
                  final page = controller.currentPageIndex.value;
                  final orig = controller.originalPageTexts[page] ?? '';
                  _textEditingController.text = orig;
                  controller.pageTexts[page] = orig;
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border, width: 1),
              ),
              child: TextField(
                controller: _textEditingController,
                maxLines: null,
                expands: true,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 13.5,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Edit page text content...',
                  hintStyle: TextStyle(color: colors.textSecondary),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  controller.updateCurrentPageText(val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Tab 2: Add Custom Text / Header / Watermark ---
  Widget _buildAddTextTab(AppColors colors) {
    final page = controller.currentPageIndex.value;
    final pageOverlays = controller.textOverlays.where((o) => o.pageIndex == page).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Insert Text Overlay',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _overlayTextController,
                  style: TextStyle(color: colors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Enter text or watermark (e.g. APPROVED, CONFIDENTIAL)',
                    hintStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
                    filled: true,
                    fillColor: colors.surfaceElevated,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Position',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildPositionChip('Top Header', Alignment.topCenter, colors),
                    const SizedBox(width: 8),
                    _buildPositionChip('Center', Alignment.center, colors),
                    const SizedBox(width: 8),
                    _buildPositionChip('Footer', Alignment.bottomCenter, colors),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Color',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildColorCircle(const Color(0xFF2563EB)),
                    _buildColorCircle(const Color(0xFFEF5350)),
                    _buildColorCircle(const Color(0xFF10B981)),
                    _buildColorCircle(const Color(0xFFF59E0B)),
                    _buildColorCircle(Colors.black),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Add to This Page',
                  width: double.infinity,
                  onPressed: () {
                    final text = _overlayTextController.text.trim();
                    if (text.isEmpty) return;

                    controller.addTextOverlay(
                      PdfTextOverlay(
                        pageIndex: controller.currentPageIndex.value,
                        text: text,
                        fontSize: _overlayFontSize,
                        color: _selectedOverlayColor,
                        alignment: _selectedAlignment,
                      ),
                    );
                    _overlayTextController.clear();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (pageOverlays.isNotEmpty) ...[
            Text(
              'Overlays on Page ${page + 1}',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pageOverlays.length,
              itemBuilder: (ctx, idx) {
                final o = pageOverlays[idx];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: o.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          o.text,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                        onPressed: () {
                          controller.textOverlays.remove(o);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPositionChip(String label, Alignment alignment, AppColors colors) {
    final isSelected = _selectedAlignment == alignment;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: colors.primary.withValues(alpha: 0.2),
      backgroundColor: colors.surfaceElevated,
      labelStyle: TextStyle(
        color: isSelected ? colors.primary : colors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11.5,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedAlignment = alignment;
          });
        }
      },
    );
  }

  Widget _buildColorCircle(Color color) {
    final isSelected = _selectedOverlayColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOverlayColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  // --- Tab 3: Freehand Drawing / Signature Canvas ---
  Widget _buildDrawingTab(AppColors colors) {
    final page = controller.currentPageIndex.value;
    final pageStrokes = controller.drawingStrokes.where((s) => s.pageIndex == page).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildDrawingColorCircle(const Color(0xFF2563EB)),
                  _buildDrawingColorCircle(Colors.black),
                  _buildDrawingColorCircle(const Color(0xFFEF5350)),
                  _buildDrawingColorCircle(const Color(0xFF10B981)),
                ],
              ),
              TextButton.icon(
                icon: const Icon(Icons.clear_all, size: 16, color: Colors.red),
                label: const Text('Clear', style: TextStyle(color: Colors.red, fontSize: 12)),
                onPressed: () {
                  controller.clearCurrentPageDrawings();
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Canvas Area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.isDark ? const Color(0xFF1C1E2B) : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border, width: 1.5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _currentPoints = [details.localPosition];
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _currentPoints.add(details.localPosition);
                    });
                  },
                  onPanEnd: (details) {
                    if (_currentPoints.isNotEmpty) {
                      controller.addDrawingStroke(
                        DrawingStroke(
                          pageIndex: page,
                          points: List.from(_currentPoints),
                          color: _selectedDrawingColor,
                          strokeWidth: _drawingStrokeWidth,
                        ),
                      );
                      setState(() {
                        _currentPoints = [];
                      });
                    }
                  },
                  child: CustomPaint(
                    painter: _SignaturePainter(
                      savedStrokes: pageStrokes,
                      currentPoints: _currentPoints,
                      currentColor: _selectedDrawingColor,
                      currentStrokeWidth: _drawingStrokeWidth,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Draw with finger or stylus to sign or annotate page ${page + 1}',
            style: TextStyle(color: colors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawingColorCircle(Color color) {
    final isSelected = _selectedDrawingColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDrawingColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  // --- Tab 4: Page Operations (Rotate, Delete) ---
  Widget _buildPageOpsTab(AppColors colors, AppLocalizations l10n) {
    final page = controller.currentPageIndex.value;
    final total = controller.totalPages.value;
    final active = controller.activePageCount;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 40,
                  color: colors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Page ${page + 1} of $total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total active pages: $active',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Rotate Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.surfaceElevated,
              foregroundColor: colors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: colors.border),
              ),
            ),
            icon: Icon(Icons.rotate_right_rounded, color: colors.primary),
            label: const Text(
              'Rotate Page Clockwise (90°)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            onPressed: () {
              controller.rotateCurrentPage();
            },
          ),
          const SizedBox(height: 12),

          // Delete Page Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B1E1E),
              foregroundColor: const Color(0xFFF87171),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFF5A2525)),
              ),
            ),
            icon: const Icon(Icons.delete_outline, color: Color(0xFFF87171)),
            label: const Text(
              'Delete Current Page',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            onPressed: () {
              _showDeletePageDialog(context, page);
            },
          ),
        ],
      ),
    );
  }

  void _showDeletePageDialog(BuildContext context, int page) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Page ${page + 1}?',
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove page ${page + 1} from this PDF?',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              controller.deleteCurrentPage(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<DrawingStroke> savedStrokes;
  final List<Offset> currentPoints;
  final Color currentColor;
  final double currentStrokeWidth;

  _SignaturePainter({
    required this.savedStrokes,
    required this.currentPoints,
    required this.currentColor,
    required this.currentStrokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw saved strokes
    for (final stroke in savedStrokes) {
      if (stroke.points.length < 2) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }

    // Draw active stroke
    if (currentPoints.length >= 2) {
      final activePaint = Paint()
        ..color = currentColor
        ..strokeWidth = currentStrokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < currentPoints.length - 1; i++) {
        canvas.drawLine(currentPoints[i], currentPoints[i + 1], activePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}

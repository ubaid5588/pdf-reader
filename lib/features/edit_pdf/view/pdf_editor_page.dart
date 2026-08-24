import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/converter/view/conversion_processing_page.dart';
import 'package:file_reader/features/edit_pdf/controller/edit_pdf_controller.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfEditorPage extends StatefulWidget {
  const PdfEditorPage({super.key});

  @override
  State<PdfEditorPage> createState() => _PdfEditorPageState();
}

class _PdfEditorPageState extends State<PdfEditorPage> {
  late final EditPdfController controller;
  final GlobalKey _canvasKey = GlobalKey();

  List<Offset> _livePoints = [];
  Offset? _shapeStart;
  Offset? _shapeEnd;
  String? _selectedElementId;
  String? _selectedExtractedId;

  final List<Color> _palette = const [
    Color(0xFF2563EB), // Blue
    Color(0xFFDC2626), // Red
    Color(0xFF16A34A), // Green
    Color(0xFFEAB308), // Yellow
    Color(0xFFEA580C), // Orange
    Color(0xFF9333EA), // Purple
    Color(0xFF0F172A), // Black
    Color(0xFFFFFFFF), // White
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EditPdfController>()
        ? Get.find<EditPdfController>()
        : Get.put(EditPdfController());
  }

  void _handleSave(BuildContext context, AppLocalizations l10n) {
    final RenderBox? renderBox =
        _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? const Size(360, 500);

    Get.to(
      () => ConversionProcessingPage(
        title: l10n.editPdf,
        initialMessage: 'Applying edits and saving PDF document...',
        isEditOrganize: true,
        completedTitle: 'PDF Ready',
        completedSubtitle: 'Your edited PDF is ready to view and share.',
        processOperation: (onProgress) => controller.saveEditedPdf(
          onProgress: onProgress,
          canvasWidth: size.width,
          canvasHeight: size.height,
        ),
      ),
    );
  }

  /// Dialog to edit existing extracted text directly on the page
  Future<void> _showEditExtractedTextDialog(
    BuildContext context,
    ExtractedPdfTextItem item,
  ) {
    final colors = context.colors;
    final textController = TextEditingController(text: item.currentText);
    double fontSize = item.fontSize;
    Color textColor = item.textColor;
    bool isBold = item.isBold;
    bool isItalic = item.isItalic;

    return showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: colors.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.edit_note_rounded, color: colors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Edit Text',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original Text reference
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colors.isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Original Text:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.originalText,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textPrimary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Editable input
                  TextField(
                    controller: textController,
                    autofocus: true,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Modified Text',
                      labelStyle: TextStyle(color: colors.primary),
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Font Style & Controls
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('Bold'),
                        selected: isBold,
                        onSelected: (val) => setState(() => isBold = val),
                        selectedColor: colors.primary.withOpacity(0.2),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Italic'),
                        selected: isItalic,
                        onSelected: (val) => setState(() => isItalic = val),
                        selectedColor: colors.primary.withOpacity(0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Font Size Stepper
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Font Size (${fontSize.toInt()}pt)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            iconSize: 20,
                            onPressed: () {
                              if (fontSize > 8) {
                                setState(() => fontSize -= 1);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            iconSize: 20,
                            onPressed: () {
                              if (fontSize < 48) {
                                setState(() => fontSize += 1);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Color Picker
                  Text(
                    'Text Color',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _palette.take(6).map((c) {
                      return GestureDetector(
                        onTap: () => setState(() => textColor = c),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: textColor == c
                                  ? colors.primary
                                  : Colors.grey,
                              width: textColor == c ? 2.5 : 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  controller.deleteExtractedTextItem(item.id);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Delete Text'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final newText = textController.text.trim();
                  controller.updateExtractedTextItem(
                    item.copyWith(
                      currentText: newText,
                      fontSize: fontSize,
                      textColor: textColor,
                      isBold: isBold,
                      isItalic: isItalic,
                      isEdited: true,
                      isDeleted: newText.isEmpty,
                    ),
                  );
                  Navigator.of(ctx).pop();
                },
                child: const Text('Apply Edit'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Bottom sheet listing all detected text lines on the active page
  void _showDetectedTextSheet(BuildContext context) {
    final colors = context.colors;
    final texts = controller.getExtractedTextsForCurrentPage();

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page ${controller.currentPageIndex.value + 1} Text Lines (${texts.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tap any text element below to edit its content and style:',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: texts.isEmpty
                    ? Center(
                        child: Text(
                          'No extractable text found on this page.',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        itemCount: texts.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: colors.divider),
                        itemBuilder: (context, index) {
                          final item = texts[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            leading: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: item.isEdited
                                    ? colors.primary.withOpacity(0.15)
                                    : colors.surface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: item.isEdited
                                        ? colors.primary
                                        : colors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              item.currentText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: item.isBold
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontStyle: item.isItalic
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                color: item.isEdited
                                    ? colors.primary
                                    : colors.textPrimary,
                              ),
                            ),
                            trailing: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: colors.primary,
                            ),
                            onTap: () {
                              Navigator.of(ctx).pop();
                              _showEditExtractedTextDialog(context, item);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddTextDialog(BuildContext context, {Offset? position}) {
    final colors = context.colors;
    final textEditingController = TextEditingController();
    double fontSize = 15.0;
    Color textColor = controller.selectedColor.value;
    bool isBold = false;
    bool isWhiteout = false;

    return showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: colors.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Add Text',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: textEditingController,
                    autofocus: true,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter text here...',
                      hintStyle: TextStyle(color: colors.textSecondary),
                      filled: isWhiteout,
                      fillColor: isWhiteout ? Colors.white : Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      FilterChip(
                        label: const Text('Bold'),
                        selected: isBold,
                        onSelected: (val) => setState(() => isBold = val),
                        selectedColor: colors.primary.withOpacity(0.2),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('White Background'),
                        selected: isWhiteout,
                        onSelected: (val) => setState(() => isWhiteout = val),
                        selectedColor: colors.primary.withOpacity(0.2),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'Color',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _palette.take(6).map((c) {
                      return GestureDetector(
                        onTap: () => setState(() => textColor = c),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: textColor == c
                                  ? colors.primary
                                  : Colors.grey,
                              width: textColor == c ? 2.5 : 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final text = textEditingController.text.trim();
                  if (text.isNotEmpty) {
                    final pos = position ?? const Offset(40, 100);
                    controller.addTextElement(
                      VisualTextElement(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        pageIndex: controller.currentPageIndex.value,
                        text: text,
                        position: pos,
                        fontSize: fontSize,
                        color: textColor,
                        isBold: isBold,
                        backgroundColor: isWhiteout ? Colors.white : null,
                      ),
                    );
                  }
                  Navigator.of(ctx).pop();
                },
                child: const Text('Add Text'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickImageStamp() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      controller.addImageElement(
        VisualImageElement(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          pageIndex: controller.currentPageIndex.value,
          imageBytes: bytes,
          position: const Offset(40, 120),
          size: const Size(120, 120),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to add image: $e');
    }
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
          icon: Icon(Icons.close_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Obx(() {
          final current = controller.currentPageIndex.value;
          final total = controller.totalPages.value;
          final rotation = controller.pageRotations[current] ?? 0;

          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                  color: current > 0
                      ? colors.primary
                      : colors.textSecondary.withOpacity(0.3),
                  onPressed: current > 0
                      ? () => controller.goToPrevPage()
                      : null,
                ),

                Text(
                  'Page ${current + 1} of $total',
                  maxLines: 1,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),

                if (rotation > 0) ...[
                  const SizedBox(width: 4),
                  Text(
                    '($rotation°)',
                    style: TextStyle(color: colors.primary, fontSize: 11),
                  ),
                ],

                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  color: current < total - 1
                      ? colors.primary
                      : colors.textSecondary.withOpacity(0.3),
                  onPressed: current < total - 1
                      ? () => controller.goToNextPage()
                      : null,
                ),
              ],
            ),
          );
        }),

        actions: [
          // Undo button
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 20),
            color: colors.textPrimary,
            tooltip: 'Undo',
            onPressed: () => controller.undo(),
          ),
          // Redo button
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 20),
            color: colors.textPrimary,
            tooltip: 'Redo',
            onPressed: () => controller.redo(),
          ),
          // Save Button
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(
                Icons.check_rounded,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                'Save',
                style: TextStyle(
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
      body: Column(
        children: [
          // Informational Tip Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app_rounded, color: colors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap any text on the page to edit it, or use the tools below.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tool Options Sub-Bar
          _buildToolOptionsBar(context),

          // Main Visual Page Canvas Viewport
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.cardShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final canvasWidth = constraints.maxWidth;
                  final canvasHeight = constraints.maxHeight;

                  return Stack(
                    key: _canvasKey,
                    children: [
                      // 1. Live Visual PDF Background
                      if (controller.sourceFile.value != null)
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring:
                                controller.activeTool.value !=
                                EditorTool.select,
                            child: SfPdfViewer.file(
                              controller.sourceFile.value!,
                              controller: controller.pdfViewerController,
                              pageLayoutMode: PdfPageLayoutMode.single,
                              canShowScrollHead: false,
                              canShowScrollStatus: false,
                              enableDoubleTapZooming: false,
                              enableTextSelection: false,
                            ),
                          ),
                        ),

                      // 2. Extracted Interactive Text Layer (Tap to edit on any page)
                      Obx(() {
                        final page = controller.currentPageIndex.value;
                        final pageSize =
                            controller.originalPageSizes[page] ??
                            const Size(595, 842);
                        final double scaleX = canvasWidth / pageSize.width;
                        final double scaleY = canvasHeight / pageSize.height;

                        final pageExtracted = controller.extractedTextItems
                            .where((t) => t.pageIndex == page && !t.isDeleted)
                            .toList();

                        return Stack(
                          children: pageExtracted.map((item) {
                            final isSelected = _selectedExtractedId == item.id;
                            final pos =
                                item.customPosition ??
                                item.originalBounds.topLeft;

                            final left = (pos.dx * scaleX).clamp(
                              0.0,
                              canvasWidth,
                            );
                            final top = (pos.dy * scaleY).clamp(
                              0.0,
                              canvasHeight,
                            );
                            final width = (item.originalBounds.width * scaleX)
                                .clamp(20.0, canvasWidth);
                            final height = (item.originalBounds.height * scaleY)
                                .clamp(14.0, canvasHeight);

                            return Positioned(
                              left: left,
                              top: top,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  setState(
                                    () => _selectedExtractedId = item.id,
                                  );
                                  _showEditExtractedTextDialog(context, item);
                                },
                                child: Container(
                                  width: item.isEdited ? null : width,
                                  height: item.isEdited ? null : height,
                                  constraints: BoxConstraints(
                                    minWidth: width,
                                    minHeight: height,
                                  ),
                                  padding: item.isEdited
                                      ? const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        )
                                      : EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                    color: item.isEdited
                                        ? Colors.white
                                        : (isSelected
                                              ? colors.primary.withOpacity(0.18)
                                              : Colors.transparent),
                                    border: Border.all(
                                      color: isSelected
                                          ? colors.primary
                                          : (item.isEdited
                                                ? colors.primary.withOpacity(
                                                    0.5,
                                                  )
                                                : colors.primary.withOpacity(
                                                    0.15,
                                                  )),
                                      width: isSelected ? 1.5 : 0.8,
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: item.isEdited
                                      ? Text(
                                          item.currentText,
                                          style: TextStyle(
                                            fontSize:
                                                item.fontSize *
                                                ((scaleX + scaleY) / 2),
                                            fontWeight: item.isBold
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            fontStyle: item.isItalic
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                            color: item.textColor,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),

                      // 3. Custom Painter Layer (Drawings, Highlights, Shapes, Whiteouts)
                      Positioned.fill(
                        child: Obx(() {
                          final page = controller.currentPageIndex.value;
                          final pageStrokes = controller.drawStrokes
                              .where((s) => s.pageIndex == page)
                              .toList();
                          final pageShapes = controller.shapeElements
                              .where((s) => s.pageIndex == page)
                              .toList();
                          final pageWhiteouts = controller.whiteoutElements
                              .where((w) => w.pageIndex == page)
                              .toList();

                          return CustomPaint(
                            painter: _CanvasElementsPainter(
                              strokes: pageStrokes,
                              shapes: pageShapes,
                              whiteouts: pageWhiteouts,
                              livePoints: _livePoints,
                              liveColor: controller.selectedColor.value,
                              liveStrokeWidth: controller.strokeWidth.value,
                              liveIsHighlighter:
                                  controller.activeTool.value ==
                                  EditorTool.highlight,
                              liveShapeStart: _shapeStart,
                              liveShapeEnd: _shapeEnd,
                              liveShapeType: controller.selectedShape.value,
                            ),
                          );
                        }),
                      ),

                      // 4. User-added Image Stamps
                      Obx(() {
                        final page = controller.currentPageIndex.value;
                        final pageImages = controller.imageElements
                            .where((img) => img.pageIndex == page)
                            .toList();

                        return Stack(
                          children: pageImages.map((img) {
                            return Positioned(
                              left: img.position.dx,
                              top: img.position.dy,
                              child: GestureDetector(
                                onPanUpdate: (details) {
                                  setState(() {
                                    img.position += details.delta;
                                  });
                                },
                                child: Container(
                                  width: img.size.width,
                                  height: img.size.height,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: colors.primary.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Image.memory(
                                        img.imageBytes,
                                        fit: BoxFit.cover,
                                        width: img.size.width,
                                        height: img.size.height,
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: GestureDetector(
                                          onTap: () {
                                            controller.imageElements
                                                .removeWhere(
                                                  (i) => i.id == img.id,
                                                );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),

                      // 5. User-added Text Elements
                      Obx(() {
                        final page = controller.currentPageIndex.value;
                        final pageTexts = controller.textElements
                            .where((t) => t.pageIndex == page)
                            .toList();

                        return Stack(
                          children: pageTexts.map((textEl) {
                            final isSelected = _selectedElementId == textEl.id;

                            return Positioned(
                              left: textEl.position.dx,
                              top: textEl.position.dy,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedElementId = isSelected
                                        ? null
                                        : textEl.id;
                                  });
                                },
                                onPanUpdate: (details) {
                                  setState(() {
                                    textEl.position += details.delta;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        textEl.backgroundColor ??
                                        (isSelected
                                            ? colors.primary.withOpacity(0.15)
                                            : Colors.transparent),
                                    border: Border.all(
                                      color: isSelected
                                          ? colors.primary
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        textEl.text,
                                        style: TextStyle(
                                          fontSize: textEl.fontSize,
                                          fontWeight: textEl.isBold
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontStyle: textEl.isItalic
                                              ? FontStyle.italic
                                              : FontStyle.normal,
                                          color: textEl.color,
                                        ),
                                      ),
                                      if (isSelected) ...[
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () => controller
                                              .removeTextElement(textEl.id),
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),

                      // 6. User Touch Gesture Layer
                      Positioned.fill(
                        child: Obx(() {
                          final tool = controller.activeTool.value;
                          if (tool == EditorTool.select) {
                            return const SizedBox.shrink();
                          }

                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapDown: (details) {
                              if (tool == EditorTool.text) {
                                _showAddTextDialog(
                                  context,
                                  position: details.localPosition,
                                );
                              }
                            },
                            onPanStart: (details) {
                              if (tool == EditorTool.draw ||
                                  tool == EditorTool.highlight) {
                                setState(() {
                                  _livePoints = [details.localPosition];
                                });
                              } else if (tool == EditorTool.shape ||
                                  tool == EditorTool.whiteout) {
                                setState(() {
                                  _shapeStart = details.localPosition;
                                  _shapeEnd = details.localPosition;
                                });
                              }
                            },
                            onPanUpdate: (details) {
                              if (tool == EditorTool.draw ||
                                  tool == EditorTool.highlight) {
                                setState(() {
                                  _livePoints.add(details.localPosition);
                                });
                              } else if (tool == EditorTool.shape ||
                                  tool == EditorTool.whiteout) {
                                setState(() {
                                  _shapeEnd = details.localPosition;
                                });
                              }
                            },
                            onPanEnd: (details) {
                              final page = controller.currentPageIndex.value;

                              if (tool == EditorTool.draw) {
                                if (_livePoints.length > 1) {
                                  controller.addDrawStroke(
                                    VisualDrawStroke(
                                      pageIndex: page,
                                      points: List.from(_livePoints),
                                      color: controller.selectedColor.value,
                                      strokeWidth: controller.strokeWidth.value,
                                      isHighlighter: false,
                                    ),
                                  );
                                }
                                setState(() => _livePoints = []);
                              } else if (tool == EditorTool.highlight) {
                                if (_livePoints.length > 1) {
                                  controller.addDrawStroke(
                                    VisualDrawStroke(
                                      pageIndex: page,
                                      points: List.from(_livePoints),
                                      color: controller.selectedColor.value,
                                      strokeWidth: 14.0,
                                      isHighlighter: true,
                                    ),
                                  );
                                }
                                setState(() => _livePoints = []);
                              } else if (tool == EditorTool.shape) {
                                if (_shapeStart != null && _shapeEnd != null) {
                                  final rect = Rect.fromPoints(
                                    _shapeStart!,
                                    _shapeEnd!,
                                  );
                                  controller.addShapeElement(
                                    VisualShapeElement(
                                      id: DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                      pageIndex: page,
                                      shapeType: controller.selectedShape.value,
                                      rect: rect,
                                      color: controller.selectedColor.value,
                                      strokeWidth: controller.strokeWidth.value,
                                    ),
                                  );
                                }
                                setState(() {
                                  _shapeStart = null;
                                  _shapeEnd = null;
                                });
                              } else if (tool == EditorTool.whiteout) {
                                if (_shapeStart != null && _shapeEnd != null) {
                                  final rect = Rect.fromPoints(
                                    _shapeStart!,
                                    _shapeEnd!,
                                  );
                                  controller.addWhiteoutElement(
                                    VisualWhiteoutElement(
                                      id: DateTime.now().millisecondsSinceEpoch
                                          .toString(),
                                      pageIndex: page,
                                      rect: rect,
                                    ),
                                  );
                                }
                                setState(() {
                                  _shapeStart = null;
                                  _shapeEnd = null;
                                });
                              }
                            },
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // Bottom Editor Toolbar
          _buildBottomEditorToolbar(context),
        ],
      ),
    );
  }

  Widget _buildToolOptionsBar(BuildContext context) {
    final colors = context.colors;

    return Obx(() {
      final tool = controller.activeTool.value;
      if (tool == EditorTool.select) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Color Palette
            Row(
              children: _palette.take(5).map((c) {
                return Obx(() {
                  final isSelected = controller.selectedColor.value == c;
                  return GestureDetector(
                    onTap: () => controller.selectedColor.value = c,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? colors.primary : Colors.grey,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),

            // Shape switcher if in shape mode
            if (tool == EditorTool.shape)
              Row(
                children: [
                  _buildShapeOption(
                    Icons.crop_square_rounded,
                    ShapeType.rectangle,
                  ),
                  _buildShapeOption(Icons.circle_outlined, ShapeType.circle),
                  _buildShapeOption(
                    Icons.horizontal_rule_rounded,
                    ShapeType.line,
                  ),
                ],
              ),

            // Stroke Width Stepper
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (controller.strokeWidth.value > 1.5) {
                      controller.strokeWidth.value -= 1.5;
                    }
                  },
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${controller.strokeWidth.value.toInt()}px',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    if (controller.strokeWidth.value < 20) {
                      controller.strokeWidth.value += 1.5;
                    }
                  },
                  child: Icon(Icons.add, size: 16, color: colors.textPrimary),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildShapeOption(IconData icon, ShapeType type) {
    return Obx(() {
      final isSelected = controller.selectedShape.value == type;
      return IconButton(
        icon: Icon(icon, size: 18),
        color: isSelected
            ? context.colors.primary
            : context.colors.textSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        constraints: const BoxConstraints(),
        onPressed: () => controller.selectedShape.value = type,
      );
    });
  }

  Widget _buildBottomEditorToolbar(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: colors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildToolButton(
              context,
              tool: EditorTool.select,
              icon: Icons.pan_tool_alt_rounded,
              label: 'Select',
            ),
            // Text Elements List for easy tapping
            _buildActionButton(
              context,
              icon: Icons.segment_rounded,
              label: 'Text Lines',
              onTap: () => _showDetectedTextSheet(context),
            ),
            _buildToolButton(
              context,
              tool: EditorTool.text,
              icon: Icons.text_fields_rounded,
              label: 'Add Text',
            ),
            _buildToolButton(
              context,
              tool: EditorTool.draw,
              icon: Icons.draw_rounded,
              label: 'Draw',
            ),
            _buildToolButton(
              context,
              tool: EditorTool.highlight,
              icon: Icons.highlight_rounded,
              label: 'Highlight',
            ),
            _buildToolButton(
              context,
              tool: EditorTool.shape,
              icon: Icons.crop_square_rounded,
              label: 'Shape',
            ),
            _buildToolButton(
              context,
              tool: EditorTool.whiteout,
              icon: Icons.auto_fix_high_rounded,
              label: 'Whiteout',
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SizedBox(
                height: 24,
                child: VerticalDivider(color: colors.divider, width: 1),
              ),
            ),

            _buildActionButton(
              context,
              icon: Icons.image_outlined,
              label: 'Image',
              onTap: _pickImageStamp,
            ),
            _buildActionButton(
              context,
              icon: Icons.rotate_right_rounded,
              label: 'Rotate',
              onTap: () => controller.rotateCurrentPage(),
            ),
            _buildActionButton(
              context,
              icon: Icons.delete_outline_rounded,
              label: 'Delete Page',
              color: Colors.red,
              onTap: () => controller.deleteCurrentPage(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(
    BuildContext context, {
    required EditorTool tool,
    required IconData icon,
    required String label,
  }) {
    final colors = context.colors;

    return Obx(() {
      final isSelected = controller.activeTool.value == tool;

      return GestureDetector(
        onTap: () {
          controller.activeTool.value = tool;
          if (tool == EditorTool.text) {
            _showAddTextDialog(context);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? colors.primary : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? colors.primary : colors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? colors.primary : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final colors = context.colors;
    final itemColor = color ?? colors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: itemColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: itemColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CanvasElementsPainter extends CustomPainter {
  final List<VisualDrawStroke> strokes;
  final List<VisualShapeElement> shapes;
  final List<VisualWhiteoutElement> whiteouts;
  final List<Offset> livePoints;
  final Color liveColor;
  final double liveStrokeWidth;
  final bool liveIsHighlighter;
  final Offset? liveShapeStart;
  final Offset? liveShapeEnd;
  final ShapeType liveShapeType;

  _CanvasElementsPainter({
    required this.strokes,
    required this.shapes,
    required this.whiteouts,
    required this.livePoints,
    required this.liveColor,
    required this.liveStrokeWidth,
    required this.liveIsHighlighter,
    this.liveShapeStart,
    this.liveShapeEnd,
    required this.liveShapeType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Whiteouts
    final whiteoutPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    for (final w in whiteouts) {
      canvas.drawRect(w.rect, whiteoutPaint);
    }

    // 2. Draw Shapes
    for (final s in shapes) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.strokeWidth
        ..style = PaintingStyle.stroke;

      if (s.shapeType == ShapeType.rectangle) {
        canvas.drawRect(s.rect, paint);
      } else if (s.shapeType == ShapeType.circle) {
        canvas.drawOval(s.rect, paint);
      } else if (s.shapeType == ShapeType.line) {
        canvas.drawLine(s.rect.topLeft, s.rect.bottomRight, paint);
      }
    }

    // 3. Draw Completed Strokes
    for (final stroke in strokes) {
      if (stroke.points.length < 2) continue;
      final paint = Paint()
        ..color = stroke.isHighlighter
            ? stroke.color.withOpacity(0.35)
            : stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (int i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // 4. Draw Live Stroke while dragging
    if (livePoints.length > 1) {
      final livePaint = Paint()
        ..color = liveIsHighlighter ? liveColor.withOpacity(0.35) : liveColor
        ..strokeWidth = liveStrokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path()..moveTo(livePoints.first.dx, livePoints.first.dy);
      for (int i = 1; i < livePoints.length; i++) {
        path.lineTo(livePoints[i].dx, livePoints[i].dy);
      }
      canvas.drawPath(path, livePaint);
    }

    // 5. Draw Live Shape while dragging
    if (liveShapeStart != null && liveShapeEnd != null) {
      final rect = Rect.fromPoints(liveShapeStart!, liveShapeEnd!);
      final paint = Paint()
        ..color = liveColor
        ..strokeWidth = liveStrokeWidth
        ..style = PaintingStyle.stroke;

      if (liveShapeType == ShapeType.rectangle) {
        canvas.drawRect(rect, paint);
      } else if (liveShapeType == ShapeType.circle) {
        canvas.drawOval(rect, paint);
      } else if (liveShapeType == ShapeType.line) {
        canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasElementsPainter oldDelegate) => true;
}

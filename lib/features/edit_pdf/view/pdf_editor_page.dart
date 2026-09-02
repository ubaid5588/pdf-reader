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
  final TransformationController _transformationController =
      TransformationController();

  List<Offset> _livePoints = [];
  Offset? _shapeStart;
  Offset? _shapeEnd;
  String? _selectedElementId;
  String? _selectedExtractedId;
  String? _selectedImageId;

  final List<Color> _palette = const [
    Color(0xFF000000), // Black
    Color(0xFFFFFFFF), // White
    Color(0xFF2563EB), // Blue
    Color(0xFFDC2626), // Red
    Color(0xFF16A34A), // Green
    Color(0xFFEAB308), // Yellow
    Color(0xFFEA580C), // Orange
    Color(0xFF9333EA), // Purple
  ];

  final TextEditingController _inlineTextController = TextEditingController();
  final FocusNode _inlineTextFocusNode = FocusNode();
  double _lastKeyboardHeight = 0.0;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EditPdfController>()
        ? Get.find<EditPdfController>()
        : Get.put(EditPdfController());
  }

  @override
  void dispose() {
    _commitInlineTextEdit();
    _transformationController.dispose();
    _inlineTextController.dispose();
    _inlineTextFocusNode.dispose();
    super.dispose();
  }

  void _ensureActiveFieldVisible({
    required double keyboardHeight,
    required double canvasHeight,
    required Size pageSize,
    required Size canvasSize,
  }) {
    if (_selectedExtractedId == null || keyboardHeight <= 0) return;

    final item = controller.extractedTextItems
        .firstWhereOrNull((t) => t.id == _selectedExtractedId);
    if (item == null) return;

    final renderRect = EditPdfController.computePdfPageRenderRect(
      pageSize: pageSize,
      canvasSize: canvasSize,
    );
    final double scale = renderRect.width / pageSize.width;

    final fieldSceneTop = renderRect.top +
        (item.customPosition?.dy ?? item.originalBounds.top) * scale;
    final fieldSceneBottom =
        fieldSceneTop + (item.originalBounds.height * scale);

    final matrix = _transformationController.value;
    final currentScale = matrix.getMaxScaleOnAxis();
    final currentTy = matrix.storage[13]; // Translation Y
    final currentTx = matrix.storage[12]; // Translation X

    final fieldViewportBottom = (fieldSceneBottom * currentScale) + currentTy;
    final fieldViewportTop = (fieldSceneTop * currentScale) + currentTy;

    // Available height in canvas above keyboard and comfortable margin
    const double comfortableMargin = 28.0;
    final double visibleBottom =
        canvasHeight - keyboardHeight - comfortableMargin;

    if (fieldViewportBottom > visibleBottom) {
      final double deltaY = visibleBottom - fieldViewportBottom;
      final newTy = currentTy + deltaY;

      _transformationController.value = Matrix4.identity()
        ..scale(currentScale, currentScale, 1.0)
        ..setTranslationRaw(currentTx, newTy, 0.0);
    } else if (fieldViewportTop < 16.0) {
      final double deltaY = 16.0 - fieldViewportTop;
      final newTy = currentTy + deltaY;

      _transformationController.value = Matrix4.identity()
        ..scale(currentScale, currentScale, 1.0)
        ..setTranslationRaw(currentTx, newTy, 0.0);
    }
  }

  void _startEditingExtractedText(ExtractedPdfTextItem item) {
    if (_selectedExtractedId == item.id) {
      _inlineTextFocusNode.requestFocus();
      return;
    }
    _commitInlineTextEdit();
    setState(() {
      _selectedExtractedId = item.id;
      _inlineTextController.text = item.currentText;
      _inlineTextController.selection = TextSelection.collapsed(
        offset: item.currentText.length,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inlineTextFocusNode.requestFocus();
        final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
        final page = controller.currentPageIndex.value;
        final pageSize =
            controller.originalPageSizes[page] ?? const Size(595, 842);
        final renderBox =
            _canvasKey.currentContext?.findRenderObject() as RenderBox?;
        final canvasSize = renderBox?.size ?? const Size(360, 500);

        _ensureActiveFieldVisible(
          keyboardHeight: keyboardHeight > 0 ? keyboardHeight : 280.0,
          canvasHeight: canvasSize.height,
          pageSize: pageSize,
          canvasSize: canvasSize,
        );
      }
    });
  }

  void _commitInlineTextEdit() {
    if (_selectedExtractedId == null) return;
    final currentId = _selectedExtractedId;
    final text = _inlineTextController.text;
    final itemIndex =
        controller.extractedTextItems.indexWhere((t) => t.id == currentId);
    if (itemIndex != -1) {
      final item = controller.extractedTextItems[itemIndex];
      if (item.currentText != text) {
        controller.updateExtractedTextItem(
          item.copyWith(
            currentText: text,
            isEdited: true,
            isDeleted: text.isEmpty,
          ),
        );
      }
    }
  }

  void _stopEditing() {
    _commitInlineTextEdit();
    _inlineTextFocusNode.unfocus();
    if (_selectedExtractedId != null ||
        _selectedElementId != null ||
        _selectedImageId != null) {
      setState(() {
        _selectedExtractedId = null;
        _selectedElementId = null;
        _selectedImageId = null;
      });
    }
  }

  VisualTextElement? get _selectedTextElement {
    if (_selectedElementId == null) return null;
    return controller.textElements
        .firstWhereOrNull((e) => e.id == _selectedElementId);
  }

  ExtractedPdfTextItem? get _selectedExtractedTextItem {
    if (_selectedExtractedId == null) return null;
    return controller.extractedTextItems
        .firstWhereOrNull((e) => e.id == _selectedExtractedId);
  }

  void _changeSelectedTextSize(double delta) {
    final textEl = _selectedTextElement;
    if (textEl != null) {
      setState(() {
        textEl.fontSize = (textEl.fontSize + delta).clamp(8.0, 64.0);
      });
      controller.textElements.refresh();
      return;
    }
    final extractedEl = _selectedExtractedTextItem;
    if (extractedEl != null) {
      setState(() {
        extractedEl.fontSize = (extractedEl.fontSize + delta).clamp(8.0, 64.0);
        extractedEl.isEdited = true;
      });
      controller.extractedTextItems.refresh();
    }
  }

  void _setSelectedTextSize(double size) {
    final textEl = _selectedTextElement;
    if (textEl != null) {
      setState(() {
        textEl.fontSize = size.clamp(8.0, 64.0);
      });
      controller.textElements.refresh();
      return;
    }
    final extractedEl = _selectedExtractedTextItem;
    if (extractedEl != null) {
      setState(() {
        extractedEl.fontSize = size.clamp(8.0, 64.0);
        extractedEl.isEdited = true;
      });
      controller.extractedTextItems.refresh();
    }
  }

  void _setSelectedTextColor(Color color) {
    final textEl = _selectedTextElement;
    if (textEl != null) {
      setState(() {
        textEl.color = color;
      });
      controller.textElements.refresh();
      return;
    }
    final extractedEl = _selectedExtractedTextItem;
    if (extractedEl != null) {
      setState(() {
        extractedEl.textColor = color;
        extractedEl.isEdited = true;
      });
      controller.extractedTextItems.refresh();
    }
  }

  Widget _buildFormatToggle({
    required String label,
    required bool isActive,
    bool isBold = false,
    bool isItalic = false,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? colors.primary.withOpacity(0.18) : colors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? colors.primary : colors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            color: isActive ? colors.primary : colors.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _showEditTextContentDialog(
    BuildContext context,
    VisualTextElement textEl,
  ) async {
    final colors = context.colors;
    final textController = TextEditingController(text: textEl.text);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Edit Text',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: TextStyle(color: colors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final newText = textController.text.trim();
              if (newText.isNotEmpty) {
                setState(() {
                  textEl.text = newText;
                });
                controller.textElements.refresh();
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTextToolbar(BuildContext context) {
    final colors = context.colors;
    final textEl = _selectedTextElement;
    final extractedEl = _selectedExtractedTextItem;

    if (textEl == null && extractedEl == null) {
      return const SizedBox.shrink();
    }

    final double currentSize =
        textEl?.fontSize ?? extractedEl?.fontSize ?? 15.0;
    final Color currentColor =
        textEl?.color ?? extractedEl?.textColor ?? Colors.black;
    final bool isBold = textEl?.isBold ?? extractedEl?.isBold ?? false;
    final bool isItalic = textEl?.isItalic ?? extractedEl?.isItalic ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.primary.withOpacity(0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected Text Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.text_fields_rounded,
                    size: 14,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Text',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 20,
              child: VerticalDivider(color: colors.border, width: 1),
            ),
            const SizedBox(width: 8),

            // Font Size Stepper
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _changeSelectedTextSize(-2.0),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.remove,
                        size: 15,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${currentSize.toInt()}px',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _changeSelectedTextSize(2.0),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        Icons.add,
                        size: 15,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            // Font Size Slider for smooth real-time drag
            SizedBox(
              width: 100,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2.5,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 12),
                ),
                child: Slider(
                  value: currentSize.clamp(8.0, 60.0),
                  min: 8.0,
                  max: 60.0,
                  divisions: 52,
                  activeColor: colors.primary,
                  inactiveColor: colors.border,
                  onChanged: (val) => _setSelectedTextSize(val),
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              height: 20,
              child: VerticalDivider(color: colors.border, width: 1),
            ),
            const SizedBox(width: 8),

            // Color Palette (Including White and Black!)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: _palette.map((c) {
                final isSelected = currentColor.value == c.value;
                return GestureDetector(
                  onTap: () => _setSelectedTextColor(c),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? colors.primary
                            : (c == const Color(0xFFFFFFFF)
                                ? Colors.grey.shade400
                                : (c == const Color(0xFF000000)
                                    ? Colors.grey.shade600
                                    : Colors.transparent)),
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: c == const Color(0xFFFFFFFF)
                                    ? Colors.black.withOpacity(0.15)
                                    : c.withOpacity(0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 20,
              child: VerticalDivider(color: colors.border, width: 1),
            ),
            const SizedBox(width: 8),

            // Bold & Italic Style Toggles
            _buildFormatToggle(
              label: 'B',
              isActive: isBold,
              isBold: true,
              onTap: () {
                if (textEl != null) {
                  setState(() => textEl.isBold = !textEl.isBold);
                  controller.textElements.refresh();
                } else if (extractedEl != null) {
                  setState(() {
                    extractedEl.isBold = !extractedEl.isBold;
                    extractedEl.isEdited = true;
                  });
                  controller.extractedTextItems.refresh();
                }
              },
            ),
            const SizedBox(width: 4),
            _buildFormatToggle(
              label: 'I',
              isActive: isItalic,
              isItalic: true,
              onTap: () {
                if (textEl != null) {
                  setState(() => textEl.isItalic = !textEl.isItalic);
                  controller.textElements.refresh();
                } else if (extractedEl != null) {
                  setState(() {
                    extractedEl.isItalic = !extractedEl.isItalic;
                    extractedEl.isEdited = true;
                  });
                  controller.extractedTextItems.refresh();
                }
              },
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 20,
              child: VerticalDivider(color: colors.border, width: 1),
            ),
            const SizedBox(width: 8),

            // Edit Text String button
            if (textEl != null) ...[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _showEditTextContentDialog(context, textEl),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: colors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_rounded,
                        size: 13,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],

            // Delete Button
            if (textEl != null) ...[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller.removeTextElement(textEl.id);
                  setState(() {
                    _selectedElementId = null;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 14,
                        color: Colors.red,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Delete',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],

            // Done / Deselect Button
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _selectedElementId = null;
                  _selectedExtractedId = null;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, size: 13, color: Colors.white),
                    SizedBox(width: 3),
                    Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSave(BuildContext context, AppLocalizations l10n) {
    _commitInlineTextEdit();
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
                              controller.goToPage(item.pageIndex);
                              _startEditingExtractedText(item);
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
                  const SizedBox(height: 12),

                  // Font Size Slider
                  Row(
                    children: [
                      Text(
                        'Size: ${fontSize.toInt()}px',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: fontSize,
                          min: 10.0,
                          max: 48.0,
                          divisions: 38,
                          activeColor: colors.primary,
                          onChanged: (v) => setState(() => fontSize = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

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

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _palette.map((c) {
                        final isSelected = textColor.value == c.value;
                        return GestureDetector(
                          onTap: () => setState(() => textColor = c),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? colors.primary
                                    : (c == const Color(0xFFFFFFFF)
                                        ? Colors.grey.shade400
                                        : (c == const Color(0xFF000000)
                                            ? Colors.grey.shade600
                                            : Colors.transparent)),
                                width: isSelected ? 2.5 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: c == const Color(0xFFFFFFFF)
                                            ? Colors.black.withOpacity(0.15)
                                            : c.withOpacity(0.4),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
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
                    final newId =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    controller.addTextElement(
                      VisualTextElement(
                        id: newId,
                        pageIndex: controller.currentPageIndex.value,
                        text: text,
                        position: pos,
                        fontSize: fontSize,
                        color: textColor,
                        isBold: isBold,
                        backgroundColor: isWhiteout ? Colors.white : null,
                      ),
                    );
                    this.setState(() {
                      _selectedElementId = newId;
                      _selectedExtractedId = null;
                      _selectedImageId = null;
                    });
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
      final page = controller.currentPageIndex.value;
      final origSize =
          controller.originalPageSizes[page] ?? const Size(595, 842);
      const initialWidth = 140.0;
      const initialHeight = 140.0;
      final centerX =
          ((origSize.width - initialWidth) / 2).clamp(20.0, origSize.width);
      final centerY =
          ((origSize.height - initialHeight) / 2).clamp(20.0, origSize.height);

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      controller.addImageElement(
        VisualImageElement(
          id: id,
          pageIndex: page,
          imageBytes: bytes,
          position: Offset(centerX, centerY),
          size: const Size(initialWidth, initialHeight),
        ),
      );
      setState(() {
        _selectedImageId = id;
        _selectedExtractedId = null;
        _selectedElementId = null;
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to add image: $e');
    }
  }

  Widget _buildCornerHandle() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF1E88E5),
          width: 2.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0 && keyboardHeight != _lastKeyboardHeight) {
      _lastKeyboardHeight = keyboardHeight;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final page = controller.currentPageIndex.value;
        final pageSize = controller.originalPageSizes[page] ??
            const Size(595, 842);
        final renderBox =
            _canvasKey.currentContext?.findRenderObject() as RenderBox?;
        final canvasSize = renderBox?.size ?? const Size(360, 500);

        _ensureActiveFieldVisible(
          keyboardHeight: keyboardHeight,
          canvasHeight: canvasSize.height,
          pageSize: pageSize,
          canvasSize: canvasSize,
        );
      });
    } else if (keyboardHeight == 0) {
      _lastKeyboardHeight = 0.0;
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      ? () {
                          _stopEditing();
                          controller.goToPrevPage();
                        }
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
                      ? () {
                          _stopEditing();
                          controller.goToNextPage();
                        }
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

                  return Obx(() {
                    final page = controller.currentPageIndex.value;
                    final origSize = controller.originalPageSizes[page] ??
                        const Size(595, 842);
                    final rotation = controller.pageRotations[page] ?? 0;
                    final isRotated90or270 = rotation == 90 || rotation == 270;
                    final pageSize = isRotated90or270
                        ? Size(origSize.height, origSize.width)
                        : origSize;

                    final renderRect =
                        EditPdfController.computePdfPageRenderRect(
                      pageSize: pageSize,
                      canvasSize: Size(canvasWidth, canvasHeight),
                    );
                    final double scale = renderRect.width / pageSize.width;

                    return InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 1.0,
                      maxScale: 4.0,
                      boundaryMargin: const EdgeInsets.symmetric(
                        vertical: 600,
                        horizontal: 100,
                      ),
                      panEnabled:
                          controller.activeTool.value == EditorTool.select,
                      scaleEnabled:
                          controller.activeTool.value == EditorTool.select,
                      child: SizedBox(
                        width: canvasWidth,
                        height: canvasHeight,
                        child: Stack(
                          key: _canvasKey,
                          children: [
                            // 1. Live Visual PDF Background (fitted inside renderRect, rotated live)
                            if (controller.sourceFile.value != null)
                              Positioned.fromRect(
                                rect: renderRect,
                                child: IgnorePointer(
                                  ignoring: true,
                                  child: RotatedBox(
                                    quarterTurns: (rotation ~/ 90) % 4,
                                    child: SizedBox(
                                      width: isRotated90or270
                                          ? renderRect.height
                                          : renderRect.width,
                                      height: isRotated90or270
                                          ? renderRect.width
                                          : renderRect.height,
                                      child: SfPdfViewer.file(
                                        controller.sourceFile.value!,
                                        controller:
                                            controller.pdfViewerController,
                                        pageLayoutMode:
                                            PdfPageLayoutMode.single,
                                        canShowScrollHead: false,
                                        canShowScrollStatus: false,
                                        enableDoubleTapZooming: false,
                                        enableTextSelection: false,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            // 2. Extracted Interactive Text Layer (Subtle, accurate bounding boxes)
                            Obx(() {
                              final pageExtracted = controller.extractedTextItems
                                  .where(
                                    (t) => t.pageIndex == page && !t.isDeleted,
                                  )
                                  .toList();

                              return Stack(
                                children: pageExtracted.map((item) {
                                  final isSelected =
                                      _selectedExtractedId == item.id;
                                  final pos = item.customPosition ??
                                      item.originalBounds.topLeft;

                                  final left = renderRect.left + pos.dx * scale;
                                  final top = renderRect.top + pos.dy * scale;
                                  final width =
                                      (item.originalBounds.width * scale).clamp(
                                        8.0,
                                        renderRect.width,
                                      );
                                  final height =
                                      (item.originalBounds.height * scale).clamp(
                                        8.0,
                                        renderRect.height,
                                      );

                                  return Positioned(
                                    left: left,
                                    top: top,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        _startEditingExtractedText(item);
                                      },
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: (isSelected || item.isEdited)
                                                ? null
                                                : width,
                                            height:
                                                (isSelected || item.isEdited)
                                                    ? null
                                                    : height,
                                            constraints: BoxConstraints(
                                              minWidth: width,
                                              minHeight: height,
                                            ),
                                            padding: (isSelected ||
                                                    item.isEdited)
                                                ? const EdgeInsets.symmetric(
                                                    horizontal: 3,
                                                    vertical: 1,
                                                  )
                                                : EdgeInsets.zero,
                                            decoration: BoxDecoration(
                                              color: (isSelected ||
                                                      item.isEdited)
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFF1E88E5)
                                                    : (item.isEdited
                                                        ? const Color(
                                                                0xFF1E88E5)
                                                            .withOpacity(0.6)
                                                        : Colors.grey
                                                            .withOpacity(0.35)),
                                                width: isSelected ? 2.0 : 0.8,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(2),
                                            ),
                                            child: isSelected
                                                ? IntrinsicWidth(
                                                    child: TextField(
                                                      controller:
                                                          _inlineTextController,
                                                      focusNode:
                                                          _inlineTextFocusNode,
                                                      autofocus: true,
                                                      maxLines: null,
                                                      cursorColor: const Color(
                                                          0xFF1E88E5),
                                                      style: TextStyle(
                                                        fontSize:
                                                            item.fontSize *
                                                                scale,
                                                        fontWeight: item.isBold
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        fontStyle: item.isItalic
                                                            ? FontStyle.italic
                                                            : FontStyle.normal,
                                                        color: item.textColor,
                                                        height: 1.15,
                                                      ),
                                                      decoration:
                                                          const InputDecoration(
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets
                                                                .symmetric(
                                                          horizontal: 2,
                                                          vertical: 0,
                                                        ),
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                      onChanged: (val) {
                                                        controller
                                                            .updateExtractedText(
                                                          item.id,
                                                          newText: val,
                                                        );
                                                      },
                                                    ),
                                                  )
                                                : (item.isEdited
                                                    ? Text(
                                                        item.currentText,
                                                        style: TextStyle(
                                                          fontSize:
                                                              item.fontSize *
                                                                  scale,
                                                          fontWeight: item
                                                                  .isBold
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                          fontStyle: item
                                                                  .isItalic
                                                              ? FontStyle.italic
                                                              : FontStyle
                                                                  .normal,
                                                          color: item.textColor,
                                                          height: 1.15,
                                                        ),
                                                      )
                                                    : null),
                                          ),

                                          // Selection handles and pin (Matching reference image)
                                          if (isSelected) ...[
                                            // 4 corner circular handles
                                            Positioned(
                                              top: -6,
                                              left: -6,
                                              child: _buildCornerHandle(),
                                            ),
                                            Positioned(
                                              bottom: -6,
                                              left: -6,
                                              child: _buildCornerHandle(),
                                            ),
                                            Positioned(
                                              top: -6,
                                              right: -6,
                                              child: _buildCornerHandle(),
                                            ),
                                            Positioned(
                                              bottom: -6,
                                              right: -6,
                                              child: _buildCornerHandle(),
                                            ),

                                            // Bottom-right teardrop action pin / finish editing button
                                            Positioned(
                                              bottom: -24,
                                              right: -10,
                                              child: GestureDetector(
                                                onTap: () => _stopEditing(),
                                                child: Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF1E88E5),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(
                                                                0xFF1E88E5)
                                                            .withOpacity(0.4),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.check_rounded,
                                                      size: 13,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }),

                            // 3. Custom Painter Layer (Drawings, Highlights, Shapes, Whiteouts)
                            Positioned.fill(
                              child: Obx(() {
                                final pageStrokes = controller.drawStrokes
                                    .where((s) => s.pageIndex == page)
                                    .toList();
                                final pageShapes = controller.shapeElements
                                    .where((s) => s.pageIndex == page)
                                    .toList();
                                final pageWhiteouts = controller
                                    .whiteoutElements
                                    .where((w) => w.pageIndex == page)
                                    .toList();

                                final isHighlighter =
                                    controller.activeTool.value ==
                                        EditorTool.highlight;
                                final effectiveLiveColor = isHighlighter
                                    ? controller.selectedColor.value
                                        .withOpacity(
                                          controller.highlightOpacity.value,
                                        )
                                    : controller.selectedColor.value;

                                return CustomPaint(
                                  painter: _CanvasElementsPainter(
                                    strokes: pageStrokes,
                                    shapes: pageShapes,
                                    whiteouts: pageWhiteouts,
                                    livePoints: _livePoints,
                                    liveColor: effectiveLiveColor,
                                    liveStrokeWidth:
                                        controller.strokeWidth.value,
                                    liveIsHighlighter: isHighlighter,
                                    liveShapeStart: _shapeStart,
                                    liveShapeEnd: _shapeEnd,
                                    liveShapeType:
                                        controller.selectedShape.value,
                                  ),
                                );
                              }),
                            ),

                            // 4. Master Canvas Gesture Handler (Accurate touch anywhere on text & tools)
                            Positioned.fill(
                              child: Obx(() {
                                final tool = controller.activeTool.value;
                                if (tool == EditorTool.select) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTapUp: (details) {
                                      final scenePos = _transformationController
                                          .toScene(details.localPosition);
                                      if (!renderRect
                                          .inflate(12)
                                          .contains(scenePos)) {
                                        _stopEditing();
                                        return;
                                      }

                                      // Hit-test user-added text elements
                                      final pageTexts = controller
                                          .textElements
                                          .where((t) => t.pageIndex == page)
                                          .toList();
                                      final hitAdded = pageTexts
                                          .firstWhereOrNull((el) {
                                        final textW =
                                            (el.text.length * el.fontSize * 0.7)
                                                .clamp(36.0, 500.0);
                                        final textH = (el.fontSize * 1.5)
                                            .clamp(24.0, 100.0);
                                        final rect = Rect.fromLTWH(
                                          el.position.dx - 8,
                                          el.position.dy - 8,
                                          textW + 16,
                                          textH + 16,
                                        );
                                        return rect.contains(scenePos);
                                      });

                                      if (hitAdded != null) {
                                        setState(() {
                                          _selectedElementId = hitAdded.id;
                                          _selectedExtractedId = null;
                                          _selectedImageId = null;
                                        });
                                        return;
                                      }

                                      final pdfX =
                                          (scenePos.dx - renderRect.left) /
                                              scale;
                                      final pdfY =
                                          (scenePos.dy - renderRect.top) /
                                              scale;
                                      final pdfPoint = Offset(pdfX, pdfY);

                                      final match = controller
                                          .findExtractedTextAt(
                                            page,
                                            pdfPoint,
                                          );
                                      if (match != null) {
                                        _startEditingExtractedText(match);
                                      } else {
                                        _stopEditing();
                                      }
                                    },
                                  );
                                }

                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (details) {
                                    final scenePos = _transformationController
                                        .toScene(details.localPosition);
                                    if (tool == EditorTool.text) {
                                      final pageTexts = controller
                                          .textElements
                                          .where((t) => t.pageIndex == page)
                                          .toList();
                                      final hitAdded = pageTexts
                                          .firstWhereOrNull((el) {
                                        final textW =
                                            (el.text.length * el.fontSize * 0.7)
                                                .clamp(36.0, 500.0);
                                        final textH = (el.fontSize * 1.5)
                                            .clamp(24.0, 100.0);
                                        final rect = Rect.fromLTWH(
                                          el.position.dx - 8,
                                          el.position.dy - 8,
                                          textW + 16,
                                          textH + 16,
                                        );
                                        return rect.contains(scenePos);
                                      });

                                      if (hitAdded != null) {
                                        setState(() {
                                          _selectedElementId = hitAdded.id;
                                          _selectedExtractedId = null;
                                          _selectedImageId = null;
                                        });
                                        return;
                                      }

                                      _showAddTextDialog(
                                        context,
                                        position: scenePos,
                                      );
                                    }
                                  },
                                  onPanStart: (details) {
                                    final scenePos = _transformationController
                                        .toScene(details.localPosition);
                                    if (tool == EditorTool.draw ||
                                        tool == EditorTool.highlight) {
                                      setState(() {
                                        _livePoints = [scenePos];
                                      });
                                    } else if (tool == EditorTool.shape ||
                                        tool == EditorTool.whiteout) {
                                      setState(() {
                                        _shapeStart = scenePos;
                                        _shapeEnd = scenePos;
                                      });
                                    }
                                  },
                                  onPanUpdate: (details) {
                                    final scenePos = _transformationController
                                        .toScene(details.localPosition);
                                    if (tool == EditorTool.draw ||
                                        tool == EditorTool.highlight) {
                                      setState(() {
                                        _livePoints.add(scenePos);
                                      });
                                    } else if (tool == EditorTool.shape ||
                                        tool == EditorTool.whiteout) {
                                      setState(() {
                                        _shapeEnd = scenePos;
                                      });
                                    }
                                  },
                                  onPanEnd: (details) {
                                    final page =
                                        controller.currentPageIndex.value;

                                    if (tool == EditorTool.draw) {
                                      if (_livePoints.length > 1) {
                                        controller.addDrawStroke(
                                          VisualDrawStroke(
                                            pageIndex: page,
                                            points: List.from(_livePoints),
                                            color: controller
                                                .selectedColor.value,
                                            strokeWidth: controller
                                                .strokeWidth.value,
                                            isHighlighter: false,
                                          ),
                                        );
                                      }
                                      setState(() => _livePoints = []);
                                    } else if (tool == EditorTool.highlight) {
                                      if (_livePoints.length > 1) {
                                        final highlightColor = controller
                                            .selectedColor.value
                                            .withOpacity(
                                              controller.highlightOpacity.value,
                                            );
                                        controller.addDrawStroke(
                                          VisualDrawStroke(
                                            pageIndex: page,
                                            points: List.from(_livePoints),
                                            color: highlightColor,
                                            strokeWidth:
                                                controller.strokeWidth.value,
                                            isHighlighter: true,
                                          ),
                                        );
                                      }
                                      setState(() => _livePoints = []);
                                    } else if (tool == EditorTool.shape) {
                                      if (_shapeStart != null &&
                                          _shapeEnd != null) {
                                        final rect = Rect.fromPoints(
                                          _shapeStart!,
                                          _shapeEnd!,
                                        );
                                        controller.addShapeElement(
                                          VisualShapeElement(
                                            id: DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString(),
                                            pageIndex: page,
                                            shapeType: controller
                                                .selectedShape.value,
                                            rect: rect,
                                            color: controller
                                                .selectedColor.value,
                                            strokeWidth: controller
                                                .strokeWidth.value,
                                          ),
                                        );
                                      }
                                      setState(() {
                                        _shapeStart = null;
                                        _shapeEnd = null;
                                      });
                                    } else if (tool == EditorTool.whiteout) {
                                      if (_shapeStart != null &&
                                          _shapeEnd != null) {
                                        final rect = Rect.fromPoints(
                                          _shapeStart!,
                                          _shapeEnd!,
                                        );
                                        controller.addWhiteoutElement(
                                          VisualWhiteoutElement(
                                            id: DateTime.now()
                                                .millisecondsSinceEpoch
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

                            // 5. User-added Image Stamps (Draggable + Resizable + Working Delete Button)
                            Obx(() {
                              final pageImages = controller.imageElements
                                  .where((img) => img.pageIndex == page)
                                  .toList();

                              return Stack(
                                children: pageImages.map((img) {
                                  final isSelected =
                                      _selectedImageId == img.id;

                                  return Positioned(
                                    left: img.position.dx,
                                    top: img.position.dy,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() {
                                          _selectedImageId = img.id;
                                          _selectedExtractedId = null;
                                          _selectedElementId = null;
                                        });
                                      },
                                      onPanUpdate: (details) {
                                        setState(() {
                                          _selectedImageId = img.id;
                                          img.position += details.delta;
                                        });
                                      },
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            width: img.size.width,
                                            height: img.size.height,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isSelected
                                                    ? const Color(0xFF1E88E5)
                                                    : colors.primary
                                                        .withOpacity(0.5),
                                                width: isSelected ? 2.0 : 1.0,
                                              ),
                                            ),
                                            child: Image.memory(
                                              img.imageBytes,
                                              fit: BoxFit.cover,
                                              width: img.size.width,
                                              height: img.size.height,
                                            ),
                                          ),

                                          // Working Close / Delete Button (Top-Right)
                                          Positioned(
                                            top: -12,
                                            right: -12,
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onTap: () {
                                                controller.removeImageElement(
                                                  img.id,
                                                );
                                                if (_selectedImageId ==
                                                    img.id) {
                                                  setState(() =>
                                                      _selectedImageId = null);
                                                }
                                              },
                                              child: Container(
                                                width: 28,
                                                height: 28,
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.3),
                                                      blurRadius: 4,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Corner Resize Handle (Bottom-Right)
                                          Positioned(
                                            bottom: -12,
                                            right: -12,
                                            child: GestureDetector(
                                              behavior: HitTestBehavior.opaque,
                                              onPanUpdate: (details) {
                                                setState(() {
                                                  _selectedImageId = img.id;
                                                  final newWidth = (img.size.width +
                                                          details.delta.dx)
                                                      .clamp(40.0, 600.0);
                                                  final newHeight = (img.size.height +
                                                          details.delta.dy)
                                                      .clamp(40.0, 600.0);
                                                  img.size = Size(
                                                    newWidth,
                                                    newHeight,
                                                  );
                                                });
                                              },
                                              child: Container(
                                                width: 26,
                                                height: 26,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFF1E88E5),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.white,
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.25),
                                                      blurRadius: 3,
                                                      offset:
                                                          const Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.open_in_full_rounded,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }),

                            // 6. User-added Text Elements
                            Obx(() {
                              final pageTexts = controller.textElements
                                  .where((t) => t.pageIndex == page)
                                  .toList();

                              return Stack(
                                children: pageTexts.map((textEl) {
                                  final isSelected =
                                      _selectedElementId == textEl.id;

                                  return Positioned(
                                    left: textEl.position.dx,
                                    top: textEl.position.dy,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() {
                                          _selectedElementId = isSelected
                                              ? null
                                              : textEl.id;
                                          _selectedExtractedId = null;
                                          _selectedImageId = null;
                                        });
                                      },
                                      onPanUpdate: (details) {
                                        setState(() {
                                          textEl.position += details.delta;
                                        });
                                      },
                                      child: Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 28,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: textEl.backgroundColor ??
                                              (isSelected
                                                  ? colors.primary
                                                      .withOpacity(0.12)
                                                  : Colors.transparent),
                                          border: Border.all(
                                            color: isSelected
                                                ? colors.primary
                                                : Colors.transparent,
                                            width: isSelected ? 1.8 : 0,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: colors.primary
                                                        .withOpacity(0.2),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ]
                                              : null,
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
                                              const SizedBox(width: 8),
                                              GestureDetector(
                                                behavior:
                                                    HitTestBehavior.opaque,
                                                onTap: () {
                                                  controller.removeTextElement(
                                                    textEl.id,
                                                  );
                                                  setState(() {
                                                    _selectedElementId = null;
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration:
                                                      const BoxDecoration(
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
                          ],
                        ),
                      ),
                    );
                  });
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
      if (_selectedElementId != null || _selectedExtractedId != null) {
        return _buildSelectedTextToolbar(context);
      }

      final tool = controller.activeTool.value;
      if (tool == EditorTool.select) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shape switcher if in shape mode
              if (tool == EditorTool.shape) ...[
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildShapeOption(
                        Icons.crop_square_rounded,
                        ShapeType.rectangle,
                      ),
                      _buildShapeOption(
                        Icons.circle_outlined,
                        ShapeType.circle,
                      ),
                      _buildShapeOption(
                        Icons.horizontal_rule_rounded,
                        ShapeType.line,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 20,
                  child: VerticalDivider(
                    color: colors.border,
                    width: 1,
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Color Palette (if tool uses color)
              if (tool != EditorTool.whiteout) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _palette.map((c) {
                    return Obx(() {
                      final isSelected = controller.selectedColor.value == c;
                      return GestureDetector(
                        onTap: () => controller.selectedColor.value = c,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? colors.primary
                                  : (c == const Color(0xFFFFFFFF)
                                      ? Colors.grey.shade400
                                      : (c == const Color(0xFF000000)
                                          ? Colors.grey.shade600
                                          : Colors.transparent)),
                              width: isSelected ? 2.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: c == const Color(0xFFFFFFFF)
                                          ? Colors.black.withOpacity(0.15)
                                          : c.withOpacity(0.4),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      );
                    });
                  }).toList(),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 20,
                  child: VerticalDivider(
                    color: colors.border,
                    width: 1,
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Highlight Opacity / Transparency Control (0% to 100%)
              if (tool == EditorTool.highlight) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.border, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.opacity_rounded,
                        size: 14,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 3),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (controller.highlightOpacity.value > 0.15) {
                            controller.highlightOpacity.value =
                                (controller.highlightOpacity.value - 0.1)
                                    .clamp(0.1, 1.0);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.remove,
                            size: 15,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${(controller.highlightOpacity.value * 100).round()}%',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (controller.highlightOpacity.value < 0.95) {
                            controller.highlightOpacity.value =
                                (controller.highlightOpacity.value + 0.1)
                                    .clamp(0.1, 1.0);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Icon(
                            Icons.add,
                            size: 15,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 20,
                  child: VerticalDivider(
                    color: colors.border,
                    width: 1,
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Stroke Width Stepper
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final step = tool == EditorTool.highlight ? 2.0 : 1.5;
                        final minW = tool == EditorTool.highlight ? 6.0 : 1.5;
                        if (controller.strokeWidth.value > minW) {
                          controller.strokeWidth.value =
                              (controller.strokeWidth.value - step)
                                  .clamp(minW, 40.0);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.remove,
                          size: 16,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${controller.strokeWidth.value.toInt()}px',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final step = tool == EditorTool.highlight ? 2.0 : 1.5;
                        const maxW = 40.0;
                        if (controller.strokeWidth.value < maxW) {
                          controller.strokeWidth.value =
                              (controller.strokeWidth.value + step)
                                  .clamp(1.5, maxW);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Icon(
                          Icons.add,
                          size: 16,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Real-Time Stroke / Highlight Preview Swatch
              if (tool == EditorTool.highlight ||
                  tool == EditorTool.draw ||
                  tool == EditorTool.shape) ...[
                const SizedBox(width: 8),
                Container(
                  width: 38,
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: colors.border, width: 0.8),
                  ),
                  child: Center(
                    child: Container(
                      width: 28,
                      height: (controller.strokeWidth.value / 2.5)
                          .clamp(3.0, 16.0),
                      decoration: BoxDecoration(
                        color: tool == EditorTool.highlight
                            ? controller.selectedColor.value.withOpacity(
                                controller.highlightOpacity.value,
                              )
                            : controller.selectedColor.value,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildShapeOption(IconData icon, ShapeType type) {
    return Obx(() {
      final isSelected = controller.selectedShape.value == type;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => controller.selectedShape.value = type,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? context.colors.primary.withOpacity(0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isSelected
                ? context.colors.primary
                : context.colors.textSecondary,
          ),
        ),
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
          if (tool == EditorTool.highlight) {
            if (controller.strokeWidth.value < 8.0) {
              controller.strokeWidth.value = 16.0;
            }
          } else if (tool == EditorTool.draw) {
            if (controller.strokeWidth.value > 15.0) {
              controller.strokeWidth.value = 3.0;
            }
          } else if (tool == EditorTool.text) {
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
        ..color = stroke.color
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
        ..color = liveColor
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

import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/converter/view/conversion_processing_page.dart';
import 'package:file_reader/features/create_pdf/controller/create_pdf_controller.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreatePdfPage extends StatefulWidget {
  const CreatePdfPage({super.key});

  @override
  State<CreatePdfPage> createState() => _CreatePdfPageState();
}

class _CreatePdfPageState extends State<CreatePdfPage> {
  late final CreatePdfController controller;
  bool _showColorPicker = false;

  final List<Color> _colorPalette = const [
    Color(0xFF1E293B), // Slate / Dark
    Color(0xFF0F172A), // Black
    Color(0xFF2563EB), // Blue
    Color(0xFFDC2626), // Red
    Color(0xFF16A34A), // Green
    Color(0xFF9333EA), // Purple
    Color(0xFFD97706), // Amber
    Color(0xFF475569), // Muted Gray
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CreatePdfController>()
        ? Get.find<CreatePdfController>()
        : Get.put(CreatePdfController());
  }

  void _handleSave(BuildContext context, AppLocalizations l10n) {
    if (controller.bodyController.text.trim().isEmpty &&
        controller.titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Empty Document',
        'Please enter document content before saving.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.to(
      () => ConversionProcessingPage(
        title: 'Create PDF',
        initialMessage: 'Generating your PDF document...',
        isEditOrganize: true,
        completedTitle: 'PDF Ready',
        completedSubtitle: 'Your new PDF is ready to view and share.',
        processOperation: (onProgress) =>
            controller.generateAndSavePdf(onProgress: onProgress),
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
          icon: Icon(Icons.arrow_back_ios_rounded, color: colors.textPrimary, size: 20),
          onPressed: () {
            if (controller.bodyController.text.isNotEmpty ||
                controller.titleController.text.isNotEmpty) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: colors.surfaceElevated,
                  title: Text('Discard Document?', style: TextStyle(color: colors.textPrimary)),
                  content: Text(
                    'You have unsaved changes. Are you sure you want to exit?',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Keep Editing', style: TextStyle(color: colors.textSecondary)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Discard', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          'Create PDF',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
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
              icon: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
              label: const Text(
                'Save PDF',
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
          // Formatting Toolbar
          _buildFormattingToolbar(context),

          // Color Palette Strip (Collapsible)
          if (_showColorPicker) _buildColorPaletteStrip(context),

          // Main Editor Sheet
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.isDark ? const Color(0xFF1E2438) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.isDark ? colors.border : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.cardShadow,
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Document Title Field
                  TextField(
                    controller: controller.titleController,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Document Title (Optional)',
                      hintStyle: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 10),
                  Divider(color: colors.divider, height: 1),
                  const SizedBox(height: 12),

                  // Document Body Field
                  Expanded(
                    child: Obx(
                      () => TextField(
                        controller: controller.bodyController,
                        maxLines: null,
                        expands: true,
                        textAlign: controller.textAlignment.value,
                        style: TextStyle(
                          fontSize: controller.fontSize.value,
                          fontWeight: controller.isBold.value
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontStyle: controller.isItalic.value
                              ? FontStyle.italic
                              : FontStyle.normal,
                          color: colors.isDark
                              ? (controller.textColor.value == Colors.black
                                  ? Colors.white
                                  : controller.textColor.value)
                              : controller.textColor.value,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Start typing your document here...\n\nUse the toolbar above to style headings, add bullet points, insert timestamps, or adjust formatting.',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: colors.textSecondary.withOpacity(0.5),
                            height: 1.5,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Quick Insert & Counter Bar
          _buildBottomStatusBar(context),
        ],
      ),
    );
  }

  Widget _buildFormattingToolbar(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Style Selector Pills
            _buildStylePill(
              context,
              'Body',
              DocumentStyleType.body,
            ),
            const SizedBox(width: 6),
            _buildStylePill(
              context,
              'H1',
              DocumentStyleType.heading1,
            ),
            const SizedBox(width: 6),
            _buildStylePill(
              context,
              'H2',
              DocumentStyleType.heading2,
            ),
            const SizedBox(width: 6),
            _buildStylePill(
              context,
              'Quote',
              DocumentStyleType.quote,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 24,
                child: VerticalDivider(color: colors.divider, width: 1),
              ),
            ),

            // Bold Toggle
            Obx(
              () => _buildIconButton(
                context,
                icon: Icons.format_bold_rounded,
                isActive: controller.isBold.value,
                onPressed: () => controller.isBold.toggle(),
                tooltip: 'Bold',
              ),
            ),

            // Italic Toggle
            Obx(
              () => _buildIconButton(
                context,
                icon: Icons.format_italic_rounded,
                isActive: controller.isItalic.value,
                onPressed: () => controller.isItalic.toggle(),
                tooltip: 'Italic',
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 24,
                child: VerticalDivider(color: colors.divider, width: 1),
              ),
            ),

            // Alignment Buttons
            Obx(
              () => _buildIconButton(
                context,
                icon: Icons.format_align_left_rounded,
                isActive: controller.textAlignment.value == TextAlign.left,
                onPressed: () =>
                    controller.textAlignment.value = TextAlign.left,
                tooltip: 'Align Left',
              ),
            ),
            Obx(
              () => _buildIconButton(
                context,
                icon: Icons.format_align_center_rounded,
                isActive: controller.textAlignment.value == TextAlign.center,
                onPressed: () =>
                    controller.textAlignment.value = TextAlign.center,
                tooltip: 'Align Center',
              ),
            ),
            Obx(
              () => _buildIconButton(
                context,
                icon: Icons.format_align_right_rounded,
                isActive: controller.textAlignment.value == TextAlign.right,
                onPressed: () =>
                    controller.textAlignment.value = TextAlign.right,
                tooltip: 'Align Right',
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                height: 24,
                child: VerticalDivider(color: colors.divider, width: 1),
              ),
            ),

            // Color Picker Toggle
            _buildIconButton(
              context,
              icon: Icons.palette_outlined,
              isActive: _showColorPicker,
              onPressed: () => setState(() {
                _showColorPicker = !_showColorPicker;
              }),
              tooltip: 'Text Color',
            ),

            // Font Size Stepper
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (controller.fontSize.value > 10) {
                        controller.fontSize.value -= 2;
                      }
                    },
                    child: Icon(Icons.remove, size: 16, color: colors.textPrimary),
                  ),
                  const SizedBox(width: 6),
                  Obx(
                    () => Text(
                      '${controller.fontSize.value.toInt()}pt',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      if (controller.fontSize.value < 36) {
                        controller.fontSize.value += 2;
                      }
                    },
                    child: Icon(Icons.add, size: 16, color: colors.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStylePill(
    BuildContext context,
    String label,
    DocumentStyleType style,
  ) {
    final colors = context.colors;

    return Obx(() {
      final isSelected = controller.currentStyle.value == style;
      return GestureDetector(
        onTap: () => controller.setStyle(style),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary
                : colors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : colors.textSecondary,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    final colors = context.colors;

    return IconButton(
      icon: Icon(icon, size: 20),
      color: isActive ? colors.primary : colors.textSecondary,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
      onPressed: onPressed,
    );
  }

  Widget _buildColorPaletteStrip(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _colorPalette.map((c) {
          return Obx(() {
            final isSelected = controller.textColor.value == c;
            return GestureDetector(
              onTap: () => controller.textColor.value = c,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? colors.primary : Colors.white,
                    width: isSelected ? 2.5 : 1.5,
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildBottomStatusBar(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: colors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Quick Insert Buttons
          Row(
            children: [
              _buildQuickActionChip(
                context,
                icon: Icons.format_list_bulleted_rounded,
                label: 'Bullet',
                onTap: controller.insertBullet,
              ),
              const SizedBox(width: 8),
              _buildQuickActionChip(
                context,
                icon: Icons.calendar_today_rounded,
                label: 'Date',
                onTap: controller.insertDate,
              ),
              const SizedBox(width: 8),
              _buildQuickActionChip(
                context,
                icon: Icons.horizontal_rule_rounded,
                label: 'Line',
                onTap: controller.insertDivider,
              ),
            ],
          ),

          // Word & Character Counter
          Obx(
            () => Text(
              '${controller.wordCount.value} words • ${controller.charCount.value} chars',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: colors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border.withOpacity(0.5), width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colors.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

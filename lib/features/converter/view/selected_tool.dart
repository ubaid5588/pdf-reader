import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/core/widgets/custom_button.dart';
import 'package:file_reader/features/converter/controller/compress_pdf_controller.dart';
import 'package:file_reader/features/converter/controller/file_to_pdf_controller.dart';
import 'package:file_reader/features/converter/controller/image_to_pdf_controller.dart';
import 'package:file_reader/features/converter/controller/protect_pdf_controller.dart';
import 'package:file_reader/features/converter/controller/remove_pages_controller.dart';
import 'package:file_reader/features/converter/controller/split_pdf_controller.dart';
import 'package:file_reader/features/converter/view/conversion_processing_page.dart';
import 'package:file_reader/features/converter/view/remove_pages_page.dart';
import 'package:file_reader/features/converter/view/split_pdf_page_selector.dart';
import 'package:file_reader/features/edit_pdf/controller/edit_pdf_controller.dart';
import 'package:file_reader/features/converter/controller/unlock_pdf_controller.dart';
import 'package:file_reader/features/converter/model/tool_type.dart';
import 'package:file_reader/features/create_pdf/view/create_pdf_page.dart';
import 'package:file_reader/features/edit_pdf/view/pdf_editor_page.dart';
import 'package:file_reader/features/merge_pdf/view/merge_pdf_page.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectedTool extends StatelessWidget {
  final ToolType toolType;
  final IconData icon;
  final Color bgColor;

  SelectedTool({
    super.key,
    required this.toolType,
    required this.icon,
    required this.bgColor,
  });

  final ImageToPdfController imageToPdfController = Get.put(
    ImageToPdfController(),
  );
  final FileToPdfController wordToPdfController = Get.put(
    FileToPdfController(),
  );

  final CompressPdfController compressPdfController = Get.put(
    CompressPdfController(),
  );

  final SplitPdfController splitPdfController = Get.put(SplitPdfController());
  final RemovePagesController removePagesController = Get.put(
    RemovePagesController(),
  );
  final ProtectPdfController protectPdfController = Get.put(
    ProtectPdfController(),
  );
  final UnlockPdfController unlockPdfController = Get.put(
    UnlockPdfController(),
  );
  final EditPdfController editPdfController = Get.put(EditPdfController());

  bool get _isEditOrganizeTool {
    switch (toolType) {
      case ToolType.createPdf:
      case ToolType.editPdf:
      case ToolType.mergePdf:
      case ToolType.splitPdf:
      case ToolType.removePages:
      case ToolType.compressPdf:
      case ToolType.protectPdf:
      case ToolType.unlockPdf:
      case ToolType.signOnPdf:
      case ToolType.ocrPdf:
      case ToolType.organizePdf:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final meta = _resolveMeta(l10n, toolType);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          meta.title,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: BoxDecoration(
                color: colors.isDark ? colors.surface : const Color(0xFFF0EFFE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.isDark ? colors.border : Colors.transparent,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.cardShadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _DocIcon(label: meta.fromLabel, color: meta.fromColor),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(
                          Icons.arrow_forward,
                          color: colors.primary,
                          size: 28,
                        ),
                      ),
                      _DocIcon(label: meta.toLabel, color: meta.toColor),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    _isEditOrganizeTool
                        ? meta.title
                        : l10n.convertTool(meta.title),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meta.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: colors.isDark ? colors.surface : const Color(0xFFF0EFFE),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.isDark ? colors.border : Colors.transparent,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.cardShadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureRow(
                    label: _isEditOrganizeTool
                        ? l10n.editOrganizeLabel1
                        : l10n.label1,
                  ),
                  const SizedBox(height: 14),
                  _FeatureRow(
                    label: _isEditOrganizeTool
                        ? l10n.editOrganizeLabel2
                        : l10n.label2,
                  ),
                  const SizedBox(height: 14),
                  _FeatureRow(
                    label: _isEditOrganizeTool
                        ? l10n.editOrganizeLabel3
                        : l10n.label3,
                  ),
                ],
              ),
            ),

            const Spacer(),

            CustomButton(
              text: meta.buttonLabel,
              width: double.infinity,
              onPressed: () async {
                switch (toolType) {
                  case ToolType.imageToPdf:
                    final imagePaths = await imageToPdfController
                        .pickImageFiles();
                    if (imagePaths != null && imagePaths.isNotEmpty) {
                      Get.to(
                        () => ConversionProcessingPage(
                          title: meta.title,
                          initialMessage:
                              'Converting ${imagePaths.length} image(s) to PDF...',
                          processOperation: (onProgress) =>
                              imageToPdfController.createPdfFromImages(
                                imagePaths,
                                onProgress: onProgress,
                              ),
                        ),
                      );
                    }
                    break;

                  case ToolType.wordToPdf:
                    final path = await wordToPdfController.pickOfficeFile(
                      OfficeFileType.word,
                    );
                    if (path != null) {
                      Get.to(
                        () => ConversionProcessingPage(
                          title: meta.title,
                          initialMessage: 'Converting Word document to PDF...',
                          processOperation: (onProgress) =>
                              wordToPdfController.convertOfficeFile(
                                path,
                                OfficeFileType.word,
                                onProgress: onProgress,
                              ),
                        ),
                      );
                    }
                    break;

                  case ToolType.pptToPdf:
                    final path = await wordToPdfController.pickOfficeFile(
                      OfficeFileType.powerpoint,
                    );
                    if (path != null) {
                      Get.to(
                        () => ConversionProcessingPage(
                          title: meta.title,
                          initialMessage:
                              'Converting PowerPoint presentation to PDF...',
                          processOperation: (onProgress) =>
                              wordToPdfController.convertOfficeFile(
                                path,
                                OfficeFileType.powerpoint,
                                onProgress: onProgress,
                              ),
                        ),
                      );
                    }
                    break;

                  case ToolType.excelToPdf:
                    final path = await wordToPdfController.pickOfficeFile(
                      OfficeFileType.excel,
                    );
                    if (path != null) {
                      Get.to(
                        () => ConversionProcessingPage(
                          title: meta.title,
                          initialMessage:
                              'Converting Excel spreadsheet to PDF...',
                          processOperation: (onProgress) =>
                              wordToPdfController.convertOfficeFile(
                                path,
                                OfficeFileType.excel,
                                onProgress: onProgress,
                              ),
                        ),
                      );
                    }
                    break;

                  case ToolType.createPdf:
                    Get.to(() => const CreatePdfPage());
                    break;

                  case ToolType.mergePdf:
                    Get.to(() => MergePdfPage());
                    break;

                  case ToolType.splitPdf:
                    final splitFile = await splitPdfController.pickPdfFile();
                    if (splitFile != null) {
                      try {
                        final total = await splitPdfController.inspectPdf(
                          splitFile,
                        );
                        Get.to(
                          () => SplitPdfPageSelectorPage(
                            file: splitFile,
                            totalPages: total,
                          ),
                        );
                      } catch (e) {
                        if (e.toString().contains('PASSWORD_REQUIRED')) {
                          final pwd = await unlockPdfController
                              .promptPassword();
                          if (pwd != null && pwd.isNotEmpty) {
                            try {
                              final total = await splitPdfController.inspectPdf(
                                splitFile,
                                password: pwd,
                              );
                              Get.to(
                                () => SplitPdfPageSelectorPage(
                                  file: splitFile,
                                  totalPages: total,
                                ),
                              );
                            } catch (err) {
                              Get.snackbar(
                                'Error',
                                'Incorrect password or unable to open PDF.',
                              );
                            }
                          }
                        } else {
                          Get.snackbar(
                            'Error',
                            e.toString().replaceAll('Exception:', '').trim(),
                          );
                        }
                      }
                    }
                    break;

                  case ToolType.removePages:
                    final remFile = await removePagesController.pickPdfFile();
                    if (remFile != null) {
                      try {
                        final total = await removePagesController.inspectPdf(
                          remFile,
                        );
                        Get.to(
                          () =>
                              RemovePagesPage(file: remFile, totalPages: total),
                        );
                      } catch (e) {
                        if (e.toString().contains('PASSWORD_REQUIRED')) {
                          final pwd = await unlockPdfController
                              .promptPassword();
                          if (pwd != null && pwd.isNotEmpty) {
                            try {
                              final total = await removePagesController
                                  .inspectPdf(remFile, password: pwd);
                              Get.to(
                                () => RemovePagesPage(
                                  file: remFile,
                                  totalPages: total,
                                ),
                              );
                            } catch (err) {
                              Get.snackbar(
                                'Error',
                                'Incorrect password or unable to open PDF.',
                              );
                            }
                          }
                        } else {
                          Get.snackbar(
                            'Error',
                            e.toString().replaceAll('Exception:', '').trim(),
                          );
                        }
                      }
                    }
                    break;

                  case ToolType.compressPdf:
                    final file = await compressPdfController.pickPdfFile();
                    if (file != null) {
                      Get.to(
                        () => ConversionProcessingPage(
                          title: meta.title,
                          initialMessage: 'Compressing and optimizing PDF...',
                          isEditOrganize: true,
                          processOperation: (onProgress) =>
                              compressPdfController.compressPdf(
                                file,
                                onProgress: onProgress,
                              ),
                        ),
                      );
                    }
                    break;

                  case ToolType.protectPdf:
                    final file = await protectPdfController.pickPdfFile();
                    if (file != null) {
                      final password = await protectPdfController
                          .promptPassword();
                      if (password != null && password.isNotEmpty) {
                        Get.to(
                          () => ConversionProcessingPage(
                            title: meta.title,
                            initialMessage: 'Encrypting and protecting PDF...',
                            isEditOrganize: true,
                            processOperation: (onProgress) =>
                                protectPdfController.protectPdf(
                                  file,
                                  userPassword: password,
                                  onProgress: onProgress,
                                ),
                          ),
                        );
                      }
                    }
                    break;

                  case ToolType.unlockPdf:
                    final file = await unlockPdfController.pickPdfFile();
                    if (file != null) {
                      final isProtected = await unlockPdfController
                          .isPdfPasswordProtected(file);
                      if (!isProtected) {
                        Get.dialog(
                          AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'PDF Not Locked',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            content: const Text(
                              'This PDF is not password protected and does not require unlocking.',
                              style: TextStyle(fontSize: 14),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text(
                                  'OK',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        );
                        break;
                      }

                      final password = await unlockPdfController
                          .promptPassword();
                      if (password != null && password.isNotEmpty) {
                        Get.to(
                          () => ConversionProcessingPage(
                            title: meta.title,
                            initialMessage: 'Decrypting and unlocking PDF...',
                            isEditOrganize: true,
                            completedTitle: 'PDF Ready',
                            completedSubtitle:
                                'Your unlocked PDF is ready to view.',
                            processOperation: (onProgress) =>
                                unlockPdfController.unlockPdf(
                                  file,
                                  password: password,
                                  onProgress: onProgress,
                                ),
                          ),
                        );
                      }
                    }
                    break;

                  case ToolType.editPdf:
                    final success = await editPdfController.pickAndInspectPdf(
                      context,
                    );
                    if (success) {
                      Get.to(() => const PdfEditorPage());
                    }
                    break;

                  default:
                    Get.snackbar(
                      meta.title,
                      'This ${_isEditOrganizeTool ? "tool" : "conversion tool"} will be available soon.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    break;
                }
              },
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    ),
  );
},
        ),
      ),
    );
  }
}

class ToolMeta {
  final String title;
  final String fromLabel;
  final Color fromColor;
  final String toLabel;
  final Color toColor;
  final String subtitle;
  final String buttonLabel;

  const ToolMeta({
    required this.title,
    required this.fromLabel,
    required this.fromColor,
    required this.toLabel,
    required this.toColor,
    required this.subtitle,
    required this.buttonLabel,
  });
}

ToolMeta _resolveMeta(AppLocalizations l10n, ToolType type) {
  const pdfRed = Color(0xFFEF5350);
  const wordBlue = Color(0xFF2B6FE0);
  const excelGreen = Color(0xFF34A853);
  const pptOrange = Color(0xFFEA4335);
  const imageViolet = Color(0xFF9C6CF5);

  switch (type) {
    case ToolType.wordToPdf:
      return ToolMeta(
        title: l10n.wordToPdf,
        fromLabel: 'Word',
        fromColor: wordBlue,
        toLabel: 'PDF',
        toColor: pdfRed,
        subtitle: l10n.wordToPdfSubtitle,
        buttonLabel: l10n.selectWordFile,
      );
    case ToolType.imageToPdf:
      return ToolMeta(
        title: l10n.imageToPdf,
        fromLabel: 'IMG',
        fromColor: imageViolet,
        toLabel: 'PDF',
        toColor: pdfRed,
        subtitle: l10n.imageToPdfSubtitle,
        buttonLabel: l10n.selectImageFile,
      );
    case ToolType.pptToPdf:
      return ToolMeta(
        title: l10n.pptToPdf,
        fromLabel: 'PPT',
        fromColor: pptOrange,
        toLabel: 'PDF',
        toColor: pdfRed,
        subtitle: l10n.pptToPdfSubtitle,
        buttonLabel: l10n.selectPptFile,
      );
    case ToolType.excelToPdf:
      return ToolMeta(
        title: l10n.excelToPdf,
        fromLabel: 'XLSX',
        fromColor: excelGreen,
        toLabel: 'PDF',
        toColor: pdfRed,
        subtitle: l10n.excelToPdfSubtitle,
        buttonLabel: l10n.selectExcelFile,
      );
    case ToolType.pdfToWord:
      return ToolMeta(
        title: l10n.pdfToWord,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'Word',
        toColor: wordBlue,
        subtitle: l10n.pdfToWordSubtitle,
        buttonLabel: l10n.selectPdfFile,
      );
    case ToolType.pdfToImage:
      return ToolMeta(
        title: l10n.pdfToImage,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'IMG',
        toColor: imageViolet,
        subtitle: l10n.pdfToImageSubtitle,
        buttonLabel: l10n.selectPdfFile,
      );
    case ToolType.pdfToPpt:
      return ToolMeta(
        title: l10n.pdfToPpt,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PPT',
        toColor: pptOrange,
        subtitle: l10n.pdfToPptSubtitle,
        buttonLabel: l10n.selectPdfFile,
      );
    case ToolType.pdfToExcel:
      return ToolMeta(
        title: l10n.pdfToExcel,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'XLSX',
        toColor: excelGreen,
        subtitle: l10n.pdfToExcelSubtitle,
        buttonLabel: l10n.selectPdfFile,
      );
    case ToolType.createPdf:
      return ToolMeta(
        title: l10n.createPdf,
        fromLabel: 'DOC',
        fromColor: const Color(0xFF2563EB),
        toLabel: 'PDF',
        toColor: pdfRed,
        subtitle: l10n.createPdfSubtitle,
        buttonLabel: l10n.createPdf,
      );
    case ToolType.editPdf:
      return ToolMeta(
        title: l10n.editPdf,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'EDIT',
        toColor: const Color(0xFF2563EB),
        subtitle: l10n.editPdfSubtitle,
        buttonLabel: l10n.selectPdfToEdit,
      );
    case ToolType.unlockPdf:
      return ToolMeta(
        title: l10n.unlockPdf,
        fromLabel: 'LOCK',
        fromColor: const Color(0xFFE53935),
        toLabel: 'PDF',
        toColor: const Color(0xFF34A853),
        subtitle: l10n.unlockPdfSubtitle,
        buttonLabel: l10n.selectPdfToUnlock,
      );
    case ToolType.mergePdf:
      return ToolMeta(
        title: l10n.mergePdf,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFFFFA000),
        subtitle: l10n.mergePdfSubtitle,
        buttonLabel: l10n.selectPdfFiles,
      );
    case ToolType.splitPdf:
      return ToolMeta(
        title: l10n.splitPdf,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFFE53935),
        subtitle: l10n.splitPdfSubtitle,
        buttonLabel: l10n.selectPdfToSplit,
      );
    case ToolType.compressPdf:
      return ToolMeta(
        title: l10n.compressPdf,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFFFFA000),
        subtitle: l10n.compressPdfSubtitle,
        buttonLabel: l10n.selectPdfToCompress,
      );
    case ToolType.protectPdf:
      return ToolMeta(
        title: l10n.protectPdf,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFF43A047),
        subtitle: l10n.protectPdfSubtitle,
        buttonLabel: l10n.selectPdfToProtect,
      );
    case ToolType.signOnPdf:
      return ToolMeta(
        title: l10n.signOnPdf,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFFE53935),
        subtitle: l10n.signOnPdfSubtitle,
        buttonLabel: l10n.selectPdfFile,
      );
    case ToolType.ocrPdf:
      return ToolMeta(
        title: l10n.ocrPdf,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFF6C4EF5),
        subtitle: l10n.ocrPdfSubtitle,
        buttonLabel: l10n.selectPdfFile,
      );
    case ToolType.organizePdf:
      return ToolMeta(
        title: l10n.organizePdf,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFF4285F4),
        subtitle: l10n.organizePdfSubtitle,
        buttonLabel: l10n.selectPdfFile,
      );
    case ToolType.removePages:
      return ToolMeta(
        title: l10n.removePages,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'DEL',
        toColor: const Color(0xFFEF4444),
        subtitle: l10n.removePagesSubtitle,
        buttonLabel: l10n.selectPdfToRemovePages,
      );
  }
}

class _DocIcon extends StatelessWidget {
  final String label;
  final Color color;

  const _DocIcon({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 88,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(20, 20),
              painter: _FoldedCornerPainter(
                color: Color.fromARGB(
                  255,
                  ((color.r * 255.0).round() * 0.7).round() & 0xff,
                  ((color.g * 255.0).round() * 0.7).round() & 0xff,
                  ((color.b * 255.0).round() * 0.7).round() & 0xff,
                ),
              ),
            ),
          ),
          Center(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: label.length > 3 ? 16 : 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoldedCornerPainter extends CustomPainter {
  final Color color;
  const _FoldedCornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
    final whitePaint = Paint()..color = Colors.white.withOpacity(0.25);
    final foldPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(foldPath, whitePaint);
  }

  @override
  bool shouldRepaint(_FoldedCornerPainter old) => old.color != color;
}

class _FeatureRow extends StatelessWidget {
  final String label;
  const _FeatureRow({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            border: Border.all(color: colors.primary, width: 1.8),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: colors.primary, size: 13),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

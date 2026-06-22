import 'package:file_reader/features/converter/controller/compress_pdf_controller.dart';
import 'package:file_reader/features/converter/controller/image_to_pdf_controller.dart';
import 'package:file_reader/features/converter/controller/file_to_pdf_controller.dart';
import 'package:file_reader/features/converter/controller/protect_pdf_controller.dart';
import 'package:file_reader/features/converter/controller/split_pdf_controller.dart';
import 'package:file_reader/features/merge_pdf/view/merge_pdf_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';

import 'package:file_reader/l10n/app_localizations.dart';

enum ToolType {
  wordToPdf,
  imageToPdf,
  pptToPdf,
  excelToPdf,
  pdfToWord,
  pdfToImage,
  pdfToPpt,
  pdfToExcel,
  mergePdf,
  splitPdf,
  compressPdf,
  protectPdf,
  signOnPdf,
  ocrPdf,
  organizePdf,
}

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
  final ProtectPdfController protectPdfController = Get.put(
    ProtectPdfController(),
  );

  static bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final meta = _resolveMeta(l10n, toolType);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          meta.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: isProcessing
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CupertinoActivityIndicator(
                    radius:
                        22.0, // Default radius is 10.0; increase this to upscale it
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.almostDone,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.finalizingFileMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF888899),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 36,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EFFE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _DocIcon(
                              label: meta.fromLabel,
                              color: meta.fromColor,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF5B4EE8),
                                size: 28,
                              ),
                            ),
                            _DocIcon(label: meta.toLabel, color: meta.toColor),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          l10n.convertTool(meta.title),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          meta.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888899),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EFFE),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FeatureRow(label: l10n.label1),
                        const SizedBox(height: 14),
                        _FeatureRow(label: l10n.label2),
                        const SizedBox(height: 14),
                        _FeatureRow(label: l10n.label3),
                      ],
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: toolType == ToolType.protectPdf
                        ? Obx(
                            () => ElevatedButton.icon(
                              onPressed: protectPdfController.isLoading.value
                                  ? null
                                  : protectPdfController.pickAndProtectPdf,
                              icon: protectPdfController.isLoading.value
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.lock),
                              label: Text(
                                protectPdfController.isLoading.value
                                    ? l10n.protecting
                                    : l10n.protectPdf,
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              // Branching on the enum (not the translated
                              // title) is what makes this work in every
                              // locale.
                              switch (toolType) {
                                case ToolType.imageToPdf:
                                  await imageToPdfController.pickImages();
                                  break;
                                case ToolType.wordToPdf:
                                  await wordToPdfController.pickFile(
                                    OfficeFileType.word,
                                  );
                                  break;
                                case ToolType.pptToPdf:
                                  await wordToPdfController.pickFile(
                                    OfficeFileType.powerpoint,
                                  );
                                  break;
                                case ToolType.excelToPdf:
                                  await wordToPdfController.pickFile(
                                    OfficeFileType.excel,
                                  );
                                  break;
                                case ToolType.mergePdf:
                                  Get.to(() => MergePdfPage());
                                  break;
                                case ToolType.splitPdf:
                                  await splitPdfController.pickFileAndSplit();
                                  break;
                                case ToolType.compressPdf:
                                  await compressPdfController
                                      .pickAndCompressPdf();
                                  break;
                                default:
                                  // pdfToWord, pdfToImage, pdfToPpt,
                                  // pdfToExcel, signOnPdf, ocrPdf,
                                  // organizePdf: wire these up to their
                                  // controllers the same way once ready.
                                  break;
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5B4EE8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              meta.buttonLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 28),
                ],
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

  // fromLabel / toLabel are short file-type tags shown inside the colored
  // icon boxes (PDF, IMG, XLS...). These are kept as universal abbreviations
  // rather than translated, same as file extensions.
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
        fromLabel: 'XLS',
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
        toLabel: 'XLS',
        toColor: excelGreen,
        subtitle: l10n.pdfToExcelSubtitle,
        buttonLabel: l10n.selectPdfFile,
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
        buttonLabel: l10n.selectPdfFile,
      );
    case ToolType.compressPdf:
      return ToolMeta(
        title: l10n.compressPdf,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFFFFA000),
        subtitle: l10n.compressPdfSubtitle,
        buttonLabel: l10n.selectPdfFile,
      );
    case ToolType.protectPdf:
      return ToolMeta(
        title: l10n.protectPdf,
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFF43A047),
        subtitle: l10n.protectPdfSubtitle,
        buttonLabel: l10n.protectPdf,
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
                  (color.red * 0.7).round(),
                  (color.green * 0.7).round(),
                  (color.blue * 0.7).round(),
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
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF5B4EE8), width: 1.8),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Color(0xFF5B4EE8), size: 13),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF444466),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

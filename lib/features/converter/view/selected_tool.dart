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

class SelectedTool extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color bgColor;

  SelectedTool({
    super.key,
    required this.title,
    required this.icon,
    required this.bgColor,
  });

  ToolMeta get _meta => _resolveMeta(title);

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
          title,
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
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                children: [
                  CupertinoActivityIndicator(
                    radius:
                        22.0, // Default radius is 10.0; increase this to upscale it
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Almost Done!',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please wait while we finalize your file',
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
                              label: _meta.fromLabel,
                              color: _meta.fromColor,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Color(0xFF5B4EE8),
                                size: 28,
                              ),
                            ),
                            _DocIcon(
                              label: _meta.toLabel,
                              color: _meta.toColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Convert $title',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _meta.subtitle,
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
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FeatureRow(label: 'Fast Conversion'),
                        SizedBox(height: 14),
                        _FeatureRow(label: 'Keep Original Formatting'),
                        SizedBox(height: 14),
                        _FeatureRow(label: 'Secure & Private'),
                      ],
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: title == 'Protect PDF'
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
                                    ? "Protecting..."
                                    : "Protect PDF",
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () async {
                              if (title == 'Image to PDF') {
                                await imageToPdfController.pickImages();
                              } else if (title == 'Word to PDF') {
                                await wordToPdfController.pickFile(
                                  OfficeFileType.word,
                                );
                              } else if (title == 'PPT to PDF') {
                                await wordToPdfController.pickFile(
                                  OfficeFileType.powerpoint,
                                );
                              } else if (title == 'Excel to PDF') {
                                await wordToPdfController.pickFile(
                                  OfficeFileType.excel,
                                );
                              } else if (title == 'Merge PDF') {
                                Get.to(() => MergePdfPage());
                              } else if (title == 'Split PDF') {
                                await splitPdfController.pickFileAndSplit();
                              } else if (title == 'Compress PDF') {
                                await compressPdfController
                                    .pickAndCompressPdf();
                              } else if (title == 'Protected PDF') {
                              } else {}
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
                              _meta.buttonLabel,
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
  final String fromLabel;
  final Color fromColor;
  final String toLabel;
  final Color toColor;
  final String subtitle;
  final String buttonLabel;

  const ToolMeta({
    required this.fromLabel,
    required this.fromColor,
    required this.toLabel,
    required this.toColor,
    required this.subtitle,
    required this.buttonLabel,
  });
}

ToolMeta _resolveMeta(String title) {
  const pdfRed = Color(0xFFEF5350);
  const wordBlue = Color(0xFF2B6FE0);
  const excelGreen = Color(0xFF34A853);
  const pptOrange = Color(0xFFEA4335);
  const imageViolet = Color(0xFF9C6CF5);

  switch (title) {
    case 'Word to PDF':
      return ToolMeta(
        fromLabel: 'Word',
        fromColor: wordBlue,
        toLabel: 'PDF',
        toColor: pdfRed,
        subtitle:
            'Convert your Word documents (.doc, .docx)\nto high-quality PDF files.',
        buttonLabel: 'Select Word File',
      );
    case 'Image to PDF':
      return ToolMeta(
        fromLabel: 'IMG',
        fromColor: imageViolet,
        toLabel: 'PDF',
        toColor: pdfRed,
        subtitle:
            'Convert your images (.jpg, .png, .webp)\nto high-quality PDF files.',
        buttonLabel: 'Select Image File',
      );
    case 'PPT to PDF':
      return ToolMeta(
        fromLabel: 'PPT',
        fromColor: pptOrange,
        toLabel: 'PDF',
        toColor: pdfRed,
        subtitle:
            'Convert your presentations (.ppt, .pptx)\nto high-quality PDF files.',
        buttonLabel: 'Select PPT File',
      );
    case 'Excel to PDF':
      return ToolMeta(
        fromLabel: 'XLS',
        fromColor: excelGreen,
        toLabel: 'PDF',
        toColor: pdfRed,
        subtitle:
            'Convert your spreadsheets (.xls, .xlsx)\nto high-quality PDF files.',
        buttonLabel: 'Select Excel File',
      );
    case 'PDF to Word':
      return ToolMeta(
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'Word',
        toColor: wordBlue,
        subtitle: 'Convert your PDF files\nto editable Word documents (.docx).',
        buttonLabel: 'Select PDF File',
      );
    case 'PDF to Image':
      return ToolMeta(
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'IMG',
        toColor: imageViolet,
        subtitle:
            'Convert your PDF pages\nto high-quality images (.jpg, .png).',
        buttonLabel: 'Select PDF File',
      );
    case 'PDF to PPT':
      return ToolMeta(
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PPT',
        toColor: pptOrange,
        subtitle: 'Convert your PDF files\nto editable presentations (.pptx).',
        buttonLabel: 'Select PDF File',
      );
    case 'PDF to Excel':
      return ToolMeta(
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'XLS',
        toColor: excelGreen,
        subtitle: 'Convert your PDF files\nto editable spreadsheets (.xlsx).',
        buttonLabel: 'Select PDF File',
      );
    case 'Merge PDF':
      return ToolMeta(
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFFFFA000),
        subtitle: 'Combine multiple PDF files\ninto a single document.',
        buttonLabel: 'Select PDF Files',
      );
    case 'Split PDF':
      return ToolMeta(
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFFE53935),
        subtitle: 'Split your PDF into separate pages\nor custom page ranges.',
        buttonLabel: 'Select PDF File',
      );
    case 'Compress PDF':
      return ToolMeta(
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFFFFA000),
        subtitle: 'Reduce the size of your PDF file\nwithout losing quality.',
        buttonLabel: 'Select PDF File',
      );
    case 'Protect PDF':
      return ToolMeta(
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFF43A047),
        subtitle: 'Encrypt and password-protect\nyour PDF documents.',
        buttonLabel: 'Select PDF File',
      );
    case 'Sign on PDF':
      return ToolMeta(
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFFE53935),
        subtitle: 'Add your digital signature\nto any PDF document.',
        buttonLabel: 'Select PDF File',
      );
    case 'OCR PDF':
      return ToolMeta(
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFF6C4EF5),
        subtitle:
            'Extract text from scanned PDFs\nusing optical character recognition.',
        buttonLabel: 'Select PDF File',
      );
    case 'Organize PDF':
      return ToolMeta(
        fromLabel: 'PDF',
        fromColor: pdfRed,
        toLabel: 'PDF',
        toColor: const Color(0xFF4285F4),
        subtitle: 'Reorder, rotate, or delete pages\nin your PDF document.',
        buttonLabel: 'Select PDF File',
      );
    default:
      return ToolMeta(
        fromLabel: title.split(' ').first,
        fromColor: const Color(0xFF6C4EF5),
        toLabel: 'PDF',
        toColor: pdfRed,
        subtitle: 'Convert your file to a high-quality PDF.',
        buttonLabel: 'Select File',
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

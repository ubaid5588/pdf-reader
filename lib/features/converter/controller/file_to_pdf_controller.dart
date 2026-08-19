import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

enum OfficeFileType { word, powerpoint, excel }

class FileToPdfController extends GetxController {
  static const Map<OfficeFileType, List<String>> _extension = {
    OfficeFileType.word: ['doc', 'docx'],
    OfficeFileType.powerpoint: ['ppt', 'pptx'],
    OfficeFileType.excel: ['xls', 'xlsx'],
  };

  RxString filePath = ''.obs;
  RxBool isLoading = false.obs;
  RxString conversionStatus = ''.obs;

  Future<String?> pickOfficeFile(OfficeFileType type) async {
    try {
      final result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: _extension[type],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;
      return result.files.single.path;
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick file: $e');
      return null;
    }
  }

  Future<File> convertOfficeFile(
    String path,
    OfficeFileType type, {
    void Function(double progress, String status)? onProgress,
  }) async {
    isLoading.value = true;
    filePath.value = path;

    try {
      onProgress?.call(0.2, 'Reading ${type.name.toUpperCase()} file...');

      late File tempPdfFile;
      switch (type) {
        case OfficeFileType.excel:
          tempPdfFile = await _convertExcelToPdf(path, onProgress: onProgress);
          break;
        case OfficeFileType.word:
          tempPdfFile = await _convertWordToPdf(path, onProgress: onProgress);
          break;
        case OfficeFileType.powerpoint:
          tempPdfFile = await _convertPowerpointToPdf(
            path,
            onProgress: onProgress,
          );
          break;
      }

      onProgress?.call(0.85, 'Saving PDF to device storage...');
      final pdfBytes = await tempPdfFile.readAsBytes();
      final baseName = File(path).path.split(Platform.pathSeparator).last.replaceAll(
        RegExp(r'\.[a-zA-Z0-9]+$'),
        '',
      );
      final fileName =
          '${baseName}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final savedPath = await PdfStorageService.savePdfToDownloads(
        pdfBytes: pdfBytes,
        fileName: fileName,
      );

      onProgress?.call(1.0, 'Finalizing...');

      if (savedPath != null) {
        return File(savedPath);
      }
      return tempPdfFile;
    } finally {
      isLoading.value = false;
    }
  }

  Future<File> _convertExcelToPdf(
    String filePath, {
    void Function(double progress, String status)? onProgress,
  }) async {
    try {
      onProgress?.call(0.35, 'Decoding spreadsheet data...');
      final bytes = await File(filePath).readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      final pdf = pw.Document();
      final fileName = File(filePath).path.split(Platform.pathSeparator).last;
      int sheetCount = excel.tables.keys.length;
      int currentSheet = 0;

      for (var table in excel.tables.keys) {
        currentSheet++;
        final sheet = excel.tables[table];
        if (sheet == null) continue;

        onProgress?.call(
          0.35 + (0.4 * (currentSheet / (sheetCount > 0 ? sheetCount : 1))),
          'Processing sheet: $table ($currentSheet/$sheetCount)...',
        );

        final rows = <List<pw.Widget>>[];

        for (var row in sheet.rows) {
          final cells = <pw.Widget>[];
          for (var cell in row) {
            cells.add(
              pw.Padding(
                padding: const pw.EdgeInsets.all(4),
                child: pw.Text(
                  cell?.value?.toString() ?? '',
                  style: const pw.TextStyle(fontSize: 10),
                  maxLines: 3,
                  overflow: pw.TextOverflow.clip,
                ),
              ),
            );
          }
          rows.add(cells);
        }
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4.landscape,
            margin: const pw.EdgeInsets.all(16),
            build: (context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '$fileName - Sheet: $table',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.TableHelper.fromTextArray(
                    border: pw.TableBorder.all(),
                    cellHeight: 30,
                    cellAlignment: pw.Alignment.centerLeft,
                    data: rows.isEmpty
                        ? [
                            ['No data'],
                          ]
                        : [
                            for (var row in rows) [for (var cell in row) cell],
                          ],
                  ),
                ],
              );
            },
          ),
        );
      }

      onProgress?.call(0.8, 'Rendering PDF pages...');
      return await _savePdfToTemp(
        pdf,
        'excel_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<File> _convertWordToPdf(
    String filePath, {
    void Function(double progress, String status)? onProgress,
  }) async {
    try {
      onProgress?.call(0.4, 'Extracting Word document contents...');
      final fileName = File(filePath).path.split(Platform.pathSeparator).last;
      final bytes = await File(filePath).readAsBytes();
      String content =
          _extractTextFromDocx(bytes) ??
          'Unable to fully parse DOCX. Showing raw content.';

      onProgress?.call(0.7, 'Formatting vector pages & typography...');

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return [
              pw.Text(
                fileName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                content,
                style: const pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign.justify,
              ),
            ];
          },
        ),
      );

      onProgress?.call(0.8, 'Writing PDF document...');
      return await _savePdfToTemp(
        pdf,
        'word_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<File> _convertPowerpointToPdf(
    String filePath, {
    void Function(double progress, String status)? onProgress,
  }) async {
    try {
      onProgress?.call(0.4, 'Extracting presentation slides...');
      final fileName = File(filePath).path.split(Platform.pathSeparator).last;
      final bytes = await File(filePath).readAsBytes();
      final content =
          _extractTextFromPptx(bytes) ??
          'Unable to extract slides. The file may be too complex.';

      onProgress?.call(0.7, 'Generating PDF slide layout...');
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) {
            return [
              pw.Text(
                fileName,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(content, style: const pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 20),
              pw.Text(
                'Note: This is a text-only conversion. For full slide layouts, use the original file.',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey,
                ),
              ),
            ];
          },
        ),
      );

      onProgress?.call(0.8, 'Saving presentation PDF...');
      return await _savePdfToTemp(
        pdf,
        'powerpoint_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      rethrow;
    }
  }

  String? _extractTextFromDocx(List<int> bytes) {
    try {
      final content = utf8.decode(bytes, allowMalformed: true);
      final regex = RegExp(r'<w:t[^>]*>([^<]*)</w:t>');
      final matches = regex.allMatches(content);

      if (matches.isEmpty) return null;

      return matches.map((m) => m.group(1) ?? '').join('\n');
    } catch (e) {
      return null;
    }
  }

  String? _extractTextFromPptx(List<int> bytes) {
    try {
      final content = utf8.decode(bytes, allowMalformed: true);
      final regex = RegExp(r'<a:t>([^<]*)</a:t>');
      final matches = regex.allMatches(content);

      if (matches.isEmpty) return null;

      final textList = <String>[];
      for (var match in matches) {
        final text = match.group(1) ?? '';
        if (text.isNotEmpty && !textList.contains(text)) {
          textList.add(text);
        }
      }

      return textList.join('\n');
    } catch (e) {
      return null;
    }
  }

  Future<File> _savePdfToTemp(pw.Document pdf, String fileName) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      rethrow;
    }
  }
}

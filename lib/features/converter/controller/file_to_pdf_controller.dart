import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart' as fp;
import 'package:file_reader/features/converter/services/pdf_storage_service.dart';
import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> pickFile(OfficeFileType type) async {
    try {
      final result = await fp.FilePicker.platform.pickFiles(
        type: fp.FileType.custom,
        allowedExtensions: _extension[type],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) return;

      isLoading.value = true;
      filePath.value = path;
      conversionStatus.value = 'Converting ${type.name}...';
      late File pdfFile;
      switch (type) {
        case OfficeFileType.excel:
          pdfFile = await _convertExcelToPdf(path);
          break;
        case OfficeFileType.word:
          pdfFile = await _convertWordToPdf(path);
          break;
        case OfficeFileType.powerpoint:
          pdfFile = await _convertPowerpointToPdf(path);
          break;
      }

      conversionStatus.value = 'Saving PDF...';
      final pdfBytes = await pdfFile.readAsBytes();
      final fileName =
          'converted_${type.name}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await PdfStorageService.savePdfToDownloads(
        pdfBytes: pdfBytes,
        fileName: fileName,
      );
      final fileController = Get.find<FilePageController>();
      await fileController.refreshPdfs();

      conversionStatus.value = 'Opening PDF...';
      Get.to(() => PdfViewer(filePath: pdfFile));

      Get.snackbar(
        'Success',
        'PDF converted and saved to Downloads',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar('Error', 'Could not convert file: $e');
    } finally {
      isLoading.value = false;
      conversionStatus.value = '';
    }
  }

  Future<File> _convertExcelToPdf(String filePath) async {
    try {
      conversionStatus.value = 'Reading Excel file...';

      final bytes = await File(filePath).readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      final pdf = pw.Document();
      final fileName = File(filePath).path.split('/').last;
      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table];
        if (sheet == null) continue;

        conversionStatus.value = 'Processing sheet: $table...';
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
      return await _savePdfToTemp(
        pdf,
        'excel_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<File> _convertWordToPdf(String filePath) async {
    try {
      conversionStatus.value = 'Reading Word file...';
      final fileName = File(filePath).path.split('/').last;
      final bytes = await File(filePath).readAsBytes();
      String content =
          _extractTextFromDocx(bytes) ??
          'Unable to fully parse DOCX. Showing raw content.';

      conversionStatus.value = 'Creating PDF...';

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

      return await _savePdfToTemp(
        pdf,
        'word_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<File> _convertPowerpointToPdf(String filePath) async {
    try {
      conversionStatus.value = 'Reading PowerPoint file...';

      final fileName = File(filePath).path.split('/').last;
      final bytes = await File(filePath).readAsBytes();
      final content =
          _extractTextFromPptx(bytes) ??
          'Unable to extract slides. The file may be too complex.';

      conversionStatus.value = 'Creating PDF...';

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
      final content = utf8.decode(bytes);
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
      final content = utf8.decode(bytes);
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

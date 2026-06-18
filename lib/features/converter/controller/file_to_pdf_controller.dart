import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart' as fp;
import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

enum OfficeFileType { word, powerpoint, excel }

class FileToPdfController extends GetxController {
  static const String _apiSecret =
      '12ZghtIDqKujDYvHEE0vYsNWA8DIOt7p'; // from your dashboard

  static const Map<OfficeFileType, List<String>> _extension = {
    OfficeFileType.word: ['doc', 'docx'],
    OfficeFileType.powerpoint: ['ppt', 'pptx'],
    OfficeFileType.excel: ['xls', 'xlsx'],
  };

  static const Map<OfficeFileType, String> _sourceFormat = {
    OfficeFileType.word: 'docx',
    OfficeFileType.powerpoint: 'pptx',
    OfficeFileType.excel: 'xlsx',
  };

  RxString filePath = ''.obs;
  RxBool isLoading = false.obs;

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

      final pdfFile = await createPdfFromFile(path, type);

      Get.to(() => PdfViewer(filePath: pdfFile));
    } catch (e) {
      Get.snackbar("Error", "Could not create PDF: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<File> createPdfFromFile(String path, OfficeFileType type) async {
    final uri = Uri.parse(
      'https://v2.convertapi.com/convert/${_sourceFormat[type]}/to/pdf?Secret=$_apiSecret',
    );

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('File', path));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception(
        'Conversion failed: ${response.statusCode} ${response.body}',
      );
    }

    final json = response.body;
    final decoded = Uri.decodeFull(json);
    final data = (jsonDecodeSafe(decoded));
    final base64Data = data['Files'][0]['FileData'] as String;
    final bytes = base64Decode(base64Data);

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/${_sourceFormat[type]}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(bytes);

    return file;
  }

  dynamic jsonDecodeSafe(String body) {
    return jsonDecode(body);
  }
}

import 'package:file_reader/services/hive_service.dart';

class RecentPdfController {
  final HiveService hiveService;

  RecentPdfController(this.hiveService);

  Future<void> saveRecentPdf(String path, String name) async {
    await hiveService.savePdf(path, name);
  }

  List getRecentPdfs() {
    return hiveService.getRecentPdfs();
  }
}

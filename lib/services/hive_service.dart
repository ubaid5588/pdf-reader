import 'package:hive/hive.dart';

class HiveService {
  final Box recentBox = Hive.box('recent_pdfs');

  Future<void> savePdf(String path, String name) async {
    await recentBox.put(path, {
      'name': name,
      'path': path,
      'lastOpened': DateTime.now().toIso8601String(),
    });
  }

  List getRecentPdfs() {
    return recentBox.values.toList();
  }
}

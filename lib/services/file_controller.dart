import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

class FileController {
  static const MethodChannel platform = MethodChannel('pdf_reader/channel');

  Future<List<SharedFile>> getInitialFiles() async {
    return await FlutterSharingIntent.instance.getInitialSharing();
  }

  Future<Uint8List> getPdfBytes(String uri) async {
    return await platform.invokeMethod('getPdfBytes', {'uri': uri});
  }
}

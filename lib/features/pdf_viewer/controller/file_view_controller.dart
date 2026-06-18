import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

class FileViewController {
  static const MethodChannel platform = MethodChannel('pdf_reader/channel');

  Future<List<SharedFile>> getInitialFiles() async {
    return await FlutterSharingIntent.instance.getInitialSharing();
  }

  Future<Uint8List> getPdfBytes(String uri) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await platform.invokeMethod('getPdfBytes', {'uri': uri});
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final path = Uri.parse(uri).toFilePath();
      return await File(path).readAsBytes();
    }

    throw UnsupportedError('Platform not supported');
  }
}

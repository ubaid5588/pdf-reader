import 'dart:io';

import 'package:file_reader/services/hive_service.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfItemMetadata {
  final int size;
  final DateTime modified;

  const PdfItemMetadata({required this.size, required this.modified});
}

class FilePageController extends GetxController {
  final RxList<File> pdfFiles = <File>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Cached metadata for instantaneous subtitle rendering (no FutureBuilder needed)
  final Map<String, PdfItemMetadata> fileMetaCache = {};

  // Guard: prevents concurrent loadPdfs() scans
  bool _loadInProgress = false;

  List<File> get filteredFiles {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return pdfFiles;
    return pdfFiles
        .where(
          (file) => file.path
              .split(Platform.pathSeparator)
              .last
              .toLowerCase()
              .contains(query),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    _loadInitialCachedPdfs();
    loadPdfs();
    Future.delayed(const Duration(milliseconds: 300), () {
      _initializeApp();
    });
  }

  /// Instantly populates pdfFiles from Hive recent files in < 1ms on startup
  /// so the screen is never blank or stuck behind a spinner.
  void _loadInitialCachedPdfs() {
    try {
      final hiveList = HiveService().getRecentPdfs();
      final List<File> initialFiles = [];
      for (final item in hiveList) {
        final path = item['path'] as String?;
        if (path != null && path.isNotEmpty) {
          final file = File(path);
          if (file.existsSync()) {
            initialFiles.add(file);
            final size = item['size'] as int? ?? 0;
            final lastOpenedStr = item['lastOpened'] as String?;
            final modified = lastOpenedStr != null
                ? (DateTime.tryParse(lastOpenedStr) ?? DateTime.now())
                : DateTime.now();
            fileMetaCache[path] = PdfItemMetadata(size: size, modified: modified);
          }
        }
      }
      if (initialFiles.isNotEmpty && pdfFiles.isEmpty) {
        pdfFiles.assignAll(initialFiles);
      }
    } catch (_) {}
  }

  Future<void> _initializeApp() async {
    try {
      if (Platform.isAndroid) {
        final currentStatus = await Permission.manageExternalStorage.status;
        if (currentStatus.isGranted) {
          await loadPdfs();
        } else if (currentStatus.isPermanentlyDenied) {
          _showPermissionSettingsDialog();
        } else {
          await _requestPermission();
        }
      }
    } catch (_) {}
  }

  Future<void> _requestPermission() async {
    try {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        await loadPdfs();
      } else if (status.isDenied) {
        Get.snackbar(
          'Permission Required',
          'Allow access to all files to view PDFs',
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () {
              _requestPermission();
              Get.back();
            },
            child: const Text('Retry'),
          ),
        );
      } else if (status.isPermanentlyDenied) {
        _showPermissionSettingsDialog();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to request permission');
    }
  }

  void _showPermissionSettingsDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Files Access Required'),
        content: const Text(
          'To access PDF files on your device, this app needs permission to access all files.\n\n'
          'Steps:\n'
          '1. Go to Settings\n'
          '2. Apps → file_reader\n'
          '3. Permissions → Files and Media\n'
          '4. Select "Allow"',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              openAppSettings();
              Get.back();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Scans device storage for PDF files.
  /// If files are already loaded in memory, does NOT block the UI with a full-screen spinner.
  Future<void> loadPdfs({bool forceSpinner = false}) async {
    if (_loadInProgress) return;
    _loadInProgress = true;

    try {
      if (forceSpinner || pdfFiles.isEmpty) {
        isLoading.value = true;
      }

      final List<String> dirsToScan = [];
      final List<String> hivePaths = [];

      try {
        final d = await getApplicationDocumentsDirectory();
        dirsToScan.add(d.path);
      } catch (_) {}

      try {
        final d = await getApplicationSupportDirectory();
        dirsToScan.add(d.path);
      } catch (_) {}

      try {
        final d = await getDownloadsDirectory();
        if (d != null) dirsToScan.add(d.path);
      } catch (_) {}

      try {
        final d = await getExternalStorageDirectory();
        if (d != null) dirsToScan.add(d.path);
      } catch (_) {}

      try {
        final dirs = await getExternalStorageDirectories(
          type: StorageDirectory.documents,
        );
        if (dirs != null) {
          for (final d in dirs) dirsToScan.add(d.path);
        }
      } catch (_) {}

      try {
        final dirs = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        if (dirs != null) {
          for (final d in dirs) dirsToScan.add(d.path);
        }
      } catch (_) {}

      // Add standard user-facing PDF directories
      dirsToScan.addAll([
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0',
      ]);

      // Collect known Hive paths
      try {
        final hiveList = HiveService().getRecentPdfs();
        for (final item in hiveList) {
          final path = item['path'] as String?;
          if (path != null && path.isNotEmpty) hivePaths.add(path);
        }
      } catch (_) {}

      // Run optimized background isolate scan
      final rawResults = await compute(
        _scanDirectoriesInBackground,
        _ScanArgs(dirsToScan: dirsToScan, hivePaths: hivePaths),
      );

      final List<File> newFileList = [];
      for (final item in rawResults) {
        final path = item['path'] as String;
        final size = item['size'] as int;
        final modifiedMs = item['modified'] as int;
        fileMetaCache[path] = PdfItemMetadata(
          size: size,
          modified: DateTime.fromMillisecondsSinceEpoch(modifiedMs),
        );
        newFileList.add(File(path));
      }

      pdfFiles.assignAll(newFileList);
    } catch (e) {
      debugPrint('Error Loading PDFs: $e');
    } finally {
      isLoading.value = false;
      _loadInProgress = false;
    }
  }

  Future<void> refreshPdfs() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await loadPdfs();
  }

  /// Immediately ensures [file] is present in [pdfFiles] without waiting for a scan.
  void ensureFileInList(File file, {int? size, DateTime? modified}) {
    if (size != null && modified != null) {
      fileMetaCache[file.path] = PdfItemMetadata(size: size, modified: modified);
    } else {
      try {
        if (file.existsSync()) {
          final stat = file.statSync();
          fileMetaCache[file.path] = PdfItemMetadata(
            size: stat.size,
            modified: stat.modified,
          );
        }
      } catch (_) {}
    }

    final idx = pdfFiles.indexWhere((f) => f.path == file.path);
    if (idx >= 0) {
      pdfFiles[idx] = file;
      pdfFiles.refresh();
    } else {
      pdfFiles.insert(0, file);
    }
  }

  /// Synchronously returns formatted size and date string for [file] in 0ms
  String getFileSizeAndDate(File file) {
    final cached = fileMetaCache[file.path];
    if (cached != null) {
      final sizeStr = formatBytes(cached.size);
      final dateStr = DateFormat('MMM d, yyyy').format(cached.modified);
      return '$sizeStr • $dateStr';
    }

    // Fallback: asynchronously cache for subsequent builds
    _cacheSingleFileStat(file);
    return '—';
  }

  void _cacheSingleFileStat(File file) {
    file.stat().then((stat) {
      fileMetaCache[file.path] = PdfItemMetadata(
        size: stat.size,
        modified: stat.modified,
      );
      pdfFiles.refresh();
    }).catchError((_) {});
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  Future<bool> renameFile(File file, String newName) async {
    try {
      var sanitized = newName.trim();
      if (sanitized.isEmpty) {
        Get.snackbar('Error', 'Name cannot be empty');
        return false;
      }
      if (!sanitized.toLowerCase().endsWith('.pdf')) {
        sanitized = '$sanitized.pdf';
      }

      final dirPath = file.parent.path;
      final newPath = '$dirPath${Platform.pathSeparator}$sanitized';

      if (newPath == file.path) return true;

      if (await File(newPath).exists()) {
        Get.snackbar('Error', 'File already exists');
        return false;
      }

      final renamed = await file.rename(newPath);
      final oldMeta = fileMetaCache.remove(file.path);
      if (oldMeta != null) {
        fileMetaCache[newPath] = oldMeta;
      }

      final index = pdfFiles.indexWhere((f) => f.path == file.path);
      if (index != -1) {
        pdfFiles[index] = renamed;
        pdfFiles.refresh();
      } else {
        pdfFiles.insert(0, renamed);
      }

      if (Get.isRegistered<RecentPdfController>()) {
        final recent = Get.find<RecentPdfController>();
        await recent.removeRecentPdf(file.path);
        await recent.addRecentPdf(newPath, sanitized);
      }

      Get.snackbar('Success', 'File renamed');
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to rename: $e');
      return false;
    }
  }

  Future<bool> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
      fileMetaCache.remove(file.path);
      pdfFiles.removeWhere((f) => f.path == file.path);
      if (Get.isRegistered<RecentPdfController>()) {
        await Get.find<RecentPdfController>().removeRecentPdf(file.path);
      }
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
      return false;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Highly Optimized Background Isolate Scanner
// Runs via compute() in a background isolate.
// Never touches UI thread.
// ─────────────────────────────────────────────────────────────────────────────

class _ScanArgs {
  final List<String> dirsToScan;
  final List<String> hivePaths;
  const _ScanArgs({required this.dirsToScan, required this.hivePaths});
}

/// Directories to strictly skip to avoid scanning thousands of camera photos / system data
const Set<String> _ignoredDirectoryNames = {
  'android',
  'dcim',
  'camera',
  'screenshots',
  'pictures',
  'movies',
  'music',
  'audio',
  'podcasts',
  'ringtones',
  'alarms',
  'notifications',
  '.thumbnails',
};

List<Map<String, dynamic>> _scanDirectoriesInBackground(_ScanArgs args) {
  final Set<String> seenNormalized = {};
  final List<Map<String, dynamic>> entries = [];

  void addPdfFile(File file) {
    try {
      final path = file.path;
      final normalized = path.toLowerCase().replaceAll('\\', '/');

      if (!normalized.endsWith('.pdf')) return;
      if (seenNormalized.contains(normalized)) return;
      seenNormalized.add(normalized);

      if (!file.existsSync()) return;

      int size = 0;
      int modifiedMs = 0;
      try {
        final stat = file.statSync();
        size = stat.size;
        modifiedMs = stat.modified.millisecondsSinceEpoch;
      } catch (_) {
        modifiedMs = 0;
      }

      entries.add({
        'path': path,
        'size': size,
        'modified': modifiedMs,
      });
    } catch (_) {}
  }

  void scanDir(String dirPath, {int maxDepth = 1, int currentDepth = 0}) {
    try {
      final dir = Directory(dirPath);
      if (!dir.existsSync()) return;

      final entities = dir.listSync(recursive: false, followLinks: false);
      for (final entity in entities) {
        final name = entity.path.split(Platform.pathSeparator).last;
        final lowerName = name.toLowerCase();

        // Skip hidden files/folders and irrelevant media/system directories
        if (lowerName.startsWith('.') || _ignoredDirectoryNames.contains(lowerName)) {
          continue;
        }

        if (entity is File) {
          if (lowerName.endsWith('.pdf')) {
            addPdfFile(entity);
          }
        } else if (entity is Directory && currentDepth < maxDepth) {
          scanDir(
            entity.path,
            maxDepth: maxDepth,
            currentDepth: currentDepth + 1,
          );
        }
      }
    } catch (_) {}
  }

  // 1. Scan primary PDF folders (Downloads, Documents, App dirs)
  for (final dirPath in args.dirsToScan) {
    final isStorageRoot = dirPath == '/storage/emulated/0';
    // Storage root is strictly non-recursive (depth 0) to avoid deep app caches
    scanDir(dirPath, maxDepth: isStorageRoot ? 0 : 1);
  }

  // 2. Add any known Hive paths directly
  for (final path in args.hivePaths) {
    if (path.isNotEmpty) {
      addPdfFile(File(path));
    }
  }

  // Sort newest first
  entries.sort((a, b) {
    final aMod = a['modified'] as int? ?? 0;
    final bMod = b['modified'] as int? ?? 0;
    return bMod.compareTo(aMod);
  });

  return entries;
}

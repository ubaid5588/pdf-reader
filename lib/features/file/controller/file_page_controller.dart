import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class FilePageController extends GetxController {
  RxList<File> pdfFiles = <File>[].obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;

  List<File> get filteredFiles {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return pdfFiles;
    return pdfFiles
        .where(
          (file) => file.path.split('/').last.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 500), () {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final currentStatus = await Permission.manageExternalStorage.status;

    if (currentStatus.isGranted) {
      await loadPdfs();
    } else if (currentStatus.isPermanentlyDenied) {
      _showPermissionSettingsDialog();
    } else {
      await _requestPermission();
    }
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

  Future<void> loadPdfs() async {
    try {
      isLoading.value = true;
      List<File> allPdfs = [];

      final searchPaths = [
        '/storage/emulated/0/Download',
        '/storage/emulated/0/Documents',
        '/storage/emulated/0/DCIM',
        '/storage/emulated/0',
      ];

      for (String path in searchPaths) {
        try {
          final dir = Directory(path);
          if (await dir.exists()) {
            final files = dir
                .listSync(recursive: false, followLinks: false)
                .whereType<File>()
                .where((file) => file.path.toLowerCase().endsWith('.pdf'))
                .toList();
            if (files.isNotEmpty) {
              allPdfs.addAll(files);
            }
          }
        } catch (e) {
          continue;
        }
      }

      final uniquePdfs = <String, File>{};
      for (var file in allPdfs) {
        try {
          final absolutePath = file.resolveSymbolicLinksSync();
          uniquePdfs[absolutePath] = file;
        } catch (e) {
          uniquePdfs[file.path] = file;
        }
      }

      allPdfs = uniquePdfs.values.toList();

      try {
        allPdfs.sort((a, b) {
          try {
            final aDate = a.statSync().modified;
            final bDate = b.statSync().modified;
            return bDate.compareTo(aDate);
          } catch (e) {
            return 0;
          }
        });
      } catch (e) {
        return;
      }

      pdfFiles.value = allPdfs;
      if (allPdfs.isEmpty) {
        Get.snackbar(
          'No PDFs Found',
          'Place PDF files in Download or Documents folder',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.snackbar('Error Loading PDFs', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPdfs() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await loadPdfs();
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
      final index = pdfFiles.indexWhere((f) => f.path == file.path);
      if (index != -1) {
        pdfFiles[index] = renamed;
        pdfFiles.refresh();
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
      pdfFiles.removeWhere((f) => f.path == file.path);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete: $e');
      return false;
    }
  }
}

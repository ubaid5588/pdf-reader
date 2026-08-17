import 'dart:io';

import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class FilePage extends StatefulWidget {
  const FilePage({super.key});

  @override
  State<FilePage> createState() => _FilePageState();
}

class _FilePageState extends State<FilePage>
    with SingleTickerProviderStateMixin {
  late FilePageController controller;
  final TextEditingController _searchController = TextEditingController();
  final RxSet<String> selectedFiles = <String>{}.obs;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    controller = Get.find();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<DateTime> getDate(File file) async {
    return await file.lastModified();
  }

  void _toggleFileSelection(String filePath) {
    if (selectedFiles.contains(filePath)) {
      selectedFiles.remove(filePath);
    } else {
      selectedFiles.add(filePath);
    }

    if (selectedFiles.isNotEmpty && !_animationController.isAnimating) {
      _animationController.forward();
    } else if (selectedFiles.isEmpty) {
      _animationController.reverse();
    }
  }

  void _selectAll(List<File> files) {
    selectedFiles.clear();
    for (var file in files) {
      selectedFiles.add(file.path);
    }
    if (selectedFiles.isNotEmpty) {
      _animationController.forward();
    }
  }

  void _clearSelection() {
    selectedFiles.clear();
    _animationController.reverse();
  }

  Future<void> _shareSelectedFiles() async {
    final files = selectedFiles.map((path) => XFile(path)).toList();

    if (files.isNotEmpty) {
      await Share.shareXFiles(files);
      _clearSelection();
    }
  }

  Future<void> _deleteSelectedFiles() async {
    final count = selectedFiles.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete PDFs'),
          content: Text(
            'Delete $count PDF${count > 1 ? 's' : ''}? This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      for (var filePath in selectedFiles) {
        await controller.deleteFile(File(filePath));
      }
      _clearSelection();
      Get.snackbar(
        'Deleted',
        '$count PDF${count > 1 ? 's' : ''} deleted successfully',
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _shareFile(File file) {
    Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> _showRenameDialog(BuildContext context, File file) async {
    final currentName = file.path.split(Platform.pathSeparator).last;
    final nameWithoutExt = currentName.toLowerCase().endsWith('.pdf')
        ? currentName.substring(0, currentName.length - 4)
        : currentName;

    final nameController = TextEditingController(text: nameWithoutExt);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Rename PDF'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter new name',
              suffixText: '.pdf',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, nameController.text),
              child: const Text('Rename'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.trim().isNotEmpty) {
      await controller.renameFile(file, newName);
    }
  }

  Future<void> _showDeleteConfirm(BuildContext context, File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete PDF'),
          content: Text('Delete "$fileName"? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await controller.deleteFile(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bool isSmall = width < 360;
        final bool isTablet = width >= 600;

        final double horizontalPadding = isSmall
            ? 10
            : isTablet
            ? 24
            : 16;
        final double searchHeight = isSmall
            ? 44
            : isTablet
            ? 52
            : 48;
        final double iconSize = isSmall
            ? 42
            : isTablet
            ? 58
            : 50;
        final double titleFontSize = isSmall
            ? 13
            : isTablet
            ? 16
            : 14;
        final double subtitleFontSize = isSmall
            ? 10
            : isTablet
            ? 13
            : 11;

        return Column(
          children: [
            // Search Bar with Selection Info
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                8,
              ),
              child: Obx(
                () => AnimatedCrossFade(
                  firstChild: SizedBox(
                    height: searchHeight,
                    child: TextField(
                      controller: _searchController,
                      onChanged: controller.updateSearch,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Search PDFs',
                        hintStyle: TextStyle(fontSize: isSmall ? 12 : 14),
                        prefixIcon: Icon(Icons.search, size: isSmall ? 20 : 22),
                        suffixIcon: Obx(() {
                          if (controller.searchQuery.value.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return IconButton(
                            icon: Icon(Icons.clear, size: isSmall ? 19 : 21),
                            onPressed: () {
                              _searchController.clear();
                              controller.clearSearch();
                            },
                          );
                        }),
                        filled: true,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  secondChild: Container(
                    height: searchHeight,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          Icons.check_circle,
                          color: Colors.blue,
                          size: isSmall ? 20 : 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${selectedFiles.length} selected',
                            style: TextStyle(
                              fontSize: isSmall ? 12 : 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        // Share Button
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          color: Colors.blue,
                          iconSize: isSmall ? 18 : 20,
                          onPressed: _shareSelectedFiles,
                          tooltip: 'Share',
                        ),
                        // Delete Button
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.red,
                          iconSize: isSmall ? 18 : 20,
                          onPressed: _deleteSelectedFiles,
                          tooltip: 'Delete',
                        ),
                        // Close/Clear Button
                        IconButton(
                          icon: const Icon(Icons.close),
                          color: Colors.blue,
                          iconSize: isSmall ? 18 : 20,
                          onPressed: _clearSelection,
                          tooltip: 'Clear',
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: selectedFiles.isEmpty
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 300),
                ),
              ),
            ),
            // File List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final files = controller.filteredFiles;

                if (controller.pdfFiles.isEmpty) {
                  return Center(
                    child: Text(
                      lang.file,
                      style: TextStyle(fontSize: isSmall ? 13 : 15),
                    ),
                  );
                }

                if (files.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Text(
                        'No PDFs match your search',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: isSmall ? 13 : 15),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadPdfs,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: 8,
                      bottom: 20,
                    ),
                    itemCount: files.length,
                    separatorBuilder: (context, index) {
                      return const Divider(height: 1, indent: 8, endIndent: 8);
                    },
                    itemBuilder: (context, index) {
                      final file = files[index];

                      return Obx(() {
                        final isSelected = selectedFiles.contains(file.path);

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.shade50
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isSmall ? 4 : 8,
                              vertical: isSmall ? 4 : 6,
                            ),
                            minVerticalPadding: 4,
                            leading: SizedBox(
                              width: iconSize,
                              height: iconSize,
                              child: GestureDetector(
                                onTap: () {
                                  _toggleFileSelection(file.path);
                                },
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 200),
                                  scale: isSelected ? 1.1 : 1.0,
                                  child: Container(
                                    padding: EdgeInsets.all(isSmall ? 5 : 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          )
                                        : Image.asset(
                                            'assets/images/pdf_logo.png',
                                            fit: BoxFit.contain,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              file.path.split(Platform.pathSeparator).last,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.blue.shade700
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: FutureBuilder<DateTime>(
                              future: getDate(file),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    'Loading date...',
                                    style: TextStyle(
                                      fontSize: subtitleFontSize,
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Text(
                                    'Error loading date',
                                    style: TextStyle(
                                      fontSize: subtitleFontSize,
                                    ),
                                  );
                                }

                                if (snapshot.hasData) {
                                  return Text(
                                    DateFormat(
                                      'dd-MM-yyyy hh:mm a',
                                    ).format(snapshot.data!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: subtitleFontSize,
                                      color: Colors.grey.shade600,
                                    ),
                                  );
                                }

                                return Text(
                                  'No date found',
                                  style: TextStyle(fontSize: subtitleFontSize),
                                );
                              },
                            ),
                            trailing: selectedFiles.isEmpty
                                ? _buildPremiumPopupMenu(context, file, isSmall)
                                : null,
                            onTap: selectedFiles.isEmpty
                                ? () {
                                    Get.to(() => PdfViewer(filePath: file));
                                  }
                                : () {
                                    _toggleFileSelection(file.path);
                                  },
                            onLongPress: () {
                              _toggleFileSelection(file.path);
                            },
                          ),
                        );
                      });
                    },
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPremiumPopupMenu(BuildContext context, File file, bool isSmall) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: isSmall ? 20 : 22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      elevation: 8,
      onSelected: (value) {
        switch (value) {
          case 'share':
            _shareFile(file);
            break;
          case 'rename':
            _showRenameDialog(context, file);
            break;
          case 'delete':
            _showDeleteConfirm(context, file);
            break;
          case 'select':
            _toggleFileSelection(file.path);
            break;
        }
      },
      itemBuilder: (context) => [
        _buildPremiumPopupMenuItem(
          icon: Icons.share_outlined,
          label: 'Share',
          value: 'share',
          color: Colors.blue,
        ),
        _buildPremiumPopupMenuItem(
          icon: Icons.edit_outlined,
          label: 'Rename',
          value: 'rename',
          color: Colors.orange,
        ),
        _buildPremiumPopupMenuItem(
          icon: Icons.check_circle_outline,
          label: 'Select',
          value: 'select',
          color: Colors.green,
        ),
        const PopupMenuDivider(height: 8),
        _buildPremiumPopupMenuItem(
          icon: Icons.delete_outline,
          label: 'Delete',
          value: 'delete',
          color: Colors.red,
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPremiumPopupMenuItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

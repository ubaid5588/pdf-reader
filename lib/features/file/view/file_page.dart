import 'dart:io';

import 'package:file_reader/core/theme/app_colors.dart';
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
    final colors = context.colors;
    final currentName = file.path.split(Platform.pathSeparator).last;
    final nameWithoutExt = currentName.toLowerCase().endsWith('.pdf')
        ? currentName.substring(0, currentName.length - 4)
        : currentName;

    final nameController = TextEditingController(text: nameWithoutExt);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surfaceElevated,
          title: Text('Rename PDF', style: TextStyle(color: colors.textPrimary)),
          content: TextField(
            controller: nameController,
            autofocus: true,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter new name',
              hintStyle: TextStyle(color: colors.textSecondary),
              suffixText: '.pdf',
              suffixStyle: TextStyle(color: colors.textSecondary),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, nameController.text),
              child: Text('Rename', style: TextStyle(color: colors.primary)),
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
    final colors = context.colors;
    final fileName = file.path.split(Platform.pathSeparator).last;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surfaceElevated,
          title: Text('Delete PDF', style: TextStyle(color: colors.textPrimary)),
          content: Text(
            'Delete "$fileName"? This cannot be undone.',
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
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
    final colors = context.colors;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

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
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 22, right: 22),
              child: Obx(
                () => AnimatedCrossFade(
                  firstChild: SizedBox(
                    height: searchHeight,
                    child: TextField(
                      controller: _searchController,
                      onChanged: controller.updateSearch,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(color: colors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search PDFs',
                        hintStyle: TextStyle(
                          fontSize: isSmall ? 12 : 14,
                          color: colors.textSecondary,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          size: isSmall ? 20 : 22,
                          color: colors.textSecondary,
                        ),
                        suffixIcon: Obx(() {
                          if (controller.searchQuery.value.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: isSmall ? 19 : 21,
                              color: colors.textSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              controller.clearSearch();
                            },
                          );
                        }),
                        filled: true,
                        fillColor: colors.surface,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.border, width: 1),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.border, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: colors.primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  secondChild: Container(
                    height: searchHeight,
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(
                          Icons.check_circle,
                          color: colors.primary,
                          size: isSmall ? 20 : 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${selectedFiles.length} selected',
                            style: TextStyle(
                              fontSize: isSmall ? 12 : 14,
                              fontWeight: FontWeight.w600,
                              color: colors.primary,
                            ),
                          ),
                        ),
                        // Share Button
                        IconButton(
                          icon: const Icon(Icons.share_outlined),
                          color: colors.primary,
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
                          color: colors.primary,
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
                  return Center(
                    child: CircularProgressIndicator(color: colors.primary),
                  );
                }

                final files = controller.filteredFiles;

                if (controller.pdfFiles.isEmpty) {
                  return Center(
                    child: Text(
                      lang.file,
                      style: TextStyle(
                        fontSize: isSmall ? 13 : 15,
                        color: colors.textSecondary,
                      ),
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
                        style: TextStyle(
                          fontSize: isSmall ? 13 : 15,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: colors.primary,
                  backgroundColor: colors.surfaceElevated,
                  onRefresh: controller.loadPdfs,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: horizontalPadding,
                      top: 12,
                      bottom: keyboardHeight + 100,
                    ),
                    itemCount: files.length,
                    separatorBuilder: (context, index) {
                      return Divider(
                        height: 1,
                        indent: 8,
                        endIndent: 8,
                        color: colors.divider,
                      );
                    },
                    itemBuilder: (context, index) {
                      final file = files[index];

                      return Obx(() {
                        final isSelected = selectedFiles.contains(file.path);

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.primary.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isSmall ? 6 : 10,
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
                                          ? colors.primary
                                          : (colors.isDark
                                              ? const Color(0xFF3B1E1E)
                                              : const Color(0xFFFFEBEE)),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? colors.primary
                                            : (colors.isDark
                                                ? const Color(0xFF5A2525)
                                                : const Color(0xFFFFCDD2)),
                                        width: 1,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                          )
                                        : Icon(
                                            Icons.picture_as_pdf_rounded,
                                            color: colors.isDark
                                                ? const Color(0xFFF87171)
                                                : const Color(0xFFEF5350),
                                            size: 26,
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
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? colors.primary
                                    : colors.textPrimary,
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
                                      color: colors.textSecondary,
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Text(
                                    'Error loading date',
                                    style: TextStyle(
                                      fontSize: subtitleFontSize,
                                      color: colors.textSecondary,
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
                                      color: colors.textSecondary,
                                    ),
                                  );
                                }

                                return Text(
                                  'No date found',
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: colors.textSecondary,
                                  ),
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
    final colors = context.colors;

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: isSmall ? 20 : 22,
        color: colors.textSecondary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.border, width: 1),
      ),
      color: colors.surfaceElevated,
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
          context: context,
          icon: Icons.share_outlined,
          label: 'Share',
          value: 'share',
          color: colors.primary,
        ),
        _buildPremiumPopupMenuItem(
          context: context,
          icon: Icons.edit_outlined,
          label: 'Rename',
          value: 'rename',
          color: Colors.orange,
        ),
        _buildPremiumPopupMenuItem(
          context: context,
          icon: Icons.check_circle_outline,
          label: 'Select',
          value: 'select',
          color: colors.success,
        ),
        PopupMenuDivider(height: 8),
        _buildPremiumPopupMenuItem(
          context: context,
          icon: Icons.delete_outline,
          label: 'Delete',
          value: 'delete',
          color: colors.error,
          isDestructive: true,
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPremiumPopupMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isDestructive = false,
  }) {
    final colors = context.colors;

    return PopupMenuItem<String>(
      value: value,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDestructive ? colors.error : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

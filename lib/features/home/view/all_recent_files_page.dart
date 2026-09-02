import 'dart:io';

import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AllRecentFilesPage extends StatefulWidget {
  final bool isTab;

  const AllRecentFilesPage({
    super.key,
    this.isTab = false,
  });

  @override
  State<AllRecentFilesPage> createState() => _AllRecentFilesPageState();
}

class _AllRecentFilesPageState extends State<AllRecentFilesPage> {
  late final RecentPdfController recentController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    recentController = Get.isRegistered<RecentPdfController>()
        ? Get.find<RecentPdfController>()
        : Get.put(RecentPdfController());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  Future<void> _showClearAllConfirm(BuildContext context) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surfaceElevated,
          title: Text(
            'Clear Recent Files',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to clear your entire recent files history? Your actual PDF files will not be deleted.',
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Clear All',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await recentController.clearRecentPdfs();
    }
  }

  Future<void> _openPdf(String path, String name) async {
    final file = File(path);
    if (await file.exists()) {
      await recentController.addRecentPdf(path, name);
      Get.to(() => PdfViewer(filePath: file));
    } else {
      Get.snackbar(
        'File Not Found',
        'This file may have been moved or deleted.',
        snackPosition: SnackPosition.BOTTOM,
      );
      await recentController.removeRecentPdf(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallPhone = screenSize.width < 360;

    final content = Column(
      children: [
        // Tab Header / Subheader
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                final count = recentController.recentPdfs.length;
                return Row(
                  children: [
                    Text(
                      'All Recent PDFs',
                      style: TextStyle(
                        fontSize: isSmallPhone ? 15 : 17,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              }),
              Obx(() {
                if (recentController.recentPdfs.isEmpty) {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
                  onTap: () => _showClearAllConfirm(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        // Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: SizedBox(
            height: isSmallPhone ? 42 : 46,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search recent PDFs...',
                hintStyle: TextStyle(
                  fontSize: isSmallPhone ? 12.5 : 13.5,
                  color: colors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: colors.textSecondary,
                ),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          size: 19,
                          color: colors.textSecondary,
                        ),
                        onPressed: _clearSearch,
                      ),
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
        ),

        // Main Recent Files List
        Expanded(
          child: Obx(() {
            if (recentController.isLoading.value) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final allPdfs = recentController.recentPdfs;

            if (allPdfs.isEmpty) {
              return _buildEmptyState(
                colors: colors,
                icon: Icons.history_rounded,
                title: 'No Recent Files',
                subtitle: 'PDF files you open will appear here',
              );
            }

            // Filter by search query
            final query = _searchQuery;
            final filteredPdfs = query.isEmpty
                ? allPdfs
                : allPdfs.where((item) {
                    final name =
                        (item['name'] ?? '').toString().toLowerCase();
                    final path =
                        (item['path'] ?? '').toString().toLowerCase();
                    return name.contains(query) || path.contains(query);
                  }).toList();

            if (filteredPdfs.isEmpty) {
              return _buildEmptyState(
                colors: colors,
                icon: Icons.search_off_rounded,
                title: 'No Matching Files',
                subtitle: 'No recent files match "$query"',
              );
            }

            return RefreshIndicator(
              color: colors.primary,
              onRefresh: () => recentController.loadRecentPdfs(),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  4,
                  16,
                  widget.isTab ? 90 : 24,
                ),
                itemCount: filteredPdfs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = filteredPdfs[index];
                  final String name = item['name'] ?? 'Untitled.pdf';
                  final String path = item['path'] ?? '';
                  final int size = (item['size'] is int)
                      ? item['size'] as int
                      : (int.tryParse(item['size']?.toString() ?? '0') ?? 0);
                  final String dateStr = item['lastOpened'] ?? '';
                  final DateTime? date = DateTime.tryParse(dateStr);

                  String formattedSubtitle = '';
                  if (size > 0) {
                    formattedSubtitle += RecentPdfController.formatBytes(size);
                  }
                  if (date != null) {
                    final dateFormatted =
                        DateFormat('MMM d, yyyy').format(date);
                    if (formattedSubtitle.isNotEmpty) {
                      formattedSubtitle += ' • $dateFormatted';
                    } else {
                      formattedSubtitle = dateFormatted;
                    }
                  }

                  return Dismissible(
                    key: Key('recent_dismissible_$path'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    onDismissed: (_) {
                      recentController.removeRecentPdf(path);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: colors.cardShadow,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: colors.isDark
                                ? const Color(0xFF3B1E1E)
                                : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.picture_as_pdf_rounded,
                            color: colors.isDark
                                ? const Color(0xFFF87171)
                                : const Color(0xFFEF5350),
                            size: 24,
                          ),
                        ),
                        title: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        subtitle: formattedSubtitle.isNotEmpty
                            ? Text(
                                formattedSubtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: colors.textSecondary,
                                ),
                              )
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: colors.textSecondary.withOpacity(0.6),
                              ),
                              tooltip: 'Remove from recents',
                              onPressed: () =>
                                  recentController.removeRecentPdf(path),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 13,
                              color: colors.textSecondary.withOpacity(0.4),
                            ),
                          ],
                        ),
                        onTap: () => _openPdf(path, name),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );

    if (widget.isTab) {
      return content;
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.topBarBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.textPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'All Recent Files',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: content,
    );
  }

  Widget _buildEmptyState({
    required AppColors colors,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.isDark
                      ? const Color(0xFF1E2438)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 36,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                  height: 1.4,
                ),
              ),
              if (_searchQuery.isNotEmpty) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear_rounded, size: 16),
                  label: const Text('Clear search'),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:file_reader/core/theme/app_colors.dart';
import 'package:file_reader/features/converter/view/selected_tool.dart';
import 'package:file_reader/features/file/controller/file_page_controller.dart';
import 'package:file_reader/features/home/controller/navi_controller.dart';
import 'package:file_reader/features/pdf_viewer/view/pdf_viewer.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:file_reader/services/recent_pdf_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePageView> {
  late final NaviController naviController;
  late final FilePageController fileController;
  late final RecentPdfController recentController;

  @override
  void initState() {
    super.initState();
    naviController = Get.isRegistered<NaviController>()
        ? Get.find<NaviController>()
        : Get.put(NaviController());
    fileController = Get.isRegistered<FilePageController>()
        ? Get.find<FilePageController>()
        : Get.put(FilePageController());
    recentController = Get.isRegistered<RecentPdfController>()
        ? Get.find<RecentPdfController>()
        : Get.put(RecentPdfController());

    recentController.loadRecentPdfs();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final lang = AppLocalizations.of(context)!;
    final colors = context.colors;

    final bool isSmallPhone = screenSize.width < 360;
    final double horizontalPadding = isSmallPhone ? 12 : 16;
    final double sectionSpacing = isSmallPhone ? 20 : 26;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isSmallPhone ? 8 : 12),

          // Convert to PDF Section
          buildSection(
            context: context,
            title: lang.convertToPdf.toUpperCase(),
            items: _convertToPdfItems(lang, colors.isDark),
            crossAxisCount: 2,
            horizontalPadding: horizontalPadding,
          ),

          SizedBox(height: sectionSpacing),

          // Edit & Organize Section
          buildSection(
            context: context,
            title: lang.editAndOrganize.toUpperCase(),
            items: _editOrganizeItems(lang, colors.isDark),
            crossAxisCount: 2,
            horizontalPadding: horizontalPadding,
          ),

          SizedBox(height: sectionSpacing),

          // All Files Count & Navigation Card
          _buildAllFilesBanner(context, screenSize, lang, horizontalPadding),

          SizedBox(height: sectionSpacing),

          // Recent Files Section
          _buildRecentFilesSection(context, screenSize, lang, horizontalPadding),

          SizedBox(height: isSmallPhone ? 60 : 80),
        ],
      ),
    );
  }

  Widget _buildAllFilesBanner(
    BuildContext context,
    Size screenSize,
    AppLocalizations lang,
    double horizontalPadding,
  ) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: GestureDetector(
        onTap: () => naviController.changePage(1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primaryGradientStart,
                colors.primaryGradientEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withOpacity(colors.isDark ? 0.2 : 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.folder_copy_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Files',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(() {
                      final count = fileController.pdfFiles.length;
                      return Text(
                        fileController.isLoading.value
                            ? 'Scanning files...'
                            : '$count ${count == 1 ? 'PDF' : 'PDFs'} in your library',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 11,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFilesSection(
    BuildContext context,
    Size screenSize,
    AppLocalizations lang,
    double horizontalPadding,
  ) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Files',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                  letterSpacing: 0.5,
                ),
              ),
              Obx(() {
                if (recentController.recentPdfs.isEmpty) {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
                  onTap: () => recentController.clearRecentPdfs(),
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() {
            if (recentController.isLoading.value) {
              return Container(
                padding: const EdgeInsets.all(24),
                alignment: Alignment.center,
                child: const CupertinoActivityIndicator(),
              );
            }

            if (recentController.recentPdfs.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.border,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.cardShadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.isDark
                            ? const Color(0xFF1E2438)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: colors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'No Recent Files',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'PDF files you open will appear here',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            final items = recentController.recentPdfs.take(5).toList();

            return Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.cardShadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: items.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 68,
                  endIndent: 16,
                  color: colors.divider,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
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
                    final dateFormatted = DateFormat('MMM d, yyyy').format(date);
                    if (formattedSubtitle.isNotEmpty) {
                      formattedSubtitle += ' • $dateFormatted';
                    } else {
                      formattedSubtitle = dateFormatted;
                    }
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ),
                    leading: Container(
                      width: 42,
                      height: 42,
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
                        size: 22,
                      ),
                    ),
                    title: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    subtitle: formattedSubtitle.isNotEmpty
                        ? Text(
                            formattedSubtitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.textSecondary,
                            ),
                          )
                        : null,
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: colors.textSecondary.withOpacity(0.5),
                    ),
                    onTap: () async {
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
                        recentController.removeRecentPdf(path);
                      }
                    },
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget buildSection({
    required BuildContext context,
    required String title,
    required List<ToolItem> items,
    required int crossAxisCount,
    required double horizontalPadding,
  }) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.primary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: items
                .map((item) => _buildToolIcon(context, item))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(BuildContext context, ToolItem item) {
    final colors = context.colors;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SelectedTool(
              toolType: item.toolType,
              icon: item.icon,
              bgColor: item.bgColor,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.cardShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 28),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ToolItem> _convertToPdfItems(AppLocalizations lang, bool isDark) => [
    ToolItem(
      icon: Icons.text_snippet_rounded,
      iconColor: isDark ? const Color(0xFF3B82F6) : Colors.white,
      bgColor: isDark ? const Color(0xFF152238) : const Color(0xFF4285F4),
      label: lang.wordToPdf,
      toolType: ToolType.wordToPdf,
    ),
    ToolItem(
      icon: Icons.image_rounded,
      iconColor: isDark ? const Color(0xFFA78BFA) : Colors.white,
      bgColor: isDark ? const Color(0xFF281E3B) : const Color(0xFF9C6CF5),
      label: lang.imageToPdf,
      toolType: ToolType.imageToPdf,
    ),
    ToolItem(
      icon: Icons.slideshow_rounded,
      iconColor: isDark ? const Color(0xFFF87171) : Colors.white,
      bgColor: isDark ? const Color(0xFF3B1E1E) : const Color(0xFFEA4335),
      label: lang.pptToPdf,
      toolType: ToolType.pptToPdf,
    ),
    ToolItem(
      icon: Icons.table_chart_rounded,
      iconColor: isDark ? const Color(0xFF34D399) : Colors.white,
      bgColor: isDark ? const Color(0xFF163326) : const Color(0xFF34A853),
      label: lang.excelToPdf,
      toolType: ToolType.excelToPdf,
    ),
  ];

  List<ToolItem> _editOrganizeItems(AppLocalizations lang, bool isDark) => [
    ToolItem(
      icon: Icons.edit_document,
      iconColor: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
      bgColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
      label: lang.editPdf,
      toolType: ToolType.editPdf,
    ),
    ToolItem(
      icon: Icons.merge_type_rounded,
      iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFFFA000),
      bgColor: isDark ? const Color(0xFF382614) : const Color(0xFFFFF3E0),
      label: lang.mergePdf,
      toolType: ToolType.mergePdf,
    ),
    ToolItem(
      icon: Icons.unfold_more_rounded,
      iconColor: isDark ? const Color(0xFFF87171) : const Color(0xFFE53935),
      bgColor: isDark ? const Color(0xFF381B1B) : const Color(0xFFFFEBEE),
      label: lang.splitPdf,
      toolType: ToolType.splitPdf,
    ),
    ToolItem(
      icon: Icons.compress_rounded,
      iconColor: isDark ? const Color(0xFFFBBF24) : const Color(0xFFFFA000),
      bgColor: isDark ? const Color(0xFF382614) : const Color(0xFFFFF8E1),
      label: lang.compressPdf,
      toolType: ToolType.compressPdf,
    ),
    ToolItem(
      icon: Icons.shield_outlined,
      iconColor: isDark ? const Color(0xFF34D399) : const Color(0xFF43A047),
      bgColor: isDark ? const Color(0xFF163326) : const Color(0xFFE8F5E9),
      label: lang.protectPdf,
      toolType: ToolType.protectPdf,
    ),
  ];
}

class ToolItem {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String label;
  final ToolType toolType;

  const ToolItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.label,
    required this.toolType,
  });
}

import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:file_reader/features/converter/view/selected_tool.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePageView> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final lang = AppLocalizations.of(context)!;

    final bool isSmallPhone = screenSize.width < 360;
    final double horizontalPadding = isSmallPhone ? 12 : 16;
    final double sectionSpacing = isSmallPhone ? 24 : 32;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isSmallPhone ? 8 : 12),

          buildSection(
            title: lang.convertToPdf,
            items: _convertToPdfItems(lang),
            crossAxisCount: 2,
            horizontalPadding: horizontalPadding,
          ),

          // SizedBox(height: sectionSpacing),
          buildSection(
            title: lang.editAndOrganize,
            items: _editOrganizeItems(lang),
            crossAxisCount: 2,
            horizontalPadding: horizontalPadding,
          ),

          SizedBox(height: sectionSpacing),

          // Recent Files Section
          _buildRecentFilesSection(screenSize, lang, horizontalPadding),

          SizedBox(height: isSmallPhone ? 60 : 80),
        ],
      ),
    );
  }

  Widget _buildRecentFilesSection(
    Size screenSize,
    AppLocalizations lang,
    double horizontalPadding,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5B5CFF), Color(0xFF4A4FE8)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B5CFF).withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Files',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '5 PDFs in your library',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'View all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection({
    required String title,
    required List<ToolItem> items,
    required int crossAxisCount,
    required double horizontalPadding,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF5B5CFF),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 5),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: items.map((item) => _buildToolIcon(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToolIcon(ToolItem item) {
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
          color: const Color.fromARGB(196, 255, 255, 255),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
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
              child: Icon(item.icon, color: item.iconColor, size: 32),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),

              child: Text(
                item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ToolItem> _convertToPdfItems(AppLocalizations lang) => [
    ToolItem(
      icon: Icons.text_fields,
      iconColor: Colors.white,
      bgColor: const Color(0xFF4285F4),
      label: lang.wordToPdf,
      toolType: ToolType.wordToPdf,
    ),
    ToolItem(
      icon: Icons.image_outlined,
      iconColor: Colors.white,
      bgColor: const Color(0xFF9C6CF5),
      label: lang.imageToPdf,
      toolType: ToolType.imageToPdf,
    ),
    ToolItem(
      icon: Icons.slideshow,
      iconColor: Colors.white,
      bgColor: const Color(0xFFEA4335),
      label: lang.pptToPdf,
      toolType: ToolType.pptToPdf,
    ),
    ToolItem(
      icon: Icons.table_chart_outlined,
      iconColor: Colors.white,
      bgColor: const Color(0xFF34A853),
      label: lang.excelToPdf,
      toolType: ToolType.excelToPdf,
    ),
  ];

  List<ToolItem> _editOrganizeItems(AppLocalizations lang) => [
    ToolItem(
      icon: Icons.merge_type,
      iconColor: const Color(0xFFFFA000),
      bgColor: const Color(0xFFFFF3E0),
      label: lang.mergePdf,
      toolType: ToolType.mergePdf,
    ),
    ToolItem(
      icon: Icons.content_cut,
      iconColor: const Color(0xFFE53935),
      bgColor: const Color(0xFFFFEBEE),
      label: lang.splitPdf,
      toolType: ToolType.splitPdf,
    ),
    ToolItem(
      icon: Icons.compress,
      iconColor: const Color(0xFFFFA000),
      bgColor: const Color(0xFFFFF8E1),
      label: lang.compressPdf,
      toolType: ToolType.compressPdf,
    ),
    ToolItem(
      icon: Icons.lock_outline,
      iconColor: const Color(0xFF43A047),
      bgColor: const Color(0xFFE8F5E9),
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

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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenSize.height * 0.02),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.height * 0.02),
            child: Container(
              height: screenSize.height * 0.2,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEDE8FF), Color(0xFFDDD5FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -20,
                    right: 80,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    right: 20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                lang.bannerTitle,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A2E),
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                lang.bannerSubtitle,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF6B6B8A),
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6C4EF5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  lang.tryNow,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // _buildPhoneIllustration(),
                      ],
                    ),
                  ),
                  // Positioned(
                  //   right: screenSize.width * 0.12,
                  //   top: screenSize.height * 0.026,
                  //   child: Image.asset(
                  //     'assets/images/prem.png',
                  //     width: screenSize.height * 0.13,
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),

          buildSection(
            title: lang.convertToPdf,
            items: _convertToPdfItems(lang),
            crossAxisCount: 3,
          ),
          const SizedBox(height: 24),
          buildSection(
            title: lang.editAndOrganize,
            items: _editOrganizeItems(lang),
            crossAxisCount: 3,
          ),
          SizedBox(height: screenSize.height * 0.1),
        ],
      ),
    );
  }

  Widget buildPhoneIllustration() {
    return SizedBox(
      width: 130,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 65,
            height: 105,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0ECFF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFCCC0FF),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'PDF',
                      style: TextStyle(
                        color: Color(0xFF6C4EF5),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(width: 30, height: 3, color: const Color(0xFFE0D9FF)),
                const SizedBox(height: 3),
                Container(width: 24, height: 3, color: const Color(0xFFE0D9FF)),
                const SizedBox(height: 3),
                Container(width: 28, height: 3, color: const Color(0xFFE0D9FF)),
              ],
            ),
          ),
          Positioned(
            top: 4,
            left: 0,
            child: _floatingIcon(
              Icons.text_fields,
              const Color(0xFF4285F4),
              26,
            ),
          ),
          Positioned(
            top: 4,
            right: 0,
            child: _floatingIcon(Icons.edit, const Color(0xFF9C27B0), 22),
          ),
          Positioned(
            bottom: 8,
            left: 2,
            child: _floatingIcon(
              Icons.table_chart,
              const Color(0xFF34A853),
              26,
            ),
          ),
          Positioned(
            bottom: 12,
            right: 2,
            child: _floatingIcon(Icons.slideshow, const Color(0xFFEA4335), 22),
          ),
        ],
      ),
    );
  }

  Widget _floatingIcon(IconData icon, Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.55),
    );
  }

  Widget buildSection({
    required String title,
    required List<ToolItem> items,
    required int crossAxisCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(250, 255, 255, 255),
              borderRadius: BorderRadius.circular(16),
            ),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,

              childAspectRatio: 1.2,

              crossAxisSpacing: 10,
              children: items.map((item) => _buildToolIcon(item)).toList(),
            ),
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
            // Pass the locale-independent enum, not the translated label -
            // SelectedTool uses this to decide which controller to run.
            builder: (_) => SelectedTool(
              toolType: item.toolType,
              icon: item.icon,
              bgColor: item.bgColor,
            ),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF444466),
              height: 1.2,
            ),
          ),
        ],
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
    // ToolItem(
    //   icon: Icons.edit_outlined,
    //   iconColor: const Color(0xFFE53935),
    //   bgColor: const Color(0xFFFFEBEE),
    //   label: lang.signOnPdf,
    //   toolType: ToolType.signOnPdf,
    // ),
    // ToolItem(
    //   icon: Icons.document_scanner_outlined,
    //   iconColor: const Color(0xFF6C4EF5),
    //   bgColor: const Color(0xFFEDE8FF),
    //   label: lang.ocrPdf,
    //   toolType: ToolType.ocrPdf,
    // ),
    // ToolItem(
    //   icon: Icons.dashboard_outlined,
    //   iconColor: const Color(0xFF4285F4),
    //   bgColor: const Color(0xFFE3F2FD),
    //   label: lang.organizePdf,
    //   toolType: ToolType.organizePdf,
    // ),
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

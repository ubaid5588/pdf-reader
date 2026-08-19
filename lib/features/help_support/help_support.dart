import 'package:file_reader/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportScreen extends StatefulWidget {
  const HelpAndSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpAndSupportScreen> createState() => _HelpAndSupportScreenState();
}

class _HelpAndSupportScreenState extends State<HelpAndSupportScreen> {
  int? expandedFaqIndex;
  int? expandedTroubleshootIndex;

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text(
          'Help & Support',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors.isDark
                      ? [
                          const Color(0xFF1E2030),
                          const Color(0xFF191B29),
                        ]
                      : [Colors.blue.shade400, Colors.blue.shade600],
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.help_outline_rounded, size: 48, color: colors.primary),
                  const SizedBox(height: 12),
                  Text(
                    'We\'re Here to Help!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Find answers to your questions',
                    style: TextStyle(fontSize: 14, color: colors.textSecondary),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Support Section
                  _buildQuickSupportSection(context),
                  const SizedBox(height: 32),

                  // FAQ Section
                  _buildFaqSection(context),
                  const SizedBox(height: 32),

                  // Troubleshooting Section
                  _buildTroubleshootingSection(context),
                  const SizedBox(height: 32),

                  // Tips & Tricks Section
                  _buildTipsAndTricksSection(context),
                  const SizedBox(height: 32),

                  // Contact Support Section
                  _buildContactSupportSection(context),
                  const SizedBox(height: 32),

                  // Feedback Section
                  _buildFeedbackSection(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSupportSection(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Support',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSupportCard(
                context: context,
                icon: Icons.mail_outline,
                title: 'Email',
                subtitle: 'support@example.com',
                onTap: () => _launchUrl('mailto:support@example.com'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSupportCard(
                context: context,
                icon: Icons.message_outlined,
                title: 'Chat',
                subtitle: 'Live support',
                onTap: () => _showComingSoon('Live Chat'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSupportCard(
                context: context,
                icon: Icons.bug_report_outlined,
                title: 'Report Bug',
                subtitle: 'Report issues',
                onTap: () => _showBugReportDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSupportCard(
                context: context,
                icon: Icons.lightbulb_outline,
                title: 'Suggest',
                subtitle: 'New features',
                onTap: () => _showFeatureRequestDialog(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSupportCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return Material(
      color: colors.surfaceElevated,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: colors.primary, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    final colors = context.colors;

    final faqList = [
      {
        'question': 'How do I protect a PDF with a password?',
        'answer':
            'Navigate to "Edit & Organize" > "Protect PDF". Select your PDF file and set a strong password. The protected PDF will be saved automatically to your Files section.',
      },
      {
        'question': 'Can I merge multiple PDFs?',
        'answer':
            'Yes! Go to "Edit & Organize" > "Merge PDF". Select multiple PDF files you want to combine, and they will be merged into a single document.',
      },
      {
        'question': 'How do I convert Word to PDF?',
        'answer':
            'Open the app, go to "Convert to PDF" > "Word to PDF". Select your Word document, and it will be automatically converted to PDF format.',
      },
      {
        'question': 'Can I split a PDF into separate pages?',
        'answer':
            'Yes! Use "Edit & Organize" > "Split PDF". Select your PDF and choose which pages you want to extract.',
      },
      {
        'question': 'How do I compress a PDF?',
        'answer':
            'Go to "Edit & Organize" > "Compress PDF". Select your PDF file. The app will reduce the file size while maintaining quality.',
      },
      {
        'question': 'Where are my files stored?',
        'answer':
            'All your files are stored locally on your device in the app\'s storage. Access them anytime from the "Files" tab.',
      },
      {
        'question': 'Can I convert images to PDF?',
        'answer':
            'Absolutely! Go to "Convert to PDF" > "Image to PDF". Select one or multiple images, and they will be converted to a PDF document.',
      },
      {
        'question': 'Is my data safe?',
        'answer':
            'Yes! All files are processed locally on your device. Nothing is uploaded to any server. Your documents remain completely private and secure.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: faqList.length,
          itemBuilder: (ctx, index) {
            final faq = faqList[index];
            return _buildFaqItem(
              context: ctx,
              index: index,
              question: faq['question']!,
              answer: faq['answer']!,
            );
          },
        ),
      ],
    );
  }

  Widget _buildFaqItem({
    required BuildContext context,
    required int index,
    required String question,
    required String answer,
  }) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: colors.primary,
          collapsedIconColor: colors.textSecondary,
          onExpansionChanged: (expanded) {
            setState(() {
              expandedFaqIndex = expanded ? index : null;
            });
          },
          title: Text(
            question,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingSection(BuildContext context) {
    final colors = context.colors;

    final troubleshoots = [
      {
        'issue': 'PDF won\'t convert',
        'solution':
            'Ensure the file is not corrupted. Try with a different PDF. Check if you have enough storage space.',
      },
      {
        'issue': 'Can\'t open a protected PDF',
        'solution':
            'Make sure you\'re using the correct password. Passwords are case-sensitive.',
      },
      {
        'issue': 'Merge not working',
        'solution':
            'Ensure you selected at least 2 PDFs. All PDFs should be valid and not corrupted.',
      },
      {
        'issue': 'File not appearing in Files tab',
        'solution':
            'Close and reopen the app. Check if you granted storage permission to the app.',
      },
      {
        'issue': 'Slow performance',
        'solution':
            'Try closing other apps. Clear app cache from Settings. Restart your device.',
      },
      {
        'issue': 'Compressed PDF is still large',
        'solution':
            'Quality settings affect file size. Some PDFs with images compress less than text-only PDFs.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Troubleshooting',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: troubleshoots.length,
          itemBuilder: (ctx, index) {
            final item = troubleshoots[index];
            return _buildTroubleshootItem(
              context: ctx,
              index: index,
              issue: item['issue']!,
              solution: item['solution']!,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTroubleshootItem({
    required BuildContext context,
    required int index,
    required String issue,
    required String solution,
  }) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: colors.warning.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
        color: colors.warning.withOpacity(0.08),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: colors.warning,
          collapsedIconColor: colors.warning,
          onExpansionChanged: (expanded) {
            setState(() {
              expandedTroubleshootIndex = expanded ? index : null;
            });
          },
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: colors.warning,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  issue,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: colors.success,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      solution,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsAndTricksSection(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💡 Tips & Tricks',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildTipCard(
          context: context,
          title: '🔐 Strong Passwords',
          description:
              'Use strong, unique passwords when protecting PDFs. Avoid simple words or birthdates.',
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          context: context,
          title: '📦 Organize Files',
          description:
              'Regularly organize your Files section. Delete old files to free up storage.',
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          context: context,
          title: '⚡ Batch Processing',
          description:
              'You can convert multiple images to PDFs. Select all images at once for faster conversion.',
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          context: context,
          title: '🗜️ Compression Tips',
          description:
              'For better results, compress PDFs with mostly images rather than text. Text-heavy PDFs compress less.',
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          context: context,
          title: '✂️ Split Wisely',
          description:
              'Before splitting, note down the page numbers. This helps extract exactly what you need.',
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          context: context,
          title: '🔄 Merge Order',
          description:
              'PDFs are merged in the order you select them. Choose carefully for the desired output.',
        ),
      ],
    );
  }

  Widget _buildTipCard({
    required BuildContext context,
    required String title,
    required String description,
  }) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.isDark
            ? const Color(0xFF142920)
            : Colors.green.shade50,
        border: Border.all(
          color: colors.success.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.success,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupportSection(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Support',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          context: context,
          icon: Icons.email_outlined,
          title: 'Email Support',
          subtitle: 'support@example.com',
          description: 'Send us an email for detailed support',
          onTap: () => _launchUrl('mailto:support@example.com'),
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          context: context,
          icon: Icons.language,
          title: 'Visit Website',
          subtitle: 'www.example.com',
          description: 'Visit our website for more info',
          onTap: () => _launchUrl('https://example.com'),
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          context: context,
          icon: Icons.access_time_rounded,
          title: 'Response Time',
          subtitle: '24-48 hours',
          description: 'We typically respond within a day',
          onTap: null,
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    VoidCallback? onTap,
  }) {
    final colors = context.colors;

    return Material(
      color: colors.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: colors.primary, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(fontSize: 11, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: colors.textSecondary.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Feedback Matters',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '⭐ Rate This App',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If you love PDF Reader, please leave a rating on the app store. Your feedback helps us improve!',
                style: TextStyle(fontSize: 12, color: colors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => _showComingSoon('Rate App'),
                        borderRadius: BorderRadius.circular(10),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(
                            child: Text(
                              'Rate Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Material(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: colors.border),
                          ),
                          child: Center(
                            child: Text(
                              'Later',
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature is coming in the next update!',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final colors = context.colors;
    final controller = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: colors.surfaceElevated,
        title: Text('Report a Bug', style: TextStyle(color: colors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Describe the issue you encountered:',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 5,
                style: TextStyle(color: colors.textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.primary),
                  ),
                  hintText: 'Describe the bug...',
                  hintStyle: TextStyle(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _launchUrl(
                  'mailto:support@example.com?subject=Bug Report&body=${controller.text}',
                );
                Get.back();
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showFeatureRequestDialog(BuildContext context) {
    final colors = context.colors;
    final controller = TextEditingController();

    Get.dialog(
      AlertDialog(
        backgroundColor: colors.surfaceElevated,
        title: Text('Request a Feature', style: TextStyle(color: colors.textPrimary)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tell us what feature you\'d like to see:',
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 5,
                style: TextStyle(color: colors.textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.primary),
                  ),
                  hintText: 'Describe your idea...',
                  hintStyle: TextStyle(color: colors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _launchUrl(
                  'mailto:support@example.com?subject=Feature Request&body=${controller.text}',
                );
                Get.back();
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

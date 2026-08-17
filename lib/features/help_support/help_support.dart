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
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.help_outline, size: 50, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'We\'re Here to Help!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find answers to your questions',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
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
                  _buildQuickSupportSection(),
                  const SizedBox(height: 32),

                  // FAQ Section
                  _buildFaqSection(),
                  const SizedBox(height: 32),

                  // Troubleshooting Section
                  _buildTroubleshootingSection(),
                  const SizedBox(height: 32),

                  // Tips & Tricks Section
                  _buildTipsAndTricksSection(),
                  const SizedBox(height: 32),

                  // Contact Support Section
                  _buildContactSupportSection(),
                  const SizedBox(height: 32),

                  // Feedback Section
                  _buildFeedbackSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Support',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSupportCard(
                icon: Icons.mail_outline,
                title: 'Email',
                subtitle: 'support@example.com',
                onTap: () => _launchUrl('mailto:support@example.com'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSupportCard(
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
                icon: Icons.bug_report_outlined,
                title: 'Report Bug',
                subtitle: 'Report issues',
                onTap: () => _showBugReportDialog(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSupportCard(
                icon: Icons.lightbulb_outline,
                title: 'Suggest',
                subtitle: 'New features',
                onTap: () => _showFeatureRequestDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSupportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
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
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: faqList.length,
          itemBuilder: (context, index) {
            final faq = faqList[index];
            return _buildFaqItem(
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
    required int index,
    required String question,
    required String answer,
  }) {
    final isExpanded = expandedFaqIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() {
              expandedFaqIndex = expanded ? index : null;
            });
          },
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingSection() {
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
        const Text(
          'Troubleshooting',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: troubleshoots.length,
          itemBuilder: (context, index) {
            final item = troubleshoots[index];
            return _buildTroubleshootItem(
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
    required int index,
    required String issue,
    required String solution,
  }) {
    final isExpanded = expandedTroubleshootIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
        color: Colors.orange.shade50,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (expanded) {
            setState(() {
              expandedTroubleshootIndex = expanded ? index : null;
            });
          },
          title: Row(
            children: [
              const Icon(
                Icons.warning_outlined,
                color: Colors.orange,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  issue,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
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
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      solution,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
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

  Widget _buildTipsAndTricksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💡 Tips & Tricks',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildTipCard(
          '🔐 Strong Passwords',
          'Use strong, unique passwords when protecting PDFs. Avoid simple words or birthdates.',
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          '📦 Organize Files',
          'Regularly organize your Files section. Delete old files to free up storage.',
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          '⚡ Batch Processing',
          'You can convert multiple images to PDFs. Select all images at once for faster conversion.',
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          '🗜️ Compression Tips',
          'For better results, compress PDFs with mostly images rather than text. Text-heavy PDFs compress less.',
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          '✂️ Split Wisely',
          'Before splitting, note down the page numbers. This helps extract exactly what you need.',
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          '🔄 Merge Order',
          'PDFs are merged in the order you select them. Choose carefully for the desired output.',
        ),
      ],
    );
  }

  Widget _buildTipCard(String title, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contact Support',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          icon: Icons.email_outlined,
          title: 'Email Support',
          subtitle: 'support@example.com',
          description: 'Send us an email for detailed support',
          onTap: () => _launchUrl('mailto:support@example.com'),
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          icon: Icons.language,
          title: 'Visit Website',
          subtitle: 'www.example.com',
          description: 'Visit our website for more info',
          onTap: () => _launchUrl('https://example.com'),
        ),
        const SizedBox(height: 12),
        _buildContactItem(
          icon: Icons.phone_outlined,
          title: 'Response Time',
          subtitle: '24-48 hours',
          description: 'We typically respond within a day',
          onTap: null,
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Feedback Matters',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            border: Border.all(color: Colors.purple.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '⭐ Rate This App',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'If you love PDF Reader, please leave a rating on the app store. Your feedback helps us improve!',
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        onTap: () => _showComingSoon('Rate App'),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: Text(
                              'Rate Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Material(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(6),
                      child: InkWell(
                        onTap: () {
                          Get.back();
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Center(
                            child: Text(
                              'Later',
                              style: TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
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
      duration: const Duration(seconds: 2),
    );
  }

  void _showBugReportDialog() {
    final controller = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Report a Bug'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Describe the issue you encountered:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Describe the bug...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
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

  void _showFeatureRequestDialog() {
    final controller = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Request a Feature'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us what feature you\'d like to see:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Describe your idea...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
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

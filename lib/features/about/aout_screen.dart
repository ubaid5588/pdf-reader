import 'package:file_reader/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

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
          'About',
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
            // App Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: colors.isDark ? const Color(0xFF191B29) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.isDark ? colors.border : Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.cardShadow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PDF Reader',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(fontSize: 14, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Section
                  _buildSection(
                    context: context,
                    title: 'About This App',
                    children: [
                      Text(
                        'PDF Reader is a comprehensive PDF management tool that lets you read, convert, edit, organize, and protect your PDF documents with ease. All your PDF needs in one powerful app.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Main Features Section
                  _buildSection(
                    context: context,
                    title: '📖 Read PDFs',
                    children: [
                      Text(
                        'View and read PDF documents with smooth scrolling and zoom capabilities. Organize all your PDFs in one place with the Files section.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Convert Section
                  _buildSection(
                    context: context,
                    title: '🔄 Convert to PDF',
                    children: [
                      _buildFeatureItem(
                        context: context,
                        icon: '📄',
                        title: 'Word to PDF',
                        description: 'Convert Word documents to PDF format',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        context: context,
                        icon: '🖼️',
                        title: 'Image to PDF',
                        description: 'Convert images (JPG, PNG, etc) to PDF',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        context: context,
                        icon: '📊',
                        title: 'PPT to PDF',
                        description: 'Convert PowerPoint presentations to PDF',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        context: context,
                        icon: '📈',
                        title: 'Excel to PDF',
                        description: 'Convert Excel spreadsheets to PDF',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Edit & Organize Section
                  _buildSection(
                    context: context,
                    title: '✏️ Edit & Organize',
                    children: [
                      _buildFeatureItem(
                        context: context,
                        icon: '🔗',
                        title: 'Merge PDF',
                        description: 'Combine multiple PDFs into one document',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        context: context,
                        icon: '✂️',
                        title: 'Split PDF',
                        description: 'Extract specific pages from a PDF',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        context: context,
                        icon: '📦',
                        title: 'Compress PDF',
                        description:
                            'Reduce PDF file size without quality loss',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        context: context,
                        icon: '🔒',
                        title: 'Protect PDF',
                        description:
                            'Add password protection with AES-256 encryption',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Files Section
                  _buildSection(
                    context: context,
                    title: '📁 Files Management',
                    children: [
                      Text(
                        'Access the Files section to:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBulletPoint(
                        context: context,
                        text: 'View all your saved PDFs in one place',
                      ),
                      _buildBulletPoint(
                        context: context,
                        text: 'Organize and manage your documents',
                      ),
                      _buildBulletPoint(
                        context: context,
                        text: 'Quick access to recently used files',
                      ),
                      _buildBulletPoint(
                        context: context,
                        text: 'Search and sort PDFs easily',
                      ),
                      _buildBulletPoint(
                        context: context,
                        text: 'Delete or share documents',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Key Features Section
                  _buildSection(
                    context: context,
                    title: '⚡ Key Features',
                    children: [
                      _buildFeatureItem(
                        context: context,
                        icon: '🔐',
                        title: 'Secure & Safe',
                        description:
                            'Military-grade AES-256 encryption for protection',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        context: context,
                        icon: '⚙️',
                        title: 'Easy to Use',
                        description:
                            'Simple, intuitive interface for all users',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        context: context,
                        icon: '🚀',
                        title: 'Fast & Efficient',
                        description: 'Quick conversions and processing',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        context: context,
                        icon: '💾',
                        title: 'Local Storage',
                        description: 'All files stored securely on your device',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Tech Stack Section
                  _buildSection(
                    context: context,
                    title: '🛠️ Built With',
                    children: [
                      _buildTechItem(
                        context: context,
                        name: 'Flutter',
                        description: 'Cross-platform mobile framework',
                      ),
                      const SizedBox(height: 8),
                      _buildTechItem(
                        context: context,
                        name: 'GetX',
                        description: 'State management & navigation',
                      ),
                      const SizedBox(height: 8),
                      _buildTechItem(
                        context: context,
                        name: 'Syncfusion PDF',
                        description: 'Advanced PDF manipulation',
                      ),
                      const SizedBox(height: 8),
                      _buildTechItem(
                        context: context,
                        name: 'File Picker',
                        description: 'File selection & management',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // How to Use Section
                  _buildSection(
                    context: context,
                    title: '📚 How to Use',
                    children: [
                      _buildStepItem(
                        context: context,
                        number: '1',
                        title: 'Home Screen',
                        description: 'Access all PDF tools from the home screen',
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        context: context,
                        number: '2',
                        title: 'Choose Tool',
                        description:
                            'Select the conversion or editing tool you need',
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        context: context,
                        number: '3',
                        title: 'Pick File',
                        description: 'Select your file from device storage',
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        context: context,
                        number: '4',
                        title: 'Process',
                        description:
                            'Configure settings (password, etc) if needed',
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        context: context,
                        number: '5',
                        title: 'Save',
                        description: 'File is saved to app storage automatically',
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        context: context,
                        number: '6',
                        title: 'Files Section',
                        description: 'Access your files anytime from Files tab',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Contact Section
                  _buildSection(
                    context: context,
                    title: '📧 Contact & Support',
                    children: [
                      Row(
                        children: [
                          _buildContactButton(
                            context: context,
                            icon: Icons.mail_outline,
                            label: 'Email',
                            onTap: () =>
                                _launchUrl('mailto:support@example.com'),
                          ),
                          const SizedBox(width: 12),
                          _buildContactButton(
                            context: context,
                            icon: Icons.public,
                            label: 'Website',
                            onTap: () => _launchUrl('https://example.com'),
                          ),
                          const SizedBox(width: 12),
                          _buildContactButton(
                            context: context,
                            icon: Icons.code,
                            label: 'GitHub',
                            onTap: () => _launchUrl('https://github.com'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Legal Section
                  _buildSection(
                    context: context,
                    title: '⚖️ Legal',
                    children: [
                      GestureDetector(
                        onTap: () => _showDialog(
                          context,
                          'Privacy Policy',
                          'Your privacy is important to us.\n\n• We do not collect any personal data\n• All files are processed locally on your device\n• No files are uploaded to any server\n• Your documents remain private and secure',
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _showDialog(
                          context,
                          'Terms & Conditions',
                          'By using this app, you agree to:\n\n• Use the app for lawful purposes only\n• Not use it to violate any copyrights\n• Not use it to protect documents you don\'t own\n\nThe developers are not responsible for misuse of this application. Use responsibly.',
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '© 2024 PDF Reader',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Made with ❤️ using Flutter',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Thank you for using PDF Reader!',
                            style: TextStyle(
                              fontSize: 11,
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildFeatureItem({
    required BuildContext context,
    required String icon,
    required String title,
    required String description,
  }) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint({
    required BuildContext context,
    required String text,
  }) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required BuildContext context,
    required String number,
    required String title,
    required String description,
  }) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
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
                description,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechItem({
    required BuildContext context,
    required String name,
    required String description,
  }) {
    final colors = context.colors;

    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return Expanded(
      child: Material(
        color: colors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              children: [
                Icon(icon, color: colors.primary, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    final colors = context.colors;

    Get.dialog(
      AlertDialog(
        backgroundColor: colors.surfaceElevated,
        title: Text(title, style: TextStyle(color: colors.textPrimary)),
        content: SingleChildScrollView(
          child: Text(content, style: TextStyle(color: colors.textSecondary)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Close', style: TextStyle(color: colors.primary)),
          ),
        ],
      ),
    );
  }
}

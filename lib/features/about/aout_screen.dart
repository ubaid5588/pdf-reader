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
    return Scaffold(
      appBar: AppBar(title: const Text('About'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // App Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      size: 50,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PDF Reader',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
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
                    title: 'About This App',
                    children: [
                      const Text(
                        'PDF Reader is a comprehensive PDF management tool that lets you read, convert, edit, organize, and protect your PDF documents with ease. All your PDF needs in one powerful app.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Main Features Section
                  _buildSection(
                    title: '📖 Read PDFs',
                    children: [
                      const Text(
                        'View and read PDF documents with smooth scrolling and zoom capabilities. Organize all your PDFs in one place with the Files section.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Convert Section
                  _buildSection(
                    title: '🔄 Convert to PDF',
                    children: [
                      _buildFeatureItem(
                        icon: '📄',
                        title: 'Word to PDF',
                        description: 'Convert Word documents to PDF format',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        icon: '🖼️',
                        title: 'Image to PDF',
                        description: 'Convert images (JPG, PNG, etc) to PDF',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        icon: '📊',
                        title: 'PPT to PDF',
                        description: 'Convert PowerPoint presentations to PDF',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        icon: '📈',
                        title: 'Excel to PDF',
                        description: 'Convert Excel spreadsheets to PDF',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Edit & Organize Section
                  _buildSection(
                    title: '✏️ Edit & Organize',
                    children: [
                      _buildFeatureItem(
                        icon: '🔗',
                        title: 'Merge PDF',
                        description: 'Combine multiple PDFs into one document',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        icon: '✂️',
                        title: 'Split PDF',
                        description: 'Extract specific pages from a PDF',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        icon: '📦',
                        title: 'Compress PDF',
                        description:
                            'Reduce PDF file size without quality loss',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
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
                    title: '📁 Files Management',
                    children: [
                      const Text(
                        'Access the Files section to:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBulletPoint(
                        'View all your saved PDFs in one place',
                      ),
                      _buildBulletPoint('Organize and manage your documents'),
                      _buildBulletPoint('Quick access to recently used files'),
                      _buildBulletPoint('Search and sort PDFs easily'),
                      _buildBulletPoint('Delete or share documents'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Key Features Section
                  _buildSection(
                    title: '⚡ Key Features',
                    children: [
                      _buildFeatureItem(
                        icon: '🔐',
                        title: 'Secure & Safe',
                        description:
                            'Military-grade AES-256 encryption for protection',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        icon: '⚙️',
                        title: 'Easy to Use',
                        description:
                            'Simple, intuitive interface for all users',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        icon: '🚀',
                        title: 'Fast & Efficient',
                        description: 'Quick conversions and processing',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureItem(
                        icon: '💾',
                        title: 'Local Storage',
                        description: 'All files stored securely on your device',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Tech Stack Section
                  _buildSection(
                    title: '🛠️ Built With',
                    children: [
                      _buildTechItem(
                        'Flutter',
                        'Cross-platform mobile framework',
                      ),
                      const SizedBox(height: 8),
                      _buildTechItem('GetX', 'State management & navigation'),
                      const SizedBox(height: 8),
                      _buildTechItem(
                        'Syncfusion PDF',
                        'Advanced PDF manipulation',
                      ),
                      const SizedBox(height: 8),
                      _buildTechItem(
                        'File Picker',
                        'File selection & management',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // How to Use Section
                  _buildSection(
                    title: '📚 How to Use',
                    children: [
                      _buildStepItem(
                        '1',
                        'Home Screen',
                        'Access all PDF tools from the home screen',
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        '2',
                        'Choose Tool',
                        'Select the conversion or editing tool you need',
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        '3',
                        'Pick File',
                        'Select your file from device storage',
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        '4',
                        'Process',
                        'Configure settings (password, etc) if needed',
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        '5',
                        'Save',
                        'File is saved to app storage automatically',
                      ),
                      const SizedBox(height: 12),
                      _buildStepItem(
                        '6',
                        'Files Section',
                        'Access your files anytime from Files tab',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Contact Section
                  _buildSection(
                    title: '📧 Contact & Support',
                    children: [
                      Row(
                        children: [
                          _buildContactButton(
                            icon: Icons.mail_outline,
                            label: 'Email',
                            onTap: () =>
                                _launchUrl('mailto:support@example.com'),
                          ),
                          const SizedBox(width: 12),
                          _buildContactButton(
                            icon: Icons.public,
                            label: 'Website',
                            onTap: () => _launchUrl('https://example.com'),
                          ),
                          const SizedBox(width: 12),
                          _buildContactButton(
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
                    title: '⚖️ Legal',
                    children: [
                      GestureDetector(
                        onTap: () => _showDialog(
                          'Privacy Policy',
                          'Your privacy is important to us.\n\n• We do not collect any personal data\n• All files are processed locally on your device\n• No files are uploaded to any server\n• Your documents remain private and secure',
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _showDialog(
                          'Terms & Conditions',
                          'By using this app, you agree to:\n\n• Use the app for lawful purposes only\n• Not use it to violate any copyrights\n• Not use it to protect documents you don\'t own\n\nThe developers are not responsible for misuse of this application. Use responsibly.',
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
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
                        const Text(
                          '© 2024 PDF Reader',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Made with ❤️ using Flutter',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Thank you for using PDF Reader!',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
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
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildFeatureItem({
    required String icon,
    required String title,
    required String description,
  }) {
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 10),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
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
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechItem(String name, String description) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: Colors.blue,
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
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blue,
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

  void _showDialog(String title, String content) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }
}

import 'package:file_reader/features/converter/model/tool_type.dart';
import 'package:file_reader/features/converter/view/selected_tool.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestWidget({
    required Size screenSize,
    required double keyboardHeight,
    required ToolType toolType,
  }) {
    return GetMaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: screenSize,
          viewInsets: EdgeInsets.only(bottom: keyboardHeight),
        ),
        child: SelectedTool(
          toolType: toolType,
          icon: Icons.lock_outline,
          bgColor: const Color(0xFF5B5CFF),
        ),
      ),
    );
  }

  group('Protect PDF & SelectedTool Keyboard Overflow Tests', () {
    testWidgets('SelectedTool for Protect PDF does not overflow when keyboard is open',
        (WidgetTester tester) async {
      // Set a smaller screen height (640x360) and simulate a 300px keyboard opening
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(
          screenSize: const Size(360, 640),
          keyboardHeight: 300.0,
          toolType: ToolType.protectPdf,
        ),
      );
      await tester.pumpAndSettle();

      // Verify no RenderFlex overflow exception was thrown
      expect(tester.takeException(), isNull);

      // Verify Lock PDF title and action button are present
      expect(find.text('Lock PDF'), findsWidgets);
      expect(find.text('Select PDF to Lock'), findsOneWidget);
    });

    testWidgets('Password prompt dialog renders properly without overflow with keyboard viewInsets',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final passwordController = TextEditingController();
      final obscureText = true.obs;

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: const Text('Lock PDF with Password'),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Enter a password to encrypt and lock this PDF:'),
                              const SizedBox(height: 14),
                              TextField(
                                controller: passwordController,
                                autofocus: true,
                                obscureText: obscureText.value,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Lock'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Open Dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Simulate keyboard open by changing MediaQuery
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      addTearDown(tester.view.resetViewInsets);

      await tester.pumpAndSettle();

      // Ensure no overflow
      expect(tester.takeException(), isNull);
      expect(find.text('Lock PDF with Password'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Enter password
      await tester.enterText(find.byType(TextField), 'MySecurePass123');
      await tester.pumpAndSettle();

      expect(passwordController.text, 'MySecurePass123');
    });
  });
}

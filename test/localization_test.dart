import 'package:file_reader/features/language_selection/controller/language_controller.dart';
import 'package:file_reader/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Localization Tests', () {
    const expectedLocales = [
      'en',
      'ur',
      'es',
      'fr',
      'de',
      'it',
      'pt',
      'ar',
      'zh',
      'ja',
      'ko',
    ];

    test('All expected locales are in AppLocalizations.supportedLocales', () {
      final supportedCodes =
          AppLocalizations.supportedLocales
              .map((loc) => loc.languageCode)
              .toList();

      for (final code in expectedLocales) {
        expect(
          supportedCodes.contains(code),
          isTrue,
          reason: 'Locale $code should be in supportedLocales',
        );
      }
    });

    test(
      'lookupAppLocalizations resolves properly and has valid non-empty strings for all locales',
      () {
        for (final code in expectedLocales) {
          final locale = Locale(code);
          final localizations = lookupAppLocalizations(locale);

          expect(localizations, isNotNull);
          expect(localizations.splashAppName.isNotEmpty, isTrue);
          expect(localizations.splashAppTitle.isNotEmpty, isTrue);
          expect(localizations.onBoardingTitle1.isNotEmpty, isTrue);
          expect(localizations.onBoardingSubtitle1.isNotEmpty, isTrue);
          expect(localizations.onBoardingNext.isNotEmpty, isTrue);
          expect(localizations.onBoardingDone.isNotEmpty, isTrue);
          expect(localizations.convertToPdf.isNotEmpty, isTrue);
          expect(localizations.wordToPdf.isNotEmpty, isTrue);
          expect(localizations.mergePdf.isNotEmpty, isTrue);
          expect(localizations.home.isNotEmpty, isTrue);
          expect(localizations.files.isNotEmpty, isTrue);
          expect(localizations.settings.isNotEmpty, isTrue);
          expect(localizations.selectLanguage.isNotEmpty, isTrue);
          expect(localizations.preferredLangauge.isNotEmpty, isTrue);
          expect(
            localizations.convertTool('Test').isNotEmpty,
            isTrue,
          );
        }
      },
    );

    test('LanguageController defines all 11 languages', () {
      final controller = LanguageController();
      expect(controller.languages.length, equals(11));

      final controllerCodes = controller.languages.map((l) => l.code).toList();
      for (final code in expectedLocales) {
        expect(
          controllerCodes.contains(code),
          isTrue,
          reason: 'LanguageController should include $code',
        );
      }
    });
  });
}

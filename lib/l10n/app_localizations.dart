import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @splashAppName.
  ///
  /// In en, this message translates to:
  /// **'PDF Reader'**
  String get splashAppName;

  /// No description provided for @splashAppTitle.
  ///
  /// In en, this message translates to:
  /// **'All your documents, one tap away'**
  String get splashAppTitle;

  /// No description provided for @onBoardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Read PDF Files Instantly'**
  String get onBoardingTitle1;

  /// No description provided for @onBoardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Open, view, and manage all your PDF documents with a smooth and fast reading experience.'**
  String get onBoardingSubtitle1;

  /// No description provided for @onBoardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Access Word Documents'**
  String get onBoardingTitle2;

  /// No description provided for @onBoardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'View DOC and DOCX files anytime, keeping your important documents organized in one place.'**
  String get onBoardingSubtitle2;

  /// No description provided for @onBoardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Presentations Made Simple'**
  String get onBoardingTitle3;

  /// No description provided for @onBoardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Open and browse PPT and PPTX slides effortlessly for work, study, and presentations.'**
  String get onBoardingSubtitle3;

  /// No description provided for @onBoardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onBoardingNext;

  /// No description provided for @onBoardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onBoardingSkip;

  /// No description provided for @onBoardingDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get onBoardingDone;

  /// No description provided for @upgradeVip.
  ///
  /// In en, this message translates to:
  /// **'Upgrade VIP'**
  String get upgradeVip;

  /// No description provided for @bannerTitle.
  ///
  /// In en, this message translates to:
  /// **'All-in-one\nPDF Workspace'**
  String get bannerTitle;

  /// No description provided for @bannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert, edit, organize\nand secure your documents.'**
  String get bannerSubtitle;

  /// No description provided for @tryNow.
  ///
  /// In en, this message translates to:
  /// **'Try now'**
  String get tryNow;

  /// No description provided for @convertToPdf.
  ///
  /// In en, this message translates to:
  /// **'Convert to PDF'**
  String get convertToPdf;

  /// No description provided for @editAndOrganize.
  ///
  /// In en, this message translates to:
  /// **'Edit & Organize'**
  String get editAndOrganize;

  /// No description provided for @wordToPdf.
  ///
  /// In en, this message translates to:
  /// **'Word to PDF'**
  String get wordToPdf;

  /// No description provided for @imageToPdf.
  ///
  /// In en, this message translates to:
  /// **'Image to PDF'**
  String get imageToPdf;

  /// No description provided for @pptToPdf.
  ///
  /// In en, this message translates to:
  /// **'PPT to PDF'**
  String get pptToPdf;

  /// No description provided for @excelToPdf.
  ///
  /// In en, this message translates to:
  /// **'Excel to PDF'**
  String get excelToPdf;

  /// No description provided for @pdfToWord.
  ///
  /// In en, this message translates to:
  /// **'PDF to Word'**
  String get pdfToWord;

  /// No description provided for @pdfToImage.
  ///
  /// In en, this message translates to:
  /// **'PDF to Image'**
  String get pdfToImage;

  /// No description provided for @pdfToPpt.
  ///
  /// In en, this message translates to:
  /// **'PDF to PPT'**
  String get pdfToPpt;

  /// No description provided for @pdfToExcel.
  ///
  /// In en, this message translates to:
  /// **'PDF to Excel'**
  String get pdfToExcel;

  /// No description provided for @mergePdf.
  ///
  /// In en, this message translates to:
  /// **'Merge PDF'**
  String get mergePdf;

  /// No description provided for @splitPdf.
  ///
  /// In en, this message translates to:
  /// **'Split PDF'**
  String get splitPdf;

  /// No description provided for @compressPdf.
  ///
  /// In en, this message translates to:
  /// **'Compress PDF'**
  String get compressPdf;

  /// No description provided for @protectPdf.
  ///
  /// In en, this message translates to:
  /// **'Protect PDF'**
  String get protectPdf;

  /// No description provided for @signOnPdf.
  ///
  /// In en, this message translates to:
  /// **'Sign on PDF'**
  String get signOnPdf;

  /// No description provided for @ocrPdf.
  ///
  /// In en, this message translates to:
  /// **'OCR PDF'**
  String get ocrPdf;

  /// No description provided for @organizePdf.
  ///
  /// In en, this message translates to:
  /// **'Organize PDF'**
  String get organizePdf;

  /// No description provided for @wordToPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert your Word documents (.doc, .docx) to high-quality PDF files.'**
  String get wordToPdfSubtitle;

  /// No description provided for @imageToPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert your images (.jpg, .png, .webp) to high-quality PDF files.'**
  String get imageToPdfSubtitle;

  /// No description provided for @pptToPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert your presentations (.ppt, .pptx) to high-quality PDF files.'**
  String get pptToPdfSubtitle;

  /// No description provided for @excelToPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert your spreadsheets (.xls, .xlsx) to high-quality PDF files.'**
  String get excelToPdfSubtitle;

  /// No description provided for @pdfToWordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert your PDF files to editable Word documents (.docx).'**
  String get pdfToWordSubtitle;

  /// No description provided for @pdfToImageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert your PDF pages to high-quality images (.jpg, .png).'**
  String get pdfToImageSubtitle;

  /// No description provided for @pdfToPptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert your PDF files to editable presentations (.pptx).'**
  String get pdfToPptSubtitle;

  /// No description provided for @pdfToExcelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert your PDF files to editable spreadsheets (.xlsx).'**
  String get pdfToExcelSubtitle;

  /// No description provided for @mergePdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Combine multiple PDF files into a single document.'**
  String get mergePdfSubtitle;

  /// No description provided for @splitPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Split your PDF into separate pages or custom page ranges.'**
  String get splitPdfSubtitle;

  /// No description provided for @compressPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduce the size of your PDF file without losing quality.'**
  String get compressPdfSubtitle;

  /// No description provided for @protectPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypt and password-protect your PDF documents.'**
  String get protectPdfSubtitle;

  /// No description provided for @signOnPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your digital signature to any PDF document.'**
  String get signOnPdfSubtitle;

  /// No description provided for @ocrPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extract text from scanned PDFs using optical character recognition.'**
  String get ocrPdfSubtitle;

  /// No description provided for @organizePdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reorder, rotate, or delete pages in your PDF document.'**
  String get organizePdfSubtitle;

  /// No description provided for @defaultToolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Convert your file to a high-quality PDF.'**
  String get defaultToolSubtitle;

  /// No description provided for @selectWordFile.
  ///
  /// In en, this message translates to:
  /// **'Select Word File'**
  String get selectWordFile;

  /// No description provided for @selectImageFile.
  ///
  /// In en, this message translates to:
  /// **'Select Image File'**
  String get selectImageFile;

  /// No description provided for @selectPptFile.
  ///
  /// In en, this message translates to:
  /// **'Select PPT File'**
  String get selectPptFile;

  /// No description provided for @selectExcelFile.
  ///
  /// In en, this message translates to:
  /// **'Select Excel File'**
  String get selectExcelFile;

  /// No description provided for @selectPdfFile.
  ///
  /// In en, this message translates to:
  /// **'Select PDF File'**
  String get selectPdfFile;

  /// No description provided for @selectPdfFiles.
  ///
  /// In en, this message translates to:
  /// **'Select PDF Files'**
  String get selectPdfFiles;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// Heading on the tool screen, e.g. 'Convert Word to PDF'
  ///
  /// In en, this message translates to:
  /// **'Convert {toolName}'**
  String convertTool(String toolName);

  /// No description provided for @almostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost Done!'**
  String get almostDone;

  /// No description provided for @finalizingFileMessage.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we finalize your file'**
  String get finalizingFileMessage;

  /// No description provided for @protecting.
  ///
  /// In en, this message translates to:
  /// **'Protecting...'**
  String get protecting;

  /// No description provided for @label1.
  ///
  /// In en, this message translates to:
  /// **'Fast Conversion'**
  String get label1;

  /// No description provided for @label2.
  ///
  /// In en, this message translates to:
  /// **'Keep Original Formatting'**
  String get label2;

  /// No description provided for @label3.
  ///
  /// In en, this message translates to:
  /// **'Secure & Private'**
  String get label3;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @files.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get files;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'No File Found'**
  String get file;

  /// No description provided for @upgradeProTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get upgradeProTitle;

  /// No description provided for @upgradeProSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features and enjoy unlimited access.'**
  String get upgradeProSubtitle;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @languageOptions.
  ///
  /// In en, this message translates to:
  /// **'Language Options'**
  String get languageOptions;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @rateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get rateUs;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @settingsPremiumTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get settingsPremiumTitle;

  /// No description provided for @settingsPremiumSutitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock all features and\nenjoy unlimited access.'**
  String get settingsPremiumSutitle;

  /// No description provided for @settingsUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get settingsUpgrade;

  /// No description provided for @settingsLabel1.
  ///
  /// In en, this message translates to:
  /// **'Language options'**
  String get settingsLabel1;

  /// No description provided for @settingsLabel2.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsLabel2;

  /// No description provided for @settingsLabel3.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settingsLabel3;

  /// No description provided for @settingsLabel4.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get settingsLabel4;

  /// No description provided for @settingsLabel5.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsLabel5;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get settingsLogout;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @preferredLangauge.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language to continue'**
  String get preferredLangauge;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

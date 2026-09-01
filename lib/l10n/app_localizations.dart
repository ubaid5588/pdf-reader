import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ur'),
    Locale('zh'),
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

  /// No description provided for @languageSelection.
  ///
  /// In en, this message translates to:
  /// **'continue'**
  String get languageSelection;

  /// No description provided for @onBoardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'All Your PDFs in One Place'**
  String get onBoardingTitle1;

  /// No description provided for @onBoardingSubtitle1.
  ///
  /// In en, this message translates to:
  /// **'Read, access, and manage your documents quickly and effortlessly.'**
  String get onBoardingSubtitle1;

  /// No description provided for @onBoardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Convert Files to PDF'**
  String get onBoardingTitle2;

  /// No description provided for @onBoardingSubtitle2.
  ///
  /// In en, this message translates to:
  /// **'Turn your documents and images into professional PDFs in just a few taps.'**
  String get onBoardingSubtitle2;

  /// No description provided for @onBoardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Powerful PDF Tools'**
  String get onBoardingTitle3;

  /// No description provided for @onBoardingSubtitle3.
  ///
  /// In en, this message translates to:
  /// **'Merge, split, compress, and lock your PDFs with simple and powerful tools.'**
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
  /// **'Lock PDF'**
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
  /// **'Convert your spreadsheets (.xlsx) to high-quality PDF files.'**
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
  /// **'Encrypt and lock your PDF documents with a password.'**
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

  /// No description provided for @createPdf.
  ///
  /// In en, this message translates to:
  /// **'Create PDF'**
  String get createPdf;

  /// No description provided for @createPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and design a new PDF document from scratch.'**
  String get createPdfSubtitle;

  /// No description provided for @editPdf.
  ///
  /// In en, this message translates to:
  /// **'Edit PDF'**
  String get editPdf;

  /// No description provided for @editPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit text, annotate, and customize your PDF documents.'**
  String get editPdfSubtitle;

  /// No description provided for @unlockPdf.
  ///
  /// In en, this message translates to:
  /// **'Unlock PDF'**
  String get unlockPdf;

  /// No description provided for @unlockPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove password protection from encrypted PDF files.'**
  String get unlockPdfSubtitle;

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

  /// No description provided for @selectPdfToEdit.
  ///
  /// In en, this message translates to:
  /// **'Select PDF to Edit'**
  String get selectPdfToEdit;

  /// No description provided for @selectPdfToUnlock.
  ///
  /// In en, this message translates to:
  /// **'Select PDF to Unlock'**
  String get selectPdfToUnlock;

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
  /// **'Locking...'**
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

  /// No description provided for @editOrganizeLabel1.
  ///
  /// In en, this message translates to:
  /// **'Edit text, annotate & customize pages'**
  String get editOrganizeLabel1;

  /// No description provided for @editOrganizeLabel2.
  ///
  /// In en, this message translates to:
  /// **'Organize, split, merge & remove pages'**
  String get editOrganizeLabel2;

  /// No description provided for @editOrganizeLabel3.
  ///
  /// In en, this message translates to:
  /// **'100% secure, offline & lossless quality'**
  String get editOrganizeLabel3;

  /// No description provided for @selectPdfToSplit.
  ///
  /// In en, this message translates to:
  /// **'Select PDF to Split'**
  String get selectPdfToSplit;

  /// No description provided for @selectPdfToProtect.
  ///
  /// In en, this message translates to:
  /// **'Select PDF to Lock'**
  String get selectPdfToProtect;

  /// No description provided for @selectPdfToCompress.
  ///
  /// In en, this message translates to:
  /// **'Select PDF to Compress'**
  String get selectPdfToCompress;

  /// No description provided for @editText.
  ///
  /// In en, this message translates to:
  /// **'Edit Text'**
  String get editText;

  /// No description provided for @selectTextToEdit.
  ///
  /// In en, this message translates to:
  /// **'Select text to edit'**
  String get selectTextToEdit;

  /// No description provided for @tapTextToEdit.
  ///
  /// In en, this message translates to:
  /// **'Tap any text on the page to edit it'**
  String get tapTextToEdit;

  /// No description provided for @originalText.
  ///
  /// In en, this message translates to:
  /// **'Original Text'**
  String get originalText;

  /// No description provided for @modifiedText.
  ///
  /// In en, this message translates to:
  /// **'Modified Text'**
  String get modifiedText;

  /// No description provided for @deleteText.
  ///
  /// In en, this message translates to:
  /// **'Delete Text'**
  String get deleteText;

  /// No description provided for @detectedTextOnPage.
  ///
  /// In en, this message translates to:
  /// **'Text on this page'**
  String get detectedTextOnPage;

  /// No description provided for @noTextDetectedOnPage.
  ///
  /// In en, this message translates to:
  /// **'No selectable text detected on this page. You can use \'Add Text\' to add new text or whiteout.'**
  String get noTextDetectedOnPage;

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

  /// No description provided for @removePages.
  ///
  /// In en, this message translates to:
  /// **'Remove Pages'**
  String get removePages;

  /// No description provided for @removePagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Delete unwanted pages from PDF document'**
  String get removePagesSubtitle;

  /// No description provided for @selectPdfToRemovePages.
  ///
  /// In en, this message translates to:
  /// **'Select PDF to Remove Pages'**
  String get selectPdfToRemovePages;

  /// No description provided for @conversionComplete.
  ///
  /// In en, this message translates to:
  /// **'Conversion Complete!'**
  String get conversionComplete;

  /// No description provided for @yourPdfIsReady.
  ///
  /// In en, this message translates to:
  /// **'Your PDF is ready'**
  String get yourPdfIsReady;

  /// No description provided for @pdfReady.
  ///
  /// In en, this message translates to:
  /// **'PDF Ready'**
  String get pdfReady;

  /// No description provided for @pdfReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your PDF is ready to edit and organize.'**
  String get pdfReadySubtitle;

  /// No description provided for @preparingPdf.
  ///
  /// In en, this message translates to:
  /// **'Preparing PDF'**
  String get preparingPdf;

  /// No description provided for @preparingPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Getting your PDF ready for editing and organizing.'**
  String get preparingPdfSubtitle;

  /// No description provided for @convertingToPdf.
  ///
  /// In en, this message translates to:
  /// **'Converting to PDF'**
  String get convertingToPdf;

  /// No description provided for @convertingToPdfSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your file is being converted to PDF.'**
  String get convertingToPdfSubtitle;

  /// No description provided for @openPdf.
  ///
  /// In en, this message translates to:
  /// **'Open PDF'**
  String get openPdf;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @conversionFailed.
  ///
  /// In en, this message translates to:
  /// **'Conversion Failed'**
  String get conversionFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing...'**
  String get preparing;

  /// No description provided for @converting.
  ///
  /// In en, this message translates to:
  /// **'Converting...'**
  String get converting;

  /// No description provided for @keepAppOpen.
  ///
  /// In en, this message translates to:
  /// **'Please keep the app open while processing'**
  String get keepAppOpen;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @unsupportedXlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unsupported file format'**
  String get unsupportedXlsTitle;

  /// No description provided for @unsupportedXlsMessage.
  ///
  /// In en, this message translates to:
  /// **'Excel .xls files are not supported. Please select an .xlsx file.'**
  String get unsupportedXlsMessage;

  /// No description provided for @pdfCantBeEditedTitle.
  ///
  /// In en, this message translates to:
  /// **'This PDF can\'t be edited'**
  String get pdfCantBeEditedTitle;

  /// No description provided for @pdfCantBeEditedMessage.
  ///
  /// In en, this message translates to:
  /// **'This file contains image-based or unsupported content that cannot be edited. Please choose an editable PDF.'**
  String get pdfCantBeEditedMessage;

  /// No description provided for @unableToOpenPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to open PDF'**
  String get unableToOpenPdfTitle;

  /// No description provided for @unableToOpenPdfMessage.
  ///
  /// In en, this message translates to:
  /// **'This PDF appears to be invalid or corrupted.'**
  String get unableToOpenPdfMessage;

  /// No description provided for @unableToSavePdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Unable to save PDF'**
  String get unableToSavePdfTitle;

  /// No description provided for @unableToSavePdfMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while saving your changes. Please try again.'**
  String get unableToSavePdfMessage;

  /// No description provided for @savePdf.
  ///
  /// In en, this message translates to:
  /// **'Save PDF'**
  String get savePdf;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'ko',
    'pt',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

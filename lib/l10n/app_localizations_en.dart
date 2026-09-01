// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get splashAppName => 'PDF Reader';

  @override
  String get splashAppTitle => 'All your documents, one tap away';

  @override
  String get languageSelection => 'continue';

  @override
  String get onBoardingTitle1 => 'All Your PDFs in One Place';

  @override
  String get onBoardingSubtitle1 =>
      'Read, access, and manage your documents quickly and effortlessly.';

  @override
  String get onBoardingTitle2 => 'Convert Files to PDF';

  @override
  String get onBoardingSubtitle2 =>
      'Turn your documents and images into professional PDFs in just a few taps.';

  @override
  String get onBoardingTitle3 => 'Powerful PDF Tools';

  @override
  String get onBoardingSubtitle3 =>
      'Merge, split, compress, and lock your PDFs with simple and powerful tools.';

  @override
  String get onBoardingNext => 'Next';

  @override
  String get onBoardingSkip => 'Skip';

  @override
  String get onBoardingDone => 'Done';

  @override
  String get upgradeVip => 'Upgrade VIP';

  @override
  String get bannerTitle => 'All-in-one\nPDF Workspace';

  @override
  String get bannerSubtitle =>
      'Convert, edit, organize\nand secure your documents.';

  @override
  String get tryNow => 'Try now';

  @override
  String get convertToPdf => 'Convert to PDF';

  @override
  String get editAndOrganize => 'Edit & Organize';

  @override
  String get wordToPdf => 'Word to PDF';

  @override
  String get imageToPdf => 'Image to PDF';

  @override
  String get pptToPdf => 'PPT to PDF';

  @override
  String get excelToPdf => 'Excel to PDF';

  @override
  String get pdfToWord => 'PDF to Word';

  @override
  String get pdfToImage => 'PDF to Image';

  @override
  String get pdfToPpt => 'PDF to PPT';

  @override
  String get pdfToExcel => 'PDF to Excel';

  @override
  String get mergePdf => 'Merge PDF';

  @override
  String get splitPdf => 'Split PDF';

  @override
  String get compressPdf => 'Compress PDF';

  @override
  String get protectPdf => 'Lock PDF';

  @override
  String get signOnPdf => 'Sign on PDF';

  @override
  String get ocrPdf => 'OCR PDF';

  @override
  String get organizePdf => 'Organize PDF';

  @override
  String get wordToPdfSubtitle =>
      'Convert your Word documents (.doc, .docx) to high-quality PDF files.';

  @override
  String get imageToPdfSubtitle =>
      'Convert your images (.jpg, .png, .webp) to high-quality PDF files.';

  @override
  String get pptToPdfSubtitle =>
      'Convert your presentations (.ppt, .pptx) to high-quality PDF files.';

  @override
  String get excelToPdfSubtitle =>
      'Convert your spreadsheets (.xlsx) to high-quality PDF files.';

  @override
  String get pdfToWordSubtitle =>
      'Convert your PDF files to editable Word documents (.docx).';

  @override
  String get pdfToImageSubtitle =>
      'Convert your PDF pages to high-quality images (.jpg, .png).';

  @override
  String get pdfToPptSubtitle =>
      'Convert your PDF files to editable presentations (.pptx).';

  @override
  String get pdfToExcelSubtitle =>
      'Convert your PDF files to editable spreadsheets (.xlsx).';

  @override
  String get mergePdfSubtitle =>
      'Combine multiple PDF files into a single document.';

  @override
  String get splitPdfSubtitle =>
      'Split your PDF into separate pages or custom page ranges.';

  @override
  String get compressPdfSubtitle =>
      'Reduce the size of your PDF file without losing quality.';

  @override
  String get protectPdfSubtitle =>
      'Encrypt and lock your PDF documents with a password.';

  @override
  String get signOnPdfSubtitle =>
      'Add your digital signature to any PDF document.';

  @override
  String get ocrPdfSubtitle =>
      'Extract text from scanned PDFs using optical character recognition.';

  @override
  String get organizePdfSubtitle =>
      'Reorder, rotate, or delete pages in your PDF document.';

  @override
  String get createPdf => 'Create PDF';

  @override
  String get createPdfSubtitle =>
      'Create and design a new PDF document from scratch.';

  @override
  String get editPdf => 'Edit PDF';

  @override
  String get editPdfSubtitle =>
      'Edit text, annotate, and customize your PDF documents.';

  @override
  String get unlockPdf => 'Unlock PDF';

  @override
  String get unlockPdfSubtitle =>
      'Remove password protection from encrypted PDF files.';

  @override
  String get defaultToolSubtitle => 'Convert your file to a high-quality PDF.';

  @override
  String get selectWordFile => 'Select Word File';

  @override
  String get selectImageFile => 'Select Image File';

  @override
  String get selectPptFile => 'Select PPT File';

  @override
  String get selectExcelFile => 'Select Excel File';

  @override
  String get selectPdfFile => 'Select PDF File';

  @override
  String get selectPdfFiles => 'Select PDF Files';

  @override
  String get selectPdfToEdit => 'Select PDF to Edit';

  @override
  String get selectPdfToUnlock => 'Select PDF to Unlock';

  @override
  String get selectFile => 'Select File';

  @override
  String convertTool(String toolName) {
    return 'Convert $toolName';
  }

  @override
  String get almostDone => 'Almost Done!';

  @override
  String get finalizingFileMessage => 'Please wait while we finalize your file';

  @override
  String get protecting => 'Locking...';

  @override
  String get label1 => 'Fast Conversion';

  @override
  String get label2 => 'Keep Original Formatting';

  @override
  String get label3 => 'Secure & Private';

  @override
  String get editOrganizeLabel1 => 'Edit text, annotate & customize pages';

  @override
  String get editOrganizeLabel2 => 'Organize, split, merge & remove pages';

  @override
  String get editOrganizeLabel3 => '100% secure, offline & lossless quality';

  @override
  String get selectPdfToSplit => 'Select PDF to Split';

  @override
  String get selectPdfToProtect => 'Select PDF to Lock';

  @override
  String get selectPdfToCompress => 'Select PDF to Compress';

  @override
  String get editText => 'Edit Text';

  @override
  String get selectTextToEdit => 'Select text to edit';

  @override
  String get tapTextToEdit => 'Tap any text on the page to edit it';

  @override
  String get originalText => 'Original Text';

  @override
  String get modifiedText => 'Modified Text';

  @override
  String get deleteText => 'Delete Text';

  @override
  String get detectedTextOnPage => 'Text on this page';

  @override
  String get noTextDetectedOnPage =>
      'No selectable text detected on this page. You can use \'Add Text\' to add new text or whiteout.';

  @override
  String get home => 'Home';

  @override
  String get files => 'Files';

  @override
  String get settings => 'Settings';

  @override
  String get file => 'No File Found';

  @override
  String get upgradeProTitle => 'Upgrade to Pro';

  @override
  String get upgradeProSubtitle =>
      'Unlock all features and enjoy unlimited access.';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get languageOptions => 'Language Options';

  @override
  String get feedback => 'Feedback';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get rateUs => 'Rate Us';

  @override
  String get about => 'About';

  @override
  String get logout => 'Log Out';

  @override
  String get settingsPremiumTitle => 'Upgrade to Pro';

  @override
  String get settingsPremiumSutitle =>
      'Unlock all features and\nenjoy unlimited access.';

  @override
  String get settingsUpgrade => 'Upgrade';

  @override
  String get settingsLabel1 => 'Language options';

  @override
  String get settingsLabel2 => 'Feedback';

  @override
  String get settingsLabel3 => 'Help & Support';

  @override
  String get settingsLabel4 => 'Rate Us';

  @override
  String get settingsLabel5 => 'About';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get preferredLangauge => 'Choose your preferred language to continue';

  @override
  String get removePages => 'Remove Pages';

  @override
  String get removePagesSubtitle => 'Delete unwanted pages from PDF document';

  @override
  String get selectPdfToRemovePages => 'Select PDF to Remove Pages';

  @override
  String get conversionComplete => 'Conversion Complete!';

  @override
  String get yourPdfIsReady => 'Your PDF is ready';

  @override
  String get pdfReady => 'PDF Ready';

  @override
  String get pdfReadySubtitle => 'Your PDF is ready to edit and organize.';

  @override
  String get preparingPdf => 'Preparing PDF';

  @override
  String get preparingPdfSubtitle =>
      'Getting your PDF ready for editing and organizing.';

  @override
  String get convertingToPdf => 'Converting to PDF';

  @override
  String get convertingToPdfSubtitle => 'Your file is being converted to PDF.';

  @override
  String get openPdf => 'Open PDF';

  @override
  String get share => 'Share';

  @override
  String get done => 'Done';

  @override
  String get conversionFailed => 'Conversion Failed';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get preparing => 'Preparing...';

  @override
  String get converting => 'Converting...';

  @override
  String get keepAppOpen => 'Please keep the app open while processing';

  @override
  String get theme => 'Theme';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get unsupportedXlsTitle => 'Unsupported file format';

  @override
  String get unsupportedXlsMessage =>
      'Excel .xls files are not supported. Please select an .xlsx file.';

  @override
  String get pdfCantBeEditedTitle => 'This PDF can\'t be edited';

  @override
  String get pdfCantBeEditedMessage =>
      'This file contains image-based or unsupported content that cannot be edited. Please choose an editable PDF.';

  @override
  String get unableToOpenPdfTitle => 'Unable to open PDF';

  @override
  String get unableToOpenPdfMessage =>
      'This PDF appears to be invalid or corrupted.';

  @override
  String get unableToSavePdfTitle => 'Unable to save PDF';

  @override
  String get unableToSavePdfMessage =>
      'Something went wrong while saving your changes. Please try again.';

  @override
  String get savePdf => 'Save PDF';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get splashAppName => 'PDF-Reader';

  @override
  String get splashAppTitle => 'Alle Ihre Dokumente mit einem Fingertipp';

  @override
  String get languageSelection => 'Weiter';

  @override
  String get onBoardingTitle1 => 'Alle Ihre PDFs an einem Ort';

  @override
  String get onBoardingSubtitle1 =>
      'Lesen, öffnen und verwalten Sie Ihre Dokumente schnell und mühelos.';

  @override
  String get onBoardingTitle2 => 'Dateien in PDF konvertieren';

  @override
  String get onBoardingSubtitle2 =>
      'Verwandeln Sie Ihre Dokumente und Bilder mit wenigen Fingertipps in professionelle PDFs.';

  @override
  String get onBoardingTitle3 => 'Leistungsstarke PDF-Tools';

  @override
  String get onBoardingSubtitle3 =>
      'Fügen Sie Ihre PDFs zusammen, teilen, komprimieren und schützen Sie sie mit einfachen und leistungsstarken Tools.';

  @override
  String get onBoardingNext => 'Weiter';

  @override
  String get onBoardingSkip => 'Überspringen';

  @override
  String get onBoardingDone => 'Fertig';

  @override
  String get upgradeVip => 'Auf VIP upgraden';

  @override
  String get bannerTitle => 'Alles-in-einem\nPDF-Arbeitsbereich';

  @override
  String get bannerSubtitle =>
      'Konvertieren, bearbeiten, organisieren\nund schützen Sie Ihre Dokumente.';

  @override
  String get tryNow => 'Jetzt testen';

  @override
  String get convertToPdf => 'In PDF konvertieren';

  @override
  String get editAndOrganize => 'Bearbeiten & Organisieren';

  @override
  String get wordToPdf => 'Word zu PDF';

  @override
  String get imageToPdf => 'Bild zu PDF';

  @override
  String get pptToPdf => 'PPT zu PDF';

  @override
  String get excelToPdf => 'Excel zu PDF';

  @override
  String get pdfToWord => 'PDF zu Word';

  @override
  String get pdfToImage => 'PDF zu Bild';

  @override
  String get pdfToPpt => 'PDF zu PPT';

  @override
  String get pdfToExcel => 'PDF zu Excel';

  @override
  String get mergePdf => 'PDF zusammenfügen';

  @override
  String get splitPdf => 'PDF teilen';

  @override
  String get compressPdf => 'PDF komprimieren';

  @override
  String get protectPdf => 'PDF schützen';

  @override
  String get signOnPdf => 'Auf PDF unterschreiben';

  @override
  String get ocrPdf => 'OCR PDF';

  @override
  String get organizePdf => 'PDF organisieren';

  @override
  String get wordToPdfSubtitle =>
      'Konvertieren Sie Ihre Word-Dokumente (.doc, .docx) in hochwertige PDF-Dateien.';

  @override
  String get imageToPdfSubtitle =>
      'Konvertieren Sie Ihre Bilder (.jpg, .png, .webp) in hochwertige PDF-Dateien.';

  @override
  String get pptToPdfSubtitle =>
      'Konvertieren Sie Ihre Präsentationen (.ppt, .pptx) in hochwertige PDF-Dateien.';

  @override
  String get excelToPdfSubtitle =>
      'Konvertieren Sie Ihre Tabellen (.xlsx) in hochwertige PDF-Dateien.';

  @override
  String get pdfToWordSubtitle =>
      'Konvertieren Sie Ihre PDF-Dateien in bearbeitbare Word-Dokumente (.docx).';

  @override
  String get pdfToImageSubtitle =>
      'Konvertieren Sie Ihre PDF-Seiten in hochwertige Bilder (.jpg, .png).';

  @override
  String get pdfToPptSubtitle =>
      'Konvertieren Sie Ihre PDF-Dateien in bearbeitbare Präsentationen (.pptx).';

  @override
  String get pdfToExcelSubtitle =>
      'Konvertieren Sie Ihre PDF-Dateien in bearbeitbare Tabellen (.xlsx).';

  @override
  String get mergePdfSubtitle =>
      'Kombinieren Sie mehrere PDF-Dateien zu einem einzigen Dokument.';

  @override
  String get splitPdfSubtitle =>
      'Teilen Sie Ihr PDF in einzelne Seiten oder benutzerdefinierte Seitenbereiche.';

  @override
  String get compressPdfSubtitle =>
      'Reduzieren Sie die Dateigröße Ihres PDFs ohne Qualitätsverlust.';

  @override
  String get protectPdfSubtitle =>
      'Verschlüsseln und schützen Sie Ihre PDF-Dokumente mit einem Passwort.';

  @override
  String get signOnPdfSubtitle =>
      'Fügen Sie Ihre digitale Unterschrift zu jedem PDF-Dokument hinzu.';

  @override
  String get ocrPdfSubtitle =>
      'Extrahieren Sie Text aus gescannten PDFs mithilfe optischer Zeichenerkennung.';

  @override
  String get organizePdfSubtitle =>
      'Seiten in Ihrem PDF-Dokument neu anordnen, drehen oder löschen.';

  @override
  String get createPdf => 'Create PDF';

  @override
  String get createPdfSubtitle =>
      'Create and design a new PDF document from scratch.';

  @override
  String get editPdf => 'PDF bearbeiten';

  @override
  String get editPdfSubtitle =>
      'Bearbeiten Sie Text, fügen Sie Anmerkungen hinzu und passen Sie Ihre PDF-Dokumente an.';

  @override
  String get unlockPdf => 'Unlock PDF';

  @override
  String get unlockPdfSubtitle =>
      'Remove password protection from encrypted PDF files.';

  @override
  String get defaultToolSubtitle =>
      'Konvertieren Sie Ihre Datei in ein hochwertiges PDF.';

  @override
  String get selectWordFile => 'Word-Datei auswählen';

  @override
  String get selectImageFile => 'Bilddatei auswählen';

  @override
  String get selectPptFile => 'PPT-Datei auswählen';

  @override
  String get selectExcelFile => 'Excel-Datei auswählen';

  @override
  String get selectPdfFile => 'PDF-Datei auswählen';

  @override
  String get selectPdfFiles => 'PDF-Dateien auswählen';

  @override
  String get selectPdfToEdit => 'PDF zum Bearbeiten auswählen';

  @override
  String get selectPdfToUnlock => 'Select PDF to Unlock';

  @override
  String get selectFile => 'Datei auswählen';

  @override
  String convertTool(String toolName) {
    return '$toolName konvertieren';
  }

  @override
  String get almostDone => 'Fast fertig!';

  @override
  String get finalizingFileMessage =>
      'Bitte warten Sie, während wir Ihre Datei fertigstellen';

  @override
  String get protecting => 'Schützen...';

  @override
  String get label1 => 'Schnelle Konvertierung';

  @override
  String get label2 => 'Ursprüngliche Formatierung beibehalten';

  @override
  String get label3 => 'Sicher & Privat';

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
  String get home => 'Startseite';

  @override
  String get files => 'Dateien';

  @override
  String get settings => 'Einstellungen';

  @override
  String get file => 'Keine Datei gefunden';

  @override
  String get upgradeProTitle => 'Auf Pro upgraden';

  @override
  String get upgradeProSubtitle =>
      'Schalten Sie alle Funktionen frei und genießen Sie unbegrenzten Zugriff.';

  @override
  String get upgrade => 'Upgraden';

  @override
  String get languageOptions => 'Sprachoptionen';

  @override
  String get feedback => 'Feedback';

  @override
  String get helpSupport => 'Hilfe & Support';

  @override
  String get rateUs => 'Bewerten Sie uns';

  @override
  String get about => 'Über uns';

  @override
  String get logout => 'Abmelden';

  @override
  String get settingsPremiumTitle => 'Auf Pro upgraden';

  @override
  String get settingsPremiumSutitle =>
      'Schalten Sie alle Funktionen frei und\ngenießen Sie unbegrenzten Zugriff.';

  @override
  String get settingsUpgrade => 'Upgraden';

  @override
  String get settingsLabel1 => 'Sprachoptionen';

  @override
  String get settingsLabel2 => 'Feedback';

  @override
  String get settingsLabel3 => 'Hilfe & Support';

  @override
  String get settingsLabel4 => 'Bewerten Sie uns';

  @override
  String get settingsLabel5 => 'Über uns';

  @override
  String get settingsLogout => 'Abmelden';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get preferredLangauge =>
      'Wählen Sie Ihre bevorzugte Sprache, um fortzufahren';

  @override
  String get removePages => 'Remove Pages';

  @override
  String get removePagesSubtitle => 'Delete unwanted pages from PDF document';

  @override
  String get selectPdfToRemovePages => 'Select PDF to Remove Pages';

  @override
  String get conversionComplete => 'Konvertierung abgeschlossen!';

  @override
  String get yourPdfIsReady => 'Ihr PDF ist fertig';

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
  String get openPdf => 'PDF öffnen';

  @override
  String get share => 'Teilen';

  @override
  String get done => 'Fertig';

  @override
  String get conversionFailed => 'Konvertierung fehlgeschlagen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get preparing => 'Vorbereitung...';

  @override
  String get converting => 'Wird konvertiert...';

  @override
  String get keepAppOpen =>
      'Bitte lassen Sie die App während der Verarbeitung geöffnet';

  @override
  String get theme => 'Design';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Hell';

  @override
  String get darkTheme => 'Dunkel';

  @override
  String get chooseTheme => 'Design auswählen';

  @override
  String get unsupportedXlsTitle => 'Nicht unterstütztes Dateiformat';

  @override
  String get unsupportedXlsMessage =>
      'Excel .xls-Dateien werden nicht unterstützt. Bitte wählen Sie eine .xlsx-Datei aus.';

  @override
  String get pdfCantBeEditedTitle => 'Dieses PDF kann nicht bearbeitet werden';

  @override
  String get pdfCantBeEditedMessage =>
      'Diese Datei enthält bildbasierte oder nicht unterstützte Inhalte, die nicht bearbeitet werden können. Bitte wählen Sie ein bearbeitbares PDF.';

  @override
  String get unableToOpenPdfTitle => 'PDF kann nicht geöffnet werden';

  @override
  String get unableToOpenPdfMessage =>
      'Dieses PDF scheint ungültig oder beschädigt zu sein.';

  @override
  String get unableToSavePdfTitle => 'PDF kann nicht gespeichert werden';

  @override
  String get unableToSavePdfMessage =>
      'Beim Speichern Ihrer Änderungen ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut.';

  @override
  String get savePdf => 'PDF speichern';
}

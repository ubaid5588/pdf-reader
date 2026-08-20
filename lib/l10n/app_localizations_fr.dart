// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get splashAppName => 'Lecteur PDF';

  @override
  String get splashAppTitle => 'Tous vos documents, à portée de main';

  @override
  String get languageSelection => 'Continuer';

  @override
  String get onBoardingTitle1 => 'Tous vos PDF en un seul endroit';

  @override
  String get onBoardingSubtitle1 =>
      'Lisez, consultez et gérez vos documents rapidement et sans effort.';

  @override
  String get onBoardingTitle2 => 'Convertissez des fichiers en PDF';

  @override
  String get onBoardingSubtitle2 =>
      'Transformez vos documents et images en PDF professionnels en quelques clics.';

  @override
  String get onBoardingTitle3 => 'Outils PDF puissants';

  @override
  String get onBoardingSubtitle3 =>
      'Fusionnez, divisez, compressez et protégez vos PDF avec des outils simples et performants.';

  @override
  String get onBoardingNext => 'Suivant';

  @override
  String get onBoardingSkip => 'Passer';

  @override
  String get onBoardingDone => 'Terminé';

  @override
  String get upgradeVip => 'Passer à VIP';

  @override
  String get bannerTitle => 'Espace de travail\nPDF tout-en-un';

  @override
  String get bannerSubtitle =>
      'Convertissez, modifiez, organisez\net sécurisez vos documents.';

  @override
  String get tryNow => 'Essayer';

  @override
  String get convertToPdf => 'Convertir en PDF';

  @override
  String get editAndOrganize => 'Modifier & Organiser';

  @override
  String get wordToPdf => 'Word en PDF';

  @override
  String get imageToPdf => 'Image en PDF';

  @override
  String get pptToPdf => 'PPT en PDF';

  @override
  String get excelToPdf => 'Excel en PDF';

  @override
  String get pdfToWord => 'PDF en Word';

  @override
  String get pdfToImage => 'PDF en Image';

  @override
  String get pdfToPpt => 'PDF en PPT';

  @override
  String get pdfToExcel => 'PDF en Excel';

  @override
  String get mergePdf => 'Fusionner PDF';

  @override
  String get splitPdf => 'Diviser PDF';

  @override
  String get compressPdf => 'Compresser PDF';

  @override
  String get protectPdf => 'Protéger PDF';

  @override
  String get signOnPdf => 'Signer sur PDF';

  @override
  String get ocrPdf => 'OCR PDF';

  @override
  String get organizePdf => 'Organiser PDF';

  @override
  String get wordToPdfSubtitle =>
      'Convertissez vos documents Word (.doc, .docx) en fichiers PDF de haute qualité.';

  @override
  String get imageToPdfSubtitle =>
      'Convertissez vos images (.jpg, .png, .webp) en fichiers PDF de haute qualité.';

  @override
  String get pptToPdfSubtitle =>
      'Convertissez vos présentations (.ppt, .pptx) en fichiers PDF de haute qualité.';

  @override
  String get excelToPdfSubtitle =>
      'Convertissez vos feuilles de calcul (.xlsx) en fichiers PDF de haute qualité.';

  @override
  String get pdfToWordSubtitle =>
      'Convertissez vos fichiers PDF en documents Word modifiables (.docx).';

  @override
  String get pdfToImageSubtitle =>
      'Convertissez vos pages PDF en images de haute qualité (.jpg, .png).';

  @override
  String get pdfToPptSubtitle =>
      'Convertissez vos fichiers PDF en présentations modifiables (.pptx).';

  @override
  String get pdfToExcelSubtitle =>
      'Convertissez vos fichiers PDF en feuilles de calcul modifiables (.xlsx).';

  @override
  String get mergePdfSubtitle =>
      'Combinez plusieurs fichiers PDF en un seul document.';

  @override
  String get splitPdfSubtitle =>
      'Divisez votre PDF en pages séparées ou selon des plages de pages.';

  @override
  String get compressPdfSubtitle =>
      'Réduisez la taille de votre fichier PDF sans perte de qualité.';

  @override
  String get protectPdfSubtitle =>
      'Chiffrez et protégez vos documents PDF par mot de passe.';

  @override
  String get signOnPdfSubtitle =>
      'Ajoutez votre signature numérique à tout document PDF.';

  @override
  String get ocrPdfSubtitle =>
      'Extrayez le texte des PDF numérisés grâce à la reconnaissance optique de caractères.';

  @override
  String get organizePdfSubtitle =>
      'Réorganisez, faites pivoter ou supprimez des pages dans votre document PDF.';

  @override
  String get editPdf => 'Modifier le PDF';

  @override
  String get editPdfSubtitle =>
      'Modifiez le texte, ajoutez des annotations et personnalisez vos documents PDF.';

  @override
  String get defaultToolSubtitle =>
      'Convertissez votre fichier en un PDF de haute qualité.';

  @override
  String get selectWordFile => 'Sélectionner un fichier Word';

  @override
  String get selectImageFile => 'Sélectionner un fichier image';

  @override
  String get selectPptFile => 'Sélectionner un fichier PPT';

  @override
  String get selectExcelFile => 'Sélectionner un fichier Excel';

  @override
  String get selectPdfFile => 'Sélectionner un fichier PDF';

  @override
  String get selectPdfFiles => 'Sélectionner des fichiers PDF';

  @override
  String get selectPdfToEdit => 'Sélectionner un PDF à modifier';

  @override
  String get selectFile => 'Sélectionner un fichier';

  @override
  String convertTool(String toolName) {
    return 'Convertir $toolName';
  }

  @override
  String get almostDone => 'Presque terminé !';

  @override
  String get finalizingFileMessage =>
      'Veuillez patienter pendant la finalisation de votre fichier';

  @override
  String get protecting => 'Protection en cours...';

  @override
  String get label1 => 'Conversion rapide';

  @override
  String get label2 => 'Conserver la mise en page d\'origine';

  @override
  String get label3 => 'Sécurisé & Privé';

  @override
  String get home => 'Accueil';

  @override
  String get files => 'Fichiers';

  @override
  String get settings => 'Paramètres';

  @override
  String get file => 'Aucun fichier trouvé';

  @override
  String get upgradeProTitle => 'Passer à la version Pro';

  @override
  String get upgradeProSubtitle =>
      'Débloquez toutes les fonctionnalités et profitez d\'un accès illimité.';

  @override
  String get upgrade => 'Mettre à niveau';

  @override
  String get languageOptions => 'Options de langue';

  @override
  String get feedback => 'Commentaires';

  @override
  String get helpSupport => 'Aide & Support';

  @override
  String get rateUs => 'Évaluez-nous';

  @override
  String get about => 'À propos';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get settingsPremiumTitle => 'Passer à la version Pro';

  @override
  String get settingsPremiumSutitle =>
      'Débloquez toutes les fonctionnalités et\nprofitez d\'un accès illimité.';

  @override
  String get settingsUpgrade => 'Mettre à niveau';

  @override
  String get settingsLabel1 => 'Options de langue';

  @override
  String get settingsLabel2 => 'Commentaires';

  @override
  String get settingsLabel3 => 'Aide & Support';

  @override
  String get settingsLabel4 => 'Évaluez-nous';

  @override
  String get settingsLabel5 => 'À propos';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get preferredLangauge =>
      'Choisissez votre langue préférée pour continuer';

  @override
  String get conversionComplete => 'Conversion terminée !';

  @override
  String get yourPdfIsReady => 'Votre PDF est prêt';

  @override
  String get openPdf => 'Ouvrir le PDF';

  @override
  String get share => 'Partager';

  @override
  String get done => 'Terminé';

  @override
  String get conversionFailed => 'Échec de la conversion';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String get preparing => 'Préparation...';

  @override
  String get converting => 'Conversion en cours...';

  @override
  String get keepAppOpen =>
      'Veuillez garder l\'application ouverte pendant le traitement';

  @override
  String get theme => 'Thème';

  @override
  String get systemTheme => 'Système';

  @override
  String get lightTheme => 'Clair';

  @override
  String get darkTheme => 'Sombre';

  @override
  String get chooseTheme => 'Choisir le thème';

  @override
  String get unsupportedXlsTitle => 'Format de fichier non pris en charge';

  @override
  String get unsupportedXlsMessage =>
      'Les fichiers Excel .xls ne sont pas pris en charge. Veuillez sélectionner un fichier .xlsx.';

  @override
  String get pdfCantBeEditedTitle => 'Ce PDF ne peut pas être modifié';

  @override
  String get pdfCantBeEditedMessage =>
      'Ce fichier contient des images ou du contenu non pris en charge qui ne peut pas être modifié. Veuillez choisir un PDF modifiable.';

  @override
  String get unableToOpenPdfTitle => 'Impossible d\'ouvrir le PDF';

  @override
  String get unableToOpenPdfMessage =>
      'Ce fichier PDF semble invalide ou corrompu.';

  @override
  String get unableToSavePdfTitle => 'Impossible d\'enregistrer le PDF';

  @override
  String get unableToSavePdfMessage =>
      'Une erreur s\'est produite lors de l\'enregistrement de vos modifications. Veuillez réessayer.';

  @override
  String get savePdf => 'Enregistrer le PDF';
}

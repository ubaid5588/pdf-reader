// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get splashAppName => 'PDFリーダー';

  @override
  String get splashAppTitle => 'すべての書類をワンタップで';

  @override
  String get languageSelection => 'continue';

  @override
  String get onBoardingTitle1 => 'PDFファイルを素早く閲覧';

  @override
  String get onBoardingSubtitle1 => 'スムーズで快適な読書体験で、すべてのPDFドキュメントを開き、閲覧し、管理します。';

  @override
  String get onBoardingTitle2 => 'Word文書にアクセス';

  @override
  String get onBoardingSubtitle2 =>
      'DOCおよびDOCXファイルをいつでも表示し、重要な書類を一箇所にまとめて整理します。';

  @override
  String get onBoardingTitle3 => 'プレゼンテーションをシンプルに';

  @override
  String get onBoardingSubtitle3 => '仕事や学習、発表のためにPPTおよびPPTXスライドを簡単に開いて閲覧できます。';

  @override
  String get onBoardingNext => '次へ';

  @override
  String get onBoardingSkip => 'スキップ';

  @override
  String get onBoardingDone => '完了';

  @override
  String get upgradeVip => 'VIPにアップグレード';

  @override
  String get bannerTitle => 'オールインワン\nPDFワークスペース';

  @override
  String get bannerSubtitle => 'ドキュメントの変換、編集、整理、\n保護をこれひとつで。';

  @override
  String get tryNow => '今すぐ試す';

  @override
  String get convertToPdf => 'PDFに変換';

  @override
  String get editAndOrganize => '編集と整理';

  @override
  String get wordToPdf => 'WordからPDF';

  @override
  String get imageToPdf => '画像からPDF';

  @override
  String get pptToPdf => 'PPTからPDF';

  @override
  String get excelToPdf => 'ExcelからPDF';

  @override
  String get pdfToWord => 'PDFからWord';

  @override
  String get pdfToImage => 'PDFから画像';

  @override
  String get pdfToPpt => 'PDFからPPT';

  @override
  String get pdfToExcel => 'PDFからExcel';

  @override
  String get mergePdf => 'PDF結合';

  @override
  String get splitPdf => 'PDF分割';

  @override
  String get compressPdf => 'PDF圧縮';

  @override
  String get protectPdf => 'PDF保護';

  @override
  String get signOnPdf => 'PDFに署名';

  @override
  String get ocrPdf => 'OCR PDF';

  @override
  String get organizePdf => 'PDF整理';

  @override
  String get wordToPdfSubtitle => 'Word文書（.doc, .docx）を高画質なPDFファイルに変換します。';

  @override
  String get imageToPdfSubtitle => '画像（.jpg, .png, .webp）を高画質なPDFファイルに変換します。';

  @override
  String get pptToPdfSubtitle => 'プレゼンテーション（.ppt, .pptx）を高画質なPDFファイルに変換します。';

  @override
  String get excelToPdfSubtitle => 'スプレッドシート（.xls, .xlsx）を高画質なPDFファイルに変換します。';

  @override
  String get pdfToWordSubtitle => 'PDFファイルを編集可能なWord文書（.docx）に変換します。';

  @override
  String get pdfToImageSubtitle => 'PDFページを高画質画像（.jpg, .png）に変換します。';

  @override
  String get pdfToPptSubtitle => 'PDFファイルを編集可能なプレゼンテーション（.pptx）に変換します。';

  @override
  String get pdfToExcelSubtitle => 'PDFファイルを編集可能なスプレッドシート（.xlsx）に変換します。';

  @override
  String get mergePdfSubtitle => '複数のPDFファイルを1つのドキュメントに結合します。';

  @override
  String get splitPdfSubtitle => 'PDFを個別のページまたは指定したページ範囲に分割します。';

  @override
  String get compressPdfSubtitle => '品質を保ちながらPDFのファイルサイズを縮小します。';

  @override
  String get protectPdfSubtitle => 'PDFドキュメントを暗号化し、パスワードで保護します。';

  @override
  String get signOnPdfSubtitle => '任意のPDFドキュメントにデジタル署名を追加します。';

  @override
  String get ocrPdfSubtitle => '光学文字認識（OCR）を使用して、スキャンしたPDFからテキストを抽出します。';

  @override
  String get organizePdfSubtitle => 'PDFドキュメントのページの並べ替え、回転、削除を行います。';

  @override
  String get defaultToolSubtitle => 'ファイルを高品質なPDFに変換します。';

  @override
  String get selectWordFile => 'Wordファイルを選択';

  @override
  String get selectImageFile => '画像ファイルを選択';

  @override
  String get selectPptFile => 'PPTファイルを選択';

  @override
  String get selectExcelFile => 'Excelファイルを選択';

  @override
  String get selectPdfFile => 'PDFファイルを選択';

  @override
  String get selectPdfFiles => 'PDFファイルを選択';

  @override
  String get selectFile => 'ファイルを選択';

  @override
  String convertTool(String toolName) {
    return '$toolNameを変換';
  }

  @override
  String get almostDone => 'もうすぐ完了します！';

  @override
  String get finalizingFileMessage => 'ファイルを処理しています。少々お待ちください';

  @override
  String get protecting => '保護中...';

  @override
  String get label1 => '高速変換';

  @override
  String get label2 => '元のレイアウトを保持';

  @override
  String get label3 => '安全＆プライベート';

  @override
  String get home => 'ホーム';

  @override
  String get files => 'ファイル';

  @override
  String get settings => '設定';

  @override
  String get file => 'ファイルが見つかりません';

  @override
  String get upgradeProTitle => 'Proにアップグレード';

  @override
  String get upgradeProSubtitle => 'すべての機能のロックを解除し、無制限のアクセスをお楽しみください。';

  @override
  String get upgrade => 'アップグレード';

  @override
  String get languageOptions => '言語オプション';

  @override
  String get feedback => 'フィードバック';

  @override
  String get helpSupport => 'ヘルプ＆サポート';

  @override
  String get rateUs => '評価する';

  @override
  String get about => 'アプリについて';

  @override
  String get logout => 'ログアウト';

  @override
  String get settingsPremiumTitle => 'Proにアップグレード';

  @override
  String get settingsPremiumSutitle => 'すべての機能のロックを解除し、\n無制限のアクセスをお楽しみください。';

  @override
  String get settingsUpgrade => 'アップグレード';

  @override
  String get settingsLabel1 => '言語オプション';

  @override
  String get settingsLabel2 => 'フィードバック';

  @override
  String get settingsLabel3 => 'ヘルプ＆サポート';

  @override
  String get settingsLabel4 => '評価する';

  @override
  String get settingsLabel5 => 'アプリについて';

  @override
  String get settingsLogout => 'ログアウト';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get preferredLangauge => '続けるには希望の言語を選択してください';
}

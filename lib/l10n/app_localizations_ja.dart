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
  String get languageSelection => '続行';

  @override
  String get onBoardingTitle1 => 'すべてのPDFをひとつに';

  @override
  String get onBoardingSubtitle1 => 'ドキュメントを素早く手軽に閲覧、アクセス、管理できます。';

  @override
  String get onBoardingTitle2 => 'ファイルをPDFに変換';

  @override
  String get onBoardingSubtitle2 => '数回タップするだけで、ドキュメントや画像を高品質なPDFに変換します。';

  @override
  String get onBoardingTitle3 => '強力なPDFツール';

  @override
  String get onBoardingSubtitle3 => 'シンプルで強力なツールでPDFを結合、分割、圧縮、保護します。';

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
  String get excelToPdfSubtitle => 'スプレッドシート（.xlsx）を高画質なPDFファイルに変換します。';

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
  String get editPdf => 'PDFを編集';

  @override
  String get editPdfSubtitle => 'テキストの編集、注釈の追加、PDFドキュメントのカスタマイズを行います。';

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
  String get selectPdfToEdit => '編集するPDFを選択';

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

  @override
  String get conversionComplete => '変換が完了しました！';

  @override
  String get yourPdfIsReady => 'PDFの準備ができました';

  @override
  String get openPdf => 'PDFを開く';

  @override
  String get share => '共有';

  @override
  String get done => '完了';

  @override
  String get conversionFailed => '変換に失敗しました';

  @override
  String get retry => '再試行';

  @override
  String get cancel => 'キャンセル';

  @override
  String get preparing => '準備中...';

  @override
  String get converting => '変換中...';

  @override
  String get keepAppOpen => '処理中はアプリを開いたままにしてください';

  @override
  String get theme => 'テーマ';

  @override
  String get systemTheme => 'システム';

  @override
  String get lightTheme => 'ライト';

  @override
  String get darkTheme => 'ダーク';

  @override
  String get chooseTheme => 'テーマを選択';

  @override
  String get unsupportedXlsTitle => '未対応のファイル形式';

  @override
  String get unsupportedXlsMessage =>
      'Excelの.xlsファイルには対応していません。.xlsxファイルを選択してください。';

  @override
  String get pdfCantBeEditedTitle => 'このPDFは編集できません';

  @override
  String get pdfCantBeEditedMessage =>
      'このファイルには編集不可能な画像ベースまたは未対応のコンテンツが含まれています。編集可能なPDFを選択してください。';

  @override
  String get unableToOpenPdfTitle => 'PDFを開けません';

  @override
  String get unableToOpenPdfMessage => 'このPDFは無効であるか破損している可能性があります。';

  @override
  String get unableToSavePdfTitle => 'PDFを保存できません';

  @override
  String get unableToSavePdfMessage => '変更の保存中にエラーが発生しました。もう一度お試しください。';

  @override
  String get savePdf => 'PDFを保存';
}

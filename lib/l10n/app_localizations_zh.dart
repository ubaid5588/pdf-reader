// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get splashAppName => 'PDF 阅读器';

  @override
  String get splashAppTitle => '轻点一下，所有文档尽在掌握';

  @override
  String get languageSelection => '继续';

  @override
  String get onBoardingTitle1 => '所有 PDF 汇聚一处';

  @override
  String get onBoardingSubtitle1 => '快速轻松地阅读、访问和管理您的文档。';

  @override
  String get onBoardingTitle2 => '将文件转换为 PDF';

  @override
  String get onBoardingSubtitle2 => '只需轻点几下，即可将文档和图片转换为专业的 PDF。';

  @override
  String get onBoardingTitle3 => '强大的 PDF 工具';

  @override
  String get onBoardingSubtitle3 => '使用简单而强大的工具合并、拆分、压缩和保护您的 PDF。';

  @override
  String get onBoardingNext => '下一步';

  @override
  String get onBoardingSkip => '跳过';

  @override
  String get onBoardingDone => '完成';

  @override
  String get upgradeVip => '升级 VIP';

  @override
  String get bannerTitle => '多合一\nPDF 工作区';

  @override
  String get bannerSubtitle => '转换、编辑、整理\n并保护您的文档。';

  @override
  String get tryNow => '立即体验';

  @override
  String get convertToPdf => '转换为 PDF';

  @override
  String get editAndOrganize => '编辑与整理';

  @override
  String get wordToPdf => 'Word 转 PDF';

  @override
  String get imageToPdf => '图片转 PDF';

  @override
  String get pptToPdf => 'PPT 转 PDF';

  @override
  String get excelToPdf => 'Excel 转 PDF';

  @override
  String get pdfToWord => 'PDF 转 Word';

  @override
  String get pdfToImage => 'PDF 转图片';

  @override
  String get pdfToPpt => 'PDF 转 PPT';

  @override
  String get pdfToExcel => 'PDF 转 Excel';

  @override
  String get mergePdf => '合并 PDF';

  @override
  String get splitPdf => '拆分 PDF';

  @override
  String get compressPdf => '压缩 PDF';

  @override
  String get protectPdf => '加密 PDF';

  @override
  String get signOnPdf => 'PDF 签名';

  @override
  String get ocrPdf => 'OCR 识别';

  @override
  String get organizePdf => '整理 PDF';

  @override
  String get wordToPdfSubtitle => '将您的 Word 文档 (.doc, .docx) 转换为高质量的 PDF 文件。';

  @override
  String get imageToPdfSubtitle => '将您的图片 (.jpg, .png, .webp) 转换为高质量的 PDF 文件。';

  @override
  String get pptToPdfSubtitle => '将您的演示文稿 (.ppt, .pptx) 转换为高质量的 PDF 文件。';

  @override
  String get excelToPdfSubtitle => '将您的电子表格 (.xlsx) 转换为高质量的 PDF 文件。';

  @override
  String get pdfToWordSubtitle => '将您的 PDF 文件转换为可编辑的 Word 文档 (.docx)。';

  @override
  String get pdfToImageSubtitle => '将您的 PDF 页面转换为高质量图片 (.jpg, .png)。';

  @override
  String get pdfToPptSubtitle => '将您的 PDF 文件转换为可编辑的演示文稿 (.pptx)。';

  @override
  String get pdfToExcelSubtitle => '将您的 PDF 文件转换为可编辑的电子表格 (.xlsx)。';

  @override
  String get mergePdfSubtitle => '将多个 PDF 文件合并为一个文档。';

  @override
  String get splitPdfSubtitle => '将 PDF 拆分为单独的页面或自定义页面范围。';

  @override
  String get compressPdfSubtitle => '在不损失质量的情况下缩小 PDF 文件大小。';

  @override
  String get protectPdfSubtitle => '加密并为您的 PDF 文档设置密码保护。';

  @override
  String get signOnPdfSubtitle => '在任何 PDF 文档中添加您的数字签名。';

  @override
  String get ocrPdfSubtitle => '使用光学字符识别从扫描的 PDF 中提取文本。';

  @override
  String get organizePdfSubtitle => '在 PDF 文档中重新排序、旋转或删除页面。';

  @override
  String get createPdf => 'Create PDF';

  @override
  String get createPdfSubtitle =>
      'Create and design a new PDF document from scratch.';

  @override
  String get editPdf => '编辑 PDF';

  @override
  String get editPdfSubtitle => '编辑文本、添加注释并自定义您的 PDF 文档。';

  @override
  String get unlockPdf => 'Unlock PDF';

  @override
  String get unlockPdfSubtitle =>
      'Remove password protection from encrypted PDF files.';

  @override
  String get defaultToolSubtitle => '将您的文件转换为高质量的 PDF。';

  @override
  String get selectWordFile => '选择 Word 文件';

  @override
  String get selectImageFile => '选择图片文件';

  @override
  String get selectPptFile => '选择 PPT 文件';

  @override
  String get selectExcelFile => '选择 Excel 文件';

  @override
  String get selectPdfFile => '选择 PDF 文件';

  @override
  String get selectPdfFiles => '选择多个 PDF 文件';

  @override
  String get selectPdfToEdit => '选择要编辑的 PDF';

  @override
  String get selectPdfToUnlock => 'Select PDF to Unlock';

  @override
  String get selectFile => '选择文件';

  @override
  String convertTool(String toolName) {
    return '转换 $toolName';
  }

  @override
  String get almostDone => '即将完成！';

  @override
  String get finalizingFileMessage => '正在处理您的文件，请稍候';

  @override
  String get protecting => '正在保护...';

  @override
  String get label1 => '快速转换';

  @override
  String get label2 => '保留原始排版格式';

  @override
  String get label3 => '安全且私密';

  @override
  String get editOrganizeLabel1 => 'Edit text, annotate & customize pages';

  @override
  String get editOrganizeLabel2 => 'Organize, split, merge & remove pages';

  @override
  String get editOrganizeLabel3 => '100% secure, offline & lossless quality';

  @override
  String get selectPdfToSplit => 'Select PDF to Split';

  @override
  String get selectPdfToProtect => 'Select PDF to Protect';

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
  String get home => '首页';

  @override
  String get files => '文件';

  @override
  String get settings => '设置';

  @override
  String get file => '未找到文件';

  @override
  String get upgradeProTitle => '升级到 Pro';

  @override
  String get upgradeProSubtitle => '解锁所有功能，畅享无限使用权限。';

  @override
  String get upgrade => '升级';

  @override
  String get languageOptions => '语言选项';

  @override
  String get feedback => '意见反馈';

  @override
  String get helpSupport => '帮助与支持';

  @override
  String get rateUs => '给我们评分';

  @override
  String get about => '关于';

  @override
  String get logout => '退出登录';

  @override
  String get settingsPremiumTitle => '升级到 Pro';

  @override
  String get settingsPremiumSutitle => '解锁所有功能\n畅享无限使用权限。';

  @override
  String get settingsUpgrade => '升级';

  @override
  String get settingsLabel1 => '语言选项';

  @override
  String get settingsLabel2 => '意见反馈';

  @override
  String get settingsLabel3 => '帮助与支持';

  @override
  String get settingsLabel4 => '给我们评分';

  @override
  String get settingsLabel5 => '关于';

  @override
  String get settingsLogout => '退出登录';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get preferredLangauge => '选择您的首选语言以继续';

  @override
  String get removePages => 'Remove Pages';

  @override
  String get removePagesSubtitle => 'Delete unwanted pages from PDF document';

  @override
  String get selectPdfToRemovePages => 'Select PDF to Remove Pages';

  @override
  String get conversionComplete => '转换完成！';

  @override
  String get yourPdfIsReady => '您的 PDF 已准备就绪';

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
  String get openPdf => '打开 PDF';

  @override
  String get share => '分享';

  @override
  String get done => '完成';

  @override
  String get conversionFailed => '转换失败';

  @override
  String get retry => '重试';

  @override
  String get cancel => '取消';

  @override
  String get preparing => '准备中...';

  @override
  String get converting => '正在转换...';

  @override
  String get keepAppOpen => '处理过程中请保持应用开启';

  @override
  String get theme => '主题';

  @override
  String get systemTheme => '跟随系统';

  @override
  String get lightTheme => '浅色';

  @override
  String get darkTheme => '深色';

  @override
  String get chooseTheme => '选择主题';

  @override
  String get unsupportedXlsTitle => '不支持的文件格式';

  @override
  String get unsupportedXlsMessage => '不支持 Excel .xls 文件。请选择 .xlsx 文件。';

  @override
  String get pdfCantBeEditedTitle => '无法编辑此 PDF';

  @override
  String get pdfCantBeEditedMessage => '此文件包含无法编辑的图片或不受支持的内容。请选择可编辑的 PDF。';

  @override
  String get unableToOpenPdfTitle => '无法打开 PDF';

  @override
  String get unableToOpenPdfMessage => '此 PDF 文件无效或已损坏。';

  @override
  String get unableToSavePdfTitle => '无法保存 PDF';

  @override
  String get unableToSavePdfMessage => '保存更改时出现问题。请重试。';

  @override
  String get savePdf => '保存 PDF';
}

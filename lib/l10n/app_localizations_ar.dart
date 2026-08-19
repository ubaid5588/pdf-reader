// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get splashAppName => 'قارئ PDF';

  @override
  String get splashAppTitle => 'جميع مستنداتك بلمسة واحدة';

  @override
  String get languageSelection => 'continue';

  @override
  String get onBoardingTitle1 => 'قراءة ملفات PDF على الفور';

  @override
  String get onBoardingSubtitle1 =>
      'افتح واعرض وأدر جميع مستندات PDF الخاصة بك بتجربة قراءة سلسة وسريعة.';

  @override
  String get onBoardingTitle2 => 'الوصول إلى مستندات Word';

  @override
  String get onBoardingSubtitle2 =>
      'عرض ملفات DOC و DOCX في أي وقت مع الحفاظ على تنظيم مستنداتك المهمة في مكان واحد.';

  @override
  String get onBoardingTitle3 => 'عروض تقديمية سهلة';

  @override
  String get onBoardingSubtitle3 =>
      'افتح واستعرض شرائح PPT و PPTX بسهولة للعمل والدراسة والعروض التقديمية.';

  @override
  String get onBoardingNext => 'التالي';

  @override
  String get onBoardingSkip => 'تخطي';

  @override
  String get onBoardingDone => 'تم';

  @override
  String get upgradeVip => 'الترقية إلى VIP';

  @override
  String get bannerTitle => 'مساحة عمل PDF\nشاملة ومتكاملة';

  @override
  String get bannerSubtitle => 'حوّل، عدّل، نظّم\nواحمِ مستنداتك.';

  @override
  String get tryNow => 'جرب الآن';

  @override
  String get convertToPdf => 'تحويل إلى PDF';

  @override
  String get editAndOrganize => 'تعديل وتنظيم';

  @override
  String get wordToPdf => 'Word إلى PDF';

  @override
  String get imageToPdf => 'صورة إلى PDF';

  @override
  String get pptToPdf => 'PPT إلى PDF';

  @override
  String get excelToPdf => 'Excel إلى PDF';

  @override
  String get pdfToWord => 'PDF إلى Word';

  @override
  String get pdfToImage => 'PDF إلى صورة';

  @override
  String get pdfToPpt => 'PDF إلى PPT';

  @override
  String get pdfToExcel => 'PDF إلى Excel';

  @override
  String get mergePdf => 'دمج PDF';

  @override
  String get splitPdf => 'تقسيم PDF';

  @override
  String get compressPdf => 'ضغط PDF';

  @override
  String get protectPdf => 'حماية PDF';

  @override
  String get signOnPdf => 'التوقيع على PDF';

  @override
  String get ocrPdf => 'OCR PDF';

  @override
  String get organizePdf => 'تنظيم PDF';

  @override
  String get wordToPdfSubtitle =>
      'حوّل مستندات Word الخاصة بك (.doc, .docx) إلى ملفات PDF عالية الجودة.';

  @override
  String get imageToPdfSubtitle =>
      'حوّل صورك (.jpg, .png, .webp) إلى ملفات PDF عالية الجودة.';

  @override
  String get pptToPdfSubtitle =>
      'حوّل عروضك التقديمية (.ppt, .pptx) إلى ملفات PDF عالية الجودة.';

  @override
  String get excelToPdfSubtitle =>
      'حوّل جداول البيانات الخاصة بك (.xls, .xlsx) إلى ملفات PDF عالية الجودة.';

  @override
  String get pdfToWordSubtitle =>
      'حوّل ملفات PDF الخاصة بك إلى مستندات Word قابلة للتعديل (.docx).';

  @override
  String get pdfToImageSubtitle =>
      'حوّل صفحات PDF إلى صور عالية الجودة (.jpg, .png).';

  @override
  String get pdfToPptSubtitle =>
      'حوّل ملفات PDF إلى عروض تقديمية قابلة للتعديل (.pptx).';

  @override
  String get pdfToExcelSubtitle =>
      'حوّل ملفات PDF إلى جداول بيانات قابلة للتعديل (.xlsx).';

  @override
  String get mergePdfSubtitle => 'اجمع عدة ملفات PDF في مستند واحد.';

  @override
  String get splitPdfSubtitle =>
      'قسّم ملف PDF إلى صفحات منفصلة أو نطاقات صفحات مخصصة.';

  @override
  String get compressPdfSubtitle => 'قلل حجم ملف PDF دون فقدان الجودة.';

  @override
  String get protectPdfSubtitle => 'شفّر مستندات PDF واحمِها بكلمة مرور.';

  @override
  String get signOnPdfSubtitle => 'أضف توقيعك الرقمي إلى أي مستند PDF.';

  @override
  String get ocrPdfSubtitle =>
      'استخرج النصوص من ملفات PDF الممسوحة ضوئيًا باستخدام التعرف الضوئي على الحروف.';

  @override
  String get organizePdfSubtitle =>
      'أعد ترتيب الصفحات أو تدويرها أو حذفها في مستند PDF الخاص بك.';

  @override
  String get defaultToolSubtitle => 'حوّل ملفك إلى PDF عالي الجودة.';

  @override
  String get selectWordFile => 'اختر ملف Word';

  @override
  String get selectImageFile => 'اختر ملف صورة';

  @override
  String get selectPptFile => 'اختر ملف PPT';

  @override
  String get selectExcelFile => 'اختر ملف Excel';

  @override
  String get selectPdfFile => 'اختر ملف PDF';

  @override
  String get selectPdfFiles => 'اختر ملفات PDF';

  @override
  String get selectFile => 'اختر ملف';

  @override
  String convertTool(String toolName) {
    return 'تحويل $toolName';
  }

  @override
  String get almostDone => 'اكتمل تقريبًا!';

  @override
  String get finalizingFileMessage =>
      'يرجى الانتظار بينما ننتهي من معالجة ملفك';

  @override
  String get protecting => 'جارٍ الحماية...';

  @override
  String get label1 => 'تحويل سريع';

  @override
  String get label2 => 'الحفاظ على التنسيق الأصلي';

  @override
  String get label3 => 'آمن وخاص';

  @override
  String get home => 'الرئيسية';

  @override
  String get files => 'الملفات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get file => 'لم يتم العثور على ملفات';

  @override
  String get upgradeProTitle => 'الترقية إلى Pro';

  @override
  String get upgradeProSubtitle => 'افتح جميع الميزات واستمتع بوصول غير محدود.';

  @override
  String get upgrade => 'ترقية';

  @override
  String get languageOptions => 'خيارات اللغة';

  @override
  String get feedback => 'الملاحظات';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get rateUs => 'قيّمنا';

  @override
  String get about => 'حول التطبيق';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get settingsPremiumTitle => 'الترقية إلى Pro';

  @override
  String get settingsPremiumSutitle =>
      'افتح جميع الميزات و\nاستمتع بوصول غير محدود.';

  @override
  String get settingsUpgrade => 'ترقية';

  @override
  String get settingsLabel1 => 'خيارات اللغة';

  @override
  String get settingsLabel2 => 'الملاحظات';

  @override
  String get settingsLabel3 => 'المساعدة والدعم';

  @override
  String get settingsLabel4 => 'قيّمنا';

  @override
  String get settingsLabel5 => 'حول التطبيق';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get preferredLangauge => 'اختر لغتك المفضلة للمتابعة';
}

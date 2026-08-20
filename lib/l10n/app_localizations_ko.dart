// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get splashAppName => 'PDF 리더';

  @override
  String get splashAppTitle => '한 번의 탭으로 모든 문서를 확인하세요';

  @override
  String get languageSelection => '계속';

  @override
  String get onBoardingTitle1 => '모든 PDF를 한곳에서';

  @override
  String get onBoardingSubtitle1 => '문서를 빠르고 손쉽게 읽고, 확인하고, 관리하세요.';

  @override
  String get onBoardingTitle2 => '파일을 PDF로 변환';

  @override
  String get onBoardingSubtitle2 => '몇 번의 탭만으로 문서와 이미지를 전문적인 PDF로 변환하세요.';

  @override
  String get onBoardingTitle3 => '강력한 PDF 도구';

  @override
  String get onBoardingSubtitle3 => '간단하고 강력한 도구로 PDF를 병합, 분할, 압축 및 보호하세요.';

  @override
  String get onBoardingNext => '다음';

  @override
  String get onBoardingSkip => '건너뛰기';

  @override
  String get onBoardingDone => '완료';

  @override
  String get upgradeVip => 'VIP 업그레이드';

  @override
  String get bannerTitle => '올인원\nPDF 작업 공간';

  @override
  String get bannerSubtitle => '문서를 변환, 편집, 정리하고\n안전하게 보호하세요.';

  @override
  String get tryNow => '지금 사용해 보기';

  @override
  String get convertToPdf => 'PDF로 변환';

  @override
  String get editAndOrganize => '편집 및 정리';

  @override
  String get wordToPdf => 'Word에서 PDF로';

  @override
  String get imageToPdf => '이미지에서 PDF로';

  @override
  String get pptToPdf => 'PPT에서 PDF로';

  @override
  String get excelToPdf => 'Excel에서 PDF로';

  @override
  String get pdfToWord => 'PDF에서 Word로';

  @override
  String get pdfToImage => 'PDF에서 이미지로';

  @override
  String get pdfToPpt => 'PDF에서 PPT로';

  @override
  String get pdfToExcel => 'PDF에서 Excel로';

  @override
  String get mergePdf => 'PDF 병합';

  @override
  String get splitPdf => 'PDF 분할';

  @override
  String get compressPdf => 'PDF 압축';

  @override
  String get protectPdf => 'PDF 보호';

  @override
  String get signOnPdf => 'PDF 서명';

  @override
  String get ocrPdf => 'OCR PDF';

  @override
  String get organizePdf => 'PDF 정리';

  @override
  String get wordToPdfSubtitle => 'Word 문서(.doc, .docx)를 고품질 PDF 파일로 변환합니다.';

  @override
  String get imageToPdfSubtitle => '이미지(.jpg, .png, .webp)를 고품질 PDF 파일로 변환합니다.';

  @override
  String get pptToPdfSubtitle => '프레젠테이션(.ppt, .pptx)을 고품질 PDF 파일로 변환합니다.';

  @override
  String get excelToPdfSubtitle => '스프레드시트(.xlsx)를 고품질 PDF 파일로 변환합니다.';

  @override
  String get pdfToWordSubtitle => 'PDF 파일을 편집 가능한 Word 문서(.docx)로 변환합니다.';

  @override
  String get pdfToImageSubtitle => 'PDF 페이지를 고품질 이미지(.jpg, .png)로 변환합니다.';

  @override
  String get pdfToPptSubtitle => 'PDF 파일을 편집 가능한 프레젠테이션(.pptx)으로 변환합니다.';

  @override
  String get pdfToExcelSubtitle => 'PDF 파일을 편집 가능한 스프레드시트(.xlsx)로 변환합니다.';

  @override
  String get mergePdfSubtitle => '여러 PDF 파일을 하나의 문서로 결합합니다.';

  @override
  String get splitPdfSubtitle => 'PDF를 개별 페이지 또는 사용자 지정 페이지 범위로 분할합니다.';

  @override
  String get compressPdfSubtitle => '품질 저하 없이 PDF 파일 크기를 줄입니다.';

  @override
  String get protectPdfSubtitle => 'PDF 문서를 암호화하고 비밀번호로 보호합니다.';

  @override
  String get signOnPdfSubtitle => '모든 PDF 문서에 디지털 서명을 추가합니다.';

  @override
  String get ocrPdfSubtitle => '광학 문자 인식을 사용하여 스캔한 PDF에서 텍스트를 추출합니다.';

  @override
  String get organizePdfSubtitle => 'PDF 문서의 페이지 순서를 변경하거나 회전 또는 삭제합니다.';

  @override
  String get editPdf => 'PDF 편집';

  @override
  String get editPdfSubtitle => '텍스트를 편집하고 주석을 추가하며 PDF 문서를 사용자 지정합니다.';

  @override
  String get defaultToolSubtitle => '파일을 고품질 PDF로 변환합니다.';

  @override
  String get selectWordFile => 'Word 파일 선택';

  @override
  String get selectImageFile => '이미지 파일 선택';

  @override
  String get selectPptFile => 'PPT 파일 선택';

  @override
  String get selectExcelFile => 'Excel 파일 선택';

  @override
  String get selectPdfFile => 'PDF 파일 선택';

  @override
  String get selectPdfFiles => 'PDF 파일 선택';

  @override
  String get selectPdfToEdit => '편집할 PDF 선택';

  @override
  String get selectFile => '파일 선택';

  @override
  String convertTool(String toolName) {
    return '$toolName 변환';
  }

  @override
  String get almostDone => '거의 완료되었습니다!';

  @override
  String get finalizingFileMessage => '파일을 마무리하는 동안 잠시 기다려 주세요';

  @override
  String get protecting => '보호 중...';

  @override
  String get label1 => '빠른 변환';

  @override
  String get label2 => '원본 서식 유지';

  @override
  String get label3 => '안전 및 비공개';

  @override
  String get home => '홈';

  @override
  String get files => '파일';

  @override
  String get settings => '설정';

  @override
  String get file => '파일을 찾을 수 없음';

  @override
  String get upgradeProTitle => 'Pro로 업그레이드';

  @override
  String get upgradeProSubtitle => '모든 기능을 잠금 해제하고 무제한 액세스를 즐기세요.';

  @override
  String get upgrade => '업그레이드';

  @override
  String get languageOptions => '언어 옵션';

  @override
  String get feedback => '의견 보내기';

  @override
  String get helpSupport => '도움말 및 지원';

  @override
  String get rateUs => '앱 평가하기';

  @override
  String get about => '정보';

  @override
  String get logout => '로그아웃';

  @override
  String get settingsPremiumTitle => 'Pro로 업그레이드';

  @override
  String get settingsPremiumSutitle => '모든 기능을 잠금 해제하고\n무제한 액세스를 즐기세요.';

  @override
  String get settingsUpgrade => '업그레이드';

  @override
  String get settingsLabel1 => '언어 옵션';

  @override
  String get settingsLabel2 => '의견 보내기';

  @override
  String get settingsLabel3 => '도움말 및 지원';

  @override
  String get settingsLabel4 => '앱 평가하기';

  @override
  String get settingsLabel5 => '정보';

  @override
  String get settingsLogout => '로그아웃';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get preferredLangauge => '계속하려면 원하는 언어를 선택하세요';

  @override
  String get conversionComplete => '변환이 완료되었습니다!';

  @override
  String get yourPdfIsReady => 'PDF가 준비되었습니다';

  @override
  String get openPdf => 'PDF 열기';

  @override
  String get share => '공유';

  @override
  String get done => '완료';

  @override
  String get conversionFailed => '변환에 실패했습니다';

  @override
  String get retry => '다시 시도';

  @override
  String get cancel => '취소';

  @override
  String get preparing => '준비 중...';

  @override
  String get converting => '변환 중...';

  @override
  String get keepAppOpen => '처리하는 동안 앱을 열어 두세요';

  @override
  String get theme => '테마';

  @override
  String get systemTheme => '시스템';

  @override
  String get lightTheme => '라이트';

  @override
  String get darkTheme => '다크';

  @override
  String get chooseTheme => '테마 선택';

  @override
  String get unsupportedXlsTitle => '지원되지 않는 파일 형식';

  @override
  String get unsupportedXlsMessage =>
      'Excel .xls 파일은 지원되지 않습니다. .xlsx 파일을 선택해 주세요.';

  @override
  String get pdfCantBeEditedTitle => '이 PDF는 편집할 수 없습니다';

  @override
  String get pdfCantBeEditedMessage =>
      '이 파일에는 편집할 수 없는 이미지 기반 또는 지원되지 않는 콘텐츠가 포함되어 있습니다. 편집 가능한 PDF를 선택해 주세요.';

  @override
  String get unableToOpenPdfTitle => 'PDF를 열 수 없음';

  @override
  String get unableToOpenPdfMessage => '이 PDF 파일이 잘못되었거나 손상되었습니다.';

  @override
  String get unableToSavePdfTitle => 'PDF를 저장할 수 없음';

  @override
  String get unableToSavePdfMessage => '변경 사항을 저장하는 동안 오류가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get savePdf => 'PDF 저장';
}

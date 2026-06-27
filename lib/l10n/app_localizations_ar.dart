// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'CS Bouira';

  @override
  String get appSubtitle => 'THE RESOURCE HUB';

  @override
  String get splashFooter => 'قسم علوم الحاسوب';

  @override
  String get pressBackAgain => 'اضغط على زر الرجوع مرة اخرى للخروج';

  @override
  String get failedToLoadData => 'فشل تحميل البيانات';

  @override
  String get failedToLoadDataHint => 'تحقق من اتصالك بالانترنت وحاول مرة اخرى.';

  @override
  String get failedToLoadDataAction => 'عرض التنزيلات';

  @override
  String get failedToLoadModules => 'فشل تحميل المقاييس.';

  @override
  String get failedToLoadFiles => 'فشل تحميل الملفات.';

  @override
  String get failedToLoadFavorites => 'فشل تحميل المفضلة.';

  @override
  String get failedToSearch => 'فشل البحث.';

  @override
  String get noModulesFound => 'لم يتم العثور على مقاييس';

  @override
  String get noModulesAvailable => 'لا توجد مقاييس متاحة';

  @override
  String get noModulesMatchSearch => 'لا توجد مقاييس تطابق بحثك';

  @override
  String get folderNotFound => 'المجلد غير موجود';

  @override
  String get noMatchingFilesOrFolders => 'لا توجد ملفات او مجلدات مطابقة';

  @override
  String get noFilesAvailable => 'لا توجد ملفات متاحة';

  @override
  String get searchFilesAndFolders => 'البحث في الملفات والمجلدات...';

  @override
  String get searchModules => 'البحث في المقاييس...';

  @override
  String get sortBy => 'ترتيب حسب';

  @override
  String get sortByNameAZ => 'الاسم (أ-ي)';

  @override
  String get sortByNameZA => 'الاسم (ي-أ)';

  @override
  String get sortByType => 'النوع';

  @override
  String get sortBySubfolders => 'المجلدات الفرعية';

  @override
  String get sortByFiles => 'الملفات';

  @override
  String get folderEmpty => 'فارغ';

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عناصر',
      one: '$count عنصر',
    );
    return '$_temp0';
  }

  @override
  String get pdfBadge => 'PDF';

  @override
  String get breadcrumbDrive => 'Drive';

  @override
  String get homeTitle => 'CS BOUIRA';

  @override
  String homeWelcome(Object name) {
    return 'مرحبا، $name';
  }

  @override
  String get homeSubtitle => ' يمكنك التصفح والوصول لمختلف أنواع الموارد والمصادر الدراسية المقدمة من جامعة البويرة';

  @override
  String get homeSearchHint => 'البحث عن دروس، ملفات، او امتحانات...';

  @override
  String get academicPath => 'المسار الدراسي';

  @override
  String get selectYear => 'اختر السنة';

  @override
  String fileCountOnYear(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملفًا',
      one: '$count ملف',
    );
    return '$_temp0';
  }

  @override
  String get statsUsers => 'المستخدمون';

  @override
  String get statsFiles => 'ملفا';

  @override
  String get statsSpecials => 'مميزات';

  @override
  String get newBadge => 'جديد';

  @override
  String get academicYear => 'السنة الجامعية 2025/2026';

  @override
  String semesterSubtitle(Object year) {
    return 'اختر فصلا دراسيا للوصول الى الدروس والاعمال التطبيقية والمواد الدراسية لـ $year.';
  }

  @override
  String moduleCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مقاييس',
      one: '$count مقياس',
    );
    return '$_temp0';
  }

  @override
  String get exploreResources => 'استكشف الموارد';

  @override
  String get booksAndExercices => 'الكتب والتمارين';

  @override
  String get semesterEmpty => 'فارغ';

  @override
  String get onlineResourcesSubtitle => 'الوصول الى المكتبة الرقمية وحلول التمارين';

  @override
  String get onlineResources => 'الموارد الالكترونية';

  @override
  String moduleBreadcrumb(Object year, Object semester) {
    return '$year / $semester';
  }

  @override
  String get activeModules => 'المقاييس النشطة';

  @override
  String get allModules => 'جميع المقاييس';

  @override
  String get searchResults => 'نتائج البحث';

  @override
  String totalCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اجمالي',
      one: '$count اجمالي',
    );
    return '$_temp0';
  }

  @override
  String folderFileBreakdown(num folders, num files) {
    String _temp0 = intl.Intl.pluralLogic(
      folders,
      locale: localeName,
      other: '$folders مجلدات',
      one: '$folders مجلد',
    );
    String _temp1 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files ملفات',
      one: '$files ملف',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String fileCount(num files) {
    String _temp0 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files ملفات',
      one: '$files ملف',
    );
    return '$_temp0';
  }

  @override
  String get totalModules => 'اجمالي المقاييس';

  @override
  String get totalFiles => 'اجمالي الملفات';

  @override
  String get courseModuleBadge => 'مقياس دراسي';

  @override
  String folderFileCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملفات',
      one: '$count ملف',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'البحث عن مقاييس، ملفات...';

  @override
  String get searchFilterYear => 'السنة';

  @override
  String get searchFilterSemester => 'الفصل الدراسي';

  @override
  String get searchFilterModule => 'المقياس';

  @override
  String get searchFilterType => 'النوع';

  @override
  String get searchFilterClear => 'مسح';

  @override
  String get noOptionsAvailable => 'لا توجد خيارات متاحة';

  @override
  String get couldNotLoadFilters => 'تعذر تحميل الفلاتر. تحقق من اتصالك.';

  @override
  String get searchResultModule => 'مقياس';

  @override
  String get searchResultFolder => 'مجلد';

  @override
  String get searchResultFile => 'ملف';

  @override
  String get startExploring => 'ابدا الاستكشاف';

  @override
  String get searchEmptyMessage => 'البحث عن مقاييس، ملفات، او مواضيع\nفي مكتبة CS Bouira بالكامل.';

  @override
  String get topResults => 'اهم النتائج';

  @override
  String itemsFound(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عناصر تم العثور عليها',
      one: '$count عنصر تم العثور عليه',
    );
    return '$_temp0';
  }

  @override
  String noResultsForQuery(Object query) {
    return 'لا توجد نتائج لـ \"$query\"';
  }

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get favoritesSavedModules => 'المقاييس المحفوظة';

  @override
  String get favoritesSavedFiles => 'الملفات المحفوظة';

  @override
  String get favoritesOnlineResources => 'الموارد الالكترونية';

  @override
  String favoritesTotal(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count اجمالي',
      one: '$count اجمالي',
    );
    return '$_temp0';
  }

  @override
  String get favoritesTabModules => 'المقاييس';

  @override
  String get favoritesTabFiles => 'الملفات';

  @override
  String get favoritesTabResources => 'الموارد';

  @override
  String get removedFromFavorites => 'تمت الازالة من المفضلة';

  @override
  String get noModulesSaved => 'لا توجد مقاييس محفوظة';

  @override
  String get noModulesSavedHint => 'قم بتمييز مقياس بنجمة لحفظه هنا\nللوصول السريع.';

  @override
  String get noFilesSaved => 'لا توجد ملفات محفوظة';

  @override
  String get noFilesSavedHint => 'قم بتمييز ملف بنجمة لحفظه هنا\nللوصول السريع.';

  @override
  String get noResourcesSaved => 'لا توجد موارد محفوظة';

  @override
  String get noResourcesSavedHint => 'قم بتمييز مورد الكتروني بنجمة لحفظه هنا\nللوصول السريع.';

  @override
  String get browseHome => 'تصفح الرئيسية';

  @override
  String favoritesFileCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملفات',
      one: '$count ملف',
    );
    return '$_temp0';
  }

  @override
  String favoritesFolderCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مجلدات',
      one: '$count مجلد',
    );
    return '$_temp0';
  }

  @override
  String get viewModule => 'عرض المقياس';

  @override
  String get downloadingSnackbar => 'جاري التنزيل...';

  @override
  String downloadComplete(Object name) {
    return 'تم تنزيل \"$name\"';
  }

  @override
  String get viewAction => 'عرض';

  @override
  String downloadFailed(Object error) {
    return 'فشل التنزيل: $error';
  }

  @override
  String get couldNotOpenLink => 'تعذر فتح الرابط';

  @override
  String get previewMenuDownload => 'تنزيل';

  @override
  String get previewMenuShareQr => 'مشاركة رمز QR';

  @override
  String get previewMenuOpenDrive => 'فتح في Google Drive';

  @override
  String get tapToExitFullscreen => 'اضغط للخروج من وضع ملء الشاشة';

  @override
  String get fileTypeLabel => 'ملف';

  @override
  String get uploadTitle => 'شارك موردا';

  @override
  String get uploadHeader => 'ساهم في المنصة';

  @override
  String get uploadSubtitle => 'ساعد زملاءك الطلاب من خلال رفع مواد دراسية موثقة.';

  @override
  String get uploadFieldFullName => 'الاسم الكامل';

  @override
  String get uploadFieldEmail => 'البريد الالكتروني';

  @override
  String get uploadCategorySection => 'فئة المورد';

  @override
  String get uploadGrade => 'السنة الدراسية';

  @override
  String get uploadSemester => 'الفصل الدراسي';

  @override
  String get uploadModule => 'المقياس';

  @override
  String get uploadDropdownPlaceholder => 'اختر';

  @override
  String get uploadFileSection => 'الملف المرفق';

  @override
  String get uploadChooseOrScan => 'اختر او مسح ملف';

  @override
  String uploadAcceptedFormats(Object maxSize) {
    return 'PDF, DOCX, ZIP (الحد الاقصى $maxSize ميغابايت)';
  }

  @override
  String get uploadAddMoreFiles => 'اضافة ملفات اخرى';

  @override
  String uploadFileSelected(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count  ملفا محددا',
      one: '$count ملف محدد',
    );
    return '$_temp0';
  }

  @override
  String get uploadButton => 'رفع المورد';

  @override
  String get uploading => 'جاري الرفع...';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'جاري رفع $current من $total...';
  }

  @override
  String get cancelUpload => 'الغاء الرفع';

  @override
  String get uploadAgreement => 'بالرفع، فانك توافق على ارشادات المجتمع وسياسة النزاهة الاكاديمية لـ CS Bouira.';

  @override
  String get uploadPickerOption => 'اختر ملفا';

  @override
  String get uploadPickerSubtitle => 'تصفح ذاكرة الجهاز';

  @override
  String get uploadScanOption => 'مسح ملف';

  @override
  String get uploadScanSubtitle => 'استخدم الكاميرا لمسح الوثائق';

  @override
  String get uploadErrorNoInternet => 'لا يوجد اتصال بالانترنت';

  @override
  String get uploadErrorTimeout => 'انتهت مهلة الطلب';

  @override
  String get uploadErrorCancelled => 'تم الغاء الرفع';

  @override
  String get uploadErrorFailed => 'فشل الرفع.';

  @override
  String get uploadRetry => 'اعادة المحاولة';

  @override
  String get uploadSuccessSingle => 'تم رفع ملفك بنجاح.';

  @override
  String uploadSuccessMultiple(Object count) {
    return 'تم رفع جميع $count موارد بنجاح.';
  }

  @override
  String get uploadSuccessTitle => 'شكرا لمساهمتك!';

  @override
  String get uploadSuccessUploadMore => 'رفع المزيد';

  @override
  String get uploadSuccessDone => 'تم';

  @override
  String uploadFileTooLarge(Object fileName, Object maxMB) {
    return '$fileName يتجاوز الحد الاقصى $maxMB ميغابايت وتم تجاهله.';
  }

  @override
  String get uploadScanError => 'تعذر قراءة الوثيقة الممسوحة.';

  @override
  String get reviewTitle => 'مراجعة الملف';

  @override
  String reviewFileCounter(Object current, Object total) {
    return '$current من $total';
  }

  @override
  String get reviewRetake => 'اعادة المسح / اختيار مرة اخرى';

  @override
  String get reviewUseThisFile => 'استخدام هذا الملف';

  @override
  String reviewApproveAll(Object remaining) {
    return 'الموافقة على الكل ($remaining متبقي)';
  }

  @override
  String get reviewPreviewNotAvailable => 'المعاينة غير متاحة';

  @override
  String get authTagline => 'مركز الموارد الاكاديمية لعلوم الحاسوب';

  @override
  String get authLoginToggle => 'تسجيل الدخول';

  @override
  String get authSignUpToggle => 'انشاء حساب';

  @override
  String get authFieldFullName => 'الاسم الكامل';

  @override
  String get authFieldEmail => 'البريد الالكتروني';

  @override
  String get authFieldPassword => 'كلمة المرور';

  @override
  String get authFieldConfirmPassword => 'تاكيد كلمة المرور';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authSignUpButton => 'انشاء حساب';

  @override
  String get authLoginButton => 'تسجيل الدخول';

  @override
  String get authOrDivider => 'او';

  @override
  String get authGoogleButton => 'الاستمرار باستخدام Google';

  @override
  String get authAgreement => 'بالاستمرار فانك توافق على شروط الخدمة وسياسة الخصوصية الخاصة بنا.';

  @override
  String get authValidationEmailRequired => 'البريد الالكتروني مطلوب';

  @override
  String get authValidationEmailInvalid => 'ادخل بريدا الكترونيا صحيحا';

  @override
  String get authValidationPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get authValidationPasswordLength => 'يجب ان تتكون كلمة المرور من 8 احرف على الاقل';

  @override
  String get authValidationPasswordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authValidationNameRequired => 'الاسم الكامل مطلوب';

  @override
  String get authSignupFailed => 'فشل انشاء الحساب. يرجى المحاولة مرة اخرى.';

  @override
  String get authMergeDialogTitle => 'دمج المفضلة';

  @override
  String authMergeDialogMessage(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'وجدنا $count عناصر محفوظة في مفضلتك المحلية. هل تريد اضافتها الى حسابك؟',
      one: 'وجدنا $count عنصر محفوظ في مفضلتك المحلية. هل تريد اضافته الى حسابك؟',
    );
    return '$_temp0';
  }

  @override
  String get authMergeDialogSkip => 'تخطي';

  @override
  String get authMergeDialogMerge => 'دمج';

  @override
  String get forgotPasswordTitle => 'اعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSubtitle => 'ادخل بريدك الالكتروني وسنرسل لك رابط اعادة التعيين.';

  @override
  String get forgotPasswordFieldEmail => 'البريد الالكتروني';

  @override
  String get forgotPasswordButton => 'ارسال رابط اعادة التعيين';

  @override
  String get forgotPasswordBackToLogin => 'الرجوع الى تسجيل الدخول';

  @override
  String get forgotPasswordValidationEmailRequired => 'البريد الالكتروني مطلوب';

  @override
  String get forgotPasswordValidationEmailInvalid => 'ادخل بريدا الكترونيا صحيحا';

  @override
  String get forgotPasswordSuccess => 'تحقق من بريدك الالكتروني للحصول على رابط اعادة تعيين كلمة المرور.';

  @override
  String get forgotPasswordError => 'فشل ارسال بريد اعادة التعيين. يرجى المحاولة مرة اخرى.';

  @override
  String get profileTitle => ' ملفي';

  @override
  String get profileGuestName => 'زائر';

  @override
  String get profileGuestBadge => 'زائر';

  @override
  String get profileEmailPlaceholder => 'اضف بريدك الالكتروني';

  @override
  String get profileStatUploads => 'المرفوعات';

  @override
  String get profileStatFavorites => 'المفضلة';

  @override
  String get profileSettingMyUploads => 'مرفوعاتي';

  @override
  String get profileSettingDownloads => 'التنزيلات';

  @override
  String get profileSettingFavorites => 'المفضلة';

  @override
  String get profileSettingLeaderboard => 'قائمة المتصدرين';

  @override
  String get profileSettingAbout => 'حول CS Bouira';

  @override
  String get profileGuestButton => 'تسجيل الدخول او انشاء حساب';

  @override
  String get profileEditNameTitle => 'تعديل الاسم';

  @override
  String get profileEditNameHint => 'ادخل اسمك';

  @override
  String get profileEditNameCancel => 'الغاء';

  @override
  String get profileEditNameSave => 'حفظ';

  @override
  String get profileEditEmailTitle => 'تعديل البريد الالكتروني';

  @override
  String get profileEditEmailHint => 'ادخل بريدك الالكتروني';

  @override
  String get profileLogoutTitle => 'تسجيل الخروج';

  @override
  String get profileLogoutMessage => 'هل انت متاكد من انك تريد تسجيل الخروج؟';

  @override
  String get profileLogoutConfirm => 'تسجيل الخروج';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileLanguageEnglish => 'الانجليزية';

  @override
  String get profileLanguageArabic => 'العربية';

  @override
  String get profileLanguageFrench => 'الفرنسية';

  @override
  String get myUploadsTitle => 'رفوعاتي';

  @override
  String get myUploadsEmpty => 'لا توجد رفوعات بعد';

  @override
  String get myUploadsEmptyHint => 'ستظهر هنا الموارد التي رفعتها.';

  @override
  String get downloadsTitle => 'التنزيلات';

  @override
  String get downloadsEmpty => 'لا توجد تنزيلات بعد';

  @override
  String get downloadsEmptyHint => 'ستظهر هنا الملفات التي قمت بتنزيلها.';

  @override
  String get downloadsOpenAction => 'فتح';

  @override
  String get downloadsDeleteAction => 'حذف';

  @override
  String get leaderboardTitle => 'قائمة المتصدرين';

  @override
  String get leaderboardHeader => 'اهم المساهمين';

  @override
  String get leaderboardYourRank => 'ترتيبك';

  @override
  String get leaderboardNotRanked => 'غير مصنف بعد';

  @override
  String get leaderboardEmpty => 'لا يوجد مساهمون بعد';

  @override
  String leaderboardUploadCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملفا مرفوعا',
      one: '$count مرفوع',
    );
    return '$_temp0';
  }

  @override
  String get leaderboardPoints => 'نقاط';

  @override
  String get aboutTitle => 'حول CS Bouira';

  @override
  String get aboutVersion => 'الاصدار';

  @override
  String get aboutDescription => 'CS Bouira هي منصة لمشاركة الموارد الاكاديمية لطلاب علوم الحاسوب في جامعة البويرة.';

  @override
  String get aboutFeatures => 'المميزات';

  @override
  String get aboutFeatureBrowseResources => 'تصفح الموارد حسب السنة والفصل والمقياس';

  @override
  String get aboutFeatureSearch => 'البحث في جميع المواد الدراسية';

  @override
  String get aboutFeatureDownload => 'تنزيل ومعاينة ملفات PDF والمستندات والصور';

  @override
  String get aboutFeatureUpload => 'رفع ومشاركة الموارد الاكاديمية';

  @override
  String get aboutFeatureBookmarks => 'حفظ المفضلة للوصول السريع';

  @override
  String get aboutFeatureQrCode => 'ماسح رمز QR للروابط الفورية للموارد';

  @override
  String get aboutFeatureOffline => 'الوصول دون اتصال الى المواد التي تم تنزيلها';

  @override
  String get aboutCreator => 'المطور';

  @override
  String get aboutCreatorSalimZedDesc => 'المطور الأصلي لمنصة Cs Bouira و api';

  @override
  String get aboutCreatorAhmedAmineDesc => 'مطور تطبيق الاندرويد';

  @override
  String get aboutSourceCode => 'الكود المصدري';

  @override
  String get aboutSourceCodeGithub => 'مستودع GitHub';

  @override
  String get aboutSourceCodeReportIssue => 'الابلاغ عن مشكلة';

  @override
  String get aboutContact => 'الاتصال';

  @override
  String get aboutLicense => 'الترخيص';

  @override
  String get aboutLicenseText => 'هذا التطبيق مرخص بموجب رخصة MIT.\n\nحقوق النشر © 2026 احمد امين. جميع الحقوق محفوظة.\n\nيُسمح لأي شخص يحصل على نسخة من هذا البرنامج والملفات المرتبطة به، التعامل مع البرنامج دون قيود، بما في ذلك دون حصر حقوق الاستخدام والنسخ والتعديل والدمج والنشر والتوزيع والترخيص و/أو بيع نسخ من البرنامج،';

  @override
  String get qrScannerTitle => 'مسح رمز QR';

  @override
  String get qrScannerInstruction => 'وجه كاميراك نحو رمز QR';

  @override
  String get qrScannerSuccess => 'تم مسح رمز QR!';

  @override
  String get qrScannerError => 'تعذر قراءة رمز QR';

  @override
  String get bottomNavHome => 'الرئيسية';

  @override
  String get bottomNavSearch => 'البحث';

  @override
  String get bottomNavFavs => 'المفضلة';

  @override
  String get bottomNavUpload => 'رفع';

  @override
  String get bottomNavProfile => ' ملفي';

  @override
  String get networkReconnected => 'عدت الى الاتصال بالانترنت';

  @override
  String get networkOffline => 'لا يوجد اتصال بالانترنت';

  @override
  String get deleteConfirm => 'حذف';

  @override
  String get deleteCancel => 'الغاء';

  @override
  String get fetchErrorFailedToLoad => 'فشل تحميل البيانات';

  @override
  String get fetchErrorCheckConnection => 'تحقق من اتصالك بالانترنت وحاول مرة اخرى.';

  @override
  String get fetchErrorViewDownloads => 'عرض التنزيلات';

  @override
  String get gradeLicence1 => 'ليـسـانس 1';

  @override
  String get gradeLicence2 => 'ليـسـانس 2';

  @override
  String get gradeLicence3Si => 'ليـسـانس 3 SI';

  @override
  String get gradeMaster1Gsi => 'ماستـر 1 GSI';

  @override
  String get gradeMaster1Isil => 'ماستـر 1 ISIL';

  @override
  String get gradeMaster1Ia => 'ماستـر 1 IA';

  @override
  String get gradeMaster2Gsi => 'ماستـر 2 GSI';

  @override
  String get gradeMaster2Isil => 'ماستـر 2 ISIL';

  @override
  String get gradeMaster2Ia => 'ماستـر 2 IA';

  @override
  String get levelBachelor => 'ليـسـانس';

  @override
  String get levelBachelorFinalYear => 'السنة النهائية للسلك الأول';

  @override
  String get levelMaster => 'ماستـر';

  @override
  String get downloadsBrowseFiles => 'تصفح الملفات';

  @override
  String get updateDialogTitle => 'تحديث متوفر';

  @override
  String updateDialogBody(Object version) {
    return 'الإصدار $version جاهز للتثبيت.';
  }

  @override
  String get updateDialogUpdate => 'تحديث';

  @override
  String get updateDialogLater => 'لاحقاً';

  @override
  String get updateDialogDownloading => 'جاري تحميل التحديث...';

  @override
  String get updateDialogError => 'فشل تحميل التحديث.';
}

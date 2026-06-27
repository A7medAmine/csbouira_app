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
  String get appSubtitle => 'مركز الموارد';

  @override
  String get splashFooter => 'قسم علوم الحاسوب';

  @override
  String get pressBackAgain => 'اضغط مرة أخرى للخروج';

  @override
  String get failedToLoadData => 'فشل تحميل البيانات';

  @override
  String get failedToLoadDataHint => 'تحقق من اتصالك بالانترنت وحاول مرة اخرى.';

  @override
  String get failedToLoadDataAction => 'عرض التنزيلات';

  @override
  String get failedToLoadModules => 'فشل تحميل الوحدات.';

  @override
  String get failedToLoadFiles => 'فشل تحميل الملفات.';

  @override
  String get failedToLoadFavorites => 'فشل تحميل المفضلة.';

  @override
  String get failedToSearch => 'فشل البحث.';

  @override
  String get noModulesFound => 'لا توجد وحدات';

  @override
  String get noModulesAvailable => 'لا توجد وحدات متاحة';

  @override
  String get noModulesMatchSearch => 'لا توجد وحدات تطابق بحثك';

  @override
  String get folderNotFound => 'المجلد غير موجود';

  @override
  String get noMatchingFilesOrFolders => 'لا توجد ملفات أو مجلدات مطابقة';

  @override
  String get noFilesAvailable => 'لا توجد ملفات متاحة';

  @override
  String get searchFilesAndFolders => 'ابحث في الملفات والمجلدات...';

  @override
  String get searchModules => 'ابحث في الوحدات...';

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
  String itemsCount(num count) => '$count ${count == 1 ? 'عنصر' : 'عناصر'}';

  @override
  String get pdfBadge => 'PDF';

  @override
  String get breadcrumbDrive => 'Drive';

  @override
  String get homeTitle => 'CS BOUIRA';

  @override
  String homeWelcome(Object name) => 'مرحباً، $name';

  @override
  String get homeSubtitle => 'الوصول إلى جميع موارد علوم الحاسوب من جامعة البويرة في مكان واحد.';

  @override
  String get homeSearchHint => 'ابحث عن المقررات أو الملفات أو الامتحانات...';

  @override
  String get academicPath => 'المسار الأكاديمي';

  @override
  String get selectYear => 'اختر السنة';

  @override
  String fileCountOnYear(num count) => '$count ${count == 1 ? 'ملف' : 'ملفات'}';

  @override
  String get statsUsers => 'المستخدمون';

  @override
  String get statsFiles => 'الملفات';

  @override
  String get statsSpecials => 'خاص';

  @override
  String get newBadge => 'جديد';

  @override
  String get academicYear => 'السنة الجامعية 2025/2026';

  @override
  String semesterSubtitle(Object year) => 'اختر فصلاً دراسياً للوصول إلى المقررات والأعمال الموجهة والمواد الأكاديمية لسنة $year.';

  @override
  String moduleCount(num count) => '$count ${count == 1 ? 'وحدة' : 'وحدات'}';

  @override
  String get exploreResources => 'استكشاف الموارد';

  @override
  String get booksAndExercices => 'الكتب والتمارين';

  @override
  String get semesterEmpty => 'فارغ';

  @override
  String get onlineResourcesSubtitle => 'الوصول إلى المكتبة الرقمية وسلاسل التمارين المصححة';

  @override
  String get onlineResources => 'الموارد عبر الإنترنت';

  @override
  String moduleBreadcrumb(Object year, Object semester) => '$year / $semester';

  @override
  String get activeModules => 'الوحدات النشطة';

  @override
  String get allModules => 'جميع الوحدات';

  @override
  String get searchResults => 'نتائج البحث';

  @override
  String totalCount(num count) => '$count المجموع';

  @override
  String folderFileBreakdown(num folders, num files) {
    final f = '$folders ${folders == 1 ? 'مجلد' : 'مجلدات'}';
    final fi = '$files ${files == 1 ? 'ملف' : 'ملفات'}';
    return '$f · $fi';
  }

  @override
  String fileCount(num files) => '$files ${files == 1 ? 'ملف' : 'ملفات'}';

  @override
  String get totalModules => 'إجمالي الوحدات';

  @override
  String get totalFiles => 'إجمالي الملفات';

  @override
  String get courseModuleBadge => 'وحدة مقرر';

  @override
  String folderFileCount(num count) => '$count ${count == 1 ? 'ملف' : 'ملفات'}';

  @override
  String get searchHint => 'ابحث عن الوحدات والملفات...';

  @override
  String get searchFilterYear => 'السنة';

  @override
  String get searchFilterSemester => 'الفصل';

  @override
  String get searchFilterModule => 'الوحدة';

  @override
  String get searchFilterType => 'النوع';

  @override
  String get searchFilterClear => 'مسح';

  @override
  String get noOptionsAvailable => 'لا توجد خيارات متاحة';

  @override
  String get couldNotLoadFilters => 'تعذر تحميل الفلاتر. تحقق من اتصالك.';

  @override
  String get searchResultModule => 'وحدة';

  @override
  String get searchResultFolder => 'مجلد';

  @override
  String get searchResultFile => 'ملف';

  @override
  String get startExploring => 'ابدأ الاستكشاف';

  @override
  String get searchEmptyMessage => 'ابحث عن الوحدات أو الملفات أو المواضيع\nفي جميع أنحاء مكتبة CS Bouira.';

  @override
  String get topResults => 'أفضل النتائج';

  @override
  String itemsFound(num count) => '$count ${count == 1 ? 'نتيجة' : 'نتائج'}';

  @override
  String noResultsForQuery(Object query) => 'لا توجد نتائج لـ "$query"';

  @override
  String get favoritesTitle => 'المفضلة';

  @override
  String get favoritesSavedModules => 'الوحدات المحفوظة';

  @override
  String get favoritesSavedFiles => 'الملفات المحفوظة';

  @override
  String get favoritesOnlineResources => 'الموارد عبر الإنترنت';

  @override
  String favoritesTotal(num count) => '$count المجموع';

  @override
  String get favoritesTabModules => 'الوحدات';

  @override
  String get favoritesTabFiles => 'الملفات';

  @override
  String get favoritesTabResources => 'الموارد';

  @override
  String get removedFromFavorites => 'تمت الإزالة من المفضلة';

  @override
  String get noModulesSaved => 'لا توجد وحدات محفوظة';

  @override
  String get noModulesSavedHint => 'ضع علامة نجمة على وحدة لحفظها\nللوصول السريع.';

  @override
  String get noFilesSaved => 'لا توجد ملفات محفوظة';

  @override
  String get noFilesSavedHint => 'ضع علامة نجمة على ملف لحفظه\nللوصول السريع.';

  @override
  String get noResourcesSaved => 'لا توجد موارد محفوظة';

  @override
  String get noResourcesSavedHint => 'ضع علامة نجمة على مورد عبر الإنترنت\nلحفظه للوصول السريع.';

  @override
  String get browseHome => 'تصفح الرئيسية';

  @override
  String favoritesFileCount(num count) => '$count ${count == 1 ? 'ملف' : 'ملفات'}';

  @override
  String favoritesFolderCount(num count) => '$count ${count == 1 ? 'مجلد' : 'مجلدات'}';

  @override
  String get viewModule => 'عرض الوحدة';

  @override
  String get downloadingSnackbar => 'جاري التحميل...';

  @override
  String downloadComplete(Object name) => '"$name" تم التحميل';

  @override
  String get viewAction => 'عرض';

  @override
  String downloadFailed(Object error) => 'فشل التحميل: $error';

  @override
  String get couldNotOpenLink => 'تعذر فتح الرابط';

  @override
  String get previewMenuDownload => 'تحميل';

  @override
  String get previewMenuShareQr => 'مشاركة QR';

  @override
  String get previewMenuOpenDrive => 'فتح في Google Drive';

  @override
  String get tapToExitFullscreen => 'اضغط للخروج من ملء الشاشة';

  @override
  String get fileTypeLabel => 'ملف';

  @override
  String get uploadTitle => 'مشاركة مورد';

  @override
  String get uploadHeader => 'ساهم في المركز';

  @override
  String get uploadSubtitle => 'ساعد زملائك الطلاب عن طريق رفع الموارد الأكاديمية الموثقة.';

  @override
  String get uploadFieldFullName => 'الاسم الكامل';

  @override
  String get uploadFieldEmail => 'البريد الإلكتروني';

  @override
  String get uploadCategorySection => 'فئة المورد';

  @override
  String get uploadGrade => 'المستوى';

  @override
  String get uploadSemester => 'الفصل';

  @override
  String get uploadModule => 'الوحدة';

  @override
  String get uploadDropdownPlaceholder => 'اختر';

  @override
  String get uploadFileSection => 'المرفقات';

  @override
  String get uploadChooseOrScan => 'اختر أو امسح ملفاً';

  @override
  String uploadAcceptedFormats(Object maxSize) => 'PDF, DOCX, ZIP (الحد الأقصى $maxSize ميغابايت)';

  @override
  String get uploadAddMoreFiles => 'أضف المزيد من الملفات';

  @override
  String uploadFileSelected(num count) => '$count ${count == 1 ? 'ملف محدد' : 'ملفات محددة'}';

  @override
  String get uploadButton => 'رفع المورد';

  @override
  String get uploading => 'جاري الرفع…';

  @override
  String uploadingProgress(Object current, Object total) => 'جاري رفع $current من $total…';

  @override
  String get cancelUpload => 'إلغاء الرفع';

  @override
  String get uploadAgreement => 'بالرفع، أنت توافق على إرشادات المجتمع وسياسة النزاهة الأكاديمية لـ CS Bouira.';

  @override
  String get uploadPickerOption => 'اختر ملفاً';

  @override
  String get uploadPickerSubtitle => 'تصفح جهاز التخزين';

  @override
  String get uploadScanOption => 'مسح ملف ضوئياً';

  @override
  String get uploadScanSubtitle => 'استخدم الكاميرا لمسح المستندات ضوئياً';

  @override
  String get uploadErrorNoInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get uploadErrorTimeout => 'انتهت مهلة الطلب';

  @override
  String get uploadErrorCancelled => 'تم إلغاء الرفع';

  @override
  String get uploadErrorFailed => 'فشل الرفع.';

  @override
  String get uploadRetry => 'إعادة المحاولة';

  @override
  String get uploadSuccessSingle => 'تم رفع المورد بنجاح.';

  @override
  String uploadSuccessMultiple(Object count) => 'تم رفع جميع الموارد $count بنجاح.';

  @override
  String get uploadSuccessTitle => 'شكراً لمساهمتك!';

  @override
  String get uploadSuccessUploadMore => 'رفع المزيد';

  @override
  String get uploadSuccessDone => 'تم';

  @override
  String uploadFileTooLarge(Object fileName, Object maxMB) => '$fileName يتجاوز حد $maxMB ميغابايت وتم تخطيه.';

  @override
  String get uploadScanError => 'تعذر قراءة المستند الممسوخ ضوئياً.';

  @override
  String get reviewTitle => 'مراجعة الملف';

  @override
  String reviewFileCounter(Object current, Object total) => '$current من $total';

  @override
  String get reviewRetake => 'إعادة / اختيار مجدداً';

  @override
  String get reviewUseThisFile => 'استخدام هذا الملف';

  @override
  String reviewApproveAll(Object remaining) => 'الموافقة على الكل ($remaining متبقي)';

  @override
  String get reviewPreviewNotAvailable => 'المعاينة غير متاحة';

  @override
  String get authTagline => 'مركز الموارد الأكاديمية لعلوم الحاسوب';

  @override
  String get authLoginToggle => 'تسجيل الدخول';

  @override
  String get authSignUpToggle => 'إنشاء حساب';

  @override
  String get authFieldFullName => 'الاسم الكامل';

  @override
  String get authFieldEmail => 'البريد الإلكتروني';

  @override
  String get authFieldPassword => 'كلمة المرور';

  @override
  String get authFieldConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get authSignUpButton => 'إنشاء حساب';

  @override
  String get authLoginButton => 'تسجيل الدخول';

  @override
  String get authOrDivider => 'أو';

  @override
  String get authGoogleButton => 'المتابعة مع Google';

  @override
  String get authAgreement => 'بالمتابعة، أنت توافق على شروط الخدمة وسياسة الخصوصية.';

  @override
  String get authValidationEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get authValidationEmailInvalid => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String get authValidationPasswordRequired => 'كلمة المرور مطلوبة';

  @override
  String get authValidationPasswordLength => 'يجب أن تتكون كلمة المرور من 8 أحرف على الأقل';

  @override
  String get authValidationPasswordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authValidationNameRequired => 'الاسم الكامل مطلوب';

  @override
  String get authSignupFailed => 'فشل إنشاء الحساب. حاول مرة أخرى.';

  @override
  String get authMergeDialogTitle => 'دمج المفضلة';

  @override
  String authMergeDialogMessage(num count) {
    if (count == 1) {
      return 'وجدنا $count عنصراً محفوظاً في مفضلتك المحلية. هل ترغب في إضافته إلى حسابك؟';
    }
    return 'وجدنا $count عناصر محفوظة في مفضلتك المحلية. هل ترغب في إضافتها إلى حسابك؟';
  }

  @override
  String get authMergeDialogSkip => 'تخطي';

  @override
  String get authMergeDialogMerge => 'دمج';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSubtitle => 'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين.';

  @override
  String get forgotPasswordFieldEmail => 'البريد الإلكتروني';

  @override
  String get forgotPasswordButton => 'إرسال رابط إعادة التعيين';

  @override
  String get forgotPasswordBackToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get forgotPasswordValidationEmailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get forgotPasswordValidationEmailInvalid => 'أدخل بريداً إلكترونياً صحيحاً';

  @override
  String get forgotPasswordSuccess => 'تحقق من بريدك الإلكتروني للحصول على رابط إعادة تعيين كلمة المرور.';

  @override
  String get forgotPasswordError => 'فشل إرسال بريد إعادة التعيين. حاول مرة أخرى.';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileGuestName => 'زائر';

  @override
  String get profileGuestBadge => 'زائر';

  @override
  String get profileEmailPlaceholder => 'أضف بريدك الإلكتروني';

  @override
  String get profileStatUploads => 'الرفع';

  @override
  String get profileStatFavorites => 'المفضلة';

  @override
  String get profileSettingMyUploads => 'رفوعاتي';

  @override
  String get profileSettingDownloads => 'التنزيلات';

  @override
  String get profileSettingFavorites => 'المفضلة';

  @override
  String get profileSettingLeaderboard => 'لوحة المتصدرين';

  @override
  String get profileSettingAbout => 'حول CS Bouira';

  @override
  String get profileGuestButton => 'تسجيل الدخول أو إنشاء حساب';

  @override
  String get profileEditNameTitle => 'تعديل الاسم';

  @override
  String get profileEditNameHint => 'أدخل اسمك';

  @override
  String get profileEditNameCancel => 'إلغاء';

  @override
  String get profileEditNameSave => 'حفظ';

  @override
  String get profileEditEmailTitle => 'تعديل البريد الإلكتروني';

  @override
  String get profileEditEmailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get profileLogoutTitle => 'تسجيل الخروج';

  @override
  String get profileLogoutMessage => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get profileLogoutConfirm => 'تسجيل الخروج';

  @override
  String get profileLanguage => 'اللغة';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageArabic => 'العربية';

  @override
  String get profileLanguageFrench => 'Français';

  @override
  String get myUploadsTitle => 'رفوعاتي';

  @override
  String get myUploadsEmpty => 'لا توجد رفوعات بعد';

  @override
  String get myUploadsEmptyHint => 'ستظهر الموارد التي رفعتها هنا.';

  @override
  String get downloadsTitle => 'التنزيلات';

  @override
  String get downloadsEmpty => 'لا توجد تنزيلات بعد';

  @override
  String get downloadsEmptyHint => 'ستظهر الملفات التي تم تنزيلها هنا.';

  @override
  String get downloadsOpenAction => 'فتح';

  @override
  String get downloadsDeleteAction => 'حذف';

  @override
  String get leaderboardTitle => 'لوحة المتصدرين';

  @override
  String get leaderboardHeader => 'أفضل المساهمين';

  @override
  String get leaderboardYourRank => 'ترتيبك';

  @override
  String get leaderboardNotRanked => 'لم يتم ترتيبك بعد';

  @override
  String get leaderboardEmpty => 'لا يوجد مساهمون بعد';

  @override
  String leaderboardUploadCount(num count) => '$count ${count == 1 ? 'رفع' : 'رفوعات'}';

  @override
  String get leaderboardPoints => 'نقاط';

  @override
  String get aboutTitle => 'حول CS Bouira';

  @override
  String get aboutVersion => 'الإصدار';

  @override
  String get aboutDescription => 'CS Bouira هي منصة لمشاركة الموارد الأكاديمية لطلاب علوم الحاسوب في جامعة البويرة.';

  @override
  String get aboutFeatures => 'الميزات';

  @override
  String get aboutFeatureBrowseResources => 'تصفح الموارد حسب السنة والفصل والوحدة';

  @override
  String get aboutFeatureSearch => 'البحث في جميع المواد الدراسية';

  @override
  String get aboutFeatureDownload => 'تحميل ومعاينة PDF والمستندات والصور';

  @override
  String get aboutFeatureUpload => 'رفع ومشاركة الموارد الأكاديمية';

  @override
  String get aboutFeatureBookmarks => 'حفظ المفضلة للوصول السريع';

  @override
  String get aboutFeatureQrCode => 'ماسح رمز QR للروابط الفورية';

  @override
  String get aboutFeatureOffline => 'الوصول دون اتصال للمواد التي تم تنزيلها';

  @override
  String get aboutCreator => 'المبتكر';

  @override
  String get aboutCreatorSalimZedDesc => 'المبتكر الأصلي لموقع و API CS Bouira';

  @override
  String get aboutCreatorAhmedAmineDesc => 'مطور تطبيق Android';

  @override
  String get aboutSourceCode => 'الكود المصدري';

  @override
  String get aboutSourceCodeGithub => 'مستودع GitHub';

  @override
  String get aboutSourceCodeReportIssue => 'الإبلاغ عن مشكلة';

  @override
  String get aboutContact => 'اتصل بنا';

  @override
  String get aboutLicense => 'الترخيص';

  @override
  String get aboutLicenseText => 'هذا التطبيق منشور تحت رخصة MIT.\n\nحقوق النشر © 2026 أحمد أمين. جميع الحقوق محفوظة.\n\nيُمنح الإذن لأي شخص يحصل على نسخة من هذا البرنامج وملفات الوثائق المرتبطة به للتعامل مع البرنامج دون قيود.';

  @override
  String get qrScannerTitle => 'مسح رمز QR';

  @override
  String get qrScannerInstruction => 'وجّه كاميرتك نحو رمز QR';

  @override
  String get qrScannerSuccess => 'تم مسح رمز QR!';

  @override
  String get qrScannerError => 'تعذر قراءة رمز QR';

  @override
  String get bottomNavHome => 'الرئيسية';

  @override
  String get bottomNavSearch => 'بحث';

  @override
  String get bottomNavFavs => 'المفضلة';

  @override
  String get bottomNavUpload => 'رفع';

  @override
  String get bottomNavProfile => 'الملف';

  @override
  String get networkReconnected => 'تمت إعادة الاتصال';

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
  String updateDialogBody(Object version) => 'الإصدار $version جاهز للتثبيت.';

  @override
  String get updateDialogUpdate => 'تحديث';

  @override
  String get updateDialogLater => 'لاحقاً';

  @override
  String get updateDialogDownloading => 'جاري تحميل التحديث...';

  @override
  String get updateDialogError => 'فشل تحميل التحديث.';
}

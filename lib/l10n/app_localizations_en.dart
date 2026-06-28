// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CS Bouira';

  @override
  String get appSubtitle => 'THE RESOURCE HUB';

  @override
  String get splashFooter => 'Department of Computer Science';

  @override
  String get pressBackAgain => 'Press back again to exit';

  @override
  String get failedToLoadData => 'Failed to load data';

  @override
  String get failedToLoadDataHint => 'Check your internet connection and try again.';

  @override
  String get failedToLoadDataAction => 'View Downloads';

  @override
  String get failedToLoadModules => 'Failed to load modules.';

  @override
  String get failedToLoadFiles => 'Failed to load files.';

  @override
  String get failedToLoadFavorites => 'Failed to load favorites.';

  @override
  String get failedToSearch => 'Failed to search.';

  @override
  String get noModulesFound => 'No modules found';

  @override
  String get noModulesAvailable => 'No modules available';

  @override
  String get noModulesMatchSearch => 'No modules match your search';

  @override
  String get folderNotFound => 'Folder not found';

  @override
  String get noMatchingFilesOrFolders => 'No matching files or folders';

  @override
  String get noFilesAvailable => 'No files available';

  @override
  String get searchFilesAndFolders => 'Search files and folders...';

  @override
  String get searchModules => 'Search modules...';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortByNameAZ => 'Name (A-Z)';

  @override
  String get sortByNameZA => 'Name (Z-A)';

  @override
  String get sortByType => 'Type';

  @override
  String get sortBySubfolders => 'Subfolders';

  @override
  String get sortByFiles => 'Files';

  @override
  String get folderEmpty => 'Empty';

  @override
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '$count item',
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
    return 'Welcome, $name';
  }

  @override
  String get homeSubtitle => 'Access all Computer Science resources from University of Bouira in one place.';

  @override
  String get homeSearchHint => 'Search courses, files, or exams...';

  @override
  String get academicPath => 'Academic Path';

  @override
  String get selectYear => 'SELECT YEAR';

  @override
  String fileCountOnYear(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '$count file',
    );
    return '$_temp0';
  }

  @override
  String get statsUsers => 'Users';

  @override
  String get statsFiles => 'Files';

  @override
  String get statsSpecials => 'Specials';

  @override
  String get newBadge => 'NEW';

  @override
  String academicYear(Object range) {
    return 'Academic Year $range';
  }

  @override
  String semesterSubtitle(Object year) {
    return 'Select a semester to access courses, tutorials, and academic materials for your $year.';
  }

  @override
  String moduleCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Modules',
      one: '$count Module',
    );
    return '$_temp0';
  }

  @override
  String get exploreResources => 'Explore Resources';

  @override
  String get booksAndExercices => 'Books & Exercices';

  @override
  String get semesterEmpty => 'Empty';

  @override
  String get onlineResourcesSubtitle => 'Access digital library and solved problem sets';

  @override
  String get onlineResources => 'ONLINE RESOURCES';

  @override
  String moduleBreadcrumb(Object year, Object semester) {
    return '$year / $semester';
  }

  @override
  String get activeModules => 'ACTIVE MODULES';

  @override
  String get allModules => 'All Modules';

  @override
  String get searchResults => 'Search Results';

  @override
  String totalCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Total',
      one: '$count Total',
    );
    return '$_temp0';
  }

  @override
  String folderFileBreakdown(num folders, num files) {
    String _temp0 = intl.Intl.pluralLogic(
      folders,
      locale: localeName,
      other: '$folders folders',
      one: '$folders folder',
    );
    String _temp1 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files files',
      one: '$files file',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String fileCount(num files) {
    String _temp0 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files files',
      one: '$files file',
    );
    return '$_temp0';
  }

  @override
  String get totalModules => 'Total Modules';

  @override
  String get totalFiles => 'Total Files';

  @override
  String get courseModuleBadge => 'Course Module';

  @override
  String folderFileCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Files',
      one: '$count File',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Search for modules, files...';

  @override
  String get searchFilterYear => 'Year';

  @override
  String get searchFilterSemester => 'Semester';

  @override
  String get searchFilterModule => 'Module';

  @override
  String get searchFilterType => 'Type';

  @override
  String get searchFilterClear => 'Clear';

  @override
  String get noOptionsAvailable => 'No options available';

  @override
  String get couldNotLoadFilters => 'Could not load filters. Check your connection.';

  @override
  String get searchResultModule => 'Module';

  @override
  String get searchResultFolder => 'Folder';

  @override
  String get searchResultFile => 'File';

  @override
  String get startExploring => 'Start Exploring';

  @override
  String get searchEmptyMessage => 'Search for modules, files, or topics\nacross the entire CS Bouira library.';

  @override
  String get topResults => 'Top Results';

  @override
  String itemsFound(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Items Found',
      one: '$count Item Found',
    );
    return '$_temp0';
  }

  @override
  String noResultsForQuery(Object query) {
    return 'No results for \"$query\"';
  }

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesSavedModules => 'Saved Modules';

  @override
  String get favoritesSavedFiles => 'Saved Files';

  @override
  String get favoritesOnlineResources => 'Online Resources';

  @override
  String favoritesTotal(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Total',
      one: '$count Total',
    );
    return '$_temp0';
  }

  @override
  String get favoritesTabModules => 'Modules';

  @override
  String get favoritesTabFiles => 'Files';

  @override
  String get favoritesTabResources => 'Resources';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get noModulesSaved => 'No modules saved';

  @override
  String get noModulesSavedHint => 'Star a module to save it here\nfor quick access.';

  @override
  String get noFilesSaved => 'No files saved';

  @override
  String get noFilesSavedHint => 'Star a file to save it here\nfor quick access.';

  @override
  String get noResourcesSaved => 'No resources saved';

  @override
  String get noResourcesSavedHint => 'Star an online resource to save it here\nfor quick access.';

  @override
  String get browseHome => 'Browse Home';

  @override
  String favoritesFileCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '$count file',
    );
    return '$_temp0';
  }

  @override
  String favoritesFolderCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count folders',
      one: '$count folder',
    );
    return '$_temp0';
  }

  @override
  String get viewModule => 'View Module';

  @override
  String get downloadingSnackbar => 'Downloading...';

  @override
  String downloadComplete(Object name) {
    return '\"$name\" downloaded';
  }

  @override
  String get viewAction => 'View';

  @override
  String downloadFailed(Object error) {
    return 'Download failed: $error';
  }

  @override
  String get couldNotOpenLink => 'Could not open link';

  @override
  String get previewMenuDownload => 'Download';

  @override
  String get previewMenuShareQr => 'Share QR';

  @override
  String get previewMenuOpenDrive => 'Open in Google Drive';

  @override
  String get tapToExitFullscreen => 'Tap to exit full screen';

  @override
  String get fileTypeLabel => 'File';

  @override
  String get uploadTitle => 'Share a Resource';

  @override
  String get uploadHeader => 'Contribute to Hub';

  @override
  String get uploadSubtitle => 'Help your fellow students by uploading verified academic materials.';

  @override
  String get uploadFieldFullName => 'FULL NAME';

  @override
  String get uploadFieldEmail => 'EMAIL ADDRESS';

  @override
  String get uploadCategorySection => 'RESOURCE CATEGORY';

  @override
  String get uploadGrade => 'GRADE';

  @override
  String get uploadSemester => 'SEMESTER';

  @override
  String get uploadModule => 'MODULE';

  @override
  String get uploadDropdownPlaceholder => 'Select';

  @override
  String get uploadFileSection => 'FILE ATTACHMENT';

  @override
  String get uploadChooseOrScan => 'Choose or Scan a File';

  @override
  String uploadAcceptedFormats(Object maxSize) {
    return 'PDF, DOCX, ZIP (Max ${maxSize}MB)';
  }

  @override
  String get uploadAddMoreFiles => 'Add more files';

  @override
  String uploadFileSelected(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files selected',
      one: '$count file selected',
    );
    return '$_temp0';
  }

  @override
  String get uploadButton => 'Upload Resource';

  @override
  String get uploading => 'Uploading…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Uploading $current of $total…';
  }

  @override
  String get cancelUpload => 'Cancel upload';

  @override
  String get uploadAgreement => 'By uploading, you agree to the community guidelines and academic integrity policy of CS Bouira.';

  @override
  String get uploadPickerOption => 'Choose a file';

  @override
  String get uploadPickerSubtitle => 'Browse device storage';

  @override
  String get uploadScanOption => 'Scan a file';

  @override
  String get uploadScanSubtitle => 'Use camera to scan documents';

  @override
  String get uploadErrorNoInternet => 'No internet connection';

  @override
  String get uploadErrorTimeout => 'Request timed out';

  @override
  String get uploadErrorCancelled => 'Upload cancelled';

  @override
  String get uploadErrorFailed => 'Upload failed.';

  @override
  String get uploadRetry => 'Retry';

  @override
  String get uploadSuccessSingle => 'Your resource has been uploaded successfully.';

  @override
  String uploadSuccessMultiple(Object count) {
    return 'All $count resources have been uploaded successfully.';
  }

  @override
  String get uploadSuccessTitle => 'Thank you for contributing!';

  @override
  String get uploadSuccessUploadMore => 'Upload more';

  @override
  String get uploadSuccessDone => 'Done';

  @override
  String uploadFileTooLarge(Object fileName, Object maxMB) {
    return '$fileName exceeds $maxMB MB limit and was skipped.';
  }

  @override
  String get uploadScanError => 'Could not read scanned document.';

  @override
  String get reviewTitle => 'Review File';

  @override
  String reviewFileCounter(Object current, Object total) {
    return '$current of $total';
  }

  @override
  String get reviewRetake => 'Retake / Choose Again';

  @override
  String get reviewUseThisFile => 'Use This File';

  @override
  String reviewApproveAll(Object remaining) {
    return 'Approve All ($remaining remaining)';
  }

  @override
  String get reviewPreviewNotAvailable => 'Preview not available';

  @override
  String get authTagline => 'The Academic Resource Hub for Computer Science';

  @override
  String get authLoginToggle => 'Log In';

  @override
  String get authSignUpToggle => 'Sign Up';

  @override
  String get authFieldFullName => 'Full Name';

  @override
  String get authFieldEmail => 'Email Address';

  @override
  String get authFieldPassword => 'Password';

  @override
  String get authFieldConfirmPassword => 'Confirm Password';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authSignUpButton => 'Sign Up';

  @override
  String get authLoginButton => 'Log In';

  @override
  String get authOrDivider => 'OR';

  @override
  String get authGoogleButton => 'Continue with Google';

  @override
  String get authAgreement => 'By continuing you agree to our Terms of Service and Privacy Policy.';

  @override
  String get authValidationEmailRequired => 'Email is required';

  @override
  String get authValidationEmailInvalid => 'Enter a valid email address';

  @override
  String get authValidationPasswordRequired => 'Password is required';

  @override
  String get authValidationPasswordLength => 'Password must be at least 8 characters';

  @override
  String get authValidationPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authValidationNameRequired => 'Full name is required';

  @override
  String get authSignupFailed => 'Signup failed. Please try again.';

  @override
  String get authMergeDialogTitle => 'Merge Favorites';

  @override
  String authMergeDialogMessage(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'We found $count items saved in your local favorites. Would you like to add them to your account?',
      one: 'We found $count item saved in your local favorites. Would you like to add them to your account?',
    );
    return '$_temp0';
  }

  @override
  String get authMergeDialogSkip => 'Skip';

  @override
  String get authMergeDialogMerge => 'Merge';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSubtitle => 'Enter your email address and we\'ll send you a reset link.';

  @override
  String get forgotPasswordFieldEmail => 'Email Address';

  @override
  String get forgotPasswordButton => 'Send Reset Link';

  @override
  String get forgotPasswordBackToLogin => 'Back to Login';

  @override
  String get forgotPasswordValidationEmailRequired => 'Email is required';

  @override
  String get forgotPasswordValidationEmailInvalid => 'Enter a valid email address';

  @override
  String get forgotPasswordSuccess => 'Check your email for the password reset link.';

  @override
  String get forgotPasswordError => 'Failed to send reset email. Please try again.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileGuestName => 'Guest';

  @override
  String get profileGuestBadge => 'GUEST';

  @override
  String get profileEmailPlaceholder => 'Add your email';

  @override
  String get profileStatUploads => 'UPLOADS';

  @override
  String get profileStatFavorites => 'FAVORITES';

  @override
  String get profileSettingMyUploads => 'My Uploads';

  @override
  String get profileSettingDownloads => 'Downloads';

  @override
  String get profileSettingFavorites => 'Favorites';

  @override
  String get profileSettingLeaderboard => 'Leaderboard';

  @override
  String get profileSettingAbout => 'About CS Bouira';

  @override
  String get profileGuestButton => 'Log In or Sign Up';

  @override
  String get profileEditNameTitle => 'Edit Name';

  @override
  String get profileEditNameHint => 'Enter your name';

  @override
  String get profileEditNameCancel => 'Cancel';

  @override
  String get profileEditNameSave => 'Save';

  @override
  String get profileEditEmailTitle => 'Edit Email';

  @override
  String get profileEditEmailHint => 'Enter your email';

  @override
  String get profileLogoutTitle => 'Log Out';

  @override
  String get profileLogoutMessage => 'Are you sure you want to log out?';

  @override
  String get profileLogoutConfirm => 'Log Out';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageArabic => 'العربية';

  @override
  String get profileLanguageFrench => 'Français';

  @override
  String get myUploadsTitle => 'My Uploads';

  @override
  String get myUploadsEmpty => 'No uploads yet';

  @override
  String get myUploadsEmptyHint => 'Your uploaded resources will appear here.';

  @override
  String get downloadsTitle => 'Downloads';

  @override
  String get downloadsEmpty => 'No downloads yet';

  @override
  String get downloadsEmptyHint => 'Downloaded files will appear here.';

  @override
  String get downloadsOpenAction => 'Open';

  @override
  String get downloadsDeleteAction => 'Delete';

  @override
  String get leaderboardTitle => 'Leaderboard';

  @override
  String get leaderboardHeader => 'Top Contributors';

  @override
  String get leaderboardYourRank => 'Your Rank';

  @override
  String get leaderboardNotRanked => 'Not ranked yet';

  @override
  String get leaderboardEmpty => 'No contributors yet';

  @override
  String leaderboardUploadCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count uploads',
      one: '$count upload',
    );
    return '$_temp0';
  }

  @override
  String get leaderboardPoints => 'points';

  @override
  String get aboutTitle => 'About CS Bouira';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutDescription => 'CS Bouira is an academic resource sharing platform for Computer Science students at the University of Bouira.';

  @override
  String get aboutFeatures => 'Features';

  @override
  String get aboutFeatureBrowseResources => 'Browse resources by year, semester, and module';

  @override
  String get aboutFeatureSearch => 'Search across all course materials';

  @override
  String get aboutFeatureDownload => 'Download and preview PDFs, documents, and images';

  @override
  String get aboutFeatureUpload => 'Upload and share academic resources';

  @override
  String get aboutFeatureBookmarks => 'Bookmark favorites for quick access';

  @override
  String get aboutFeatureQrCode => 'QR code scanner for instant resource links';

  @override
  String get aboutFeatureOffline => 'Offline access to downloaded materials';

  @override
  String get aboutCreator => 'Creator';

  @override
  String get aboutCreatorSalimZedDesc => 'Original creator of CS Bouira website & API';

  @override
  String get aboutCreatorAhmedAmineDesc => 'Android app developer';

  @override
  String get aboutSourceCode => 'Source Code';

  @override
  String get aboutSourceCodeGithub => 'GitHub Repository';

  @override
  String get aboutSourceCodeReportIssue => 'Report an Issue';

  @override
  String get aboutContact => 'Contact';

  @override
  String get aboutLicense => 'License';

  @override
  String get aboutLicenseText => 'This application is released under the MIT License.\n\nCopyright © 2026 Ahmed Amine. All rights reserved.\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files, to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software.';

  @override
  String get qrScannerTitle => 'Scan QR Code';

  @override
  String get qrScannerInstruction => 'Point your camera at a QR code';

  @override
  String get qrScannerSuccess => 'QR code scanned!';

  @override
  String get qrScannerError => 'Could not read QR code';

  @override
  String get bottomNavHome => 'Home';

  @override
  String get bottomNavSearch => 'Search';

  @override
  String get bottomNavFavs => 'Favs';

  @override
  String get bottomNavUpload => 'Upload';

  @override
  String get bottomNavProfile => 'Profile';

  @override
  String get networkReconnected => 'You\'re back online';

  @override
  String get networkOffline => 'No internet connection';

  @override
  String get deleteConfirm => 'Delete';

  @override
  String get deleteCancel => 'Cancel';

  @override
  String get fetchErrorFailedToLoad => 'Failed to load data';

  @override
  String get fetchErrorCheckConnection => 'Check your internet connection and try again.';

  @override
  String get fetchErrorViewDownloads => 'View Downloads';

  @override
  String get gradeLicence1 => 'Licence 1';

  @override
  String get gradeLicence2 => 'Licence 2';

  @override
  String get gradeLicence3Si => 'Licence 3 SI';

  @override
  String get gradeMaster1Gsi => 'Master 1 GSI';

  @override
  String get gradeMaster1Isil => 'Master 1 ISIL';

  @override
  String get gradeMaster1Ia => 'Master 1 IA';

  @override
  String get gradeMaster2Gsi => 'Master 2 GSI';

  @override
  String get gradeMaster2Isil => 'Master 2 ISIL';

  @override
  String get gradeMaster2Ia => 'Master 2 IA';

  @override
  String get levelBachelor => 'Bachelor';

  @override
  String get levelBachelorFinalYear => 'Bachelor Final Year';

  @override
  String get levelMaster => 'Master';

  @override
  String get downloadsBrowseFiles => 'Browse Files';

  @override
  String get updateDialogTitle => 'Update Available';

  @override
  String updateDialogBody(Object version) {
    return 'Version $version is ready to install.';
  }

  @override
  String get updateDialogUpdate => 'Update';

  @override
  String get updateDialogLater => 'Later';

  @override
  String get updateDialogDownloading => 'Downloading update...';

  @override
  String get updateDialogError => 'Failed to download update.';

  @override
  String updateBannerDownloading(Object progress) {
    return 'Downloading update... $progress%';
  }

  @override
  String get updateBannerReady => 'Update downloaded. Tap to install.';

  @override
  String get updateBannerError => 'Download failed. Tap to retry.';

  @override
  String get aboutCreatorSalimZed => 'Salim Zed';

  @override
  String get aboutCreatorAhmedAmine => 'Ahmed Amine';

  @override
  String get downloadsLoadError => 'Failed to load downloads.';

  @override
  String get downloadsNoAppToOpen => 'No app available to open this file type.';

  @override
  String get downloadsDeleteTitle => 'Delete Download';

  @override
  String downloadsDeleteMessage(Object name) {
    return 'Delete \"$name\" from your device?';
  }

  @override
  String downloadsDeletedSnackbar(Object name) {
    return '\"$name\" deleted';
  }

  @override
  String get aboutCheckUpdate => 'Check for updates';

  @override
  String get aboutCheckingUpdate => 'Checking for updates...';

  @override
  String get aboutNoUpdate => 'Your app is up to date.';

  @override
  String get qrFileNotFound => 'File not found';

  @override
  String get qrFileNotFoundHint => 'This file may have been moved or deleted.';

  @override
  String qrCameraError(Object error) {
    return 'Camera error: $error';
  }

  @override
  String get qrPermissionRequired => 'Camera Permission Required';

  @override
  String get qrPermissionHint => 'Camera access is needed to scan QR codes. Please enable it in your device settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get shareFileTitle => 'Share File';

  @override
  String get shareQrHint => 'Scan this QR code with the in-app scanner to open this file instantly.';

  @override
  String previewNotAvailableForExt(Object ext) {
    return 'No preview available for .$ext files.';
  }

  @override
  String get openInDrive => 'Open in Drive';

  @override
  String get extractFileIdError => 'Could not extract file ID from link.';

  @override
  String get failedToLoadPdf => 'Failed to load PDF';

  @override
  String get failedToLoadImage => 'Failed to load image';

  @override
  String get failedToDisplayImage => 'Failed to display image';

  @override
  String get forgotPasswordEmailNotRegistered => 'This email is not registered.';

  @override
  String get forgotPasswordOtpInvalidLength => 'Enter the full 6-digit code';

  @override
  String get forgotPasswordOtpInvalidCode => 'Invalid code. Please check and try again.';

  @override
  String get forgotPasswordValidationPasswordNumber => 'Password must contain a number';

  @override
  String get forgotPasswordOtpTitle => 'Verification';

  @override
  String get forgotPasswordNewPasswordTitle => 'New Password';

  @override
  String get forgotPasswordOtpHeadline => 'Verify your email';

  @override
  String get forgotPasswordOtpSubtitle => 'Enter the 6-digit code sent to ';

  @override
  String get forgotPasswordOtpPasteCode => 'Paste code';

  @override
  String get forgotPasswordOtpResend => 'Resend Code';

  @override
  String get forgotPasswordOtpVerify => 'Verify Code';

  @override
  String get forgotPasswordEmailHint => 'student@univ-bouira.dz';

  @override
  String get forgotPasswordCreateNewPassword => 'Create New Password';

  @override
  String get forgotPasswordNewPasswordSubtitle => 'Your new password must be different from previous used passwords.';

  @override
  String get forgotPasswordFieldNewPassword => 'New Password';

  @override
  String get forgotPasswordNewPasswordHint => 'Enter new password';

  @override
  String get forgotPasswordFieldConfirmPassword => 'Confirm New Password';

  @override
  String get forgotPasswordConfirmPasswordHint => 'Repeat new password';

  @override
  String get forgotPasswordRequirementMinChars => 'At least 8 characters';

  @override
  String get forgotPasswordRequirementNumber => 'Contains a number';

  @override
  String get forgotPasswordUpdateButton => 'Update Password';

  @override
  String get forgotPasswordNewPasswordStepSubtitle => 'Choose a new password for your account.';
}

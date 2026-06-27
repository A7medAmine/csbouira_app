import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// Application title used in splash and branding
  ///
  /// In en, this message translates to:
  /// **'CS Bouira'**
  String get appTitle;

  /// Subtitle shown on the splash screen
  ///
  /// In en, this message translates to:
  /// **'THE RESOURCE HUB'**
  String get appSubtitle;

  /// Footer text on the splash screen
  ///
  /// In en, this message translates to:
  /// **'Department of Computer Science'**
  String get splashFooter;

  /// Snackbar message when pressing back to exit the app
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackAgain;

  /// Generic fetch error title
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get failedToLoadData;

  /// Generic fetch error subtitle/hint
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get failedToLoadDataHint;

  /// Action button shown on generic fetch error
  ///
  /// In en, this message translates to:
  /// **'View Downloads'**
  String get failedToLoadDataAction;

  /// Error message when modules fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load modules.'**
  String get failedToLoadModules;

  /// Error message when files fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load files.'**
  String get failedToLoadFiles;

  /// Error message when favorites fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load favorites.'**
  String get failedToLoadFavorites;

  /// Error message when search fails
  ///
  /// In en, this message translates to:
  /// **'Failed to search.'**
  String get failedToSearch;

  /// Empty state when no modules exist
  ///
  /// In en, this message translates to:
  /// **'No modules found'**
  String get noModulesFound;

  /// Empty state when modules list is empty
  ///
  /// In en, this message translates to:
  /// **'No modules available'**
  String get noModulesAvailable;

  /// Empty state when search yields no modules
  ///
  /// In en, this message translates to:
  /// **'No modules match your search'**
  String get noModulesMatchSearch;

  /// Error when a folder is not found
  ///
  /// In en, this message translates to:
  /// **'Folder not found'**
  String get folderNotFound;

  /// Empty state when file/folder search yields no results
  ///
  /// In en, this message translates to:
  /// **'No matching files or folders'**
  String get noMatchingFilesOrFolders;

  /// Empty state when no files exist
  ///
  /// In en, this message translates to:
  /// **'No files available'**
  String get noFilesAvailable;

  /// Hint for file/folder search field
  ///
  /// In en, this message translates to:
  /// **'Search files and folders...'**
  String get searchFilesAndFolders;

  /// Hint for module search field
  ///
  /// In en, this message translates to:
  /// **'Search modules...'**
  String get searchModules;

  /// Title of the sort/filter bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// Sort option ascending alphabetically
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get sortByNameAZ;

  /// Sort option descending alphabetically
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get sortByNameZA;

  /// Sort option by type
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get sortByType;

  /// Filter option for subfolders
  ///
  /// In en, this message translates to:
  /// **'Subfolders'**
  String get sortBySubfolders;

  /// Filter option for files
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get sortByFiles;

  /// Empty state for a folder with no contents
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get folderEmpty;

  /// Count of items with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} item} other{{count} items}}'**
  String itemsCount(num count);

  /// Badge label for PDF file type
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get pdfBadge;

  /// Root breadcrumb label for Drive
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get breadcrumbDrive;

  /// Home screen title
  ///
  /// In en, this message translates to:
  /// **'CS BOUIRA'**
  String get homeTitle;

  /// Welcome message on home screen with user name interpolation
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String homeWelcome(Object name);

  /// Subtitle text on the home screen
  ///
  /// In en, this message translates to:
  /// **'Access all Computer Science resources from University of Bouira in one place.'**
  String get homeSubtitle;

  /// Search field hint on home screen
  ///
  /// In en, this message translates to:
  /// **'Search courses, files, or exams...'**
  String get homeSearchHint;

  /// Label for academic path section on home screen
  ///
  /// In en, this message translates to:
  /// **'Academic Path'**
  String get academicPath;

  /// Label prompting user to select a year on home screen
  ///
  /// In en, this message translates to:
  /// **'SELECT YEAR'**
  String get selectYear;

  /// File count shown on year cards with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} file} other{{count} files}}'**
  String fileCountOnYear(num count);

  /// Statistics label for user count
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get statsUsers;

  /// Statistics label for file count
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get statsFiles;

  /// Statistics label for special items
  ///
  /// In en, this message translates to:
  /// **'Specials'**
  String get statsSpecials;

  /// Badge indicating new content
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get newBadge;

  /// Current academic year displayed on semester screen
  ///
  /// In en, this message translates to:
  /// **'Academic Year 2025/2026'**
  String get academicYear;

  /// Subtitle on semester screen with year interpolation
  ///
  /// In en, this message translates to:
  /// **'Select a semester to access courses, tutorials, and academic materials for your {year}.'**
  String semesterSubtitle(Object year);

  /// Module count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} Module} other{{count} Modules}}'**
  String moduleCount(num count);

  /// Label for explore resources section
  ///
  /// In en, this message translates to:
  /// **'Explore Resources'**
  String get exploreResources;

  /// Label for books and exercises section
  ///
  /// In en, this message translates to:
  /// **'Books & Exercices'**
  String get booksAndExercices;

  /// Empty state on semester screen
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get semesterEmpty;

  /// Subtitle for online resources section
  ///
  /// In en, this message translates to:
  /// **'Access digital library and solved problem sets'**
  String get onlineResourcesSubtitle;

  /// Section header for online resources
  ///
  /// In en, this message translates to:
  /// **'ONLINE RESOURCES'**
  String get onlineResources;

  /// Breadcrumb showing year and semester on module screen
  ///
  /// In en, this message translates to:
  /// **'{year} / {semester}'**
  String moduleBreadcrumb(Object year, Object semester);

  /// Section header for active modules
  ///
  /// In en, this message translates to:
  /// **'ACTIVE MODULES'**
  String get activeModules;

  /// Label for all modules view
  ///
  /// In en, this message translates to:
  /// **'All Modules'**
  String get allModules;

  /// Label heading search results
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// Total count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} Total} other{{count} Total}}'**
  String totalCount(num count);

  /// Breakdown showing folder count and file count, both pluralized
  ///
  /// In en, this message translates to:
  /// **'{folders, plural, =1{{folders} folder} other{{folders} folders}} · {files, plural, =1{{files} file} other{{files} files}}'**
  String folderFileBreakdown(num folders, num files);

  /// File count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{files, plural, =1{{files} file} other{{files} files}}'**
  String fileCount(num files);

  /// Label for total modules stat
  ///
  /// In en, this message translates to:
  /// **'Total Modules'**
  String get totalModules;

  /// Label for total files stat
  ///
  /// In en, this message translates to:
  /// **'Total Files'**
  String get totalFiles;

  /// Badge label for course module type
  ///
  /// In en, this message translates to:
  /// **'Course Module'**
  String get courseModuleBadge;

  /// File count on folder screen with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} File} other{{count} Files}}'**
  String folderFileCount(num count);

  /// Hint text for the search screen field
  ///
  /// In en, this message translates to:
  /// **'Search for modules, files...'**
  String get searchHint;

  /// Filter label for year
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get searchFilterYear;

  /// Filter label for semester
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get searchFilterSemester;

  /// Filter label for module
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get searchFilterModule;

  /// Filter label for content type
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get searchFilterType;

  /// Action to clear search filters
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get searchFilterClear;

  /// Empty state for filter options dropdown
  ///
  /// In en, this message translates to:
  /// **'No options available'**
  String get noOptionsAvailable;

  /// Error message when filters fail to load
  ///
  /// In en, this message translates to:
  /// **'Could not load filters. Check your connection.'**
  String get couldNotLoadFilters;

  /// Label for module type in search results
  ///
  /// In en, this message translates to:
  /// **'Module'**
  String get searchResultModule;

  /// Label for folder type in search results
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get searchResultFolder;

  /// Label for file type in search results
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get searchResultFile;

  /// Empty state action on search screen
  ///
  /// In en, this message translates to:
  /// **'Start Exploring'**
  String get startExploring;

  /// Empty state message on search screen before any query
  ///
  /// In en, this message translates to:
  /// **'Search for modules, files, or topics\nacross the entire CS Bouira library.'**
  String get searchEmptyMessage;

  /// Section header for top search results
  ///
  /// In en, this message translates to:
  /// **'Top Results'**
  String get topResults;

  /// Search result count with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} Item Found} other{{count} Items Found}}'**
  String itemsFound(num count);

  /// Empty state when search yields no results
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noResultsForQuery(Object query);

  /// Screen title for favorites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// Tab label for saved modules in favorites
  ///
  /// In en, this message translates to:
  /// **'Saved Modules'**
  String get favoritesSavedModules;

  /// Tab label for saved files in favorites
  ///
  /// In en, this message translates to:
  /// **'Saved Files'**
  String get favoritesSavedFiles;

  /// Tab label for online resources in favorites
  ///
  /// In en, this message translates to:
  /// **'Online Resources'**
  String get favoritesOnlineResources;

  /// Total count on favorites screen with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} Total} other{{count} Total}}'**
  String favoritesTotal(num count);

  /// Compact tab label for modules
  ///
  /// In en, this message translates to:
  /// **'Modules'**
  String get favoritesTabModules;

  /// Compact tab label for files
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get favoritesTabFiles;

  /// Compact tab label for resources
  ///
  /// In en, this message translates to:
  /// **'Resources'**
  String get favoritesTabResources;

  /// Snackbar when an item is removed from favorites
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// Empty state for saved modules tab
  ///
  /// In en, this message translates to:
  /// **'No modules saved'**
  String get noModulesSaved;

  /// Hint text for empty saved modules
  ///
  /// In en, this message translates to:
  /// **'Star a module to save it here\nfor quick access.'**
  String get noModulesSavedHint;

  /// Empty state for saved files tab
  ///
  /// In en, this message translates to:
  /// **'No files saved'**
  String get noFilesSaved;

  /// Hint text for empty saved files
  ///
  /// In en, this message translates to:
  /// **'Star a file to save it here\nfor quick access.'**
  String get noFilesSavedHint;

  /// Empty state for saved resources tab
  ///
  /// In en, this message translates to:
  /// **'No resources saved'**
  String get noResourcesSaved;

  /// Hint text for empty saved resources
  ///
  /// In en, this message translates to:
  /// **'Star an online resource to save it here\nfor quick access.'**
  String get noResourcesSavedHint;

  /// Action button on favorites empty state to browse home
  ///
  /// In en, this message translates to:
  /// **'Browse Home'**
  String get browseHome;

  /// File count on favorites cards with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} file} other{{count} files}}'**
  String favoritesFileCount(num count);

  /// Folder count on favorites cards with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} folder} other{{count} folders}}'**
  String favoritesFolderCount(num count);

  /// Action to view a module from favorites
  ///
  /// In en, this message translates to:
  /// **'View Module'**
  String get viewModule;

  /// Snackbar message when a download starts
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloadingSnackbar;

  /// Snackbar message when a download completes with file name
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" downloaded'**
  String downloadComplete(Object name);

  /// Snackbar action button to view the downloaded file
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewAction;

  /// Snackbar message when download fails with error details
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String downloadFailed(Object error);

  /// Error message when a link cannot be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open link'**
  String get couldNotOpenLink;

  /// Popup menu option to download a file
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get previewMenuDownload;

  /// Popup menu option to share via QR code
  ///
  /// In en, this message translates to:
  /// **'Share QR'**
  String get previewMenuShareQr;

  /// Popup menu option to open in Google Drive
  ///
  /// In en, this message translates to:
  /// **'Open in Google Drive'**
  String get previewMenuOpenDrive;

  /// Hint to tap to exit full screen mode
  ///
  /// In en, this message translates to:
  /// **'Tap to exit full screen'**
  String get tapToExitFullscreen;

  /// Fallback label for file type
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get fileTypeLabel;

  /// App bar title for upload screen
  ///
  /// In en, this message translates to:
  /// **'Share a Resource'**
  String get uploadTitle;

  /// Header text on upload screen
  ///
  /// In en, this message translates to:
  /// **'Contribute to Hub'**
  String get uploadHeader;

  /// Subtitle text on upload screen
  ///
  /// In en, this message translates to:
  /// **'Help your fellow students by uploading verified academic materials.'**
  String get uploadSubtitle;

  /// Label for full name field on upload form
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get uploadFieldFullName;

  /// Label for email address field on upload form
  ///
  /// In en, this message translates to:
  /// **'EMAIL ADDRESS'**
  String get uploadFieldEmail;

  /// Section header for resource category fields
  ///
  /// In en, this message translates to:
  /// **'RESOURCE CATEGORY'**
  String get uploadCategorySection;

  /// Dropdown label for grade/year
  ///
  /// In en, this message translates to:
  /// **'GRADE'**
  String get uploadGrade;

  /// Dropdown label for semester
  ///
  /// In en, this message translates to:
  /// **'SEMESTER'**
  String get uploadSemester;

  /// Dropdown label for module
  ///
  /// In en, this message translates to:
  /// **'MODULE'**
  String get uploadModule;

  /// Placeholder text for dropdown fields
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get uploadDropdownPlaceholder;

  /// Section header for file attachment
  ///
  /// In en, this message translates to:
  /// **'FILE ATTACHMENT'**
  String get uploadFileSection;

  /// Label for file picker trigger
  ///
  /// In en, this message translates to:
  /// **'Choose or Scan a File'**
  String get uploadChooseOrScan;

  /// Accepted file formats and max size
  ///
  /// In en, this message translates to:
  /// **'PDF, DOCX, ZIP (Max {maxSize}MB)'**
  String uploadAcceptedFormats(Object maxSize);

  /// Button to add more files to the upload
  ///
  /// In en, this message translates to:
  /// **'Add more files'**
  String get uploadAddMoreFiles;

  /// File count selected for upload with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} file selected} other{{count} files selected}}'**
  String uploadFileSelected(num count);

  /// Primary upload button label
  ///
  /// In en, this message translates to:
  /// **'Upload Resource'**
  String get uploadButton;

  /// Upload in progress state
  ///
  /// In en, this message translates to:
  /// **'Uploading…'**
  String get uploading;

  /// Upload progress with current and total counts
  ///
  /// In en, this message translates to:
  /// **'Uploading {current} of {total}…'**
  String uploadingProgress(Object current, Object total);

  /// Button to cancel an ongoing upload
  ///
  /// In en, this message translates to:
  /// **'Cancel upload'**
  String get cancelUpload;

  /// Legal agreement text for uploads
  ///
  /// In en, this message translates to:
  /// **'By uploading, you agree to the community guidelines and academic integrity policy of CS Bouira.'**
  String get uploadAgreement;

  /// Option to pick a file from device storage
  ///
  /// In en, this message translates to:
  /// **'Choose a file'**
  String get uploadPickerOption;

  /// Subtitle for file picker option
  ///
  /// In en, this message translates to:
  /// **'Browse device storage'**
  String get uploadPickerSubtitle;

  /// Option to scan a file via camera
  ///
  /// In en, this message translates to:
  /// **'Scan a file'**
  String get uploadScanOption;

  /// Subtitle for scan option
  ///
  /// In en, this message translates to:
  /// **'Use camera to scan documents'**
  String get uploadScanSubtitle;

  /// Error when no internet connection during upload
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get uploadErrorNoInternet;

  /// Error when upload request times out
  ///
  /// In en, this message translates to:
  /// **'Request timed out'**
  String get uploadErrorTimeout;

  /// Error when upload is cancelled
  ///
  /// In en, this message translates to:
  /// **'Upload cancelled'**
  String get uploadErrorCancelled;

  /// Generic upload failure message
  ///
  /// In en, this message translates to:
  /// **'Upload failed.'**
  String get uploadErrorFailed;

  /// Action to retry upload after failure
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get uploadRetry;

  /// Success message after single file upload
  ///
  /// In en, this message translates to:
  /// **'Your resource has been uploaded successfully.'**
  String get uploadSuccessSingle;

  /// Success message after multiple file upload
  ///
  /// In en, this message translates to:
  /// **'All {count} resources have been uploaded successfully.'**
  String uploadSuccessMultiple(Object count);

  /// Success dialog title after upload
  ///
  /// In en, this message translates to:
  /// **'Thank you for contributing!'**
  String get uploadSuccessTitle;

  /// Button to upload more files after success
  ///
  /// In en, this message translates to:
  /// **'Upload more'**
  String get uploadSuccessUploadMore;

  /// Button to dismiss success dialog
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get uploadSuccessDone;

  /// Warning when a file exceeds size limit
  ///
  /// In en, this message translates to:
  /// **'{fileName} exceeds {maxMB} MB limit and was skipped.'**
  String uploadFileTooLarge(Object fileName, Object maxMB);

  /// Error when scanned document cannot be read
  ///
  /// In en, this message translates to:
  /// **'Could not read scanned document.'**
  String get uploadScanError;

  /// Title for the upload review screen
  ///
  /// In en, this message translates to:
  /// **'Review File'**
  String get reviewTitle;

  /// File counter showing current file index and total
  ///
  /// In en, this message translates to:
  /// **'{current} of {total}'**
  String reviewFileCounter(Object current, Object total);

  /// Button to retake or choose a different file
  ///
  /// In en, this message translates to:
  /// **'Retake / Choose Again'**
  String get reviewRetake;

  /// Button to confirm using the reviewed file
  ///
  /// In en, this message translates to:
  /// **'Use This File'**
  String get reviewUseThisFile;

  /// Button to approve all remaining files
  ///
  /// In en, this message translates to:
  /// **'Approve All ({remaining} remaining)'**
  String reviewApproveAll(Object remaining);

  /// Message when file preview is unavailable
  ///
  /// In en, this message translates to:
  /// **'Preview not available'**
  String get reviewPreviewNotAvailable;

  /// Tagline displayed on the auth screen
  ///
  /// In en, this message translates to:
  /// **'The Academic Resource Hub for Computer Science'**
  String get authTagline;

  /// Toggle to switch to login form
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get authLoginToggle;

  /// Toggle to switch to sign up form
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUpToggle;

  /// Label for full name field on auth form
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get authFieldFullName;

  /// Label for email field on auth form
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authFieldEmail;

  /// Label for password field on auth form
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authFieldPassword;

  /// Label for confirm password field on auth form
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authFieldConfirmPassword;

  /// Link to navigate to forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// Sign up submit button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUpButton;

  /// Log in submit button
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get authLoginButton;

  /// Divider text between email login and social login
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get authOrDivider;

  /// Button to sign in with Google
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authGoogleButton;

  /// Legal agreement text on auth screen
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our Terms of Service and Privacy Policy.'**
  String get authAgreement;

  /// Validation error when email is empty
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get authValidationEmailRequired;

  /// Validation error when email is invalid
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get authValidationEmailInvalid;

  /// Validation error when password is empty
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get authValidationPasswordRequired;

  /// Validation error when password is too short
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get authValidationPasswordLength;

  /// Validation error when password confirmation does not match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authValidationPasswordsDoNotMatch;

  /// Validation error when name is empty
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get authValidationNameRequired;

  /// Error message when sign up fails
  ///
  /// In en, this message translates to:
  /// **'Signup failed. Please try again.'**
  String get authSignupFailed;

  /// Title for merge favorites dialog on login
  ///
  /// In en, this message translates to:
  /// **'Merge Favorites'**
  String get authMergeDialogTitle;

  /// Message asking user to merge local favorites with account
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{We found {count} item saved in your local favorites. Would you like to add them to your account?} other{We found {count} items saved in your local favorites. Would you like to add them to your account?}}'**
  String authMergeDialogMessage(num count);

  /// Button to skip merging favorites
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get authMergeDialogSkip;

  /// Button to merge favorites
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get authMergeDialogMerge;

  /// Screen title for forgot password
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// Subtitle on forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a reset link.'**
  String get forgotPasswordSubtitle;

  /// Label for email field on forgot password form
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get forgotPasswordFieldEmail;

  /// Submit button on forgot password screen
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get forgotPasswordButton;

  /// Link to go back to login screen
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get forgotPasswordBackToLogin;

  /// Validation error when email is empty on forgot password
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get forgotPasswordValidationEmailRequired;

  /// Validation error when email is invalid on forgot password
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get forgotPasswordValidationEmailInvalid;

  /// Success message after sending reset link
  ///
  /// In en, this message translates to:
  /// **'Check your email for the password reset link.'**
  String get forgotPasswordSuccess;

  /// Error message when reset email fails to send
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset email. Please try again.'**
  String get forgotPasswordError;

  /// Screen title for profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Display name for guest users
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get profileGuestName;

  /// Badge label for guest status
  ///
  /// In en, this message translates to:
  /// **'GUEST'**
  String get profileGuestBadge;

  /// Placeholder shown when no email is set
  ///
  /// In en, this message translates to:
  /// **'Add your email'**
  String get profileEmailPlaceholder;

  /// Stat label for uploads count
  ///
  /// In en, this message translates to:
  /// **'UPLOADS'**
  String get profileStatUploads;

  /// Stat label for favorites count
  ///
  /// In en, this message translates to:
  /// **'FAVORITES'**
  String get profileStatFavorites;

  /// Settings row for my uploads
  ///
  /// In en, this message translates to:
  /// **'My Uploads'**
  String get profileSettingMyUploads;

  /// Settings row for downloads
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get profileSettingDownloads;

  /// Settings row for favorites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get profileSettingFavorites;

  /// Settings row for leaderboard
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get profileSettingLeaderboard;

  /// Settings row for about screen
  ///
  /// In en, this message translates to:
  /// **'About CS Bouira'**
  String get profileSettingAbout;

  /// Button for guest users to log in or sign up
  ///
  /// In en, this message translates to:
  /// **'Log In or Sign Up'**
  String get profileGuestButton;

  /// Dialog title for editing display name
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get profileEditNameTitle;

  /// Hint for edit name dialog field
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get profileEditNameHint;

  /// Cancel button on edit name dialog
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileEditNameCancel;

  /// Save button on edit name dialog
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profileEditNameSave;

  /// Dialog title for editing email
  ///
  /// In en, this message translates to:
  /// **'Edit Email'**
  String get profileEditEmailTitle;

  /// Hint for edit email dialog field
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get profileEditEmailHint;

  /// Dialog title for logout confirmation
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogoutTitle;

  /// Confirmation message for logout dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogoutMessage;

  /// Confirm button on logout dialog
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogoutConfirm;

  /// Settings row for language selection
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// Language option for English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEnglish;

  /// Language option for Arabic
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get profileLanguageArabic;

  /// Language option for French
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get profileLanguageFrench;

  /// Screen title for my uploads
  ///
  /// In en, this message translates to:
  /// **'My Uploads'**
  String get myUploadsTitle;

  /// Empty state for my uploads
  ///
  /// In en, this message translates to:
  /// **'No uploads yet'**
  String get myUploadsEmpty;

  /// Empty state hint for my uploads
  ///
  /// In en, this message translates to:
  /// **'Your uploaded resources will appear here.'**
  String get myUploadsEmptyHint;

  /// Screen title for downloads
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloadsTitle;

  /// Empty state for downloads
  ///
  /// In en, this message translates to:
  /// **'No downloads yet'**
  String get downloadsEmpty;

  /// Empty state hint for downloads
  ///
  /// In en, this message translates to:
  /// **'Downloaded files will appear here.'**
  String get downloadsEmptyHint;

  /// Action to open a downloaded file
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get downloadsOpenAction;

  /// Action to delete a downloaded file
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get downloadsDeleteAction;

  /// Screen title for leaderboard
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboardTitle;

  /// Header for top contributors section
  ///
  /// In en, this message translates to:
  /// **'Top Contributors'**
  String get leaderboardHeader;

  /// Label showing current user's rank
  ///
  /// In en, this message translates to:
  /// **'Your Rank'**
  String get leaderboardYourRank;

  /// Text when user is not ranked
  ///
  /// In en, this message translates to:
  /// **'Not ranked yet'**
  String get leaderboardNotRanked;

  /// Empty state for leaderboard
  ///
  /// In en, this message translates to:
  /// **'No contributors yet'**
  String get leaderboardEmpty;

  /// Upload count on leaderboard with pluralization
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} upload} other{{count} uploads}}'**
  String leaderboardUploadCount(num count);

  /// Label for points value
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get leaderboardPoints;

  /// Screen title for about
  ///
  /// In en, this message translates to:
  /// **'About CS Bouira'**
  String get aboutTitle;

  /// Label for app version
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// Description of the app on about screen
  ///
  /// In en, this message translates to:
  /// **'CS Bouira is an academic resource sharing platform for Computer Science students at the University of Bouira.'**
  String get aboutDescription;

  /// Section title for features on about screen
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get aboutFeatures;

  /// Feature: browse resources by academic structure
  ///
  /// In en, this message translates to:
  /// **'Browse resources by year, semester, and module'**
  String get aboutFeatureBrowseResources;

  /// Feature: search course materials
  ///
  /// In en, this message translates to:
  /// **'Search across all course materials'**
  String get aboutFeatureSearch;

  /// Feature: download and preview files
  ///
  /// In en, this message translates to:
  /// **'Download and preview PDFs, documents, and images'**
  String get aboutFeatureDownload;

  /// Feature: upload and share resources
  ///
  /// In en, this message translates to:
  /// **'Upload and share academic resources'**
  String get aboutFeatureUpload;

  /// Feature: bookmark favorites
  ///
  /// In en, this message translates to:
  /// **'Bookmark favorites for quick access'**
  String get aboutFeatureBookmarks;

  /// Feature: QR code scanner
  ///
  /// In en, this message translates to:
  /// **'QR code scanner for instant resource links'**
  String get aboutFeatureQrCode;

  /// Feature: offline access
  ///
  /// In en, this message translates to:
  /// **'Offline access to downloaded materials'**
  String get aboutFeatureOffline;

  /// Section title for creator on about screen
  ///
  /// In en, this message translates to:
  /// **'Creator'**
  String get aboutCreator;

  /// Description of Salim Zed's role
  ///
  /// In en, this message translates to:
  /// **'Original creator of CS Bouira website & API'**
  String get aboutCreatorSalimZedDesc;

  /// Description of Ahmed Amine's role
  ///
  /// In en, this message translates to:
  /// **'Android app developer'**
  String get aboutCreatorAhmedAmineDesc;

  /// Section title for source code on about screen
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get aboutSourceCode;

  /// Label for GitHub repository link
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository'**
  String get aboutSourceCodeGithub;

  /// Button to report an issue on GitHub
  ///
  /// In en, this message translates to:
  /// **'Report an Issue'**
  String get aboutSourceCodeReportIssue;

  /// Section title for contact on about screen
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get aboutContact;

  /// Section title for license on about screen
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutLicense;

  /// Full MIT License text
  ///
  /// In en, this message translates to:
  /// **'This application is released under the MIT License.\n\nCopyright © 2026 Ahmed Amine. All rights reserved.\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files, to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software.'**
  String get aboutLicenseText;

  /// Screen title for QR scanner
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get qrScannerTitle;

  /// Instruction text on QR scanner
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a QR code'**
  String get qrScannerInstruction;

  /// Success message when QR code is scanned
  ///
  /// In en, this message translates to:
  /// **'QR code scanned!'**
  String get qrScannerSuccess;

  /// Error when QR code cannot be read
  ///
  /// In en, this message translates to:
  /// **'Could not read QR code'**
  String get qrScannerError;

  /// Bottom navigation tab for home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottomNavHome;

  /// Bottom navigation tab for search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get bottomNavSearch;

  /// Bottom navigation tab for favorites
  ///
  /// In en, this message translates to:
  /// **'Favs'**
  String get bottomNavFavs;

  /// Bottom navigation tab for upload
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get bottomNavUpload;

  /// Bottom navigation tab for profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get bottomNavProfile;

  /// Banner message when internet reconnects
  ///
  /// In en, this message translates to:
  /// **'You\'re back online'**
  String get networkReconnected;

  /// Banner message when internet disconnects
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get networkOffline;

  /// Confirm action for delete dialogs
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteConfirm;

  /// Dismiss action for delete dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteCancel;

  /// Generic error message when data fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get fetchErrorFailedToLoad;

  /// Suggestion to check internet connection on error
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get fetchErrorCheckConnection;

  /// Button text to navigate to downloads page
  ///
  /// In en, this message translates to:
  /// **'View Downloads'**
  String get fetchErrorViewDownloads;

  /// No description provided for @gradeLicence1.
  ///
  /// In en, this message translates to:
  /// **'Licence 1'**
  String get gradeLicence1;

  /// No description provided for @gradeLicence2.
  ///
  /// In en, this message translates to:
  /// **'Licence 2'**
  String get gradeLicence2;

  /// No description provided for @gradeLicence3Si.
  ///
  /// In en, this message translates to:
  /// **'Licence 3 SI'**
  String get gradeLicence3Si;

  /// No description provided for @gradeMaster1Gsi.
  ///
  /// In en, this message translates to:
  /// **'Master 1 GSI'**
  String get gradeMaster1Gsi;

  /// No description provided for @gradeMaster1Isil.
  ///
  /// In en, this message translates to:
  /// **'Master 1 ISIL'**
  String get gradeMaster1Isil;

  /// No description provided for @gradeMaster1Ia.
  ///
  /// In en, this message translates to:
  /// **'Master 1 IA'**
  String get gradeMaster1Ia;

  /// No description provided for @gradeMaster2Gsi.
  ///
  /// In en, this message translates to:
  /// **'Master 2 GSI'**
  String get gradeMaster2Gsi;

  /// No description provided for @gradeMaster2Isil.
  ///
  /// In en, this message translates to:
  /// **'Master 2 ISIL'**
  String get gradeMaster2Isil;

  /// No description provided for @gradeMaster2Ia.
  ///
  /// In en, this message translates to:
  /// **'Master 2 IA'**
  String get gradeMaster2Ia;

  /// No description provided for @levelBachelor.
  ///
  /// In en, this message translates to:
  /// **'Bachelor'**
  String get levelBachelor;

  /// No description provided for @levelBachelorFinalYear.
  ///
  /// In en, this message translates to:
  /// **'Bachelor Final Year'**
  String get levelBachelorFinalYear;

  /// No description provided for @levelMaster.
  ///
  /// In en, this message translates to:
  /// **'Master'**
  String get levelMaster;

  /// No description provided for @downloadsBrowseFiles.
  ///
  /// In en, this message translates to:
  /// **'Browse Files'**
  String get downloadsBrowseFiles;

  /// Title for the update available dialog
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateDialogTitle;

  /// Body text for the update dialog showing the new version
  ///
  /// In en, this message translates to:
  /// **'Version {version} is ready to install.'**
  String updateDialogBody(Object version);

  /// Button to start the update
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateDialogUpdate;

  /// Button to dismiss the update dialog
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateDialogLater;

  /// Text shown while the update is downloading
  ///
  /// In en, this message translates to:
  /// **'Downloading update...'**
  String get updateDialogDownloading;

  /// Error message when update download fails
  ///
  /// In en, this message translates to:
  /// **'Failed to download update.'**
  String get updateDialogError;

  /// Background update banner progress message
  ///
  /// In en, this message translates to:
  /// **'Downloading update... {progress}%'**
  String updateBannerDownloading(Object progress);

  /// Background update banner completed message
  ///
  /// In en, this message translates to:
  /// **'Update downloaded. Tap to install.'**
  String get updateBannerReady;

  /// Background update banner error message
  ///
  /// In en, this message translates to:
  /// **'Download failed. Tap to retry.'**
  String get updateBannerError;

  /// Button to manually check for updates
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get aboutCheckUpdate;

  /// Loading text when checking for updates
  ///
  /// In en, this message translates to:
  /// **'Checking for updates...'**
  String get aboutCheckingUpdate;

  /// Message shown when no update is available
  ///
  /// In en, this message translates to:
  /// **'Your app is up to date.'**
  String get aboutNoUpdate;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

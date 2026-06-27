// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'CS Bouira';

  @override
  String get appSubtitle => 'LE CENTRE DE RESSOURCES';

  @override
  String get splashFooter => 'Département d\'Informatique';

  @override
  String get pressBackAgain => 'Appuyez à nouveau pour quitter';

  @override
  String get failedToLoadData => 'Échec du chargement des données';

  @override
  String get failedToLoadDataHint => 'Vérifiez votre connexion internet et réessayez.';

  @override
  String get failedToLoadDataAction => 'Voir les téléchargements';

  @override
  String get failedToLoadModules => 'Échec du chargement des modules.';

  @override
  String get failedToLoadFiles => 'Échec du chargement des fichiers.';

  @override
  String get failedToLoadFavorites => 'Échec du chargement des favoris.';

  @override
  String get failedToSearch => 'Échec de la recherche.';

  @override
  String get noModulesFound => 'Aucun module trouvé';

  @override
  String get noModulesAvailable => 'Aucun module disponible';

  @override
  String get noModulesMatchSearch => 'Aucun module ne correspond à votre recherche';

  @override
  String get folderNotFound => 'Dossier introuvable';

  @override
  String get noMatchingFilesOrFolders => 'Aucun fichier ou dossier correspondant';

  @override
  String get noFilesAvailable => 'Aucun fichier disponible';

  @override
  String get searchFilesAndFolders => 'Rechercher fichiers et dossiers...';

  @override
  String get searchModules => 'Rechercher modules...';

  @override
  String get sortBy => 'Trier par';

  @override
  String get sortByNameAZ => 'Nom (A-Z)';

  @override
  String get sortByNameZA => 'Nom (Z-A)';

  @override
  String get sortByType => 'Type';

  @override
  String get sortBySubfolders => 'Sous-dossiers';

  @override
  String get sortByFiles => 'Fichiers';

  @override
  String get folderEmpty => 'Vide';

  @override
  String itemsCount(num count) => '$count ${count == 1 ? 'élément' : 'éléments'}';

  @override
  String get pdfBadge => 'PDF';

  @override
  String get breadcrumbDrive => 'Drive';

  @override
  String get homeTitle => 'CS BOUIRA';

  @override
  String homeWelcome(Object name) => 'Bienvenue, $name';

  @override
  String get homeSubtitle => 'Accédez à toutes les ressources informatiques de l\'Université de Bouira en un seul endroit.';

  @override
  String get homeSearchHint => 'Rechercher cours, fichiers ou examens...';

  @override
  String get academicPath => 'Parcours Académique';

  @override
  String get selectYear => 'SÉLECTIONNER';

  @override
  String fileCountOnYear(num count) => '$count ${count == 1 ? 'fichier' : 'fichiers'}';

  @override
  String get statsUsers => 'Utilisateurs';

  @override
  String get statsFiles => 'Fichiers';

  @override
  String get statsSpecials => 'Spéciaux';

  @override
  String get newBadge => 'NOUVEAU';

  @override
  String get academicYear => 'Année Académique 2025/2026';

  @override
  String semesterSubtitle(Object year) => 'Sélectionnez un semestre pour accéder aux cours, travaux dirigés et matériels académiques pour votre $year.';

  @override
  String moduleCount(num count) => '$count ${count == 1 ? 'Module' : 'Modules'}';

  @override
  String get exploreResources => 'Explorer les Ressources';

  @override
  String get booksAndExercices => 'Livres & Exercices';

  @override
  String get semesterEmpty => 'Vide';

  @override
  String get onlineResourcesSubtitle => 'Accédez à la bibliothèque numérique et aux séries d\'exercices corrigés';

  @override
  String get onlineResources => 'RESSOURCES EN LIGNE';

  @override
  String moduleBreadcrumb(Object year, Object semester) => '$year / $semester';

  @override
  String get activeModules => 'MODULES ACTIFS';

  @override
  String get allModules => 'Tous les Modules';

  @override
  String get searchResults => 'Résultats de recherche';

  @override
  String totalCount(num count) => '$count Total';

  @override
  String folderFileBreakdown(num folders, num files) {
    final f = '$folders ${folders == 1 ? 'dossier' : 'dossiers'}';
    final fi = '$files ${files == 1 ? 'fichier' : 'fichiers'}';
    return '$f · $fi';
  }

  @override
  String fileCount(num files) => '$files ${files == 1 ? 'fichier' : 'fichiers'}';

  @override
  String get totalModules => 'Total Modules';

  @override
  String get totalFiles => 'Total Fichiers';

  @override
  String get courseModuleBadge => 'Module de Cours';

  @override
  String folderFileCount(num count) => '$count ${count == 1 ? 'Fichier' : 'Fichiers'}';

  @override
  String get searchHint => 'Rechercher modules, fichiers...';

  @override
  String get searchFilterYear => 'Année';

  @override
  String get searchFilterSemester => 'Semestre';

  @override
  String get searchFilterModule => 'Module';

  @override
  String get searchFilterType => 'Type';

  @override
  String get searchFilterClear => 'Effacer';

  @override
  String get noOptionsAvailable => 'Aucune option disponible';

  @override
  String get couldNotLoadFilters => 'Impossible de charger les filtres. Vérifiez votre connexion.';

  @override
  String get searchResultModule => 'Module';

  @override
  String get searchResultFolder => 'Dossier';

  @override
  String get searchResultFile => 'Fichier';

  @override
  String get startExploring => 'Commencer l\'exploration';

  @override
  String get searchEmptyMessage => 'Recherchez des modules, fichiers ou sujets\ndans toute la bibliothèque CS Bouira.';

  @override
  String get topResults => 'Meilleurs résultats';

  @override
  String itemsFound(num count) => '$count ${count == 1 ? 'élément trouvé' : 'éléments trouvés'}';

  @override
  String noResultsForQuery(Object query) => 'Aucun résultat pour "$query"';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get favoritesSavedModules => 'Modules sauvegardés';

  @override
  String get favoritesSavedFiles => 'Fichiers sauvegardés';

  @override
  String get favoritesOnlineResources => 'Ressources en ligne';

  @override
  String favoritesTotal(num count) => '$count Total';

  @override
  String get favoritesTabModules => 'Modules';

  @override
  String get favoritesTabFiles => 'Fichiers';

  @override
  String get favoritesTabResources => 'Ressources';

  @override
  String get removedFromFavorites => 'Retiré des favoris';

  @override
  String get noModulesSaved => 'Aucun module sauvegardé';

  @override
  String get noModulesSavedHint => 'Marquez un module d\'une étoile pour le sauvegarder\npour un accès rapide.';

  @override
  String get noFilesSaved => 'Aucun fichier sauvegardé';

  @override
  String get noFilesSavedHint => 'Marquez un fichier d\'une étoile pour le sauvegarder\npour un accès rapide.';

  @override
  String get noResourcesSaved => 'Aucune ressource sauvegardée';

  @override
  String get noResourcesSavedHint => 'Marquez une ressource en ligne d\'une étoile\npour la sauvegarder pour un accès rapide.';

  @override
  String get browseHome => 'Parcourir l\'accueil';

  @override
  String favoritesFileCount(num count) => '$count ${count == 1 ? 'fichier' : 'fichiers'}';

  @override
  String favoritesFolderCount(num count) => '$count ${count == 1 ? 'dossier' : 'dossiers'}';

  @override
  String get viewModule => 'Voir le module';

  @override
  String get downloadingSnackbar => 'Téléchargement...';

  @override
  String downloadComplete(Object name) => '"$name" téléchargé';

  @override
  String get viewAction => 'Voir';

  @override
  String downloadFailed(Object error) => 'Échec du téléchargement : $error';

  @override
  String get couldNotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get previewMenuDownload => 'Télécharger';

  @override
  String get previewMenuShareQr => 'Partager QR';

  @override
  String get previewMenuOpenDrive => 'Ouvrir dans Google Drive';

  @override
  String get tapToExitFullscreen => 'Appuyez pour quitter le plein écran';

  @override
  String get fileTypeLabel => 'Fichier';

  @override
  String get uploadTitle => 'Partager une ressource';

  @override
  String get uploadHeader => 'Contribuer au Hub';

  @override
  String get uploadSubtitle => 'Aidez vos camarades en téléchargeant des ressources académiques vérifiées.';

  @override
  String get uploadFieldFullName => 'NOM COMPLET';

  @override
  String get uploadFieldEmail => 'ADRESSE EMAIL';

  @override
  String get uploadCategorySection => 'CATÉGORIE DE RESSOURCE';

  @override
  String get uploadGrade => 'NIVEAU';

  @override
  String get uploadSemester => 'SEMESTRE';

  @override
  String get uploadModule => 'MODULE';

  @override
  String get uploadDropdownPlaceholder => 'Sélectionner';

  @override
  String get uploadFileSection => 'PIÈCE JOINTE';

  @override
  String get uploadChooseOrScan => 'Choisir ou numériser un fichier';

  @override
  String uploadAcceptedFormats(Object maxSize) => 'PDF, DOCX, ZIP (Max $maxSize Mo)';

  @override
  String get uploadAddMoreFiles => 'Ajouter d\'autres fichiers';

  @override
  String uploadFileSelected(num count) => '$count ${count == 1 ? 'fichier sélectionné' : 'fichiers sélectionnés'}';

  @override
  String get uploadButton => 'Télécharger la ressource';

  @override
  String get uploading => 'Téléchargement…';

  @override
  String uploadingProgress(Object current, Object total) => 'Téléchargement $current sur $total…';

  @override
  String get cancelUpload => 'Annuler le téléchargement';

  @override
  String get uploadAgreement => 'En téléchargeant, vous acceptez les directives communautaires et la politique d\'intégrité académique de CS Bouira.';

  @override
  String get uploadPickerOption => 'Choisir un fichier';

  @override
  String get uploadPickerSubtitle => 'Parcourir le stockage de l\'appareil';

  @override
  String get uploadScanOption => 'Numériser un fichier';

  @override
  String get uploadScanSubtitle => 'Utiliser la caméra pour numériser des documents';

  @override
  String get uploadErrorNoInternet => 'Pas de connexion internet';

  @override
  String get uploadErrorTimeout => 'La demande a expiré';

  @override
  String get uploadErrorCancelled => 'Téléchargement annulé';

  @override
  String get uploadErrorFailed => 'Échec du téléchargement.';

  @override
  String get uploadRetry => 'Réessayer';

  @override
  String get uploadSuccessSingle => 'Votre ressource a été téléchargée avec succès.';

  @override
  String uploadSuccessMultiple(Object count) => 'Les $count ressources ont été téléchargées avec succès.';

  @override
  String get uploadSuccessTitle => 'Merci pour votre contribution !';

  @override
  String get uploadSuccessUploadMore => 'Télécharger plus';

  @override
  String get uploadSuccessDone => 'Terminé';

  @override
  String uploadFileTooLarge(Object fileName, Object maxMB) => '$fileName dépasse la limite de $maxMB Mo et a été ignoré.';

  @override
  String get uploadScanError => 'Impossible de lire le document numérisé.';

  @override
  String get reviewTitle => 'Vérifier le fichier';

  @override
  String reviewFileCounter(Object current, Object total) => '$current sur $total';

  @override
  String get reviewRetake => 'Reprendre / Choisir à nouveau';

  @override
  String get reviewUseThisFile => 'Utiliser ce fichier';

  @override
  String reviewApproveAll(Object remaining) => 'Tout approuver ($remaining restant)';

  @override
  String get reviewPreviewNotAvailable => 'Aperçu non disponible';

  @override
  String get authTagline => 'Le centre de ressources académiques pour l\'Informatique';

  @override
  String get authLoginToggle => 'Connexion';

  @override
  String get authSignUpToggle => 'Inscription';

  @override
  String get authFieldFullName => 'Nom complet';

  @override
  String get authFieldEmail => 'Adresse email';

  @override
  String get authFieldPassword => 'Mot de passe';

  @override
  String get authFieldConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authSignUpButton => 'Inscription';

  @override
  String get authLoginButton => 'Connexion';

  @override
  String get authOrDivider => 'OU';

  @override
  String get authGoogleButton => 'Continuer avec Google';

  @override
  String get authAgreement => 'En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.';

  @override
  String get authValidationEmailRequired => 'L\'email est requis';

  @override
  String get authValidationEmailInvalid => 'Entrez une adresse email valide';

  @override
  String get authValidationPasswordRequired => 'Le mot de passe est requis';

  @override
  String get authValidationPasswordLength => 'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get authValidationPasswordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get authValidationNameRequired => 'Le nom complet est requis';

  @override
  String get authSignupFailed => 'Échec de l\'inscription. Veuillez réessayer.';

  @override
  String get authMergeDialogTitle => 'Fusionner les favoris';

  @override
  String authMergeDialogMessage(num count) {
    if (count == 1) {
      return 'Nous avons trouvé $count élément dans vos favoris locaux. Souhaitez-vous l\'ajouter à votre compte ?';
    }
    return 'Nous avons trouvé $count éléments dans vos favoris locaux. Souhaitez-vous les ajouter à votre compte ?';
  }

  @override
  String get authMergeDialogSkip => 'Ignorer';

  @override
  String get authMergeDialogMerge => 'Fusionner';

  @override
  String get forgotPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get forgotPasswordSubtitle => 'Entrez votre adresse email et nous vous enverrons un lien de réinitialisation.';

  @override
  String get forgotPasswordFieldEmail => 'Adresse email';

  @override
  String get forgotPasswordButton => 'Envoyer le lien';

  @override
  String get forgotPasswordBackToLogin => 'Retour à la connexion';

  @override
  String get forgotPasswordValidationEmailRequired => 'L\'email est requis';

  @override
  String get forgotPasswordValidationEmailInvalid => 'Entrez une adresse email valide';

  @override
  String get forgotPasswordSuccess => 'Vérifiez votre email pour le lien de réinitialisation.';

  @override
  String get forgotPasswordError => 'Échec de l\'envoi de l\'email. Veuillez réessayer.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileGuestName => 'Invité';

  @override
  String get profileGuestBadge => 'INVITÉ';

  @override
  String get profileEmailPlaceholder => 'Ajouter votre email';

  @override
  String get profileStatUploads => 'TÉLÉCHARGEMENTS';

  @override
  String get profileStatFavorites => 'FAVORIS';

  @override
  String get profileSettingMyUploads => 'Mes téléchargements';

  @override
  String get profileSettingDownloads => 'Téléchargements';

  @override
  String get profileSettingFavorites => 'Favoris';

  @override
  String get profileSettingLeaderboard => 'Classement';

  @override
  String get profileSettingAbout => 'À propos de CS Bouira';

  @override
  String get profileGuestButton => 'Connexion ou inscription';

  @override
  String get profileEditNameTitle => 'Modifier le nom';

  @override
  String get profileEditNameHint => 'Entrez votre nom';

  @override
  String get profileEditNameCancel => 'Annuler';

  @override
  String get profileEditNameSave => 'Enregistrer';

  @override
  String get profileEditEmailTitle => 'Modifier l\'email';

  @override
  String get profileEditEmailHint => 'Entrez votre email';

  @override
  String get profileLogoutTitle => 'Déconnexion';

  @override
  String get profileLogoutMessage => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get profileLogoutConfirm => 'Déconnexion';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageArabic => 'العربية';

  @override
  String get profileLanguageFrench => 'Français';

  @override
  String get myUploadsTitle => 'Mes téléchargements';

  @override
  String get myUploadsEmpty => 'Aucun téléchargement pour l\'instant';

  @override
  String get myUploadsEmptyHint => 'Vos ressources téléchargées apparaîtront ici.';

  @override
  String get downloadsTitle => 'Téléchargements';

  @override
  String get downloadsEmpty => 'Aucun téléchargement pour l\'instant';

  @override
  String get downloadsEmptyHint => 'Les fichiers téléchargés apparaîtront ici.';

  @override
  String get downloadsOpenAction => 'Ouvrir';

  @override
  String get downloadsDeleteAction => 'Supprimer';

  @override
  String get leaderboardTitle => 'Classement';

  @override
  String get leaderboardHeader => 'Meilleurs contributeurs';

  @override
  String get leaderboardYourRank => 'Votre rang';

  @override
  String get leaderboardNotRanked => 'Pas encore classé';

  @override
  String get leaderboardEmpty => 'Aucun contributeur pour l\'instant';

  @override
  String leaderboardUploadCount(num count) => '$count ${count == 1 ? 'téléchargement' : 'téléchargements'}';

  @override
  String get leaderboardPoints => 'points';

  @override
  String get aboutTitle => 'À propos de CS Bouira';

  @override
  String get aboutVersion => 'Version';

  @override
  String get aboutDescription => 'CS Bouira est une plateforme de partage de ressources académiques pour les étudiants en Informatique de l\'Université de Bouira.';

  @override
  String get aboutFeatures => 'Fonctionnalités';

  @override
  String get aboutFeatureBrowseResources => 'Parcourir les ressources par année, semestre et module';

  @override
  String get aboutFeatureSearch => 'Rechercher dans tous les supports de cours';

  @override
  String get aboutFeatureDownload => 'Télécharger et prévisualiser des PDF, documents et images';

  @override
  String get aboutFeatureUpload => 'Télécharger et partager des ressources académiques';

  @override
  String get aboutFeatureBookmarks => 'Marquer les favoris pour un accès rapide';

  @override
  String get aboutFeatureQrCode => 'Scanner de code QR pour des liens instantanés';

  @override
  String get aboutFeatureOffline => 'Accès hors ligne aux documents téléchargés';

  @override
  String get aboutCreator => 'Créateur';

  @override
  String get aboutCreatorSalimZedDesc => 'Créateur original du site web et de l\'API CS Bouira';

  @override
  String get aboutCreatorAhmedAmineDesc => 'Développeur de l\'application Android';

  @override
  String get aboutSourceCode => 'Code source';

  @override
  String get aboutSourceCodeGithub => 'Dépôt GitHub';

  @override
  String get aboutSourceCodeReportIssue => 'Signaler un problème';

  @override
  String get aboutContact => 'Contact';

  @override
  String get aboutLicense => 'Licence';

  @override
  String get aboutLicenseText => 'Cette application est publiée sous licence MIT.\n\nCopyright © 2026 Ahmed Amine. Tous droits réservés.\n\nPermission est accordée, gratuitement, à toute personne obtenant une copie de ce logiciel et des fichiers de documentation associés, de traiter le logiciel sans restriction.';

  @override
  String get qrScannerTitle => 'Scanner le code QR';

  @override
  String get qrScannerInstruction => 'Pointez votre appareil photo vers un code QR';

  @override
  String get qrScannerSuccess => 'Code QR scanné !';

  @override
  String get qrScannerError => 'Impossible de lire le code QR';

  @override
  String get bottomNavHome => 'Accueil';

  @override
  String get bottomNavSearch => 'Recherche';

  @override
  String get bottomNavFavs => 'Favoris';

  @override
  String get bottomNavUpload => 'Upload';

  @override
  String get bottomNavProfile => 'Profil';

  @override
  String get networkReconnected => 'Vous êtes de nouveau en ligne';

  @override
  String get networkOffline => 'Pas de connexion internet';

  @override
  String get deleteConfirm => 'Supprimer';

  @override
  String get deleteCancel => 'Annuler';

  @override
  String get fetchErrorFailedToLoad => 'Échec du chargement des données';

  @override
  String get fetchErrorCheckConnection => 'Vérifiez votre connexion internet et réessayez.';

  @override
  String get fetchErrorViewDownloads => 'Voir les téléchargements';

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
  String get levelBachelor => 'Licence';

  @override
  String get levelBachelorFinalYear => 'Licence (dernière année)';

  @override
  String get levelMaster => 'Master';

  @override
  String get downloadsBrowseFiles => 'Parcourir les fichiers';

  @override
  String get updateDialogTitle => 'Mise à jour disponible';

  @override
  String updateDialogBody(Object version) => 'La version $version est prête à être installée.';

  @override
  String get updateDialogUpdate => 'Mettre à jour';

  @override
  String get updateDialogLater => 'Plus tard';

  @override
  String get updateDialogDownloading => 'Téléchargement...';

  @override
  String get updateDialogError => 'Échec du téléchargement.';
}

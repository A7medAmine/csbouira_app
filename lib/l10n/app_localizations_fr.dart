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
  String get appSubtitle => 'LE PORTAIL DES RESSOURCES';

  @override
  String get splashFooter => 'Département d\'Informatique';

  @override
  String get pressBackAgain => 'Appuyez à nouveau sur retour pour quitter';

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
  String get searchFilesAndFolders => 'Rechercher des fichiers et dossiers...';

  @override
  String get searchModules => 'Rechercher des modules...';

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
  String itemsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '$count élément',
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
    return 'Bienvenue, $name';
  }

  @override
  String get homeSubtitle => 'Accédez à toutes les ressources d\'Informatique de l\'Université de Bouira en un seul endroit.';

  @override
  String get homeSearchHint => 'Rechercher des cours, fichiers ou examens...';

  @override
  String get academicPath => 'Parcours académique';

  @override
  String get selectYear => 'SÉLECTIONNER L\'ANNÉE';

  @override
  String fileCountOnYear(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers',
      one: '$count fichier',
    );
    return '$_temp0';
  }

  @override
  String get statsUsers => 'Utilisateurs';

  @override
  String get statsFiles => 'Fichiers';

  @override
  String get statsSpecials => 'Spéciaux';

  @override
  String get newBadge => 'NOUVEAU';

  @override
  String get academicYear => 'Année universitaire 2025/2026';

  @override
  String semesterSubtitle(Object year) {
    return 'Sélectionnez un semestre pour accéder aux cours, travaux dirigés et supports pédagogiques de votre $year.';
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
  String get exploreResources => 'Explorer les ressources';

  @override
  String get booksAndExercices => 'Livres et exercices';

  @override
  String get semesterEmpty => 'Vide';

  @override
  String get onlineResourcesSubtitle => 'Accédez à la bibliothèque numérique et aux séries d\'exercices corrigées';

  @override
  String get onlineResources => 'RESSOURCES EN LIGNE';

  @override
  String moduleBreadcrumb(Object year, Object semester) {
    return '$year / $semester';
  }

  @override
  String get activeModules => 'MODULES ACTIFS';

  @override
  String get allModules => 'Tous les modules';

  @override
  String get searchResults => 'Résultats de recherche';

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
      other: '$folders dossiers',
      one: '$folders dossier',
    );
    String _temp1 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files fichiers',
      one: '$files fichier',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String fileCount(num files) {
    String _temp0 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files fichiers',
      one: '$files fichier',
    );
    return '$_temp0';
  }

  @override
  String get totalModules => 'Total des modules';

  @override
  String get totalFiles => 'Total des fichiers';

  @override
  String get courseModuleBadge => 'Module de cours';

  @override
  String folderFileCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fichiers',
      one: '$count Fichier',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Rechercher des modules, fichiers...';

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
  String get startExploring => 'Commencer à explorer';

  @override
  String get searchEmptyMessage => 'Recherchez des modules, fichiers ou sujets\ndans toute la bibliothèque CS Bouira.';

  @override
  String get topResults => 'Meilleurs résultats';

  @override
  String itemsFound(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Éléments trouvés',
      one: '$count Élément trouvé',
    );
    return '$_temp0';
  }

  @override
  String noResultsForQuery(Object query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get favoritesSavedModules => 'Modules enregistrés';

  @override
  String get favoritesSavedFiles => 'Fichiers enregistrés';

  @override
  String get favoritesOnlineResources => 'Ressources en ligne';

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
  String get favoritesTabFiles => 'Fichiers';

  @override
  String get favoritesTabResources => 'Ressources';

  @override
  String get removedFromFavorites => 'Retiré des favoris';

  @override
  String get noModulesSaved => 'Aucun module enregistré';

  @override
  String get noModulesSavedHint => 'Ajoutez un module à vos favoris pour le retrouver\nrapidement ici.';

  @override
  String get noFilesSaved => 'Aucun fichier enregistré';

  @override
  String get noFilesSavedHint => 'Ajoutez un fichier à vos favoris pour le retrouver\nrapidement ici.';

  @override
  String get noResourcesSaved => 'Aucune ressource enregistrée';

  @override
  String get noResourcesSavedHint => 'Ajoutez une ressource en ligne à vos favoris pour la retrouver\nrapidement ici.';

  @override
  String get browseHome => 'Parcourir l\'accueil';

  @override
  String favoritesFileCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers',
      one: '$count fichier',
    );
    return '$_temp0';
  }

  @override
  String favoritesFolderCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dossiers',
      one: '$count dossier',
    );
    return '$_temp0';
  }

  @override
  String get viewModule => 'Voir le module';

  @override
  String get downloadingSnackbar => 'Téléchargement...';

  @override
  String downloadComplete(Object name) {
    return '« $name » téléchargé';
  }

  @override
  String get viewAction => 'Voir';

  @override
  String downloadFailed(Object error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String get couldNotOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get previewMenuDownload => 'Télécharger';

  @override
  String get previewMenuShareQr => 'Partager via QR';

  @override
  String get previewMenuOpenDrive => 'Ouvrir dans Google Drive';

  @override
  String get tapToExitFullscreen => 'Appuyez pour quitter le plein écran';

  @override
  String get fileTypeLabel => 'Fichier';

  @override
  String get uploadTitle => 'Partager une ressource';

  @override
  String get uploadHeader => 'Contribuer au portail';

  @override
  String get uploadSubtitle => 'Aidez vos camarades en partageant des supports académiques vérifiés.';

  @override
  String get uploadFieldFullName => 'NOM COMPLET';

  @override
  String get uploadFieldEmail => 'ADRESSE E-MAIL';

  @override
  String get uploadCategorySection => 'CATÉGORIE DE LA RESSOURCE';

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
  String get uploadChooseOrScan => 'Choisir ou scanner un fichier';

  @override
  String uploadAcceptedFormats(Object maxSize) {
    return 'PDF, DOCX, ZIP (Max $maxSize Mo)';
  }

  @override
  String get uploadAddMoreFiles => 'Ajouter d\'autres fichiers';

  @override
  String uploadFileSelected(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers sélectionnés',
      one: '$count fichier sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get uploadButton => 'Envoyer la ressource';

  @override
  String get uploading => 'Envoi en cours…';

  @override
  String uploadingProgress(Object current, Object total) {
    return 'Envoi de $current sur $total…';
  }

  @override
  String get cancelUpload => 'Annuler l\'envoi';

  @override
  String get uploadAgreement => 'En envoyant ce fichier, vous acceptez les règles de la communauté et la politique d\'intégrité académique de CS Bouira.';

  @override
  String get uploadPickerOption => 'Choisir un fichier';

  @override
  String get uploadPickerSubtitle => 'Parcourir le stockage de l\'appareil';

  @override
  String get uploadScanOption => 'Scanner un fichier';

  @override
  String get uploadScanSubtitle => 'Utiliser l\'appareil photo pour scanner des documents';

  @override
  String get uploadErrorNoInternet => 'Aucune connexion internet';

  @override
  String get uploadErrorTimeout => 'La requête a expiré';

  @override
  String get uploadErrorCancelled => 'Envoi annulé';

  @override
  String get uploadErrorFailed => 'L\'envoi a échoué.';

  @override
  String get uploadRetry => 'Réessayer';

  @override
  String get uploadSuccessSingle => 'Votre ressource a été envoyée avec succès.';

  @override
  String uploadSuccessMultiple(Object count) {
    return 'Les $count ressources ont été envoyées avec succès.';
  }

  @override
  String get uploadSuccessTitle => 'Merci pour votre contribution !';

  @override
  String get uploadSuccessUploadMore => 'Envoyer d\'autres fichiers';

  @override
  String get uploadSuccessDone => 'Terminé';

  @override
  String uploadFileTooLarge(Object fileName, Object maxMB) {
    return '$fileName dépasse la limite de $maxMB Mo et a été ignoré.';
  }

  @override
  String get uploadScanError => 'Impossible de lire le document scanné.';

  @override
  String get reviewTitle => 'Vérifier le fichier';

  @override
  String reviewFileCounter(Object current, Object total) {
    return '$current sur $total';
  }

  @override
  String get reviewRetake => 'Reprendre / Choisir à nouveau';

  @override
  String get reviewUseThisFile => 'Utiliser ce fichier';

  @override
  String reviewApproveAll(Object remaining) {
    return 'Tout approuver ($remaining restants)';
  }

  @override
  String get reviewPreviewNotAvailable => 'Aperçu non disponible';

  @override
  String get authTagline => 'Le portail des ressources académiques pour l\'Informatique';

  @override
  String get authLoginToggle => 'Connexion';

  @override
  String get authSignUpToggle => 'Inscription';

  @override
  String get authFieldFullName => 'Nom complet';

  @override
  String get authFieldEmail => 'Adresse e-mail';

  @override
  String get authFieldPassword => 'Mot de passe';

  @override
  String get authFieldConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authSignUpButton => 'S\'inscrire';

  @override
  String get authLoginButton => 'Se connecter';

  @override
  String get authOrDivider => 'OU';

  @override
  String get authGoogleButton => 'Continuer avec Google';

  @override
  String get authAgreement => 'En continuant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.';

  @override
  String get authValidationEmailRequired => 'L\'e-mail est requis';

  @override
  String get authValidationEmailInvalid => 'Saisissez une adresse e-mail valide';

  @override
  String get authValidationPasswordRequired => 'Le mot de passe est requis';

  @override
  String get authValidationPasswordLength => 'Le mot de passe doit contenir au moins 8 caractères';

  @override
  String get authValidationPasswordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get authValidationNameRequired => 'Le nom complet est requis';

  @override
  String get authSignupFailed => 'L\'inscription a échoué. Veuillez réessayer.';

  @override
  String get authMergeDialogTitle => 'Fusionner les favoris';

  @override
  String authMergeDialogMessage(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nous avons trouvé $count éléments enregistrés dans vos favoris locaux. Souhaitez-vous les ajouter à votre compte ?',
      one: 'Nous avons trouvé $count élément enregistré dans vos favoris locaux. Souhaitez-vous l\'ajouter à votre compte ?',
    );
    return '$_temp0';
  }

  @override
  String get authMergeDialogSkip => 'Ignorer';

  @override
  String get authMergeDialogMerge => 'Fusionner';

  @override
  String get forgotPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get forgotPasswordSubtitle => 'Saisissez votre adresse e-mail et nous vous enverrons un lien de réinitialisation.';

  @override
  String get forgotPasswordFieldEmail => 'Adresse e-mail';

  @override
  String get forgotPasswordButton => 'Envoyer le lien de réinitialisation';

  @override
  String get forgotPasswordBackToLogin => 'Retour à la connexion';

  @override
  String get forgotPasswordValidationEmailRequired => 'L\'e-mail est requis';

  @override
  String get forgotPasswordValidationEmailInvalid => 'Saisissez une adresse e-mail valide';

  @override
  String get forgotPasswordSuccess => 'Consultez votre e-mail pour le lien de réinitialisation du mot de passe.';

  @override
  String get forgotPasswordError => 'Échec de l\'envoi de l\'e-mail de réinitialisation. Veuillez réessayer.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileGuestName => 'Invité';

  @override
  String get profileGuestBadge => 'INVITÉ';

  @override
  String get profileEmailPlaceholder => 'Ajoutez votre e-mail';

  @override
  String get profileStatUploads => 'ENVOIS';

  @override
  String get profileStatFavorites => 'FAVORIS';

  @override
  String get profileSettingMyUploads => 'Mes envois';

  @override
  String get profileSettingDownloads => 'Téléchargements';

  @override
  String get profileSettingFavorites => 'Favoris';

  @override
  String get profileSettingLeaderboard => 'Classement';

  @override
  String get profileSettingAbout => 'À propos de CS Bouira';

  @override
  String get profileGuestButton => 'Se connecter ou s\'inscrire';

  @override
  String get profileEditNameTitle => 'Modifier le nom';

  @override
  String get profileEditNameHint => 'Saisissez votre nom';

  @override
  String get profileEditNameCancel => 'Annuler';

  @override
  String get profileEditNameSave => 'Enregistrer';

  @override
  String get profileEditEmailTitle => 'Modifier l\'e-mail';

  @override
  String get profileEditEmailHint => 'Saisissez votre e-mail';

  @override
  String get profileLogoutTitle => 'Déconnexion';

  @override
  String get profileLogoutMessage => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get profileLogoutConfirm => 'Se déconnecter';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileLanguageEnglish => 'Anglais';

  @override
  String get profileLanguageArabic => 'العربية';

  @override
  String get profileLanguageFrench => 'Français';

  @override
  String get myUploadsTitle => 'Mes envois';

  @override
  String get myUploadsEmpty => 'Aucun envoi pour le moment';

  @override
  String get myUploadsEmptyHint => 'Vos ressources envoyées apparaîtront ici.';

  @override
  String get downloadsTitle => 'Téléchargements';

  @override
  String get downloadsEmpty => 'Aucun téléchargement pour le moment';

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
  String get leaderboardEmpty => 'Aucun contributeur pour le moment';

  @override
  String leaderboardUploadCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count envois',
      one: '$count envoi',
    );
    return '$_temp0';
  }

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
  String get aboutFeatureSearch => 'Rechercher dans l\'ensemble des supports de cours';

  @override
  String get aboutFeatureDownload => 'Télécharger et prévisualiser des PDF, documents et images';

  @override
  String get aboutFeatureUpload => 'Envoyer et partager des ressources académiques';

  @override
  String get aboutFeatureBookmarks => 'Mettre des favoris en signet pour un accès rapide';

  @override
  String get aboutFeatureQrCode => 'Scanner de QR code pour des liens instantanés vers les ressources';

  @override
  String get aboutFeatureOffline => 'Accès hors ligne aux supports téléchargés';

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
  String get aboutLicenseText => 'Cette application est publiée sous licence MIT.\n\nCopyright © 2026 Ahmed Amine. Tous droits réservés.\n\nLa permission est accordée, à titre gratuit, à toute personne obtenant une copie de ce logiciel et des fichiers de documentation associés, d\'utiliser, copier, modifier, fusionner, publier, distribuer, sous-licencier et/ou vendre des copies du logiciel.';

  @override
  String get qrScannerTitle => 'Scanner un QR code';

  @override
  String get qrScannerInstruction => 'Pointez votre appareil photo vers un QR code';

  @override
  String get qrScannerSuccess => 'QR code scanné !';

  @override
  String get qrScannerError => 'Impossible de lire le QR code';

  @override
  String get bottomNavHome => 'Accueil';

  @override
  String get bottomNavSearch => 'Recherche';

  @override
  String get bottomNavFavs => 'Favoris';

  @override
  String get bottomNavUpload => 'Envoyer';

  @override
  String get bottomNavProfile => 'Profil';

  @override
  String get networkReconnected => 'Vous êtes de nouveau en ligne';

  @override
  String get networkOffline => 'Aucune connexion internet';

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
  String updateDialogBody(Object version) {
    return 'La version $version est prête à être installée.';
  }

  @override
  String get updateDialogUpdate => 'Mettre à jour';

  @override
  String get updateDialogLater => 'Plus tard';

  @override
  String get updateDialogDownloading => 'Téléchargement...';

  @override
  String get updateDialogError => 'Échec du téléchargement.';
}

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart' as mime_pkg;
import 'package:csbouira_app/l10n/app_localizations.dart';
import '../../core/constants.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/selected_upload_file.dart';
import '../../data/models/upload_result.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/drive_providers.dart';
import '../../data/providers/my_uploads_provider.dart';
import '../../data/providers/upload_count_provider.dart';
import '../../data/providers/upload_state_provider.dart';
import '../../data/services/local_profile_cache.dart';
import '../../data/services/upload_service.dart' show CancelToken, UploadService;
import '../../shared/widgets/network_banner.dart';
import 'upload_review_screen.dart';

final _uploadServiceProvider = Provider<UploadService>((ref) {
  return UploadService();
});

const _grades = [
  'Licence 1',
  'Licence 2',
  'Licence 3 SI',
  'Master 1 GSI',
  'Master 1 ISIL',
  'Master 1 IA',
  'Master 2 GSI',
  'Master 2 ISIL',
  'Master 2 IA',
];

const _gradeShortcuts = {
  'Licence 1': 'L1',
  'Licence 2': 'L2',
  'Licence 3 SI': 'L3 SI',
  'Master 1 GSI': 'M1 GSI',
  'Master 1 ISIL': 'M1 ISIL',
  'Master 1 IA': 'M1 IA',
  'Master 2 GSI': 'M2 GSI',
  'Master 2 ISIL': 'M2 ISIL',
  'Master 2 IA': 'M2 IA',
};

const _moduleShortcuts = {
  'Algèbre 1': 'ALG1',
  'Algorithmique Et Structure De Données 1': 'ASD1',
  'Analyse 1': 'ANA1',
  'Anglais 1': 'ANG1',
  'Physique 1': 'PHY1',
  'Structure Machine 1': 'SM1',
  'Terminologie Scientifique': 'TS',
  // 'Doc Scanner Testing': 'DST',
  'Algèbre 2': 'ALG2',
  'Algorithmique Et Structure De Données 2': 'ASD2',
  'Analyse 2': 'ANA2',
  'Outils De Programmation Pour Les Mathématiques': 'OPM',
  'Physique 2': 'PHY2',
  'Probabilités Et Statistique Descriptive': 'PSD',
  'Structure Machine 2': 'SM2',
  "Technologie De L'Information Et De La Communication": 'TIC',
  'Algorithmique Et Structure De Données 3': 'ASD3',
  'Anglais 3': 'ANG3',
  'Architecture Des Ordinateurs': 'AO',
  'Logique Mathématique': 'LM',
  'Méthodes Numériques': 'MN',
  "Systèmes D'Information": 'SI',
  'Theorie Des Graphes': 'TG',
  'Anglais 4': 'ANG4',
  'Base De Donnees': 'BD',
  "Developpement D'applications Web": 'DAW',
  'Programmation Orienté Objet': 'POO',
  'Reseaux': 'RES',
  "Système D'exploitation 1": 'SE1',
  'Theorie Des Langages': 'TL',
  'Compilation': 'COMP',
  'Economie numérique et veille stratégique': 'ENVS',
  'Génie Logiciel': 'GL',
  'IHM': 'IHM',
  'Probabilités': 'PROBA',
  'Programmation Linéaire': 'PL',
  "Systèmes d'exploitation 2": 'SE2',
  'Application Mobile': 'AM',
  'Créer Une Startup': 'CUS',
  'Données Semi Structurées': 'DSS',
  'Intelligence Artificielle': 'IA',
  'Rédaction Scientifique': 'RS',
  'Sécurité Informatique': 'SECI',
  'Algorithmique avancée et complexité': 'AAC',
  'Architecture et administration des bases de données': 'AABD',
  'Architectures modernes des systèmes informatiques': 'AMSI',
  'Cloud computing': 'CC',
  'Implementation Methods and technologies': 'IMT',
  'Réseaux des couches basses': 'RCB',
  "Systèmes d'exploitation": 'SE',
  'Systèmes de communication vocaux et vidéos': 'SCVV',
  'Cybercriminalité': 'CYBER',
  "Gestion de l'incertain": 'GI',
  'Inforgraphie': 'INFO',
  'Internet of Things': 'IoT',
  'Les Middlewares pour les systèmes répartis': 'MSR',
  'Les réseaux IP': 'RIP',
  'Machine learning': 'ML',
  'Modélisation et Architectures logicielles': 'MAL',
  'Analyse de données': 'AD',
  'Bases de données avancées': 'BDA',
  "Fondements de l'intelligence artificielle": 'FIA',
  'Introduction au Machine Learning': 'IML',
  'Introduction au traitement automatique des langues naturelles': 'ITALN',
  'Modélisation et architectures logicielles': 'MAL',
  "Systèmes d'Information géographiques": 'SIG',
  'Algorithmique Avancée et Complexité': 'AAC',
  'Base de Données Avancées': 'BDA',
  "Méthodes d'optimisation": 'MO',
  'Représentation des connaissances': 'RC',
  'Réseaux Avancés': 'RA',
  'Technologies Émergentes': 'TE',
  'Computer Vision': 'CV',
  'Deep Learning': 'DL',
  "Gestion de l'Incertain": 'GI',
  'Gestion de projets informatiques': 'GPI',
  'Modélisation et simulation': 'MS',
  'Systèmes Multi Agents': 'SMA',
  'Virtualisation et Cloud': 'VC',
  'Big Data': 'BIGD',
  'Blockchain': 'BLOCK',
  'Computational Intelligence': 'CINT',
  'Evaluation de performances': 'EP',
  'Methodolohie de recherche et de documentation': 'MRD',
  'Mobile Networks': 'MNET',
  'System On Chip': 'SOC',
  'Introduction aux ERP': 'ERP',
  'Méthodologie de recherche et de documentation': 'MRD',
  'Ontologie et sémantique web': 'OSW',
  'Programmation pour le Big data': 'PBD',
  "Sécurité des systèmes d'information": 'SSI',
  "Systèmes d'Information Coopératifs": 'SIC',
  'Systèmes décisionnels et entrepôt de données': 'SDED',
  'Application de Deep Learning': 'ADL',
  'Calcul intensif': 'CALC',
  'Modèles stochastiques pour la simulation': 'MSS',
  'Programmation pour le Big Data': 'PBD',
  'Robotique': 'ROBO',
  'Vision artificielle': 'VA',
};

const _semestersByGrade = {
  'Licence 1': ['S01', 'S02'],
  'Licence 2': ['S03', 'S04'],
  'Licence 3 SI': ['S05', 'S06'],
  'Master 1 GSI': ['S07', 'S08'],
  'Master 1 ISIL': ['S07', 'S08'],
  'Master 1 IA': ['S07', 'S08'],
  'Master 2 GSI': ['S09'],
  'Master 2 ISIL': ['S09'],
  'Master 2 IA': ['S09'],
};

const _modulesByGradeSemester = {
  'Licence 1': {
    'S01': [
      'Algèbre 1',
      'Algorithmique Et Structure De Données 1',
      'Analyse 1',
      'Anglais 1',
      'Physique 1',
      'Structure Machine 1',
      'Terminologie Scientifique'
      // 'Doc Scanner Testing'
    ],
    'S02': [
      'Algèbre 2',
      'Algorithmique Et Structure De Données 2',
      'Analyse 2',
      'Outils De Programmation Pour Les Mathématiques',
      'Physique 2',
      'Probabilités Et Statistique Descriptive',
      'Structure Machine 2',
      "Technologie De L'Information Et De La Communication"
    ]
  },
  'Licence 2': {
    'S03': [
      'Algorithmique Et Structure De Données 3',
      'Anglais 3',
      'Architecture Des Ordinateurs',
      'Logique Mathématique',
      'Méthodes Numériques',
      "Systèmes D'Information",
      'Theorie Des Graphes'
    ],
    'S04': [
      'Anglais 4',
      'Base De Donnees',
      "Developpement D'applications Web",
      'Programmation Orienté Objet',
      'Reseaux',
      "Système D'exploitation 1",
      'Theorie Des Langages'
    ]
  },
  'Licence 3 SI': {
    'S05': [
      'Compilation',
      'Economie numérique et veille stratégique',
      'Génie Logiciel',
      'IHM',
      'Probabilités',
      'Programmation Linéaire',
      "Systèmes d'exploitation 2"
    ],
    'S06': [
      'Application Mobile',
      'Créer Une Startup',
      'Données Semi Structurées',
      'Intelligence Artificielle',
      'Rédaction Scientifique',
      'Sécurité Informatique'
    ]
  },
  'Master 1 GSI': {
    'S07': [
      'Algorithmique avancée et complexité',
      'Architecture et administration des bases de données',
      'Architectures modernes des systèmes informatiques',
      'Cloud computing',
      'Implementation Methods and technologies',
      'Réseaux des couches basses',
      "Systèmes d'exploitation",
      'Systèmes de communication vocaux et vidéos'
    ],
    'S08': [
      'Cybercriminalité',
      "Gestion de l'incertain",
      'Inforgraphie',
      'Internet of Things',
      'Les Middlewares pour les systèmes répartis',
      'Les réseaux IP',
      'Machine learning',
      'Modélisation et Architectures logicielles'
    ]
  },
  'Master 1 ISIL': {
    'S08': [
      'Analyse de données',
      'Bases de données avancées',
      'Cybercriminalité',
      "Fondements de l'intelligence artificielle",
      'Introduction au Machine Learning',
      'Introduction au traitement automatique des langues naturelles',
      'Modélisation et architectures logicielles',
      'Systèmes d\'Information géographiques'
    ]
  },
  'Master 1 IA': {
    'S07': [
      'Algorithmique Avancée et Complexité',
      'Analyse de données',
      'Base de Données Avancées',
      'Machine Learning',
      "Méthodes d'optimisation",
      'Représentation des connaissances',
      'Réseaux Avancés',
      'Technologies Émergentes'
    ],
    'S08': [
      'Computer Vision',
      'Cybercriminalité',
      'Deep Learning',
      'Gestion de l\'Incertain',
      'Gestion de projets informatiques',
      'Modélisation et simulation',
      'Systèmes Multi Agents',
      'Virtualisation et Cloud'
    ]
  },
  'Master 2 GSI': {
    'S09': [
      'Big Data',
      'Blockchain',
      'Computational Intelligence',
      'Deep Learning',
      'Evaluation de performances',
      'Methodolohie de recherche et de documentation',
      'Mobile Networks',
      'System On Chip'
    ]
  },
  'Master 2 ISIL': {
    'S09': [
      'Deep Learning',
      'Introduction aux ERP',
      'Méthodologie de recherche et de documentation',
      'Ontologie et sémantique web',
      'Programmation pour le Big data',
      "Sécurité des systèmes d'information",
      'Systèmes d\'Information Coopératifs',
      'Systèmes décisionnels et entrepôt de données'
    ]
  },
  'Master 2 IA': {
    'S09': [
      'Application de Deep Learning',
      'Calcul intensif',
      "Méthodes d'optimisation",
      'Modèles stochastiques pour la simulation',
      'Programmation pour le Big Data',
      'Robotique',
      'Vision artificielle'
    ]
  }
};

const _categories = ['Cours', 'Summary', 'TP', 'TD', 'Test', 'Exam', 'Other'];

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _FileReviewResult {
  final SelectedUploadFile file;
  final bool approveAll;
  const _FileReviewResult(this.file, {this.approveAll = false});
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  String? _selectedCategory;
  String? _selectedGrade;
  String? _selectedSemester;
  String? _selectedModule;

  final List<SelectedUploadFile> _selectedFiles = [];
  int _currentUploadIndex = 0;

  List<String> _allModules = [];
  CancelToken? _cancelToken;
  bool _uploadCancelled = false;

  bool get _isFormValid =>
      _selectedCategory != null &&
      _selectedGrade != null &&
      _selectedSemester != null &&
      _selectedModule != null &&
      _selectedModule!.trim().isNotEmpty &&
      _selectedFiles.isNotEmpty;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  String _mapSemester(String code) {
    final num = int.tryParse(code.replaceAll('S', '')) ?? 0;
    return num.isOdd ? 'S1' : 'S2';
  }



  void _showFilePickerOptions() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _PickerOption(
                icon: Icons.folder_open,
                title: l10n.uploadPickerOption,
                subtitle: l10n.uploadPickerSubtitle,
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFile();
                },
              ),
              if (!kIsWeb) ...[
                const SizedBox(height: 8),
                _PickerOption(
                  icon: Icons.document_scanner,
                  title: l10n.uploadScanOption,
                  subtitle: l10n.uploadScanSubtitle,
                  onTap: () {
                    Navigator.pop(ctx);
                    _scanFile();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'zip', 'doc', 'ppt', 'pptx'],
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final maxBytes = UploadConstants.maxFileSizeBytes;
    final maxMB = maxBytes ~/ (1024 * 1024);

    final validFiles = <SelectedUploadFile>[];
    for (final platformFile in result.files) {
      if (platformFile.bytes == null) continue;

      if (platformFile.bytes!.length > maxBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.uploadFileTooLarge(platformFile.name, maxMB)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        continue;
      }

      final mimeType = mime_pkg.lookupMimeType(platformFile.name) ?? 'application/octet-stream';
      validFiles.add(SelectedUploadFile(
        bytes: platformFile.bytes!,
        fileName: platformFile.name,
        mimeType: mimeType,
      ));
    }

    final totalCount = validFiles.length;
    for (int i = 0; i < totalCount; i++) {
      if (!mounted) return;
      final result = await _promptReviewFile(validFiles[i], currentIndex: i + 1, totalCount: totalCount);
      if (result == null) continue;

      if (mounted) {
        setState(() => _selectedFiles.add(result.file));
      }

      if (result.approveAll && mounted) {
        setState(() {
          for (int j = i + 1; j < totalCount; j++) {
            _selectedFiles.add(validFiles[j]);
          }
        });
        break;
      }
    }
  }

  Future<_FileReviewResult?> _promptReviewFile(SelectedUploadFile file, {int currentIndex = 1, int totalCount = 1}) {
    final completer = Completer<_FileReviewResult?>();
    showUploadReviewSheet(
      context: context,
      file: file,
      currentIndex: currentIndex,
      totalCount: totalCount,
      onRetake: () => completer.complete(null),
      onConfirm: (confirmed) => completer.complete(_FileReviewResult(confirmed, approveAll: false)),
      onApproveAll: () => completer.complete(_FileReviewResult(file, approveAll: true)),
    );
    return completer.future;
  }

  Future<void> _scanFile() async {
      final l10n = AppLocalizations.of(context)!;
      try {
        final result = await FlutterDocScanner().getScannedDocumentAsPdf();
        if (result == null) return;

        final pdfUri = result.pdfUri;
        if (pdfUri.isEmpty) return;

        Uint8List bytes;
        try {
          bytes = await _readBytesFromUri(pdfUri);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.uploadScanError),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return;
        }

        final selected = SelectedUploadFile(
          bytes: bytes,
          fileName: 'scan_${DateTime.now().millisecondsSinceEpoch}.pdf',
          mimeType: 'application/pdf',
        );

        if (mounted) {
          setState(() => _selectedFiles.add(selected));
        }
      } on DocScanException {
        return;
      }
  }

  Future<Uint8List> _readBytesFromUri(String uriString) async {
    final uri = Uri.parse(uriString);
    if (uri.scheme == 'file' || uri.scheme.isEmpty) {
      return await File.fromUri(uri).readAsBytes();
    }
    try {
      return await File.fromUri(uri).readAsBytes();
    } catch (e) {
      debugPrint('Error in _UploadScreenState._readBytesFromUri (first): $e');
    }
    try {
      if (uri.path.isNotEmpty) {
        return await File(uri.path).readAsBytes();
      }
    } catch (e) {
      debugPrint('Error in _UploadScreenState._readBytesFromUri (second): $e');
    }
    if (uri.scheme == 'content') {
      final channel = MethodChannel('csbouira_app/file_utils');
      final bytes = await channel.invokeMethod<Uint8List>('readContentUri', uriString);
      if (bytes != null) return bytes;
    }
    throw Exception('Could not read file from URI: $uriString');
  }

  Future<void> _submit() async {
    if (!_isFormValid) return;

    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(currentUserProvider);
    String fullName;
    String email;

    if (user != null) {
      final profileAsync = ref.read(profileProvider(user.id));
      final profile = profileAsync.asData?.value;
      fullName = (profile?['full_name'] as String?) ??
          user.userMetadata?['full_name'] as String? ??
          user.email ??
          'User';
      email = user.email ?? '';
    } else {
      final guestProfile = ref.read(guestProfileProvider).asData?.value ?? {};
      final guestName = guestProfile['name'] as String? ?? '';
      fullName = guestName.isNotEmpty ? guestName : 'Guest';
      final rawEmail = guestProfile['email'] as String? ?? '';
      email = rawEmail.isNotEmpty ? rawEmail : 'guest@csbouira.dz';
    }

    final categoryMap = {
      'Cours': 'Cours',
      'Summary': 'Summary',
      'TP': 'TP',
      'TD': 'TD',
      'Test': 'Test',
      'Exam': 'Exam',
      'Other': 'Other',
    };

    final moduleName = _selectedModule!.trim();
    final fileType = categoryMap[_selectedCategory]!;
    final service = ref.read(_uploadServiceProvider);
    final stateNotifier = ref.read(uploadStateProvider.notifier);

    int successCount = 0;
    String? lastError;
    UploadErrorType? lastErrorType;

    _uploadCancelled = false;

    for (int i = 0; i < _selectedFiles.length; i++) {
      if (_uploadCancelled) break;
      if (!mounted) return;

      final file = _selectedFiles[i];
      _currentUploadIndex = i;
      stateNotifier.setUploading();

      final ext = file.fileName.contains('.')
          ? file.fileName.substring(file.fileName.lastIndexOf('.'))
          : '';
      final year = DateTime.now().year.toString();
      final moduleShort = _moduleShortcuts[moduleName] ?? moduleName;
      final gradeShort = _gradeShortcuts[_selectedGrade] ?? _selectedGrade!;
      final uploadFileName = '$fileType $moduleShort $gradeShort-${_mapSemester(_selectedSemester!)}-$year$ext';

      final cancelToken = CancelToken();
      _cancelToken = cancelToken;

      final result = await service.uploadResource(
        fullName: fullName,
        email: email,
        fileType: fileType,
        moduleName: moduleName,
        grade: _selectedGrade!,
        semester: _mapSemester(_selectedSemester!),
        fileName: uploadFileName,
        fileBytes: file.bytes,
        mimeType: file.mimeType,
        onProgress: (progress) {
          stateNotifier.setProgress(progress);
        },
        cancelToken: cancelToken,
      );

      _cancelToken = null;

      if (result.success) {
        successCount++;
        if (user != null) {
          try {
            final supabase = ref.read(supabaseProvider);
            await supabase.from('uploads').insert({
              'user_id': user.id,
              'file_name': uploadFileName,
              'module_name': moduleName,
              'grade': _selectedGrade!,
              'semester': _mapSemester(_selectedSemester!),
              'file_type': fileType,
            });
          } catch (e) {
            debugPrint('Error in _UploadScreenState._submit (supabase insert): $e');
          }
        } else {
          final cache = LocalProfileCache();
          await cache.incrementUploadCount();
          await cache.addUploadEntry({
            'file_name': uploadFileName,
            'module_name': moduleName,
            'grade': _selectedGrade!,
            'semester': _mapSemester(_selectedSemester!),
            'file_type': fileType,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      } else {
        lastError = '$uploadFileName: ${result.message ?? l10n.uploadErrorFailed}';
        lastErrorType = result.errorType;
      }
    }

    ref.invalidate(uploadCountProvider);
    if (user != null) {
      ref.invalidate(myUploadsProvider);
    }

    if (mounted) {
      _currentUploadIndex = 0;
      if (successCount > 0) {
        stateNotifier.setSuccess();
      } else if (lastError != null) {
        stateNotifier.setError(UploadResult(
          success: false,
          message: lastError,
          errorType: lastErrorType,
        ));
      }
    }
  }

  Widget _buildSuccessScreen(ThemeData theme, AppLocalizations l10n) {
    final count = _selectedFiles.length;
    final label = count == 1
        ? l10n.uploadSuccessSingle
        : l10n.uploadSuccessMultiple(count);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(theme: theme, title: l10n.uploadTitle),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withAlpha(51),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.uploadSuccessTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _resetForm,
                          child: Text(l10n.uploadSuccessUploadMore),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            _resetForm();
                            StatefulNavigationShell.of(context).goBranch(
                              0,
                              initialLocation: true,
                            );
                          },
                          child: Text(l10n.uploadSuccessDone),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetForm() {
    _cancelToken?.cancel();
    _cancelToken = null;
    _uploadCancelled = false;
    ref.read(uploadStateProvider.notifier).reset();
    setState(() {
      _selectedCategory = null;
      _selectedGrade = null;
      _selectedSemester = null;
      _selectedModule = null;
      _selectedFiles.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);

    String displayName;
    String email;

    if (user != null) {
      final profileAsync = ref.watch(profileProvider(user.id));
      final profile = profileAsync.asData?.value;
      final meta = user.userMetadata;
      displayName = (profile?['full_name'] as String?) ??
          meta?['full_name'] as String? ??
          meta?['name'] as String? ??
          user.email ??
          'User';
      email = user.email ?? '';
    } else {
      final guestProfile = ref.watch(guestProfileProvider).asData?.value ?? {};
      final guestName = guestProfile['name'] as String? ?? '';
      displayName = guestName.isNotEmpty ? guestName : 'Guest';
      final rawEmail = guestProfile['email'] as String? ?? '';
      email = rawEmail.isNotEmpty ? rawEmail : 'guest@csbouira.dz';
    }

    final driveAsync = ref.watch(driveRootDataProvider);
    final driveData = driveAsync.asData?.value;
    if (driveData != null && _allModules.isEmpty) {
      final modules = <String>{};
      for (final yearNode in driveData.years.entries) {
        for (final semesterNode in yearNode.value.subfolders.entries) {
          if (semesterNode.key == 'Books & Exercices') continue;
          for (final moduleNode in semesterNode.value.subfolders.entries) {
            modules.add(moduleNode.key);
          }
        }
      }
      _allModules = modules.toList()..sort();
    }

    final suggestions = const <String>[]; // module suggestions now via dropdown
    final semesters = _semestersByGrade[_selectedGrade] ?? [];
    final uploadState = ref.watch(uploadStateProvider);

    if (uploadState.uploadSuccess) return _buildSuccessScreen(theme, l10n);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(theme: theme, title: l10n.uploadTitle),
            const NetworkBanner(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile,
                  AppSpacing.stackSm,
                  AppSpacing.marginMobile,
                  32,
                ),
                children: [
                  _buildHeader(theme, l10n),
                  const SizedBox(height: AppSpacing.stackLg),
                  _buildUserInfo(theme, l10n, displayName, email),
                  const SizedBox(height: AppSpacing.stackLg),
                  _buildGradeSemesterRow(theme, l10n, semesters),
                  const SizedBox(height: AppSpacing.stackLg),
                  _buildCategorySelector(theme, l10n),
                  const SizedBox(height: AppSpacing.stackLg),
                  _buildModuleField(theme, l10n, suggestions),
                  const SizedBox(height: AppSpacing.stackLg),
                  _buildFileDropzone(theme, l10n),
                  if (uploadState.error != null) ...[
                    const SizedBox(height: AppSpacing.stackSm),
                    _buildErrorBanner(theme, l10n, uploadState.error!),
                  ],
                  const SizedBox(height: AppSpacing.stackLg),
                  _buildSubmitButton(theme, l10n, uploadState),
                  const SizedBox(height: AppSpacing.stackSm),
                  _buildDisclaimer(theme, l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(ThemeData theme, AppLocalizations l10n, UploadResult error) {
    final (icon, title) = switch (error.errorType) {
      UploadErrorType.offline => (Icons.wifi_off, l10n.uploadErrorNoInternet),
      UploadErrorType.timeout => (Icons.timer_off, l10n.uploadErrorTimeout),
      UploadErrorType.cancelled => (Icons.cancel_outlined, l10n.uploadErrorCancelled),
      UploadErrorType.serverError => (Icons.error_outline, error.message ?? l10n.uploadErrorFailed),
      UploadErrorType.unknown => (Icons.error_outline, error.message ?? l10n.uploadErrorFailed),
      null => (Icons.error_outline, error.message ?? l10n.uploadErrorFailed),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withAlpha(51),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.error.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          if (error.errorType != UploadErrorType.cancelled) ...[
            const SizedBox(height: AppSpacing.stackSm),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.uploadRetry),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.uploadHeader,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.uploadSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(ThemeData theme, AppLocalizations l10n, String name, String email) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 400;
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _InfoField(
                            theme: theme,
                            icon: Icons.person_outline,
                            label: l10n.uploadFieldFullName,
                            value: name,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.stackMd),
                        Expanded(
                          child: _InfoField(
                            theme: theme,
                            icon: Icons.alternate_email,
                            label: l10n.uploadFieldEmail,
                            value: email,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _InfoField(
                          theme: theme,
                          icon: Icons.person_outline,
                          label: l10n.uploadFieldFullName,
                          value: name,
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        _InfoField(
                          theme: theme,
                          icon: Icons.alternate_email,
                          label: l10n.uploadFieldEmail,
                          value: email,
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryCard(String cat, ThemeData theme, {double? width, double? height}) {
    final selected = _selectedCategory == cat;
    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = cat),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primaryContainer.withAlpha(51)
                : const Color(0xFF15151F).withAlpha(204),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withAlpha(77),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: Text(
              cat,
              style: theme.textTheme.labelMedium?.copyWith(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            l10n.uploadCategorySection,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            final crossAxisCount = isWide ? 4 : 2;
            final spacing = 8.0;
            final itemWidth = (constraints.maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;
            final itemHeight = itemWidth / (isWide ? 2.5 : 3.2);

            final rows = <Widget>[];
            for (int i = 0; i < _categories.length; i += crossAxisCount) {
              final chunk = _categories.skip(i).take(crossAxisCount).toList();
              final isLastRow = i + crossAxisCount >= _categories.length;

              final rowItems = <Widget>[];
              for (int j = 0; j < chunk.length; j++) {
                rowItems.add(_buildCategoryCard(chunk[j], theme, width: itemWidth, height: itemHeight));
                if (j < chunk.length - 1) {
                  rowItems.add(SizedBox(width: spacing));
                }
              }

              rows.add(
                isLastRow && chunk.length < crossAxisCount
                    ? SizedBox(
                        height: itemHeight,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: rowItems,
                          ),
                        ),
                      )
                    : SizedBox(
                        height: itemHeight,
                        child: Row(
                          children: rowItems,
                        ),
                      ),
              );
              if (i + crossAxisCount < _categories.length) {
                rows.add(SizedBox(height: spacing));
              }
            }
            return Column(children: rows);
          },
        ),
      ],
    );
  }

  Widget _buildModuleField(ThemeData theme, AppLocalizations l10n, List<String> _) {
    final gradeMap = _selectedGrade != null ? _modulesByGradeSemester[_selectedGrade] : null;
    final modules = gradeMap != null && _selectedSemester != null ? gradeMap[_selectedSemester] ?? [] : <String>[];
    final moduleEnabled = _selectedGrade != null && _selectedSemester != null;
    return _buildDropdown(
      theme: theme,
      l10n: l10n,
      label: l10n.uploadModule,
      value: _selectedModule,
      items: modules,
      enabled: moduleEnabled,
      onChanged: (v) => setState(() => _selectedModule = v),
    );
  }

  Widget _buildGradeSemesterRow(ThemeData theme, AppLocalizations l10n, List<String> semesters) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            theme: theme,
            l10n: l10n,
            label: l10n.uploadGrade,
            value: _selectedGrade,
            items: _grades,
            onChanged: (v) {
              setState(() {
                _selectedGrade = v;
                _selectedSemester = null;
              });
            },
          ),
        ),
        const SizedBox(width: AppSpacing.stackMd),
        Expanded(
          child: _buildDropdown(
            theme: theme,
            l10n: l10n,
            label: l10n.uploadSemester,
            value: _selectedSemester,
            items: semesters,
            enabled: _selectedGrade != null,
            onChanged: (v) => setState(() => _selectedSemester = v),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required ThemeData theme,
    required AppLocalizations l10n,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: enabled ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withAlpha(128),
            ),
          ),
        ),
        GestureDetector(
          onTap: enabled
              ? () => _showDropdownSheet(theme, l10n, label, value, items, onChanged)
              : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: enabled ? 1.0 : 0.45,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.stackMd,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: enabled
                    ? theme.colorScheme.surfaceContainer
                    : theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: enabled
                      ? theme.colorScheme.outlineVariant.withAlpha(77)
                      : theme.colorScheme.outlineVariant.withAlpha(38),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? (enabled ? l10n.uploadDropdownPlaceholder : '\u2014'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: value != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant.withAlpha(enabled ? 255 : 128),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.expand_more,
                    color: theme.colorScheme.outline.withAlpha(enabled ? 255 : 77),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      ),
    );
  }

  void _showDropdownSheet(
    ThemeData theme,
    AppLocalizations l10n,
    String label,
    String? currentValue,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.ltr,
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];
                      final selected = item == currentValue;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          onTap: () {
                            onChanged(item);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              color: selected
                                  ? theme.colorScheme.primaryContainer.withAlpha(51)
                                  : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: selected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface,
                                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  Icon(
                                    Icons.check,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildFileDropzone(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            l10n.uploadFileSection,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        if (_selectedFiles.isNotEmpty)
          _buildFilesSelected(theme, l10n)
        else
          _buildFileEmpty(theme, l10n),
      ],
    );
  }

  Widget _buildFileEmpty(ThemeData theme, AppLocalizations l10n) {
    final maxMB = UploadConstants.maxFileSizeBytes ~/ (1024 * 1024);
    return GestureDetector(
      onTap: _showFilePickerOptions,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(128),
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_upload,
                  color: theme.colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: AppSpacing.stackSm),
              Text(
                l10n.uploadChooseOrScan,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.uploadAcceptedFormats(maxMB),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilesSelected(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        ...List.generate(_selectedFiles.length, (i) {
          final file = _selectedFiles[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(AppSpacing.stackSm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: theme.colorScheme.primaryContainer.withAlpha(77),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withAlpha(51),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    file.mimeType == 'application/pdf'
                        ? Icons.picture_as_pdf
                        : Icons.description,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.stackSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.fileName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        file.formattedSize,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _selectedFiles.removeAt(i));
                  },
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showFilePickerOptions,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withAlpha(77),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  l10n.uploadAddMoreFiles,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedFiles.length > 1) ...[
          const SizedBox(height: 6),
          Text(
            l10n.uploadFileSelected(_selectedFiles.length),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme, AppLocalizations l10n, UploadFormState uploadState) {
    if (uploadState.isUploading) {
      final total = _selectedFiles.length;
      final fileLabel = total == 1
          ? l10n.uploading
          : l10n.uploadingProgress(_currentUploadIndex + 1, total);
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: null,
              icon: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white70,
                ),
              ),
              label: Text(fileLabel),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
                disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _uploadCancelled = true;
                _cancelToken?.cancel();
              },
              icon: const Icon(Icons.close, size: 18),
              label: Text(l10n.cancelUpload),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error.withAlpha(77)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final enabled = _isFormValid;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: enabled ? _submit : null,
        style: FilledButton.styleFrom(
          backgroundColor: enabled
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          foregroundColor: enabled
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant.withAlpha(102),
          disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
          disabledForegroundColor: theme.colorScheme.onSurfaceVariant.withAlpha(102),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.uploadButton,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer(ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackMd),
      child: Text(
        l10n.uploadAgreement,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final ThemeData theme;
  final String title;

  const _AppBar({required this.theme, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(77),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (MediaQuery.of(context).viewInsets.bottom > 0) {
                FocusScope.of(context).unfocus();
                return;
              }
              final shell = StatefulNavigationShell.of(context);
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else if (shell.currentIndex != 0) {
                shell.goBranch(0, initialLocation: true);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

        ],
      ),
    );
  }
}

class _InfoField extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;

  const _InfoField({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.stackMd,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(77),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.outline, size: 20),
              const SizedBox(width: AppSpacing.stackSm),
              Expanded(
                child: Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(77),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(51),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

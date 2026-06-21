import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart' as mime_pkg;
import '../../core/constants.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/selected_upload_file.dart';
import '../../data/models/upload_result.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/drive_providers.dart';
import '../../data/providers/upload_count_provider.dart';
import '../../data/providers/upload_state_provider.dart';
import '../../data/services/local_profile_cache.dart';
import '../../data/services/upload_service.dart';
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
      'Terminologie Scientifique',
      'Doc Scanner Testing'
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
      'Systèmes d'Information géographiques'
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
      'Gestion de l'Incertain',
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
      'Systèmes d'Information Coopératifs',
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

class _UploadScreenState extends ConsumerState<UploadScreen> {
  String? _selectedCategory;
  String? _selectedGrade;
  String? _selectedSemester;
  String? _selectedModule;

  SelectedUploadFile? _selectedFile;

  List<String> _allModules = [];

  bool get _isFormValid =>
      _selectedCategory != null &&
      _selectedGrade != null &&
      _selectedSemester != null &&
      _selectedModule != null &&
      _selectedModule!.trim().isNotEmpty &&
      _selectedFile != null;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _mapSemester(String code) {
    final num = int.tryParse(code.replaceAll('S', '')) ?? 0;
    return num.isOdd ? 'S1' : 'S2';
  }



  void _showFilePickerOptions() {
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
                title: 'Choose a file',
                subtitle: 'Browse device storage',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFile();
                },
              ),
              if (!kIsWeb) ...[
                const SizedBox(height: 8),
                _PickerOption(
                  icon: Icons.document_scanner,
                  title: 'Scan a file',
                  subtitle: 'Use camera to scan documents',
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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'zip', 'doc', 'ppt', 'pptx'],
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final platformFile = result.files.first;
    if (platformFile.bytes == null) return;

    final mimeType = mime_pkg.lookupMimeType(platformFile.name) ?? 'application/octet-stream';

    if (platformFile.bytes!.length > UploadConstants.maxFileSizeBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File exceeds ${UploadConstants.maxFileSizeBytes ~/ (1024 * 1024)}MB limit.',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    final selected = SelectedUploadFile(
      bytes: platformFile.bytes!,
      fileName: platformFile.name,
      mimeType: mimeType,
    );

    if (mounted) {
      showUploadReviewSheet(
        context: context,
        file: selected,
        onRetake: () {
          _selectedFile = null;
          _showFilePickerOptions();
        },
        onConfirm: (confirmed) {
          setState(() => _selectedFile = confirmed);
        },
      );
    }
  }

  Future<void> _scanFile() async {
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
                content: const Text('Could not read scanned document.'),
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
          showUploadReviewSheet(
            context: context,
            file: selected,
            onRetake: () {
              _selectedFile = null;
              _showFilePickerOptions();
            },
            onConfirm: (confirmed) {
              setState(() => _selectedFile = confirmed);
            },
          );
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
    } catch (_) {}
    try {
      if (uri.path.isNotEmpty) {
        return await File(uri.path).readAsBytes();
      }
    } catch (_) {}
    if (uri.scheme == 'content') {
      final channel = MethodChannel('csbouira_app/file_utils');
      final bytes = await channel.invokeMethod<Uint8List>('readContentUri', uriString);
      if (bytes != null) return bytes;
    }
    throw Exception('Could not read file from URI: $uriString');
  }

  Future<void> _submit() async {
    if (!_isFormValid) return;
    final stateNotifier = ref.read(uploadStateProvider.notifier);
    stateNotifier.setUploading();

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
      email = guestProfile['email'] as String? ?? '';
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

    final service = ref.read(_uploadServiceProvider);
    final result = await service.uploadResource(
      fullName: fullName,
      email: email,
      fileType: categoryMap[_selectedCategory]!,
      moduleName: moduleName,
      grade: _selectedGrade!,
      semester: _mapSemester(_selectedSemester!),
      fileName: _selectedFile!.fileName,
      fileBytes: _selectedFile!.bytes,
      mimeType: _selectedFile!.mimeType,
    );

    if (!mounted) return;

    if (result.success) {
      stateNotifier.setSuccess();
      if (user != null) {
        try {
          final supabase = ref.read(supabaseProvider);
          await supabase.from('uploads').insert({
            'user_id': user.id,
            'file_name': _selectedFile!.fileName,
            'module_name': moduleName,
            'grade': _selectedGrade!,
            'semester': _mapSemester(_selectedSemester!),
            'file_type': categoryMap[_selectedCategory]!,
          });
        } catch (_) {}
        ref.invalidate(uploadCountProvider);
      } else {
        final cache = LocalProfileCache();
        await cache.incrementUploadCount();
      }
    } else {
      stateNotifier.setError(result);
    }
  }

  Widget _buildSuccessScreen(ThemeData theme) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(theme: theme),
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
                        'Thank you for contributing!',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your resource has been uploaded successfully.',
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
                          child: const Text('Upload another'),
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
                          child: const Text('Done'),
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
    ref.read(uploadStateProvider.notifier).reset();
    setState(() {
      _selectedCategory = null;
      _selectedGrade = null;
      _selectedSemester = null;
      _selectedModule = null;
      _selectedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      email = guestProfile['email'] as String? ?? '';
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

    if (uploadState.uploadSuccess) return _buildSuccessScreen(theme);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _AppBar(theme: theme),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile,
                  AppSpacing.stackSm,
                  AppSpacing.marginMobile,
                  32,
                ),
                children: [
                  _buildHeader(theme),
                  const SizedBox(height: AppSpacing.stackLg),
                  _buildUserInfo(theme, displayName, email),
                  const SizedBox(height: AppSpacing.stackLg),
                  _buildGradeSemesterRow(theme, semesters),
                  const SizedBox(height: AppSpacing.stackLg),
                  _buildCategorySelector(theme),
                  const SizedBox(height: AppSpacing.stackLg),
                  _buildModuleField(theme, suggestions),
                  const SizedBox(height: AppSpacing.stackLg),
                  _buildFileDropzone(theme),
                  if (uploadState.error != null) ...[
                    const SizedBox(height: AppSpacing.stackSm),
                    _buildErrorBanner(theme, uploadState.error!),
                  ],
                  const SizedBox(height: AppSpacing.stackLg),
                  _buildSubmitButton(theme, uploadState),
                  const SizedBox(height: AppSpacing.stackSm),
                  _buildDisclaimer(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(ThemeData theme, UploadResult error) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackSm),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withAlpha(51),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: theme.colorScheme.error.withAlpha(77),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error.message ?? 'Upload failed.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contribute to Hub',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Help your fellow students by uploading verified academic materials.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(ThemeData theme, String name, String email) {
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
                            label: 'FULL NAME',
                            value: name,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.stackMd),
                        Expanded(
                          child: _InfoField(
                            theme: theme,
                            icon: Icons.alternate_email,
                            label: 'EMAIL ADDRESS',
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
                          label: 'FULL NAME',
                          value: name,
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        _InfoField(
                          theme: theme,
                          icon: Icons.alternate_email,
                          label: 'EMAIL ADDRESS',
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

  Widget _buildCategorySelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'RESOURCE CATEGORY',
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
            mainAxisSize: MainAxisSize.max,
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

  Widget _buildModuleField(ThemeData theme, List<String> _) {
    final gradeMap = _selectedGrade != null ? _modulesByGradeSemester[_selectedGrade] : null;
    final modules = gradeMap != null && _selectedSemester != null ? gradeMap[_selectedSemester] ?? [] : <String>[];    return _buildDropdown(
      theme: theme,
      label: 'MODULE',
      value: _selectedModule,
      items: modules,
      onChanged: (v) => setState(() => _selectedModule = v),
    );
  }

  Widget _buildGradeSemesterRow(ThemeData theme, List<String> semesters) {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            theme: theme,
            label: 'GRADE',
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
            label: 'SEMESTER',
            value: _selectedSemester,
            items: semesters,
            onChanged: (v) => setState(() => _selectedSemester = v),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required ThemeData theme,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showDropdownSheet(theme, label, value, items, onChanged),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.stackMd,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withAlpha(77),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? 'Select',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: value != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more,
                  color: theme.colorScheme.outline,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDropdownSheet(
    ThemeData theme,
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
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
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
    );
  }

  Widget _buildFileDropzone(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'FILE ATTACHMENT',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        if (_selectedFile != null)
          _buildFileSelected(theme)
        else
          _buildFileEmpty(theme),
      ],
    );
  }

  Widget _buildFileEmpty(ThemeData theme) {
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
                'Choose or Scan a File',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PDF, DOCX, ZIP (Max ${UploadConstants.maxFileSizeBytes ~/ (1024 * 1024)}MB)',
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

  Widget _buildFileSelected(ThemeData theme) {
    final file = _selectedFile!;
    return Column(
      children: [
        Container(
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
                  setState(() => _selectedFile = null);
                },
                icon: Icon(
                  Icons.close,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
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
                Icon(Icons.refresh, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Change file',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ThemeData theme, UploadFormState uploadState) {
    final enabled = _isFormValid && !uploadState.isUploading;
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
        child: uploadState.isUploading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Upload Resource',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDisclaimer(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackMd),
      child: Text(
        'By uploading, you agree to the community guidelines and academic integrity policy of CS Bouira.',
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

  const _AppBar({required this.theme});

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
              'Share a Resource',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.more_vert,
                color: theme.colorScheme.primary,
                size: 24,
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
          padding: const EdgeInsets.only(left: 4, bottom: 8),
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

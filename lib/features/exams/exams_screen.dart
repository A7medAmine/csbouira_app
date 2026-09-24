import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';

import '../../core/theme/app_spacing.dart';
import '../../data/models/catalog_file.dart';
import '../../data/navigation_data.dart';
import '../../data/providers/catalog_providers.dart';
import '../../shared/widgets/catalog_file_tile.dart';
import '../../shared/widgets/fetch_error_widget.dart';
import '../preview/open_catalog_file.dart';

const _yearKey = 'exams_year';
const _semesterKey = 'exams_semester';

/// Past exams and tests of one semester, grouped by module.
class ExamsScreen extends ConsumerStatefulWidget {
  const ExamsScreen({super.key});

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends ConsumerState<ExamsScreen> {
  String _year = kYears.first.name;
  String _semester = kSemesters[kYears.first.name]!.first;

  /// null shows both exams and tests.
  ResourceCategory? _kind;
  bool _correctionsOnly = false;

  @override
  void initState() {
    super.initState();
    _restoreSelection();
  }

  Future<void> _restoreSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final year = prefs.getString(_yearKey);
    final semester = prefs.getString(_semesterKey);
    if (!mounted || year == null || !kSemesters.containsKey(year)) return;
    setState(() {
      _year = year;
      final semesters = kSemesters[year]!;
      _semester = semesters.contains(semester) ? semester! : semesters.first;
    });
  }

  Future<void> _select({String? year, String? semester}) async {
    setState(() {
      if (year != null) {
        _year = year;
        _semester = kSemesters[year]!.first;
      }
      if (semester != null) _semester = semester;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_yearKey, _year);
    await prefs.setString(_semesterKey, _semester);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final indexAsync = ref.watch(catalogIndexProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.examsTitle),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          _Filters(
            year: _year,
            semester: _semester,
            kind: _kind,
            correctionsOnly: _correctionsOnly,
            onYear: (y) => _select(year: y),
            onSemester: (s) => _select(semester: s),
            onKind: (k) => setState(() => _kind = k),
            onCorrectionsOnly: (v) => setState(() => _correctionsOnly = v),
          ),
          Expanded(
            child: indexAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => FetchErrorWidget(error: e),
              data: (index) {
                final byModule = <String, List<CatalogFile>>{};
                for (final f in index.files) {
                  if (f.year != _year || f.semester != _semester) continue;
                  if (f.category != ResourceCategory.exam &&
                      f.category != ResourceCategory.test) {
                    continue;
                  }
                  if (_kind != null && f.category != _kind) continue;
                  if (_correctionsOnly && !f.isCorrection) continue;
                  byModule.putIfAbsent(f.module, () => []).add(f);
                }
                if (byModule.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        l10n.examsEmpty,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                final modules = byModule.keys.toList()..sort();
                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginMobile, 8, AppSpacing.marginMobile, 24,
                  ),
                  children: [
                    for (final module in modules) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                module,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Text(
                              l10n.fileCount(byModule[module]!.length),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (final file in byModule[module]!)
                        CatalogFileTile(
                          file: file,
                          subtitle: file.folderPath.skip(4).isEmpty
                              ? null
                              : file.folderPath.skip(4).join(' › '),
                          onTap: () => openCatalogFile(context, index, file),
                        ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final String year;
  final String semester;
  final ResourceCategory? kind;
  final bool correctionsOnly;
  final ValueChanged<String> onYear;
  final ValueChanged<String> onSemester;
  final ValueChanged<ResourceCategory?> onKind;
  final ValueChanged<bool> onCorrectionsOnly;

  const _Filters({
    required this.year,
    required this.semester,
    required this.kind,
    required this.correctionsOnly,
    required this.onYear,
    required this.onSemester,
    required this.onKind,
    required this.onCorrectionsOnly,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final y in kYears)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(y.name),
                      selected: y.name == year,
                      onSelected: (_) => onYear(y.name),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final s in kSemesters[year]!)
                ChoiceChip(
                  label: Text(s),
                  selected: s == semester,
                  onSelected: (_) => onSemester(s),
                ),
              FilterChip(
                label: Text(l10n.examsCorrectionsOnly),
                selected: correctionsOnly,
                onSelected: onCorrectionsOnly,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SegmentedButton<ResourceCategory?>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: null, label: Text(l10n.examsKindAll)),
              ButtonSegment(
                value: ResourceCategory.exam,
                label: Text(l10n.categoryExam),
              ),
              ButtonSegment(
                value: ResourceCategory.test,
                label: Text(l10n.categoryTest),
              ),
            ],
            selected: {kind},
            onSelectionChanged: (s) => onKind(s.first),
          ),
        ],
      ),
    );
  }
}

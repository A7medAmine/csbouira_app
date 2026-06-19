import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/drive_node.dart';
import '../../data/providers/drive_providers.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/upload_fab.dart';

enum SearchResultType { module, folder, file }

class SearchResult {
  final SearchResultType type;
  final String name;
  final String subtitle;
  final List<String> pathSegments;

  const SearchResult({
    required this.type,
    required this.name,
    required this.subtitle,
    required this.pathSegments,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  String _query = '';
  String? _filterYear;
  String? _filterSemester;
  String? _filterModule;
  SearchResultType? _filterType;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setFilterYear(String? v) {
    setState(() {
      _filterYear = v;
      _filterSemester = null;
      _filterModule = null;
    });
  }

  void _setFilterSemester(String? v) {
    setState(() {
      _filterSemester = v;
      _filterModule = null;
    });
  }

  void _setFilterModule(String? v) {
    setState(() => _filterModule = v);
  }

  void _setFilterType(SearchResultType? v) {
    setState(() => _filterType = v);
  }

  void _clearFilters() {
    setState(() {
      _filterYear = null;
      _filterSemester = null;
      _filterModule = null;
      _filterType = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocation = GoRouterState.of(context).uri.toString();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _SearchHeader(
                  controller: _searchController,
                  hasText: _query.isNotEmpty,
                  onChanged: (v) => setState(() => _query = v),
                  onClear: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  theme: theme,
                ),
                _FilterChips(
                  selectedYear: _filterYear,
                  selectedSemester: _filterSemester,
                  selectedModule: _filterModule,
                  selectedType: _filterType,
                  onYearTap: () =>
                      _showFilterOptions<String>(
                        title: 'Year',
                        optionsBuilder: (root) =>
                            root.years.keys.toList()..sort(),
                        selected: _filterYear,
                        onSelect: _setFilterYear,
                        formatLabel: (v) => v,
                      ),
                  onSemesterTap: () {
                    if (_filterYear == null) return;
                    _showFilterOptions<String>(
                      title: 'Semester',
                      optionsBuilder: (root) {
                        final yearNode = root.years[_filterYear!];
                        if (yearNode == null) return [];
                        return yearNode.subfolders.keys.toList()..sort();
                      },
                      selected: _filterSemester,
                      onSelect: _setFilterSemester,
                      formatLabel: (v) => v,
                    );
                  },
                  onModuleTap: () {
                    if (_filterYear == null || _filterSemester == null) return;
                    _showFilterOptions<String>(
                      title: 'Module',
                      optionsBuilder: (root) {
                        final yearNode = root.years[_filterYear!];
                        final semNode =
                            yearNode?.subfolders[_filterSemester!];
                        if (semNode == null) return [];
                        return semNode.subfolders.keys.toList()..sort();
                      },
                      selected: _filterModule,
                      onSelect: _setFilterModule,
                      formatLabel: (v) => v,
                    );
                  },
                  onTypeTap: () =>
                      _showFilterOptions<SearchResultType>(
                        title: 'Type',
                        optionsBuilder: (_) =>
                            SearchResultType.values,
                        selected: _filterType,
                        onSelect: _setFilterType,
                        formatLabel: (v) => switch (v) {
                          SearchResultType.module => 'Module',
                          SearchResultType.folder => 'Folder',
                          SearchResultType.file => 'File',
                        },
                      ),
                  onClearFilters: _filterYear != null ||
                          _filterSemester != null ||
                          _filterModule != null ||
                          _filterType != null
                      ? _clearFilters
                      : null,
                  theme: theme,
                ),
                Expanded(
                  child: _query.isEmpty
                      ? _EmptyState(theme: theme)
                      : _SearchResults(
                          query: _query,
                          filterYear: _filterYear,
                          filterSemester: _filterSemester,
                          filterModule: _filterModule,
                          filterType: _filterType,
                          theme: theme,
                        ),
                ),
              ],
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomNav(currentLocation: currentLocation),
            ),

            const UploadFab(),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions<T>(
    {required String title,
    required List<T> Function(DriveRootData) optionsBuilder,
    required T? selected,
    required void Function(T?) onSelect,
    required String Function(T) formatLabel}
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (ctx, ref, _) {
            final rootAsync = ref.watch(driveRootDataProvider);
            return rootAsync.when(
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const SizedBox(height: 0),
              data: (root) {
                final options = optionsBuilder(root);
                return SizedBox(
                  height: MediaQuery.of(ctx).size.height * 0.45,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: Theme.of(ctx)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(ctx).colorScheme.onSurface,
                                  ),
                            ),
                            if (selected != null)
                              GestureDetector(
                                onTap: () {
                                  onSelect(null);
                                  Navigator.pop(ctx);
                                },
                                child: Text(
                                  'Clear',
                                  style: Theme.of(ctx)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color:
                                            Theme.of(ctx).colorScheme.primary,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (options.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                'No options available',
                                style: Theme.of(ctx)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(ctx)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ),
                          )
                        else
                          Flexible(
                            child: ListView(
                              shrinkWrap: true,
                              children: options.map(
                                (opt) => _FilterOption<T>(
                                  label: formatLabel(opt),
                                  isSelected: opt == selected,
                                  onTap: () {
                                    onSelect(opt);
                                    Navigator.pop(ctx);
                                  },
                                ),
                              ).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final bool hasText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ThemeData theme;

  const _SearchHeader({
    required this.controller,
    required this.hasText,
    required this.onChanged,
    required this.onClear,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.stackMd,
        AppSpacing.marginMobile,
        0,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(200),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(30),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.arrow_back,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withAlpha(51),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    autofocus: false,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: hasText
                          ? GestureDetector(
                              onTap: onClear,
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            )
                          : null,
                      hintText: 'Search for modules, files...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final String? selectedYear;
  final String? selectedSemester;
  final String? selectedModule;
  final SearchResultType? selectedType;
  final VoidCallback onYearTap;
  final VoidCallback onSemesterTap;
  final VoidCallback onModuleTap;
  final VoidCallback onTypeTap;
  final VoidCallback? onClearFilters;
  final ThemeData theme;

  const _FilterChips({
    required this.selectedYear,
    required this.selectedSemester,
    required this.selectedModule,
    required this.selectedType,
    required this.onYearTap,
    required this.onSemesterTap,
    required this.onModuleTap,
    required this.onTypeTap,
    this.onClearFilters,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.stackSm,
        AppSpacing.marginMobile,
        AppSpacing.stackSm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(200),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(30),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _FilterChip(
              label: selectedYear ?? 'Year',
              isActive: selectedYear != null,
              onTap: onYearTap,
              theme: theme,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: selectedSemester ?? 'Semester',
              isActive: selectedSemester != null,
              onTap: onSemesterTap,
              theme: theme,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: selectedModule ?? 'Module',
              isActive: selectedModule != null,
              onTap: onModuleTap,
              theme: theme,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: selectedType != null
                  ? switch (selectedType!) {
                      SearchResultType.module => 'Module',
                      SearchResultType.folder => 'Folder',
                      SearchResultType.file => 'File',
                    }
                  : 'Type',
              isActive: selectedType != null,
              onTap: onTypeTap,
              theme: theme,
            ),
            if (onClearFilters != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClearFilters,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.error.withAlpha(51),
                    ),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final ThemeData theme;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withAlpha(26)
              : theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? theme.colorScheme.primary.withAlpha(51)
                : theme.colorScheme.outlineVariant.withAlpha(51),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 16,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterOption<T> extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withAlpha(51)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(26),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.manage_search,
              size: 80,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          Text(
            'Start Exploring',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.stackSm),
          Text(
            'Search for modules, files, or topics\nacross the entire CS Bouira library.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  final String query;
  final String? filterYear;
  final String? filterSemester;
  final String? filterModule;
  final SearchResultType? filterType;
  final ThemeData theme;

  const _SearchResults({
    required this.query,
    this.filterYear,
    this.filterSemester,
    this.filterModule,
    this.filterType,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootAsync = ref.watch(driveRootDataProvider);

    return rootAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Failed to search: $err')),
      data: (root) {
        final results = _performSearch(
          query,
          root.years,
          filterYear: filterYear,
          filterSemester: filterSemester,
          filterModule: filterModule,
          filterType: filterType,
        );

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.stackMd),
                Text(
                  'No results for "$query"',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginMobile,
            AppSpacing.stackLg,
            AppSpacing.marginMobile,
            160,
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Results',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${results.length} Items Found',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.stackMd),
            ...results.map(
              (result) => _ResultCard(
                result: result,
                theme: theme,
                onTap: () => _navigateToResult(context, result),
              ),
            ),
          ],
        );
      },
    );
  }

  List<SearchResult> _performSearch(
    String query,
    Map<String, DriveNode> years, {
    String? filterYear,
    String? filterSemester,
    String? filterModule,
    SearchResultType? filterType,
  }) {
    final q = query.toLowerCase();
    final results = <SearchResult>[];

    for (final yearEntry in years.entries) {
      final yearName = yearEntry.key;
      if (filterYear != null && yearName != filterYear) continue;
      final yearNode = yearEntry.value;

      for (final semEntry in yearNode.subfolders.entries) {
        final semName = semEntry.key;
        if (filterSemester != null && semName != filterSemester) continue;
        final semNode = semEntry.value;

        for (final modEntry in semNode.subfolders.entries) {
          final modName = modEntry.key;
          if (filterModule != null && modName != filterModule) continue;
          final modNode = modEntry.value;

          if ((filterType == null || filterType == SearchResultType.module)
              && modName.toLowerCase().contains(q)) {
            results.add(SearchResult(
              type: SearchResultType.module,
              name: modName,
              subtitle: '$yearName \u2022 $semName',
              pathSegments: [yearName, semName, modName],
            ));
          }

          for (final folderEntry in modNode.subfolders.entries) {
            final folderName = folderEntry.key;
            final folderNode = folderEntry.value;

            if ((filterType == null || filterType == SearchResultType.folder)
                && folderName.toLowerCase().contains(q)) {
              results.add(SearchResult(
                type: SearchResultType.folder,
                name: folderName,
                subtitle: '${folderNode.totalFiles} Files \u2022 $modName',
                pathSegments: [yearName, semName, modName, folderName],
              ));
            }

            if (filterType == null || filterType == SearchResultType.file) {
              for (final file in folderNode.files) {
                if (file.name.toLowerCase().contains(q)) {
                  results.add(SearchResult(
                    type: SearchResultType.file,
                    name: file.name,
                    subtitle: modName,
                    pathSegments: [yearName, semName, modName, folderName],
                  ));
                }
              }
            }
          }
        }
      }
    }

    return results;
  }

  void _navigateToResult(BuildContext context, SearchResult result) {
    final segments = result.pathSegments;
    final encodedName = Uri.encodeComponent(result.name);
    switch (result.type) {
      case SearchResultType.module:
        context.push(
          '/year/${Uri.encodeComponent(segments[0])}'
          '/semester/${Uri.encodeComponent(segments[1])}'
          '/module/${Uri.encodeComponent(segments[2])}'
          '?highlight=$encodedName',
        );
      case SearchResultType.folder:
        context.push(
          '/year/${Uri.encodeComponent(segments[0])}'
          '/semester/${Uri.encodeComponent(segments[1])}'
          '/module/${Uri.encodeComponent(segments[2])}'
          '/folder/${Uri.encodeComponent(segments[3])}'
          '?highlight=$encodedName',
        );
      case SearchResultType.file:
        context.push(
          '/year/${Uri.encodeComponent(segments[0])}'
          '/semester/${Uri.encodeComponent(segments[1])}'
          '/module/${Uri.encodeComponent(segments[2])}'
          '/folder/${Uri.encodeComponent(segments[3])}'
          '?highlight=$encodedName',
        );
    }
  }
}

class _ResultCard extends StatelessWidget {
  final SearchResult result;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ResultCard({
    required this.result,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (result.type) {
      SearchResultType.module => (
        Icons.menu_book,
        theme.colorScheme.primary,
        'Module',
      ),
      SearchResultType.folder => (
        Icons.folder,
        theme.colorScheme.secondary,
        'Folder',
      ),
      SearchResultType.file => (
        Icons.picture_as_pdf,
        Colors.red,
        'File',
      ),
    };

    final bgColor = switch (result.type) {
      SearchResultType.module => theme.colorScheme.primary.withAlpha(51),
      SearchResultType.folder => theme.colorScheme.secondary.withAlpha(51),
      SearchResultType.file => Colors.red.withAlpha(51),
    };

    final labelColor = switch (result.type) {
      SearchResultType.module => theme.colorScheme.primary,
      SearchResultType.folder => theme.colorScheme.secondary,
      SearchResultType.file => Colors.red,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.stackSm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF15151F).withAlpha(180),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(26),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: labelColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: labelColor.withAlpha(51),
                      ),
                    ),
                    child: Text(
                      label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: labelColor,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

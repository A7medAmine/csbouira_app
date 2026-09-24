import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/text_search.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/catalog_file.dart';
import '../../data/models/drive_node.dart';
import '../../data/providers/catalog_providers.dart';
import '../../data/providers/drive_providers.dart';
import '../../data/services/catalog_index.dart';
import '../../shared/file_icons.dart';
import '../../shared/widgets/fetch_error_widget.dart';
import '../../shared/widgets/network_banner.dart';
import '../preview/open_catalog_file.dart';


enum SearchResultType { module, folder, file }

class SearchResult {
  final SearchResultType type;
  final String name;
  final String subtitle;
  final List<String> pathSegments;

  /// Set for file results.
  final CatalogFile? file;
  final int score;

  const SearchResult({
    required this.type,
    required this.name,
    required this.subtitle,
    required this.pathSegments,
    this.file,
    this.score = 0,
  });
}

/// The last few queries that led to a result being opened.
class _RecentSearches {
  static const _key = 'recent_searches';
  static const _max = 8;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? const [];
  }

  static Future<List<String>> add(String query) async {
    final q = query.trim();
    final items = [...await load()];
    if (q.isEmpty) return items;
    items
      ..removeWhere((e) => e.toLowerCase() == q.toLowerCase())
      ..insert(0, q);
    if (items.length > _max) items.removeRange(_max, items.length);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, items);
    return items;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
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
  ResourceCategory? _filterCategory;
  List<String> _recentSearches = const [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _RecentSearches.load().then((items) {
      if (mounted) setState(() => _recentSearches = items);
    });
  }

  void _useRecentSearch(String query) {
    _searchController.text = query;
    _searchController.selection =
        TextSelection.collapsed(offset: query.length);
    setState(() => _query = query);
  }

  Future<void> _rememberQuery() async {
    final items = await _RecentSearches.add(_query);
    if (mounted) setState(() => _recentSearches = items);
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
    setState(() {
      _filterType = v;
      // Categories only apply to files.
      if (v != SearchResultType.file) _filterCategory = null;
    });
  }

  void _setFilterCategory(ResourceCategory? v) {
    setState(() {
      _filterCategory = v;
      if (v != null) _filterType = SearchResultType.file;
    });
  }

  void _clearFilters() {
    setState(() {
      _filterYear = null;
      _filterSemester = null;
      _filterModule = null;
      _filterType = null;
      _filterCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _SearchHeader(
                  controller: _searchController,
                  hasText: _searchController.text.isNotEmpty,
                  onChanged: (v) {
                    // Searching thousands of files on every keystroke is
                    // wasted work; wait for a short pause in typing.
                    _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 250), () {
                      if (mounted) setState(() => _query = v);
                    });
                  },
                  onClear: () {
                    _debounce?.cancel();
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  theme: theme,
                ),
                const NetworkBanner(),
                _FilterChips(
                  selectedYear: _filterYear,
                  selectedSemester: _filterSemester,
                  selectedModule: _filterModule,
                  selectedType: _filterType,
                  selectedCategory: _filterCategory,
                  onCategoryTap: () {
                    _showFilterOptions<ResourceCategory>(
                      title: l10n.searchFilterCategory,
                      optionsBuilder: (_) => ResourceCategory.values
                          .where((c) => c != ResourceCategory.other)
                          .toList(),
                      selected: _filterCategory,
                      onSelect: _setFilterCategory,
                      formatLabel: (v) => categoryLabel(l10n, v),
                    );
                  },
                  onYearTap: () =>
                      _showFilterOptions<String>(
                        title: l10n.searchFilterYear,
                        optionsBuilder: (root) =>
                            root.years.keys.toList()..sort(),
                        selected: _filterYear,
                        onSelect: _setFilterYear,
                        formatLabel: (v) => v,
                      ),
                  onSemesterTap: () {
                    if (_filterYear == null) return;
                    _showFilterOptions<String>(
                      title: l10n.searchFilterSemester,
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
                      title: l10n.searchFilterModule,
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
                  onTypeTap: () {
                    final typeL10n = AppLocalizations.of(context)!;
                    _showFilterOptions<SearchResultType>(
                      title: l10n.searchFilterType,
                      optionsBuilder: (_) =>
                          SearchResultType.values,
                      selected: _filterType,
                      onSelect: _setFilterType,
                      formatLabel: (v) => switch (v) {
                        SearchResultType.module => typeL10n.searchResultModule,
                        SearchResultType.folder => typeL10n.searchResultFolder,
                        SearchResultType.file => typeL10n.searchResultFile,
                      },
                    );
                  },
                  onClearFilters: _filterYear != null ||
                          _filterSemester != null ||
                          _filterModule != null ||
                          _filterType != null ||
                          _filterCategory != null
                      ? _clearFilters
                      : null,
                  theme: theme,
                ),
                Expanded(
                  child: _query.trim().isEmpty
                      ? _EmptyState(
                          theme: theme,
                          recentSearches: _recentSearches,
                          onRecentTap: _useRecentSearch,
                          onClearRecent: () async {
                            await _RecentSearches.clear();
                            if (mounted) setState(() => _recentSearches = const []);
                          },
                        )
                      : _SearchResults(
                          query: _query,
                          filterYear: _filterYear,
                          filterSemester: _filterSemester,
                          filterModule: _filterModule,
                          filterType: _filterType,
                          filterCategory: _filterCategory,
                          onResultOpened: _rememberQuery,
                          theme: theme,
                        ),
                ),
              ],
            ),

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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Consumer(
          builder: (ctx, ref, _) {
            final rootAsync = ref.watch(driveRootDataProvider);
            return rootAsync.when(
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppLocalizations.of(ctx)!.couldNotLoadFilters,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
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
                                  AppLocalizations.of(ctx)!.searchFilterClear,
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
                                AppLocalizations.of(ctx)!.noOptionsAvailable,
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
        ),
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
                onTap: () {
                  if (MediaQuery.of(context).viewInsets.bottom > 0) {
                    FocusScope.of(context).unfocus();
                    return;
                  }
                  final shell = StatefulNavigationShell.of(context);
                  if (Navigator.of(context).canPop()) {
                    context.pop();
                  } else if (shell.currentIndex != 0) {
                    shell.goBranch(0, initialLocation: true);
                  }
                },
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
                      hintText: AppLocalizations.of(context)!.searchHint,
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
  final ResourceCategory? selectedCategory;
  final VoidCallback onCategoryTap;
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
    required this.selectedCategory,
    required this.onCategoryTap,
    required this.onYearTap,
    required this.onSemesterTap,
    required this.onModuleTap,
    required this.onTypeTap,
    this.onClearFilters,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
              label: selectedYear ?? l10n.searchFilterYear,
              isActive: selectedYear != null,
              onTap: onYearTap,
              theme: theme,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: selectedSemester ?? l10n.searchFilterSemester,
              isActive: selectedSemester != null,
              onTap: onSemesterTap,
              theme: theme,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: selectedModule ?? l10n.searchFilterModule,
              isActive: selectedModule != null,
              onTap: onModuleTap,
              theme: theme,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: selectedType != null
                  ? switch (selectedType!) {
                      SearchResultType.module => l10n.searchResultModule,
                      SearchResultType.folder => l10n.searchResultFolder,
                      SearchResultType.file => l10n.searchResultFile,
                    }
                  : l10n.searchFilterType,
              isActive: selectedType != null,
              onTap: onTypeTap,
              theme: theme,
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: selectedCategory != null
                  ? categoryLabel(l10n, selectedCategory!)
                  : l10n.searchFilterCategory,
              isActive: selectedCategory != null,
              onTap: onCategoryTap,
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
  final List<String> recentSearches;
  final ValueChanged<String> onRecentTap;
  final VoidCallback onClearRecent;

  const _EmptyState({
    required this.theme,
    required this.recentSearches,
    required this.onRecentTap,
    required this.onClearRecent,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (recentSearches.isNotEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          AppSpacing.stackLg,
          AppSpacing.marginMobile,
          24,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.searchRecent,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              TextButton(
                onPressed: onClearRecent,
                child: Text(l10n.searchFilterClear),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final q in recentSearches)
                ActionChip(
                  avatar: const Icon(Icons.history, size: 16),
                  label: Text(q),
                  onPressed: () => onRecentTap(q),
                ),
            ],
          ),
        ],
      );
    }
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
            l10n.startExploring,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.stackSm),
          Text(
            l10n.searchEmptyMessage,
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
  final ResourceCategory? filterCategory;
  final VoidCallback onResultOpened;
  final ThemeData theme;

  const _SearchResults({
    required this.query,
    this.filterYear,
    this.filterSemester,
    this.filterModule,
    this.filterType,
    this.filterCategory,
    required this.onResultOpened,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootAsync = ref.watch(driveRootDataProvider);
    final index = ref.watch(catalogIndexProvider).valueOrNull;
    final l10n = AppLocalizations.of(context)!;

    return rootAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => FetchErrorWidget(
        error: err,
        message: l10n.failedToSearch,
      ),
      data: (root) {
        if (index == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = _performSearch(query, root.years, index, l10n);

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
                  l10n.noResultsForQuery(query),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginMobile,
            AppSpacing.stackLg,
            AppSpacing.marginMobile,
            24,
          ),
          itemCount: results.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.topResults,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      l10n.itemsFound(results.length),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              );
            }
            final result = results[i - 1];
            return _ResultCard(
              result: result,
              theme: theme,
              onTap: () {
                onResultOpened();
                _navigateToResult(context, index, result);
              },
            );
          },
        );
      },
    );
  }

  /// Modules and category folders are matched by name; files come from the
  /// catalogue index, which also covers nested folders and books.
  List<SearchResult> _performSearch(
    String query,
    Map<String, DriveNode> years,
    CatalogIndex index,
    AppLocalizations l10n,
  ) {
    final q = normalizeForSearch(query);
    if (q.isEmpty) return const [];
    final results = <SearchResult>[];
    final wantsFolders = filterCategory == null;

    if (wantsFolders) {
      for (final yearEntry in years.entries) {
        final yearName = yearEntry.key;
        if (filterYear != null && yearName != filterYear) continue;

        for (final semEntry in yearEntry.value.subfolders.entries) {
          final semName = semEntry.key;
          if (filterSemester != null && semName != filterSemester) continue;

          for (final modEntry in semEntry.value.subfolders.entries) {
            final modName = modEntry.key;
            if (filterModule != null && modName != filterModule) continue;

            if (filterType == null || filterType == SearchResultType.module) {
              final score = matchScore(q, normalizeForSearch(modName));
              if (score > 0) {
                results.add(SearchResult(
                  type: SearchResultType.module,
                  name: modName,
                  subtitle: '$yearName • $semName',
                  pathSegments: [yearName, semName, modName],
                  score: score + 20,
                ));
              }
            }

            if (filterType == null || filterType == SearchResultType.folder) {
              for (final folderEntry in modEntry.value.subfolders.entries) {
                final folderName = folderEntry.key;
                final score = matchScore(
                  q,
                  normalizeForSearch('$folderName $modName'),
                );
                if (score > 0) {
                  results.add(SearchResult(
                    type: SearchResultType.folder,
                    name: folderName,
                    subtitle:
                        '${l10n.fileCount(folderEntry.value.totalFiles)} • $modName',
                    pathSegments: [yearName, semName, modName, folderName],
                    score: score,
                  ));
                }
              }
            }
          }
        }
      }
    }

    if (filterType == null || filterType == SearchResultType.file) {
      final files = index.search(
        query,
        year: filterYear,
        semester: filterSemester,
        module: filterModule,
        category: filterCategory,
      );
      for (var i = 0; i < files.length; i++) {
        final f = files[i];
        results.add(SearchResult(
          type: SearchResultType.file,
          name: f.name,
          subtitle: '${f.module} • ${categoryLabel(l10n, f.category)}',
          pathSegments: f.folderPath,
          file: f,
          // index.search is already ranked; keep its order.
          score: files.length - i,
        ));
      }
    }

    // Modules and folders first when they match well, then files.
    final folders = results.where((r) => r.file == null).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return [...folders, ...results.where((r) => r.file != null)];
  }

  void _navigateToResult(
    BuildContext context,
    CatalogIndex index,
    SearchResult result,
  ) {
    final file = result.file;
    if (file != null) {
      openCatalogFile(context, index, file);
      return;
    }
    final segments = result.pathSegments;
    final encodedName = Uri.encodeComponent(result.name);
    final modulePath = '/year/${Uri.encodeComponent(segments[0])}'
        '/semester/${Uri.encodeComponent(segments[1])}'
        '/module/${Uri.encodeComponent(segments[2])}';
    switch (result.type) {
      case SearchResultType.module:
        context.push('$modulePath?highlight=$encodedName');
      case SearchResultType.folder:
      case SearchResultType.file:
        context.push(
          '$modulePath/folder/${Uri.encodeComponent(segments[3])}'
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
    final l10n = AppLocalizations.of(context)!;
    final (icon, color, label) = switch (result.type) {
      SearchResultType.module => (
        Icons.menu_book,
        theme.colorScheme.primary,
        l10n.searchResultModule,
      ),
      SearchResultType.folder => (
        Icons.folder,
        theme.colorScheme.secondary,
        l10n.searchResultFolder,
      ),
      SearchResultType.file => (
        fileIconFor(result.name),
        fileIconColorFor(result.name, theme),
        l10n.searchResultFile,
      ),
    };

    final bgColor = switch (result.type) {
      SearchResultType.module => theme.colorScheme.primary.withAlpha(51),
      SearchResultType.folder => theme.colorScheme.secondary.withAlpha(51),
      SearchResultType.file => fileIconColorFor(result.name, theme).withAlpha(51),
    };

    final labelColor = switch (result.type) {
      SearchResultType.module => theme.colorScheme.primary,
      SearchResultType.folder => theme.colorScheme.secondary,
      SearchResultType.file => fileIconColorFor(result.name, theme),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.stackSm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
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
                    Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left : Icons.chevron_right,
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

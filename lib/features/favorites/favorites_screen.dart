import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../data/models/drive_node.dart';
import '../../data/providers/drive_providers.dart';
import '../../data/providers/favorites_providers.dart';
import '../../data/providers/thumbnail_providers.dart';
import '../../data/services/file_cache_service.dart';
import '../../shared/widgets/fetch_error_widget.dart';
import '../../shared/widgets/network_banner.dart';
import '../preview/preview_args.dart';


// ─── Helpers ────────────────────────────────────────────────────────────────

String _shortYear(String year) {
  return year
      .replaceFirst('Licence ', 'L')
      .replaceFirst('Master ', 'M');
}

String _shortSemester(String sem) {
  final num = sem.replaceFirst('S', '');
  return 'SEM $num';
}

String _badgeFromSegments(List<String> segments) {
  if (segments.length < 2) return '';
  return '${_shortYear(segments[0])} - ${_shortSemester(segments[1])}';
}

String _moduleInitials(String name) {
  final words = name.split(RegExp(r'[\s\-]+'));
  if (words.length >= 2) {
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
  final cleaned = name.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  if (cleaned.length >= 2) return cleaned.substring(0, 2).toUpperCase();
  return cleaned.toUpperCase();
}

IconData _fileIcon(String name) {
  final ext = name.split('.').last.toLowerCase();
  switch (ext) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'doc':
    case 'docx':
      return Icons.description;
    case 'ppt':
    case 'pptx':
      return Icons.slideshow;
    case 'xls':
    case 'xlsx':
      return Icons.table_chart;
    case 'zip':
    case 'rar':
      return Icons.folder_zip;
    case 'mp4':
    case 'avi':
    case 'mkv':
      return Icons.play_circle;
    default:
      return Icons.insert_drive_file;
  }
}

Color _fileIconColor(String name, ThemeData theme) {
  final ext = name.split('.').last.toLowerCase();
  switch (ext) {
    case 'pdf':
      return theme.colorScheme.error;
    case 'doc':
    case 'docx':
      return const Color(0xFF448AFF);
    case 'ppt':
    case 'pptx':
      return const Color(0xFFFF7043);
    case 'xls':
    case 'xlsx':
      return const Color(0xFF66BB6A);
    default:
      return theme.colorScheme.primary;
  }
}

Color _fileIconBg(String name, ThemeData theme) {
  final ext = name.split('.').last.toLowerCase();
  switch (ext) {
    case 'pdf':
      return theme.colorScheme.errorContainer.withAlpha(51);
    case 'doc':
    case 'docx':
      return const Color(0xFF448AFF).withAlpha(51);
    case 'ppt':
    case 'pptx':
      return const Color(0xFFFF7043).withAlpha(51);
    case 'xls':
    case 'xlsx':
      return const Color(0xFF66BB6A).withAlpha(51);
    default:
      return theme.colorScheme.primaryContainer.withAlpha(51);
  }
}

// ─── Main Screen ────────────────────────────────────────────────────────────

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _selectedTab = 0;
  late final PageController _pageController;
  final Set<String> _removingIds = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.listen(favoritesListProvider, (prev, next) {
        next.whenData((favorites) {
          if (_removingIds.isNotEmpty && mounted) {
            final allRemoved = _removingIds.every((key) {
              return !favorites.any(
                  (f) => '${f.itemType}:${f.itemPath}' == key);
            });
            if (allRemoved) setState(() => _removingIds.clear());
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _removeFavorite(FavoriteItem item) async {
    final key = '${item.itemType}:${item.itemPath}';
    if (_removingIds.contains(key)) return;

    setState(() => _removingIds.add(key));

    await ref.read(favoritesListProvider.notifier).remove(
      item.itemType,
      item.itemPath,
    );
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.removedFromFavorites),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateTo(FavoriteItem item) {
    if (item.itemType == 'module') {
      final segments = item.pathSegments;
      if (segments.length >= 3) {
        context.push(
          '/year/${Uri.encodeComponent(segments[0])}'
          '/semester/${Uri.encodeComponent(segments[1])}'
          '/module/${Uri.encodeComponent(segments[2])}',
        );
      }
    } else if (item.itemType == 'file') {
      final fileId = extractDriveFileId(item.itemPath);
      final file = DriveFile(
        name: item.displayName,
        link: item.itemPath,
        downloadLink: fileId != null
            ? 'https://drive.usercontent.google.com/download?id=$fileId'
            : null,
        previewLink: fileId != null
            ? 'https://drive.google.com/file/d/$fileId/preview'
            : null,
      );
      context.push('/preview', extra: PreviewArgs(
        files: [file],
        initialIndex: 0,
        folderPath: item.folderPath?.split('>'),
      ));
    } else if (item.itemType == 'online_resource') {
      final uri = Uri.tryParse(item.itemPath);
      if (uri != null) {
        launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  String _tabTitle(int index, AppLocalizations l10n) {
    switch (index) {
      case 0:
        return l10n.favoritesSavedModules;
      case 1:
        return l10n.favoritesSavedFiles;
      case 2:
        return l10n.favoritesOnlineResources;
      default:
        return '';
    }
  }

  Widget _buildTabPage({
    required List<FavoriteItem> items,
    required int tabIndex,
    required ThemeData theme,
    required AsyncValue<DriveRootData> rootAsync,
    required AppLocalizations l10n,
  }) {
    if (items.isEmpty) {
      return _FavoritesEmptyState(theme: theme, tabIndex: tabIndex, l10n: l10n);
    }
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(favoritesListProvider);
        await ref.read(favoritesListProvider.future);
      },
      child: ScrollConfiguration(
        behavior: const _VerticalOnlyScrollBehavior(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginMobile,
            AppSpacing.stackLg,
            AppSpacing.marginMobile,
            24,
          ),
          children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _tabTitle(tabIndex, l10n),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            Text(
              l10n.favoritesTotal(items.length),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackMd),
        ...items.map((item) {
          final key = '${item.itemType}:${item.itemPath}';
          final isRemoving = _removingIds.contains(key);
          Widget card;
          switch (tabIndex) {
            case 0:
              card = _ModuleFavoriteCard(
                item: item,
                rootAsync: rootAsync,
                theme: theme,
                l10n: l10n,
                onRemove: () => _removeFavorite(item),
                onTap: () => _navigateTo(item),
              );
            case 1:
              card = _FileFavoriteCard(
                item: item,
                theme: theme,
                onRemove: () => _removeFavorite(item),
                onTap: () => _navigateTo(item),
              );
            case 2:
              card = _OnlineResourceFavoriteCard(
                item: item,
                theme: theme,
                onRemove: () => _removeFavorite(item),
                onTap: () => _navigateTo(item),
              );
            default:
              card = const SizedBox.shrink();
          }
          return AnimatedOpacity(
            opacity: isRemoving ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: AnimatedSlide(
              offset: isRemoving ? const Offset(-0.3, 0) : Offset.zero,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              child: AnimatedScale(
                scale: isRemoving ? 0.85 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: card,
              ),
            ),
          );
        }),
      ],
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favoritesAsync = ref.watch(favoritesListProvider);
    final rootAsync = ref.watch(driveRootDataProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF111221),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            // Gradient mesh background
            Positioned.fill(
              child: Stack(
                children: [
                  Positioned(
                    top: -40,
                    left: -40,
                    width: 200,
                    height: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withAlpha(13),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -40,
                    right: -40,
                    width: 200,
                    height: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primaryContainer.withAlpha(13),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                // Top App Bar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.marginMobile,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111221).withAlpha(204),
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
                        child: Text(
                          l10n.favoritesTitle,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const NetworkBanner(),

                // Content
                Expanded(
                  child: favoritesAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (err, _) => FetchErrorWidget(
                      error: err,
                      message: l10n.failedToLoadFavorites,
                    ),
                    data: (favorites) {
                      final displayFavorites = favorites.where((f) {
                        return !_removingIds.contains('${f.itemType}:${f.itemPath}');
                      }).toList();
                      final modules = displayFavorites
                          .where((f) => f.itemType == 'module')
                          .toList();
                      final files = displayFavorites
                          .where((f) => f.itemType == 'file')
                          .toList();
                      final onlineResources = displayFavorites
                          .where((f) => f.itemType == 'online_resource')
                          .toList();
                      final counts = [modules.length, files.length, onlineResources.length];

                      return Column(
                        children: [
                          _FavoritesTabBar(
                            selectedTab: _selectedTab,
                            counts: counts,
                            onTabChanged: (i) {
                              _pageController.animateToPage(
                                i,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                              setState(() => _selectedTab = i);
                            },
                            theme: theme,
                            l10n: l10n,
                          ),
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              physics: const PageScrollPhysics(),
                              onPageChanged: (i) =>
                                  setState(() => _selectedTab = i),
                              children: [
                                _buildTabPage(
                                  items: modules,
                                  tabIndex: 0,
                                  theme: theme,
                                  rootAsync: rootAsync,
                                  l10n: l10n,
                                ),
                                _buildTabPage(
                                  items: files,
                                  tabIndex: 1,
                                  theme: theme,
                                  rootAsync: rootAsync,
                                  l10n: l10n,
                                ),
                                _buildTabPage(
                                  items: onlineResources,
                                  tabIndex: 2,
                                  theme: theme,
                                  rootAsync: rootAsync,
                                  l10n: l10n,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tab Bar ────────────────────────────────────────────────────────────────

class _FavoritesTabBar extends StatelessWidget {
  final int selectedTab;
  final List<int> counts;
  final ValueChanged<int> onTabChanged;
  final ThemeData theme;
  final AppLocalizations l10n;

  const _FavoritesTabBar({
    required this.selectedTab,
    required this.counts,
    required this.onTabChanged,
    required this.theme,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final labels = [l10n.favoritesTabModules, l10n.favoritesTabFiles, l10n.favoritesTabResources];
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMobile,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111221).withAlpha(204),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(26),
          ),
        ),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          return _TabItem(
            label: labels[i],
            count: counts[i],
            isSelected: selectedTab == i,
            onTap: () => onTabChanged(i),
            theme: theme,
          );
        }),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _TabItem({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.only(
          top: 12,
          bottom: 12,
          end: 12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withAlpha(26)
                    : theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Module Card ────────────────────────────────────────────────────────────

class _ModuleFavoriteCard extends StatelessWidget {
  final FavoriteItem item;
  final AsyncValue<DriveRootData> rootAsync;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _ModuleFavoriteCard({
    required this.item,
    required this.rootAsync,
    required this.theme,
    required this.l10n,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final segments = item.pathSegments;
    final badge = _badgeFromSegments(segments);
    final initials = _moduleInitials(item.displayName);

    String? fileCountStr;
    String? folderCountStr;

    final rootData = rootAsync.asData?.value;
    if (rootData != null && segments.length >= 3) {
      final yearNode = rootData.years[segments[0]];
      final semNode = yearNode?.subfolders[segments[1]];
      final modNode = semNode?.subfolders[segments[2]];
      if (modNode != null) {
        final fc = modNode.totalFiles;
        final folC = modNode.subfolders.length;
        if (fc > 0) fileCountStr = l10n.favoritesFileCount(fc);
        if (folC > 0) folderCountStr = l10n.favoritesFolderCount(folC);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF15151F).withAlpha(179),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(77),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge + Star
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(26),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badge,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 11,
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  GestureDetector(
                    onTap: onRemove,
                    child: Icon(
                      Icons.star,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Module name with initials
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withAlpha(51),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Module context
              if (segments.length >= 2)
                Text(
                  '${segments[0]} \u2022 ${segments[1]}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

              // Divider + Footer
              if (folderCountStr != null || fileCountStr != null) ...[
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withAlpha(26),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (folderCountStr != null) ...[
                          Icon(
                            Icons.folder_open,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            folderCountStr,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (fileCountStr != null) ...[
                          Icon(
                            Icons.description,
                            size: 14,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            fileCountStr,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      l10n.viewModule,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── File Card ──────────────────────────────────────────────────────────────

class _FileFavoriteCard extends StatelessWidget {
  final FavoriteItem item;
  final ThemeData theme;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _FileFavoriteCard({
    required this.item,
    required this.theme,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _fileIcon(item.displayName);
    final iconColor = _fileIconColor(item.displayName, theme);
    final iconBg = _fileIconBg(item.displayName, theme);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF15151F).withAlpha(179),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(77),
            ),
          ),
          child: Row(
            children: [
              // File icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),

              // Name
              Expanded(
                child: Text(
                  item.displayName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Remove button
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.star,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Online Resource Card ───────────────────────────────────────────────────

class _OnlineResourceFavoriteCard extends ConsumerWidget {
  final FavoriteItem item;
  final ThemeData theme;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _OnlineResourceFavoriteCard({
    required this.item,
    required this.theme,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resourceType = item.resourceType ?? '';
    final isYoutube = resourceType.toLowerCase().contains('youtube');
    final thumbAsync = ref.watch(resourceThumbnailProvider(item.itemPath));
    final typeIcon = isYoutube ? Icons.play_circle_fill : Icons.language;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF15151F).withAlpha(179),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(77),
            ),
          ),
          child: Row(
            children: [
              // Thumbnail or fallback icon
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: thumbAsync.asData?.value != null
                      ? CachedNetworkImage(
                          imageUrl: thumbAsync.asData!.value!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _favoritesThumbnailFallback(typeIcon, theme),
                          errorWidget: (_, __, ___) => _favoritesThumbnailFallback(typeIcon, theme),
                        )
                      : _favoritesThumbnailFallback(typeIcon, theme),
                ),
              ),
              const SizedBox(width: 16),

              // Name + badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Type badge
                    if (resourceType.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withAlpha(102),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          resourceType,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Remove button
              GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.star,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _favoritesThumbnailFallback(IconData icon, ThemeData theme) {
  return Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.colorScheme.primary.withAlpha(26),
          theme.colorScheme.surfaceContainerHigh,
        ],
      ),
    ),
    child: Center(
      child: Icon(
        icon,
        color: theme.colorScheme.primary.withAlpha(179),
        size: 28,
      ),
    ),
  );
}

// ─── Empty State ────────────────────────────────────────────────────────────

class _FavoritesEmptyState extends StatelessWidget {
  final ThemeData theme;
  final int tabIndex;
  final AppLocalizations l10n;

  const _FavoritesEmptyState({
    required this.theme,
    required this.tabIndex,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle) = switch (tabIndex) {
      0 => (
        Icons.menu_book,
        l10n.noModulesSaved,
        l10n.noModulesSavedHint,
      ),
      1 => (
        Icons.insert_drive_file,
        l10n.noFilesSaved,
        l10n.noFilesSavedHint,
      ),
      _ => (
        Icons.language,
        l10n.noResourcesSaved,
        l10n.noResourcesSavedHint,
      ),
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withAlpha(13),
                ),
              ),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surfaceContainer,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withAlpha(51),
                  ),
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackLg),
          Text(
            title,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.stackSm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(38),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Text(
                l10n.browseHome,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalOnlyScrollBehavior extends ScrollBehavior {
  const _VerticalOnlyScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

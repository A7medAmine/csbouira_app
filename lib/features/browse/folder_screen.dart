import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/catalog_file.dart'
    show ResourceCategory, categoryFromFolder, moduleKeyOf;
import '../../data/navigation_data.dart';
import '../../data/providers/drive_providers.dart';
import '../../shared/widgets/favorite_star.dart';
import 'widgets/module_actions.dart';
import '../../core/theme/app_surfaces.dart';

class FolderScreen extends ConsumerWidget {
  final String year;
  final String semester;
  final String module;

  const FolderScreen({
    super.key,
    required this.year,
    required this.semester,
    required this.module,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final moduleNodeAsync = ref.watch(
      driveNodeProvider(drivePathKey([year, semester, module])),
    );

    final folderFileCounts = <String, int>{};
    final moduleNode = moduleNodeAsync.asData?.value;
    // Older modules share the standard category folders; newer ones (e.g.
    // Licence 1 2024-2025) name theirs freely, so show what Drive has.
    final actualFolders = moduleNode?.subfolders.keys.toList() ?? const [];
    final folders = actualFolders.every(kFolderTypes.contains)
        ? kFolderTypes
        : actualFolders;
    if (moduleNode != null) {
      for (final f in folders) {
        folderFileCounts[f] = moduleNode.subfolders[f]?.totalFiles ?? 0;
      }
    }

    return Scaffold(
      backgroundColor: context.surfaces.shell,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
          child: SafeArea(
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
                            color: theme.colorScheme.primaryContainer.withAlpha(
                              13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    // AppBar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.marginMobile,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: context.surfaces.shell.withAlpha(204),
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outlineVariant.withAlpha(
                              77,
                            ),
                          ),
                        ),
                      ),
                      child: Row(
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.moduleBreadcrumb(
                                    year,
                                    semesterLabel(semester, l10n.promoArchive),
                                  ),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  module,
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          OfflinePackButton(
                            moduleKey: moduleKeyOf(year, semester, module),
                            moduleName: module,
                            moduleNode: moduleNode,
                          ),
                          FollowModuleButton(
                            moduleKey: moduleKeyOf(year, semester, module),
                          ),
                          FavoriteStar(
                            itemType: 'module',
                            itemPath:
                                '$year>subfolders>$semester>subfolders>$module',
                            displayName: module,
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => ref.refreshDriveData(),
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.marginMobile,
                            AppSpacing.stackLg,
                            AppSpacing.marginMobile,
                            24,
                          ),
                          children: [
                            OfflinePackBanner(
                              moduleKey: moduleKeyOf(year, semester, module),
                            ),
                            // Folder grid
                            _buildFolderGrid(
                              context,
                              theme,
                              folders,
                              folderFileCounts,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFolderGrid(
    BuildContext context,
    ThemeData theme,
    List<String> folders,
    Map<String, int> counts,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AppSpacing.stackMd;
        final cardWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children:
              folders.asMap().entries.map((entry) {
                final folder = entry.value;
                final fCount = counts[folder] ?? 0;
                final isEmpty = fCount == 0;
                // An odd last card (Tests in the standard layout) spans the
                // full width.
                final isTests = folders.length.isOdd &&
                    entry.key == folders.length - 1;
                final iconColor = _folderIconColor(folder, theme);
                final iconData = _folderIconData(folder);

                if (isTests) {
                  return SizedBox(
                    width: constraints.maxWidth,
                    child: _FolderCard(
                      folder: folder,
                      fileCount: fCount,
                      isEmpty: isEmpty,
                      iconColor: iconColor,
                      iconData: iconData,
                      isHorizontal: true,
                      onTap:
                          isEmpty
                              ? null
                              : () => context.push(
                                '/year/${Uri.encodeComponent(year)}'
                                '/semester/${Uri.encodeComponent(semester)}'
                                '/module/${Uri.encodeComponent(module)}'
                                '/folder/${Uri.encodeComponent(folder)}',
                              ),
                    ),
                  );
                }

                return SizedBox(
                  width: cardWidth,
                  child: _FolderCard(
                    folder: folder,
                    fileCount: fCount,
                    isEmpty: isEmpty,
                    iconColor: iconColor,
                    iconData: iconData,
                    isHorizontal: false,
                    onTap:
                        isEmpty
                            ? null
                            : () => context.push(
                              '/year/${Uri.encodeComponent(year)}'
                              '/semester/${Uri.encodeComponent(semester)}'
                              '/module/${Uri.encodeComponent(module)}'
                              '/folder/${Uri.encodeComponent(folder)}',
                            ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  Color _folderIconColor(String folder, ThemeData theme) {
    switch (categoryFromFolder(folder)) {
      case ResourceCategory.exam:
        return theme.colorScheme.secondary;
      case ResourceCategory.summary:
        return theme.colorScheme.tertiary;
      case ResourceCategory.test:
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _folderIconData(String folder) {
    switch (categoryFromFolder(folder)) {
      case ResourceCategory.course:
        return Icons.menu_book;
      case ResourceCategory.exam:
        return Icons.description;
      case ResourceCategory.summary:
        return Icons.article;
      case ResourceCategory.tdTp:
        return Icons.build;
      case ResourceCategory.test:
        return Icons.fact_check;
      default:
        return Icons.folder;
    }
  }
}

class _FolderCard extends StatelessWidget {
  final String folder;
  final int fileCount;
  final bool isEmpty;
  final Color iconColor;
  final IconData iconData;
  final bool isHorizontal;
  final VoidCallback? onTap;

  const _FolderCard({
    required this.folder,
    required this.fileCount,
    required this.isEmpty,
    required this.iconColor,
    required this.iconData,
    required this.isHorizontal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.surfaces.card.withAlpha(179),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isEmpty
                    ? theme.colorScheme.outlineVariant.withAlpha(51)
                    : theme.colorScheme.outlineVariant.withAlpha(77),
          ),
        ),
        child:
            isHorizontal
                ? _horizontalLayout(context, theme, l10n)
                : _verticalLayout(context, theme, l10n),
      ),
    );
  }

  Widget _verticalLayout(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Text(
          folder,
          style: theme.textTheme.titleMedium?.copyWith(
            color: isEmpty ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isEmpty ? l10n.folderEmpty : l10n.folderFileCount(fileCount),
          style: theme.textTheme.labelMedium?.copyWith(
            color:
                isEmpty
                    ? theme.colorScheme.onSurfaceVariant.withAlpha(128)
                    : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _horizontalLayout(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        const SizedBox(width: AppSpacing.stackMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                folder,
                style: theme.textTheme.titleMedium?.copyWith(
                  color:
                      isEmpty
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isEmpty ? l10n.folderEmpty : l10n.folderFileCount(fileCount),
                style: theme.textTheme.labelMedium?.copyWith(
                  color:
                      isEmpty
                          ? theme.colorScheme.onSurfaceVariant.withAlpha(128)
                          : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (!isEmpty)
          Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.chevron_left
                : Icons.chevron_right,
            color: theme.colorScheme.outline,
          ),
      ],
    );
  }
}

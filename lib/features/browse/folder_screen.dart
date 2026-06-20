import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/navigation_data.dart';
import '../../data/providers/drive_providers.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/favorite_star.dart';
import '../../shared/widgets/upload_fab.dart';

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
    final moduleNodeAsync = ref.watch(driveNodeProvider(drivePathKey([year, semester, module])));
    final currentLocation = GoRouterState.of(context).uri.toString();

    final folderFileCounts = <String, int>{};
    final moduleNode = moduleNodeAsync.asData?.value;
    if (moduleNode != null) {
      for (final f in kFolderTypes) {
        folderFileCounts[f] = moduleNode.subfolders[f]?.totalFiles ?? 0;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111221),
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
                // AppBar
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
                              '$year / $semester',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              module,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.marginMobile,
                      AppSpacing.stackLg,
                      AppSpacing.marginMobile,
                      140,
                    ),
                    children: [
                      // Badge pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary.withAlpha(51),
                          ),
                        ),
                        child: Text(
                          'Course Module',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.stackLg),

                      // Folder grid
                      _buildFolderGrid(context, theme, folderFileCounts),
                    ],
                  ),
                ),
              ],
            ),

            // Bottom navigation
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

  Widget _buildFolderGrid(
    BuildContext context,
    ThemeData theme,
    Map<String, int> counts,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = AppSpacing.stackMd;
        final cardWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: kFolderTypes.map((folder) {
            final fCount = counts[folder] ?? 0;
            final isEmpty = fCount == 0;
            final isTests = folder == 'Tests';
            final iconColor = _folderIconColor(folder, theme);
            final iconData = _folderIconData(folder);

            // Tests spans full width with horizontal layout
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
                  onTap: isEmpty
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
                onTap: isEmpty
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
    switch (folder) {
      case 'Cours':
      case 'TDs & TPs':
        return theme.colorScheme.primary;
      case 'Exams':
        return theme.colorScheme.secondary;
      case 'Résumé':
        return theme.colorScheme.tertiary;
      case 'Tests':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _folderIconData(String folder) {
    switch (folder) {
      case 'Cours':
        return Icons.menu_book;
      case 'Exams':
        return Icons.description;
      case 'Résumé':
        return Icons.article;
      case 'TDs & TPs':
        return Icons.build;
      case 'Tests':
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF15151F).withAlpha(179),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEmpty
                ? theme.colorScheme.outlineVariant.withAlpha(51)
                : theme.colorScheme.outlineVariant.withAlpha(77),
          ),
        ),
        child: isHorizontal ? _horizontalLayout(theme) : _verticalLayout(theme),
      ),
    );
  }

  Widget _verticalLayout(ThemeData theme) {
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
            color: isEmpty ? theme.colorScheme.onSurfaceVariant : Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isEmpty ? 'Empty' : '$fileCount Files',
          style: theme.textTheme.labelMedium?.copyWith(
            color: isEmpty
                ? theme.colorScheme.onSurfaceVariant.withAlpha(128)
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _horizontalLayout(ThemeData theme) {
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
                  color: isEmpty ? theme.colorScheme.onSurfaceVariant : Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isEmpty ? 'Empty' : '$fileCount Files',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isEmpty
                      ? theme.colorScheme.onSurfaceVariant.withAlpha(128)
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (!isEmpty)
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.outline,
          ),
      ],
    );
  }
}

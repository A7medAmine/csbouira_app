import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/providers/drive_providers.dart';
import '../../shared/widgets/favorite_star.dart';

String _moduleInitials(String name) {
  final words = name.split(RegExp(r'[\s\-]+'));
  if (words.length >= 2) {
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
  final cleaned = name.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  if (cleaned.length >= 2) return cleaned.substring(0, 2).toUpperCase();
  return cleaned.toUpperCase();
}

class ModuleScreen extends ConsumerStatefulWidget {
  final String year;
  final String semester;

  const ModuleScreen({super.key, required this.year, required this.semester});

  @override
  ConsumerState<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends ConsumerState<ModuleScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nodeAsync = ref.watch(
      driveNodeProvider(drivePathKey([widget.year, widget.semester])),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF111221),
      resizeToAvoidBottomInset: false,
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
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${widget.year} / ${widget.semester}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.more_vert,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: nodeAsync.when(
                        loading:
                            () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                        error:
                            (err, _) =>
                                Center(child: Text('Failed to load: $err')),
                        data: (node) {
                          if (node == null)
                            return const Center(
                              child: Text('No modules found'),
                            );
                          final allModules =
                              node.subfolders.entries.where((e) {
                                return e.key != 'Books & Exercices';
                              }).toList();
                          final filtered =
                              _query.isEmpty
                                  ? allModules
                                  : allModules
                                      .where(
                                        (e) => e.key.toLowerCase().contains(
                                          _query.toLowerCase(),
                                        ),
                                      )
                                      .toList();
                          if (allModules.isEmpty) {
                            return const Center(
                              child: Text('No modules available'),
                            );
                          }

                          final totalFiles = allModules.fold<int>(
                            0,
                            (sum, e) => sum + e.value.totalFiles,
                          );

                          return ListView(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.marginMobile,
                              AppSpacing.stackLg,
                              AppSpacing.marginMobile,
                              24,
                            ),
                            children: [
                              // Search & Filter Row
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            theme.colorScheme.surfaceContainer,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: theme
                                              .colorScheme
                                              .outlineVariant
                                              .withAlpha(77),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.search,
                                            size: 20,
                                            color: theme.colorScheme.outline,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: TextField(
                                              controller: _searchController,
                                              onChanged:
                                                  (v) => setState(
                                                    () => _query = v,
                                                  ),
                                              style: theme.textTheme.bodyMedium,
                                              decoration: InputDecoration(
                                                hintText: 'Search modules...',
                                                hintStyle: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: theme
                                                          .colorScheme
                                                          .outline
                                                          .withAlpha(128),
                                                    ),
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 12,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.stackMd),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.colorScheme.outlineVariant
                                            .withAlpha(77),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.filter_list,
                                      size: 20,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.stackLg),

                              // Section header
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ACTIVE MODULES',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                              letterSpacing: 1.5,
                                              color: theme.colorScheme.primary,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _query.isEmpty
                                            ? 'All Modules'
                                            : 'Search Results',
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${_query.isEmpty ? allModules.length : filtered.length} Total',
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color:
                                              theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: AppSpacing.stackMd),

                              // Module cards
                              if (filtered.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 48,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'No modules match your search',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color:
                                                theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                )
                              else
                                ...filtered.map((entry) {
                                  final fc = entry.value.totalFiles;
                                  final folCount =
                                      entry.value.subfolders.length;
                                  final initials = _moduleInitials(entry.key);
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: AppSpacing.stackMd,
                                    ),
                                    child: GestureDetector(
                                      onTap:
                                          () => context.push(
                                            '/year/${Uri.encodeComponent(widget.year)}'
                                            '/semester/${Uri.encodeComponent(widget.semester)}'
                                            '/module/${Uri.encodeComponent(entry.key)}',
                                          ),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF15151F,
                                          ).withAlpha(179),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: theme
                                                .colorScheme
                                                .outlineVariant
                                                .withAlpha(77),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            // Initials badge
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color: theme
                                                    .colorScheme
                                                    .primaryContainer
                                                    .withAlpha(51),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: theme
                                                      .colorScheme
                                                      .primary
                                                      .withAlpha(51),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  initials,
                                                  style: theme
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        color:
                                                            theme
                                                                .colorScheme
                                                                .primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: AppSpacing.stackMd,
                                            ),
                                            // Name + metadata
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    entry.key,
                                                    style: theme
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          color: Colors.white,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.folder_open,
                                                        size: 14,
                                                        color:
                                                            theme
                                                                .colorScheme
                                                                .outline,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        folCount > 0
                                                            ? '$folCount folders · $fc files'
                                                            : '$fc files',
                                                        style: theme
                                                            .textTheme
                                                            .labelMedium
                                                            ?.copyWith(
                                                              color:
                                                                  theme
                                                                      .colorScheme
                                                                      .onSurfaceVariant,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            FavoriteStar(
                                              itemType: 'module',
                                              itemPath:
                                                  '${widget.year}>subfolders>${widget.semester}>subfolders>${entry.key}',
                                              displayName: entry.key,
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.chevron_right,
                                              color: theme.colorScheme.outline,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                              const SizedBox(height: AppSpacing.stackMd),

                              // Bottom info cards
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF15151F,
                                        ).withAlpha(179),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: theme
                                              .colorScheme
                                              .outlineVariant
                                              .withAlpha(51),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            color: theme.colorScheme.primary,
                                            size: 22,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Total Modules',
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                          ),
                                          Text(
                                            '${allModules.length}',
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.stackMd),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF15151F,
                                        ).withAlpha(179),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: theme
                                              .colorScheme
                                              .outlineVariant
                                              .withAlpha(51),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.cloud_download,
                                            color: theme.colorScheme.tertiary,
                                            size: 22,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Total Files',
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color:
                                                      theme
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                ),
                                          ),
                                          Text(
                                            '$totalFiles',
                                            style: theme
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
        ),
      ),
    );
  }
}

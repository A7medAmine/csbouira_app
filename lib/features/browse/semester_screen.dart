import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/navigation_data.dart';
import '../../data/models/drive_node.dart';
import '../../data/providers/drive_providers.dart';
import '../../data/providers/thumbnail_providers.dart';
import '../../shared/widgets/favorite_star.dart';

class SemesterScreen extends ConsumerWidget {
  final String year;

  const SemesterScreen({super.key, required this.year});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final semesters = kSemesters[year] ?? [];
    final nodeAsync = ref.watch(driveNodeProvider(drivePathKey([year])));
    final onlineAsync = ref.watch(onlineResourcesProvider);

    Map<String, int> moduleCounts = {};
    nodeAsync.asData?.value?.subfolders.forEach((key, node) {
      moduleCounts[key] = node.subfolders.length;
    });

    final yearResources = onlineAsync.asData?.value[year];

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

            // Main content
            Column(
              children: [
                // Top AppBar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.marginMobile,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withAlpha(204),
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          year,
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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.marginMobile,
                      AppSpacing.marginMobile,
                      AppSpacing.marginMobile,
                      24,
                    ),
                    children: [
                      // Academic year badge + description
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withAlpha(26),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.primary.withAlpha(51),
                              ),
                            ),
                            child: Text(
                              'Academic Year 2025/2026',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.stackMd),
                      Text(
                        'Select a semester to access courses, tutorials, and academic materials for your $year.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.stackLg),

                      // Semester cards
                      ...semesters.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final sem = entry.value;
                        final count = moduleCounts[sem] ?? 0;

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: idx < semesters.length - 1
                                ? AppSpacing.stackMd
                                : 0,
                          ),
                          child: _SemesterCard(
                            semester: sem,
                            moduleCount: count,
                            year: year,
                          ),
                        );
                      }),

                      const SizedBox(height: AppSpacing.stackMd),

                      // Books & Exercises card
                      _BooksExercisesCard(year: year),

                      const SizedBox(height: AppSpacing.stackLg),

                      // Online Resources section
                      _OnlineResourcesSection(resources: yearResources),
                    ],
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

IconData _semesterIcon(int num) {
  switch (num) {
    case 1: return Icons.filter_1;
    case 2: return Icons.filter_2;
    case 3: return Icons.filter_3;
    case 4: return Icons.filter_4;
    case 5: return Icons.filter_5;
    case 6: return Icons.filter_6;
    case 7: return Icons.filter_7;
    case 8: return Icons.filter_8;
    case 9: return Icons.filter_9;
    default: return Icons.filter_1;
  }
}

class _SemesterCard extends StatelessWidget {
  final String semester;
  final int moduleCount;
  final String year;

  const _SemesterCard({
    required this.semester,
    required this.moduleCount,
    required this.year,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semNum = int.tryParse(semester.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final label = semester;
    final icon = _semesterIcon(semNum);
    final iconColor = theme.colorScheme.primary;
    final iconBg = theme.colorScheme.primaryContainer.withAlpha(51);
    final glowColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => context.push(
        '/year/${Uri.encodeComponent(year)}/semester/${Uri.encodeComponent(semester)}',
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF15151F).withAlpha(204),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(77),
          ),
        ),
        child: Stack(
          children: [
            // Gradient spotlight
            Positioned(
              right: -45,
              top: -45,
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.6,
                    colors: [
                      glowColor.withAlpha(40),
                      glowColor.withAlpha(13),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  label,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 4),
                // Module count
                Row(
                  children: [
                    Icon(
                      Icons.auto_stories,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$moduleCount Modules',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Explore link
                Row(
                  children: [
                    Text(
                      'Explore Resources',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BooksExercisesCard extends StatelessWidget {
  final String year;

  const _BooksExercisesCard({required this.year});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

final isMaster = year.startsWith('Master');
if (isMaster) {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainer.withAlpha(128),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withAlpha(77),
      ),
    ),
    child: Row(
      children: [
        Icon(
          Icons.menu_book,
          color: theme.colorScheme.onSurfaceVariant,
          size: 32,
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Books & Exercices',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'No content available for this grade',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
return GestureDetector(
  onTap: () => context.push(
    '/year/${Uri.encodeComponent(year)}/books',
  ),
  child: Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: const Color(0xFF15151F).withAlpha(204),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withAlpha(77),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withAlpha(51),
                theme.colorScheme.surfaceContainerHighest,
              ],
            ),
          ),
          child: Icon(
            Icons.menu_book,
            color: theme.colorScheme.primary,
            size: 32,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Books & Exercices',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Access digital library and solved problem sets',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
  }
}

class _OnlineResourcesSection extends StatelessWidget {
  final Map<String, List<OnlineResource>>? resources;

  const _OnlineResourcesSection({this.resources});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (resources == null || resources!.isEmpty) return const SizedBox.shrink();

    // Flatten into a list of (subject, OnlineResource) pairs
    final items = <_ResourceItem>[];
    for (final entry in resources!.entries) {
      for (final r in entry.value) {
        items.add(_ResourceItem(subject: entry.key, resource: r));
      }
    }

    items.sort((a, b) {
      final aIsYt = a.resource.url.contains('youtube') || a.resource.url.contains('youtu.be');
      final bIsYt = b.resource.url.contains('youtube') || b.resource.url.contains('youtu.be');
      if (aIsYt && !bIsYt) return -1;
      if (!aIsYt && bIsYt) return 1;
      return 0;
    });

    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ONLINE RESOURCES',
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1.5,
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: items.map((item) {
              return Padding(
                padding: EdgeInsets.only(
                  right: items.last == item ? 0 : AppSpacing.stackMd,
                ),
                child: _OnlineResourceCard(
                  subject: item.subject,
                  resource: item.resource,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ResourceItem {
  final String subject;
  final OnlineResource resource;
  const _ResourceItem({required this.subject, required this.resource});
}

class _OnlineResourceCard extends ConsumerWidget {
  final String subject;
  final OnlineResource resource;

  const _OnlineResourceCard({
    required this.subject,
    required this.resource,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final thumbAsync = ref.watch(resourceThumbnailProvider(resource.url));
    final typeIcon = resource.type.toLowerCase().contains('youtube')
        ? Icons.play_circle_fill
        : Icons.language;

    return GestureDetector(
      onTap: () {
        final uri = Uri.tryParse(resource.url);
        if (uri != null) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(AppSpacing.stackMd),
        decoration: BoxDecoration(
          color: const Color(0xFF15151F).withAlpha(204),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(77),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail or fallback icon
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: double.infinity,
                height: 100,
                child: thumbAsync.asData?.value != null
                    ? CachedNetworkImage(
                        imageUrl: thumbAsync.asData!.value!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _thumbnailFallback(theme, typeIcon),
                        errorWidget: (_, __, ___) => _thumbnailFallback(theme, typeIcon),
                      )
                    : _thumbnailFallback(theme, typeIcon),
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            // Subject label
            Text(
              subject.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            // Resource name + FavoriteStar
            Row(
              children: [
                Expanded(
                  child: Text(
                    resource.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                FavoriteStar(
                  itemType: 'online_resource',
                  itemPath: resource.url,
                  displayName: resource.name,
                  resourceType: resource.type,
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Type + Language badges
            Row(
              children: [
                _Badge(
                  label: resource.type,
                  color: theme.colorScheme.primaryContainer.withAlpha(102),
                  textColor: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                _Badge(
                  label: resource.language,
                  color: theme.colorScheme.secondaryContainer.withAlpha(102),
                  textColor: theme.colorScheme.onSecondaryContainer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _thumbnailFallback(ThemeData theme, IconData icon) {
  return Container(
    width: double.infinity,
    height: 100,
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
        size: 40,
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

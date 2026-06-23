import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/navigation_data.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/drive_providers.dart';
import '../../shared/widgets/avatar_widget.dart';
import '../../shared/widgets/network_banner.dart';

String _initials(String name) {
  if (name.isEmpty) return 'G';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  return name[0].toUpperCase();
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final countsAsync = ref.watch(fileCountsProvider);
    final counts = countsAsync.asData?.value ?? {};
    final user = ref.watch(currentUserProvider);

    String displayName;
    String? avatarUrl;
    String? avatarBase64;

    if (user != null) {
      final profileAsync = ref.watch(profileProvider(user.id));
      final profile = profileAsync.asData?.value;
      final meta = user.userMetadata;
      final emailName = user.email?.split('@').first;
      displayName =
          (profile?['full_name'] as String?) ??
          meta?['full_name'] as String? ??
          meta?['name'] as String? ??
          emailName ??
          'User';
      avatarUrl =
          (profile?['avatar_url'] as String?) ??
          meta?['avatar_url'] as String? ??
          meta?['picture'] as String?;
      avatarBase64 = null;
    } else {
      final guestProfile = ref.watch(guestProfileProvider).asData?.value ?? {};
      final guestName = guestProfile['name'] as String? ?? '';
      displayName = guestName.isNotEmpty ? guestName : 'Guest';
      avatarBase64 = guestProfile['avatarBase64'] as String?;
      avatarUrl = null;
    }

    final avatarInitials = _initials(displayName);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSpacing.containerMax),
          child: SafeArea(
            child: Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.marginMobile,
                    right: AppSpacing.marginMobile,
                    top: 0,
                    bottom: 24,
                  ),
                  children: [
                    const SizedBox(height: 16),
                    // Top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CS BOUIRA',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: AvatarWidget(
                            size: 40,
                            avatarUrl: avatarUrl,
                            avatarBase64: avatarBase64,
                            initials: avatarInitials,
                            showEditButton: false,
                          ),
                        ),
                      ],
                    ),

                    const NetworkBanner(),
                    const SizedBox(height: 24),

                    // Hero section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, $displayName',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Access all Computer Science resources from University of Bouira in one place.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Search bar
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => context.push('/search'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.stackMd,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant.withAlpha(
                                    77,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: theme.colorScheme.outline,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Search courses, files, or exams...',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant.withAlpha(77),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.qr_code_scanner),
                            color: theme.colorScheme.onSurfaceVariant,
                            onPressed: () => context.push('/scan'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Academic Path header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Academic Path',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withAlpha(
                              51,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            'SELECT YEAR',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Bento grid
                    _BentoYearGrid(counts: counts),

                    const SizedBox(height: 32),

                    _StatsSection(),
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

class _BentoYearGrid extends StatelessWidget {
  final Map<String, int> counts;

  const _BentoYearGrid({required this.counts});

  @override
  Widget build(BuildContext context) {
    const gap = 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final halfWidth = constraints.maxWidth / 2;
        final fullWidth = constraints.maxWidth;

        return Column(
          children: [
            // Row 1: Licence 1 + Licence 2
            Row(
              children: [
                SizedBox(
                  width: halfWidth - gap / 2,
                  child: _YearCard(
                    year: kYears[0],
                    fileCount: counts[kYears[0].name] ?? 0,
                  ),
                ),
                const SizedBox(width: gap),
                SizedBox(
                  width: halfWidth - gap / 2,
                  child: _YearCard(
                    year: kYears[1],
                    fileCount: counts[kYears[1].name] ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: gap),

            // Row 2: Licence 3 SI (full width)
            SizedBox(
              width: fullWidth,
              child: _YearCard(
                year: kYears[2],
                fileCount: counts[kYears[2].name] ?? 0,
              ),
            ),
            const SizedBox(height: gap),

            // Row 3: Master 1 GSI + Master 1 ISIL
            Row(
              children: [
                SizedBox(
                  width: halfWidth - gap / 2,
                  child: _YearCard(
                    year: kYears[3],
                    fileCount: counts[kYears[3].name] ?? 0,
                  ),
                ),
                const SizedBox(width: gap),
                SizedBox(
                  width: halfWidth - gap / 2,
                  child: _YearCard(
                    year: kYears[4],
                    fileCount: counts[kYears[4].name] ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: gap),

            // Row 4: Master 1 AI (full width, highlighted)
            SizedBox(
              width: fullWidth,
              child: _YearCard(
                year: kYears[5],
                fileCount: counts[kYears[5].name] ?? 0,
              ),
            ),
            const SizedBox(height: gap),

            // Row 5: Master 2 GSI + ISIL + AI (3 cols)
            Row(
              children: [
                Expanded(
                  child: _YearCard(
                    year: kYears[6],
                    fileCount: counts[kYears[6].name] ?? 0,
                  ),
                ),
                const SizedBox(width: gap / 2),
                Expanded(
                  child: _YearCard(
                    year: kYears[7],
                    fileCount: counts[kYears[7].name] ?? 0,
                  ),
                ),
                const SizedBox(width: gap / 2),
                Expanded(
                  child: _YearCard(
                    year: kYears[8],
                    fileCount: counts[kYears[8].name] ?? 0,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _YearCard extends StatelessWidget {
  final YearInfo year;
  final int fileCount;

  const _YearCard({required this.year, required this.fileCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNew = year.badge == 'NEW';

    return GestureDetector(
      onTap: () => context.push('/year/${Uri.encodeComponent(year.name)}'),
      child: Container(
        constraints: const BoxConstraints(minHeight: 140),
        padding: const EdgeInsets.all(AppSpacing.stackMd),
        decoration: BoxDecoration(
          color: const Color(0xFF15151F).withAlpha(204),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isNew
                    ? theme.colorScheme.primary.withAlpha(51)
                    : theme.colorScheme.outlineVariant.withAlpha(77),
          ),
          boxShadow:
              isNew
                  ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(38),
                      blurRadius: 20,
                    ),
                  ]
                  : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (year.level.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      year.level.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        year.name,
                        style:
                            year.name.length > 12
                                ? theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                )
                                : theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                    ),
                    if (year.icon != null)
                      Icon(
                        year.icon,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.description,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$fileCount files',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

class _StatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(51),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '2.4k+', label: 'Users'),
          Container(
            width: 1,
            height: 32,
            color: theme.colorScheme.outlineVariant.withAlpha(77),
          ),
          _StatItem(value: '15k', label: 'Files'),
          Container(
            width: 1,
            height: 32,
            color: theme.colorScheme.outlineVariant.withAlpha(77),
          ),
          _StatItem(value: '12', label: 'Specials'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

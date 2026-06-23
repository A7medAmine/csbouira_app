import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/leaderboard_entry.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/leaderboard_providers.dart';
import '../../shared/widgets/user_avatar.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final topAsync = ref.watch(topContributorsProvider);
    final rankAsync = ref.watch(currentUserRankProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Leaderboard',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: topAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.error),
                  const SizedBox(height: AppSpacing.stackMd),
                  Text(
                    'Could not load leaderboard',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (entries) {
            if (entries.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.emoji_events_outlined,
                          size: 64, color: theme.colorScheme.outlineVariant),
                      const SizedBox(height: AppSpacing.stackMd),
                      Text(
                        'No contributors yet',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Be the first to upload study materials!',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final isLoggedIn = user != null;
            final rank = rankAsync.asData?.value;
            final isInTopList = rank != null && rank.rank <= entries.length;

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(topContributorsProvider);
                ref.invalidate(currentUserRankProvider);
                await ref.read(topContributorsProvider.future);
                await ref.read(currentUserRankProvider.future);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile,
                  AppSpacing.stackMd,
                  AppSpacing.marginMobile,
                  AppSpacing.stackLg,
                ),
                children: [
                  if (entries.length >= 3)
                    _PodiumPreview(theme: theme, top3: entries.take(3).toList()),
                  const SizedBox(height: AppSpacing.stackLg),
                  ...entries.map((entry) => _LeaderboardRow(
                        theme: theme,
                        entry: entry,
                        isCurrentUser: entry.userId == user?.id,
                      )),
                  const SizedBox(height: AppSpacing.stackLg),
                  if (isLoggedIn && rank != null && !isInTopList)
                    _CurrentUserRankCard(
                      theme: theme,
                      rank: rank.rank,
                      count: rank.count,
                    ),
                  if (!isLoggedIn)
                    _GuestPrompt(theme: theme),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PodiumPreview extends StatelessWidget {
  final ThemeData theme;
  final List<LeaderboardEntry> top3;

  const _PodiumPreview({required this.theme, required this.top3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.emoji_events, color: const Color(0xFFFFD700), size: 40),
        const SizedBox(height: AppSpacing.stackMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (top3.length > 1)
              _PodiumSpot(
                theme: theme,
                entry: top3[1],
                medal: '\u{1F948}',
                height: 100,
              ),
            const SizedBox(width: 12),
            _PodiumSpot(
              theme: theme,
              entry: top3[0],
              medal: '\u{1F947}',
              height: 120,
            ),
            const SizedBox(width: 12),
            if (top3.length > 2)
              _PodiumSpot(
                theme: theme,
                entry: top3[2],
                medal: '\u{1F949}',
                height: 80,
              ),
          ],
        ),
      ],
    );
  }
}

class _PodiumSpot extends StatelessWidget {
  final ThemeData theme;
  final LeaderboardEntry entry;
  final String medal;
  final double height;

  const _PodiumSpot({
    required this.theme,
    required this.entry,
    required this.medal,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        UserAvatar(
          size: height * 0.4,
          avatarUrl: entry.avatarUrl,
          fullName: entry.fullName,
        ),
        const SizedBox(height: 4),
        Text(medal, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 2),
        SizedBox(
          width: 80,
          child: Text(
            entry.fullName,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          '${entry.uploadCount}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 56,
          height: height * 0.3,
          decoration: BoxDecoration(
            color: medal == '\u{1F947}'
                ? const Color(0xFFFFD700).withAlpha(51)
                : medal == '\u{1F948}'
                    ? const Color(0xFFC0C0C0).withAlpha(51)
                    : const Color(0xFFCD7F32).withAlpha(51),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.md),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final ThemeData theme;
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const _LeaderboardRow({
    required this.theme,
    required this.entry,
    required this.isCurrentUser,
  });

  Widget _rankWidget(int rank) {
    switch (rank) {
      case 1:
        return const Text('\u{1F947}', style: TextStyle(fontSize: 22));
      case 2:
        return const Text('\u{1F948}', style: TextStyle(fontSize: 22));
      case 3:
        return const Text('\u{1F949}', style: TextStyle(fontSize: 22));
      default:
        return Text(
          '$rank',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.stackSm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.stackMd,
        vertical: AppSpacing.stackSm,
      ),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? theme.colorScheme.primaryContainer.withAlpha(26)
            : const Color(0x0D15151F),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isCurrentUser
              ? theme.colorScheme.primary.withAlpha(77)
              : const Color(0xFF1A1A26).withAlpha(128),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Center(child: _rankWidget(entry.rank)),
          ),
          const SizedBox(width: AppSpacing.stackMd),
          UserAvatar(
            size: 40,
            avatarUrl: entry.avatarUrl,
            fullName: entry.fullName,
          ),
          const SizedBox(width: AppSpacing.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${entry.uploadCount} upload${entry.uploadCount == 1 ? '' : 's'}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(51),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                'YOU',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CurrentUserRankCard extends StatelessWidget {
  final ThemeData theme;
  final int rank;
  final int count;

  const _CurrentUserRankCard({
    required this.theme,
    required this.rank,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(26),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(77),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Rank',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.stackSm),
          Text(
            '#$rank',
            style: theme.textTheme.displayLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count upload${count == 1 ? '' : 's'}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestPrompt extends StatelessWidget {
  final ThemeData theme;

  const _GuestPrompt({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.stackLg),
      decoration: BoxDecoration(
        color: const Color(0x0D15151F),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: const Color(0xFF1A1A26).withAlpha(128),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 40,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.stackSm),
          Text(
            'Log in to see your rank',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => context.push('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Text(
                'Log In or Sign Up',
                style: theme.textTheme.headlineMedium?.copyWith(
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

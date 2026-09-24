import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';

import '../../core/theme/app_spacing.dart';
import '../../data/providers/catalog_providers.dart';
import '../../data/providers/drive_providers.dart';
import '../../shared/widgets/catalog_file_tile.dart';
import '../../shared/widgets/fetch_error_widget.dart';
import '../preview/open_catalog_file.dart';

/// Files added to the catalogue recently, optionally only from followed
/// modules.
class WhatsNewScreen extends ConsumerStatefulWidget {
  const WhatsNewScreen({super.key});

  @override
  ConsumerState<WhatsNewScreen> createState() => _WhatsNewScreenState();
}

class _WhatsNewScreenState extends ConsumerState<WhatsNewScreen> {
  bool _followingOnly = false;

  String _dayLabel(DateTime day, AppLocalizations l10n, String locale) {
    final today = DateUtils.dateOnly(DateTime.now());
    final d = DateUtils.dateOnly(day);
    if (d == today) return l10n.whatsNewToday;
    if (d == today.subtract(const Duration(days: 1))) return l10n.whatsNewYesterday;
    return DateFormat.yMMMMd(locale).format(d);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final newAsync = ref.watch(whatsNewProvider);
    final followed = ref.watch(followedModulesProvider).valueOrNull ?? const {};
    final index = ref.watch(catalogIndexProvider).valueOrNull;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.whatsNewTitle),
        leading: BackButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          if (followed.isNotEmpty)
            IconButton(
              tooltip: l10n.followingManage,
              icon: const Icon(Icons.notifications_active_outlined),
              onPressed: () => _showFollowing(context),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
            child: Row(
              children: [
                FilterChip(
                  label: Text(l10n.whatsNewFollowingOnly(followed.length)),
                  selected: _followingOnly,
                  onSelected: followed.isEmpty
                      ? null
                      : (v) => setState(() => _followingOnly = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refreshDriveData(),
              child: newAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => FetchErrorWidget(error: e),
                data: (items) {
                  final visible = _followingOnly
                      ? items.where((i) => followed.contains(i.file.moduleKey)).toList()
                      : items;
                  if (visible.isEmpty || index == null) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(32),
                      children: [
                        const SizedBox(height: 48),
                        Icon(Icons.inbox_outlined,
                            size: 56, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(
                          l10n.whatsNewEmpty,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  }
                  final children = <Widget>[];
                  DateTime? lastDay;
                  for (final item in visible) {
                    final day = DateUtils.dateOnly(item.firstSeen);
                    if (day != lastDay) {
                      lastDay = day;
                      children.add(Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          _dayLabel(day, l10n, locale),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ));
                    }
                    children.add(CatalogFileTile(
                      file: item.file,
                      subtitle: '${item.file.year} · ${item.file.module}',
                      onTap: () => openCatalogFile(context, index, item.file),
                    ));
                  }
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.marginMobile, 0, AppSpacing.marginMobile, 24,
                    ),
                    children: children,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFollowing(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final l10n = AppLocalizations.of(ctx)!;
          final followed =
              (ref.watch(followedModulesProvider).valueOrNull ?? const <String>{})
                  .toList()
                ..sort();
          return SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Text(l10n.followingManage,
                      style: Theme.of(ctx).textTheme.titleMedium),
                ),
                for (final key in followed)
                  ListTile(
                    title: Text(key.split('>').last),
                    subtitle: Text(key.split('>').take(2).join(' · ')),
                    trailing: IconButton(
                      tooltip: l10n.moduleUnfollow,
                      icon: const Icon(Icons.notifications_off_outlined),
                      onPressed: () =>
                          ref.read(followedModulesProvider.notifier).toggle(key),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

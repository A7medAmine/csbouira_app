import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';

import '../../../data/models/drive_node.dart';
import '../../../data/providers/catalog_providers.dart';
import '../../../data/providers/module_pack_provider.dart';

/// Every file under [node], depth first.
List<DriveFile> allFilesUnder(DriveNode node) => [
      ...node.files,
      for (final sub in node.subfolders.values) ...allFilesUnder(sub),
    ];

/// Bell button that follows a module for new-file notifications.
class FollowModuleButton extends ConsumerWidget {
  final String moduleKey;

  const FollowModuleButton({super.key, required this.moduleKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final followed =
        ref.watch(followedModulesProvider).valueOrNull?.contains(moduleKey) ??
            false;

    return IconButton(
      tooltip: followed ? l10n.moduleUnfollow : l10n.moduleFollow,
      icon: Icon(
        followed ? Icons.notifications_active : Icons.notifications_none,
        color: followed
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
      onPressed: () async {
        final nowFollowed =
            await ref.read(followedModulesProvider.notifier).toggle(moduleKey);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(
              nowFollowed ? l10n.moduleFollowedSnack : l10n.moduleUnfollowedSnack,
            ),
          ));
      },
    );
  }
}

/// Button that downloads the whole module, or one category, for offline use.
class OfflinePackButton extends ConsumerWidget {
  final String moduleKey;
  final String moduleName;
  final DriveNode? moduleNode;

  const OfflinePackButton({
    super.key,
    required this.moduleKey,
    required this.moduleName,
    required this.moduleNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final node = moduleNode;

    return IconButton(
      tooltip: l10n.offlinePackTitle,
      icon: Icon(
        Icons.download_for_offline_outlined,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onPressed: node == null ? null : () => _showOptions(context, ref, node),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref, DriveNode node) {
    final l10n = AppLocalizations.of(context)!;
    if (ref.read(modulePackProvider).isRunning) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.offlinePackBusy)),
      );
      return;
    }
    final all = allFilesUnder(node);
    final categories = node.subfolders.entries
        .map((e) => (name: e.key, files: allFilesUnder(e.value)))
        .where((c) => c.files.isNotEmpty)
        .toList();

    void start(String label, List<DriveFile> files) {
      Navigator.of(context).pop();
      ref.read(modulePackProvider.notifier).start(
            label: label,
            moduleKey: moduleKey,
            files: files,
          );
    }

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.6,
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
                  child: Text(l10n.offlinePackTitle, style: theme.textTheme.titleMedium),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Text(
                    l10n.offlinePackHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.select_all),
                  title: Text(l10n.offlinePackAll),
                  trailing: Text(l10n.fileCount(all.length)),
                  enabled: all.isNotEmpty,
                  onTap: () => start(moduleName, all),
                ),
                for (final c in categories)
                  ListTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: Text(c.name),
                    trailing: Text(l10n.fileCount(c.files.length)),
                    onTap: () => start('$moduleName · ${c.name}', c.files),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Progress of the offline download job, shown on the module's screen.
class OfflinePackBanner extends ConsumerWidget {
  final String moduleKey;

  const OfflinePackBanner({super.key, required this.moduleKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final pack = ref.watch(modulePackProvider);
    if (pack.status == ModulePackStatus.idle || pack.moduleKey != moduleKey) {
      return const SizedBox.shrink();
    }

    final String status = switch (pack.status) {
      ModulePackStatus.running =>
        l10n.offlinePackProgress(pack.completed + pack.failed, pack.total),
      ModulePackStatus.cancelled => l10n.offlinePackCancelled,
      _ => pack.failed > 0
          ? l10n.offlinePackDoneWithErrors(pack.completed, pack.failed)
          : l10n.offlinePackDone(pack.completed),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                pack.isRunning ? Icons.downloading : Icons.download_done,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: pack.isRunning
                    ? ref.read(modulePackProvider.notifier).cancel
                    : ref.read(modulePackProvider.notifier).dismiss,
                child: Text(pack.isRunning ? l10n.offlinePackCancel : l10n.offlinePackDismiss),
              ),
            ],
          ),
          if (pack.isRunning) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(value: pack.progress),
          ],
        ],
      ),
    );
  }
}

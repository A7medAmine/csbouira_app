import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/update_info.dart';
import '../../../data/providers/update_download_provider.dart';
import '../../../l10n/app_localizations.dart';

/// Shows the update-available dialog.
/// Once "Update" is tapped, the download is triggered in the background
/// using the [updateDownloadProvider], and the dialog is dismissed.
Future<void> showUpdateDialog(
  BuildContext context,
  UpdateInfo info,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _UpdateDialogContent(info: info),
  );
}

class _UpdateDialogContent extends ConsumerWidget {
  final UpdateInfo info;
  const _UpdateDialogContent({required this.info});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.updateDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.updateDialogBody(info.latestVersion)),
          if (info.releaseNotes != null && info.releaseNotes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              info.releaseNotes!,
              style: theme.textTheme.bodySmall,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.updateDialogLater),
        ),
        TextButton(
          onPressed: () {
            ref.read(updateDownloadProvider.notifier).startDownload(info.downloadUrl, info.latestVersion);
            Navigator.of(context).pop();
          },
          child: Text(l10n.updateDialogUpdate),
        ),
      ],
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../../../data/models/update_info.dart';
import '../../../l10n/app_localizations.dart';

/// Shows the update-available dialog.
/// Once "Update" is tapped the APK downloads with a progress indicator,
/// then Android's package installer is invoked via open_filex.
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

class _UpdateDialogContent extends StatefulWidget {
  final UpdateInfo info;
  const _UpdateDialogContent({required this.info});

  @override
  State<_UpdateDialogContent> createState() => _UpdateDialogContentState();
}

class _UpdateDialogContentState extends State<_UpdateDialogContent> {
  bool _downloading = false;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.updateDialogTitle),
      content: _downloading
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.updateDialogDownloading),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 8),
                Text(
                  '${(_progress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.updateDialogBody(widget.info.latestVersion)),
                if (widget.info.releaseNotes != null &&
                    widget.info.releaseNotes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.info.releaseNotes!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
      actions: [
        if (!_downloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.updateDialogLater),
          ),
        TextButton(
          onPressed: _downloading ? null : _startDownload,
          child: Text(l10n.updateDialogUpdate),
        ),
      ],
    );
  }

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
      _progress = 0;
    });

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(widget.info.downloadUrl));
      final response = await client.send(request);

      final totalBytes = response.contentLength ?? -1;
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/csbouira_update.apk';
      final file = File(filePath);

      final sink = file.openWrite();
      int received = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (totalBytes > 0) {
          setState(() {
            _progress = received / totalBytes;
          });
        }
      }
      await sink.close();
      client.close();

      if (!mounted) return;
      Navigator.of(context).pop();

      await OpenFilex.open(filePath);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _progress = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.updateDialogError)),
      );
    }
  }
}

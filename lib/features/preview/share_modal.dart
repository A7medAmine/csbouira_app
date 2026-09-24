import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/deep_links.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../data/models/drive_node.dart';
import '../../data/services/file_cache_service.dart' show extractDriveFileId;
import '../../data/services/qr_share_service.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';

class ShareModal extends StatelessWidget {
  final DriveFile file;
  final ShareFileData? shareData;

  const ShareModal({
    super.key,
    required this.file,
    this.shareData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final fileId = extractDriveFileId(file.link);
    final appLink = fileId != null ? fileDeepLink(fileId) : null;
    // The app link also opens the app when scanned with the camera app;
    // the older path-based format is kept for files without a Drive ID.
    final qrContent = appLink ?? (shareData != null
        ? encodeFileShareData(
            grade: shareData!.grade,
            semester: shareData!.semester,
            module: shareData!.module,
            folder: shareData!.folder,
            fileIndex: shareData!.fileIndex,
            subpath: shareData!.subpath,
          )
        : null);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(77),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.shareFileTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              file.name,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (qrContent != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: QrImageView(
                  data: qrContent,
                  version: QrVersions.auto,
                  size: 200,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF1A1A2E),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.shareQrHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (appLink != null) ...[
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => SharePlus.instance.share(ShareParams(
                        text: l10n.shareLinkMessage(file.name, appLink, file.link),
                        subject: file.name,
                      )),
                      icon: const Icon(Icons.share, size: 18),
                      label: Text(l10n.shareLinkAction),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    tooltip: l10n.copyLinkAction,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: appLink));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.linkCopied)),
                        );
                      }
                    },
                    icon: const Icon(Icons.link),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(file.link);
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.couldNotOpenLink)),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(AppLocalizations.of(context)!.previewMenuOpenDrive),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentBlue,
                  side: const BorderSide(color: AppColors.accentBlue),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

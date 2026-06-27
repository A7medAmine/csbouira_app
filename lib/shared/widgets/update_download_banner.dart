import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';
import '../../data/providers/update_download_provider.dart';

class UpdateDownloadBanner extends ConsumerWidget {
  const UpdateDownloadBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadState = ref.watch(updateDownloadProvider);
    if (downloadState.status == UpdateDownloadStatus.idle) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Color bannerColor;
    IconData icon;
    String text;
    Widget? trailing;
    VoidCallback? onTap;

    switch (downloadState.status) {
      case UpdateDownloadStatus.downloading:
        bannerColor = const Color(0xFF15151F);
        icon = Icons.cloud_download;
        final percentage = (downloadState.progress * 100).toStringAsFixed(0);
        text = l10n.updateBannerDownloading(percentage);
        trailing = SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            value: downloadState.progress > 0 ? downloadState.progress : null,
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
          ),
        );
        break;
      case UpdateDownloadStatus.completed:
        bannerColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle;
        text = l10n.updateBannerReady;
        onTap = () => ref.read(updateDownloadProvider.notifier).installUpdate();
        trailing = IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          onPressed: () => ref.read(updateDownloadProvider.notifier).reset(),
        );
        break;
      case UpdateDownloadStatus.error:
        bannerColor = const Color(0xFFC62828);
        icon = Icons.error;
        text = l10n.updateBannerError;
        onTap = () => ref.read(updateDownloadProvider.notifier).reset();
        trailing = IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          onPressed: () => ref.read(updateDownloadProvider.notifier).reset(),
        );
        break;
      default:
        return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 8,
      color: bannerColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(51),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

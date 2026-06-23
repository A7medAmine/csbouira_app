import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../data/models/downloaded_file.dart';
import '../../data/providers/downloads_providers.dart';
import '../../data/services/download_service.dart';
import '../../shared/widgets/fetch_error_widget.dart';
import 'local_file_viewer.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final downloadsAsync = ref.watch(downloadsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () {
            if (MediaQuery.of(context).viewInsets.bottom > 0) {
              FocusScope.of(context).unfocus();
              return;
            }
            if (Navigator.of(context).canPop()) {
              context.pop();
            }
          },
        ),
        title: Text(
          'Downloads',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: downloadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => FetchErrorWidget(
          error: err,
          message: 'Failed to load downloads.',
        ),
        data: (downloads) {
          if (downloads.isEmpty) {
            return _EmptyState(theme: theme);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginMobile,
              AppSpacing.stackLg,
              AppSpacing.marginMobile,
              24,
            ),
            itemCount: downloads.length,
            itemBuilder: (_, i) => _DownloadCard(item: downloads[i]),
          );
        },
      ),
    );
  }
}

class _DownloadCard extends ConsumerStatefulWidget {
  final DownloadedFile item;

  const _DownloadCard({required this.item});

  @override
  ConsumerState<_DownloadCard> createState() => _DownloadCardState();
}

class _DownloadCardState extends ConsumerState<_DownloadCard> {
  IconData _fileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      case 'mp4':
      case 'avi':
      case 'mkv':
        return Icons.play_circle;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _iconColor(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Theme.of(context).colorScheme.error;
      case 'doc':
      case 'docx':
        return const Color(0xFF448AFF);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFFF7043);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF66BB6A);
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  Color _iconBg(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Theme.of(context).colorScheme.errorContainer.withAlpha(51);
      case 'doc':
      case 'docx':
        return const Color(0xFF448AFF).withAlpha(51);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFFF7043).withAlpha(51);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF66BB6A).withAlpha(51);
      default:
        return Theme.of(context).colorScheme.primaryContainer.withAlpha(51);
    }
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  bool get _isViewableInApp {
    final ext = widget.item.fileName.split('.').last.toLowerCase();
    return ext == 'pdf' || {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'}.contains(ext);
  }

  static const _officeExtensions = {'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'};

  Future<void> _openFile() async {
    final ext = widget.item.fileName.split('.').last.toLowerCase();

    if (_isViewableInApp) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LocalFileViewerScreen(
            filePath: widget.item.localPath,
            fileName: widget.item.fileName,
          ),
        ),
      );
      return;
    }

    if (_officeExtensions.contains(ext)) {
      final uri = Uri.tryParse(widget.item.driveLink);
      if (uri != null) {
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        } catch (_) {}
      }
    }

    final service = ref.read(downloadServiceProvider);
    final result = await service.openFile(widget.item.localPath);
    if (result.type == ResultType.noAppToOpen) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No app available to open this file type.')),
      );
    }
  }

  Future<void> _deleteDownload() async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Delete Download',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Delete "${widget.item.fileName}" from your device?',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final service = ref.read(downloadServiceProvider);
      await service.deleteDownload(widget.item.localPath);
      ref.invalidate(downloadsListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${widget.item.fileName}" deleted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = _fileIcon(widget.item.fileName);
    final iconColor = _iconColor(widget.item.fileName);
    final iconBg = _iconBg(widget.item.fileName);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
      child: GestureDetector(
        onTap: _openFile,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF15151F).withAlpha(179),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(77),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.fileName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (widget.item.fileSize != null) ...[
                          Text(
                            _formatSize(widget.item.fileSize),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _formatDate(widget.item.downloadedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _deleteDownload,
                child: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error.withAlpha(179),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;

  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 40),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withAlpha(13),
                ),
              ),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surfaceContainer,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withAlpha(51),
                  ),
                ),
                child: Icon(
                  Icons.download_outlined,
                  size: 40,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackLg),
          Text(
            'No downloads yet',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.stackSm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Files you download will appear here\nfor offline access.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          GestureDetector(
            onTap: () => context.go('/'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(38),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Text(
                'Browse Files',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
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

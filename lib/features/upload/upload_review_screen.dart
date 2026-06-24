import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/selected_upload_file.dart';

const _imageMimePrefixes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'image/bmp'];

void showUploadReviewSheet({
  required BuildContext context,
  required SelectedUploadFile file,
  required VoidCallback onRetake,
  required ValueChanged<SelectedUploadFile> onConfirm,
  VoidCallback? onApproveAll,
  int currentIndex = 1,
  int totalCount = 1,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: false,
    isDismissible: false,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _UploadReviewSheet(
      file: file,
      currentIndex: currentIndex,
      totalCount: totalCount,
      onRetake: () {
        Navigator.pop(ctx);
        onRetake();
      },
      onConfirm: () {
        Navigator.pop(ctx);
        onConfirm(file);
      },
      onApproveAll: onApproveAll != null
          ? () {
              Navigator.pop(ctx);
              onApproveAll();
            }
          : null,
    ),
  );
}

class _UploadReviewSheet extends StatefulWidget {
  final SelectedUploadFile file;
  final int currentIndex;
  final int totalCount;
  final VoidCallback onRetake;
  final VoidCallback onConfirm;
  final VoidCallback? onApproveAll;

  const _UploadReviewSheet({
    required this.file,
    required this.currentIndex,
    required this.totalCount,
    required this.onRetake,
    required this.onConfirm,
    this.onApproveAll,
  });

  @override
  State<_UploadReviewSheet> createState() => _UploadReviewSheetState();
}

class _UploadReviewSheetState extends State<_UploadReviewSheet> {
  bool _isPdfLoading = true;

  bool get _isPdf => widget.file.mimeType == 'application/pdf';

  bool get _isImage => _imageMimePrefixes.any((p) => widget.file.mimeType.startsWith(p));

  @override
  void initState() {
    super.initState();
    if (_isPdf) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _isPdfLoading = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // -- close button row ----------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Text(
                  widget.totalCount > 1
                      ? '${widget.currentIndex} of ${widget.totalCount}'
                      : 'Review File',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // -- preview -------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: maxHeight * 0.5,
              child: _buildPreview(theme),
            ),
          ),
          const SizedBox(height: 16),
          // -- file info ------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildFileInfo(theme),
          ),
          const SizedBox(height: 24),
          // -- action buttons -------------------------------------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onRetake,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Retake / Choose Again'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurface,
                          side: BorderSide(color: theme.colorScheme.outlineVariant),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: widget.onConfirm,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Use This File'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (widget.totalCount > 1 && widget.onApproveAll != null) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: widget.onApproveAll,
                      icon: const Icon(Icons.done_all, size: 18),
                      label: Text('Approve All (${widget.totalCount - widget.currentIndex + 1} remaining)'),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    if (_isPdf) {
      if (_isPdfLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SfPdfViewer.memory(
          widget.file.bytes,
        ),
      );
    }

    if (_isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Image.memory(
          widget.file.bytes,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _unsupportedPreview(theme),
        ),
      );
    }

    return _unsupportedPreview(theme);
  }

  Widget _unsupportedPreview(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.description, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(
              'Preview not available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfo(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(51),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              _isPdf ? Icons.picture_as_pdf : Icons.description,
              color: theme.colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.file.fileName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.file.formattedSize,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 22),
        ],
      ),
    );
  }
}

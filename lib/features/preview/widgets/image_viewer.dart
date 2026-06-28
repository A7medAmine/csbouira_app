import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/drive_node.dart';
import '../../../data/services/file_cache_service.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';

/// Image viewer with pinch-to-zoom and pan using PhotoView.
///
/// Downloads the image to a local cache via [FileCacheService], then renders
/// it with full gesture-based zoom/pan. Supports jpg, png, gif, webp.
class ImageViewerWidget extends ConsumerStatefulWidget {
  final DriveFile file;

  const ImageViewerWidget({
    super.key,
    required this.file,
  });

  @override
  ConsumerState<ImageViewerWidget> createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends ConsumerState<ImageViewerWidget> {
  bool _isLoading = true;
  String? _error;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant ImageViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.link != widget.file.link) {
      setState(() {
        _isLoading = true;
        _error = null;
        _imageFile = null;
      });
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    try {
      final cache = ref.read(fileCacheServiceProvider);
      final downloadUrl = widget.file.downloadLink ?? widget.file.link;
      final fileId = extractDriveFileId(downloadUrl);

      if (fileId == null) {
        setState(() {
          _error = AppLocalizations.of(context)!.extractFileIdError;
          _isLoading = false;
        });
        return;
      }

      final file = await cache.getOrDownload(
        fileId: fileId,
        downloadUrl: downloadUrl,
      );

      if (mounted) {
        setState(() {
          _imageFile = file;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.failedToLoadImage,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    if (_imageFile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return PhotoView(
      imageProvider: FileImage(_imageFile!),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3,
      backgroundDecoration: const BoxDecoration(
        color: Color(0xFF111221),
      ),
      loadingBuilder: (context, event) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorBuilder: (context, error, stackTrace) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.failedToDisplayImage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

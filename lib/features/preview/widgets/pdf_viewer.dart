import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/drive_node.dart';
import '../../../data/services/file_cache_service.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';

/// PDF viewer using Syncfusion's SfPdfViewer.
///
/// Downloads the PDF to a local cache via [FileCacheService], then renders
/// it with full page navigation, pinch-to-zoom, and page tracking built in.
/// Syncfusion handles page virtualization internally — no manual pagination.
class PdfViewerWidget extends ConsumerStatefulWidget {
  final DriveFile file;
  final PdfViewerController? controller;
  final void Function(int currentPage, int totalPages)? onPageChanged;

  const PdfViewerWidget({
    super.key,
    required this.file,
    this.controller,
    this.onPageChanged,
  });

  @override
  ConsumerState<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends ConsumerState<PdfViewerWidget> {
  bool _isLoading = true;
  String? _error;
  File? _pdfFile;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void didUpdateWidget(covariant PdfViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.link != widget.file.link) {
      setState(() {
        _isLoading = true;
        _error = null;
        _pdfFile = null;
      });
      _loadPdf();
    }
  }

  Future<void> _loadPdf() async {
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
          _pdfFile = file;
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
      return const Center(
        child: CircularProgressIndicator(),
      );
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
                AppLocalizations.of(context)!.failedToLoadPdf,
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

    if (_pdfFile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SfPdfViewer.file(
      _pdfFile!,
      controller: widget.controller,
      onDocumentLoaded: (details) {
        _totalPages = details.document.pages.count;
        widget.onPageChanged?.call(1, _totalPages);
      },
      onPageChanged: (details) {
        widget.onPageChanged?.call(details.newPageNumber, _totalPages);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

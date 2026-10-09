import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' show PdfPage, PdfPageRotateAngle;
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

  /// Height / width of each page, for [pageAtViewportCenter].
  List<double> _pageAspects = const [];
  Size _viewport = Size.zero;
  int _reportedPage = 0;

  /// Polls the scroll position while the user drags or a fling settles;
  /// the controller doesn't notify scroll changes.
  Timer? _scrollWatch;
  Offset? _lastOffset;
  int _stillTicks = 0;
  bool _pointerDown = false;

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

    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        return Listener(
          onPointerDown: (_) {
            _pointerDown = true;
            _watchScroll();
          },
          onPointerUp: (_) => _pointerDown = false,
          onPointerCancel: (_) => _pointerDown = false,
          child: SfPdfViewer.file(
            _pdfFile!,
            controller: widget.controller,
            onDocumentLoaded: (details) {
              final pages = details.document.pages;
              _totalPages = pages.count;
              _pageAspects = [
                for (var i = 0; i < pages.count; i++) _aspectOf(pages[i]),
              ];
              _reportedPage = 1;
              widget.onPageChanged?.call(1, _totalPages);
            },
            onPageChanged: (details) {
              // Also fires on jumps that don't involve a drag.
              _reportPage(details.newPageNumber);
              _watchScroll();
            },
          ),
        );
      },
    );
  }

  /// Reports the page under the middle of the screen. Syncfusion's own page
  /// number is the page at the top edge, so it lags a page behind when the
  /// end of the previous page is still showing.
  void _reportPage([int? fallback]) {
    final controller = widget.controller;
    final page = controller != null && _pageAspects.isNotEmpty
        ? pageAtViewportCenter(
            pageAspects: _pageAspects,
            viewport: _viewport,
            scrollY: controller.scrollOffset.dy,
            zoom: controller.zoomLevel,
          )
        : fallback;
    if (page == null || page == 0 || page == _reportedPage) return;
    _reportedPage = page;
    widget.onPageChanged?.call(page, _totalPages);
  }

  void _watchScroll() {
    _stillTicks = 0;
    _scrollWatch ??= Timer.periodic(const Duration(milliseconds: 120), (_) {
      final offset = widget.controller?.scrollOffset;
      if (offset == _lastOffset && !_pointerDown) {
        if (++_stillTicks > 4) {
          _scrollWatch?.cancel();
          _scrollWatch = null;
        }
      } else {
        _stillTicks = 0;
      }
      _lastOffset = offset;
      _reportPage();
    });
  }

  @override
  void dispose() {
    _scrollWatch?.cancel();
    super.dispose();
  }
}

double _aspectOf(PdfPage page) {
  final size = page.size;
  final quarterTurn = page.rotation == PdfPageRotateAngle.rotateAngle90 ||
      page.rotation == PdfPageRotateAngle.rotateAngle270;
  return quarterTurn ? size.width / size.height : size.height / size.width;
}

/// 1-based page under the vertical middle of the viewport, for SfPdfViewer's
/// continuous vertical layout on phones: every page is as wide as the
/// viewport, pages are [spacing] apart, and [scrollY] is in unzoomed units.
int pageAtViewportCenter({
  required List<double> pageAspects,
  required Size viewport,
  required double scrollY,
  required double zoom,
  double spacing = 4,
}) {
  if (pageAspects.isEmpty || viewport.width <= 0) return 0;
  final center = scrollY + viewport.height / zoom / 2;
  var bottom = 0.0;
  for (var i = 0; i < pageAspects.length; i++) {
    bottom += viewport.width * pageAspects[i] + spacing;
    if (center < bottom) return i + 1;
  }
  return pageAspects.length;
}

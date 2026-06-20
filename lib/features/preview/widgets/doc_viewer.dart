// ---------------------------------------------------------------------------
// WebView-based document viewer for Office docs (doc/docx/ppt/pptx).
//
// WHY WEBVIEW: There is no reliable native Flutter renderer for Microsoft
// Office formats. Google Drive's embeddable preview (accessible via
// `previewLink`) is the standard practical approach — it renders the
// document inside a webview while keeping the app's native UI shell
// (AppBar, next/prev arrows) around it.
//
// FALLBACK: If the webview fails to load or the document type isn't
// viewable via Drive preview, we show an in-app message with an
// "Open in Drive" button using `url_launcher`.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/drive_node.dart';
import '../../../core/theme/app_colors.dart';

class DocViewerWidget extends StatefulWidget {
  final DriveFile file;

  const DocViewerWidget({
    super.key,
    required this.file,
  });

  @override
  State<DocViewerWidget> createState() => _DocViewerWidgetState();
}

class _DocViewerWidgetState extends State<DocViewerWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  @override
  void didUpdateWidget(covariant DocViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.file.link != widget.file.link) {
      _initWebView();
    }
  }

  void _initWebView() {
    final previewUrl = widget.file.previewLink ?? widget.file.link;
    _isLoading = true;
    _hasError = false;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(previewUrl));
  }

  Future<void> _openInDrive() async {
    final uri = Uri.parse(widget.file.link);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _FallbackView(
        file: widget.file,
        onOpenInDrive: _openInDrive,
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

/// Fallback view shown when the webview fails or the file type isn't viewable.
class FallbackView extends StatelessWidget {
  final DriveFile file;

  const FallbackView({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return _FallbackView(
      file: file,
      onOpenInDrive: () async {
        final uri = Uri.parse(file.link);
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {}
      },
    );
  }
}

class _FallbackView extends StatelessWidget {
  final DriveFile file;
  final VoidCallback onOpenInDrive;

  const _FallbackView({
    required this.file,
    required this.onOpenInDrive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = file.name.split('.').last.toLowerCase();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insert_drive_file_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: 24),
            Text(
              'Preview not available',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No preview available for .$ext files.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onOpenInDrive,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Open in Drive'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accentBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

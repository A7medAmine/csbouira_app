import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../app.dart';

const _imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'};

class LocalFileViewerScreen extends StatefulWidget {
  final String filePath;
  final String fileName;

  const LocalFileViewerScreen({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<LocalFileViewerScreen> createState() => _LocalFileViewerScreenState();
}

class _LocalFileViewerScreenState extends State<LocalFileViewerScreen> {
  String get _extension {
    final dotIndex = widget.fileName.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == widget.fileName.length - 1) return '';
    return widget.fileName.substring(dotIndex + 1).toLowerCase();
  }

  bool get _isPdf => _extension == 'pdf';
  bool get _isImage => _imageExtensions.contains(_extension);

  void _toggleFullScreen() {
    final next = !fullScreenNotifier.value;
    fullScreenNotifier.value = next;
    if (next) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void dispose() {
    if (fullScreenNotifier.value) {
      fullScreenNotifier.value = false;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<bool>(
      valueListenable: fullScreenNotifier,
      builder: (context, isFullScreen, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF111221),
          appBar: isFullScreen
              ? null
              : AppBar(
                  backgroundColor: const Color(0xFF111221),
                  leading: IconButton(
                    icon:
                        Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                    onPressed: () => context.pop(),
                  ),
                  title: Text(
                    widget.fileName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  centerTitle: true,
                  actions: [
                    GestureDetector(
                      onTap: _toggleFullScreen,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          Icons.fullscreen,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
          body: GestureDetector(
            onTap: isFullScreen ? _toggleFullScreen : null,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                Positioned.fill(child: _buildViewer()),
                if (isFullScreen)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AnimatedOpacity(
                        opacity: 0.6,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(120),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app,
                                color: Colors.white.withAlpha(180),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tap to exit full screen',
                                style: TextStyle(
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildViewer() {
    if (_isPdf) {
      return SfPdfViewer.file(
        File(widget.filePath),
      );
    }

    if (_isImage) {
      return PhotoView(
        imageProvider: FileImage(File(widget.filePath)),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        backgroundDecoration: const BoxDecoration(
          color: Color(0xFF111221),
        ),
      );
    }

    return Center(
      child: Text(
        'Unsupported file type',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

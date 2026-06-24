import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/drive_node.dart';
import '../../data/providers/downloads_providers.dart';
import '../../data/services/download_service.dart';
import '../../data/services/qr_share_service.dart';
import '../../shared/widgets/favorite_star.dart';
import 'preview_args.dart';
import 'share_modal.dart';
import 'widgets/pdf_viewer.dart';
import 'widgets/image_viewer.dart';
import 'widgets/doc_viewer.dart';

/// Supported image extensions for the native image viewer.
const _imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'};

/// Extensions that should attempt Google Drive preview via webview.
const _officeExtensions = {'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx'};

/// Returns the lowercase file extension from a file name.
String _getExtension(String name) {
  final dotIndex = name.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == name.length - 1) return '';
  return name.substring(dotIndex + 1).toLowerCase();
}

enum _OverflowAction { download, share, openInDrive }

class PreviewScreen extends ConsumerStatefulWidget {
  const PreviewScreen({super.key});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  int _currentIndex = 0;
  late List<DriveFile> _files;
  List<String>? _folderPath;

  // PDF page tracking
  PdfViewerController? _pdfController;
  int _pdfPage = 1;
  int _pdfTotalPages = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is PreviewArgs && _files.isEmpty) {
      _files = extra.files;
      _currentIndex = extra.initialIndex;
      _folderPath = extra.folderPath;
    }
  }

  @override
  void initState() {
    super.initState();
    _files = [];
    _pdfController = PdfViewerController();
  }

  @override
  void dispose() {
    if (fullScreenNotifier.value) {
      fullScreenNotifier.value = false;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    super.dispose();
  }

  DriveFile get _currentFile => _files[_currentIndex];
  bool get _hasPrevious => _currentIndex > 0;
  bool get _hasNext => _currentIndex < _files.length - 1;
  String get _extension => _getExtension(_currentFile.name);
  bool get _isPdf => _extension == 'pdf';
  bool get _isImage => _imageExtensions.contains(_extension);
  bool get _isOffice => _officeExtensions.contains(_extension);

  void _toggleFullScreen() {
    final next = !fullScreenNotifier.value;
    fullScreenNotifier.value = next;
    if (next) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _goToPrevious() {
    if (!_hasPrevious) return;
    setState(() {
      _currentIndex--;
      _pdfPage = 1;
      _pdfTotalPages = 0;
    });
  }

  void _goToNext() {
    if (!_hasNext) return;
    setState(() {
      _currentIndex++;
      _pdfPage = 1;
      _pdfTotalPages = 0;
    });
  }

  Future<void> _downloadFile() async {
    final service = ref.read(downloadServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Downloading...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final downloaded = await service.downloadFile(_currentFile);
      messenger.hideCurrentSnackBar();
      ref.invalidate(downloadsListProvider);

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('"${downloaded.fileName}" downloaded'),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => context.push('/profile/my-downloads'),
          ),
        ),
      );
    } catch (e) {
      messenger.hideCurrentSnackBar();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  Future<void> _openExternally() async {
    final uri = Uri.parse(_currentFile.link);
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

  ShareFileData? _buildShareData() {
    final folderPath = _folderPath;
    if (folderPath == null || folderPath.length < 2) return null;

    if (folderPath.length <= 2) {
      return ShareFileData(
        grade: folderPath[0],
        semester: '',
        module: '',
        folder: folderPath[1],
        fileIndex: _currentIndex,
        subpath: folderPath.length > 2 ? folderPath.sublist(2).join('>') : null,
      );
    }
    return ShareFileData(
      grade: folderPath[0],
      semester: folderPath[1],
      module: folderPath[2],
      folder: folderPath.length >= 4 ? folderPath[3] : '',
      fileIndex: _currentIndex,
      subpath: folderPath.length > 4 ? folderPath.sublist(4).join('>') : null,
    );
  }

  void _showShareModal() {
    final shareData = _buildShareData();
    showDialog(
      context: context,
      builder: (ctx) => ShareModal(file: _currentFile, shareData: shareData),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_files.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF111221),
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                  actionsPadding: EdgeInsets.zero,
                  titleSpacing: 0,
                  leading: IconButton(
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.arrow_back,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentFile.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _fileTypeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  actions: [
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: FavoriteStar(
                        key: ValueKey<String>(_currentFile.link),
                        itemType: 'file',
                        itemPath: _currentFile.link,
                        displayName: _currentFile.name,
                        folderPath: _folderPath?.join('>'),
                        size: 28,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: GestureDetector(
                        onTap: _toggleFullScreen,
                        child: Icon(
                          isFullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 28,
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: PopupMenuButton<_OverflowAction>(
                        icon: Icon(
                          Icons.more_vert,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 28,
                        ),
                        padding: EdgeInsets.zero,
                      onSelected: (action) {
                        switch (action) {
                          case _OverflowAction.download:
                            _downloadFile();
                          case _OverflowAction.share:
                            _showShareModal();
                          case _OverflowAction.openInDrive:
                            _openExternally();
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: _OverflowAction.download,
                          child: SizedBox(
                            width: 160,
                            child: Row(
                              children: [
                                const Icon(Icons.download, size: 20),
                                const SizedBox(width: 12),
                                const Text('Download'),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: _OverflowAction.share,
                          child: SizedBox(
                            width: 160,
                            child: Row(
                              children: [
                                const Icon(Icons.qr_code, size: 20),
                                const SizedBox(width: 12),
                                const Text('Share QR'),
                              ],
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: _OverflowAction.openInDrive,
                          child: SizedBox(
                            width: 160,
                            child: Row(
                              children: [
                                const Icon(Icons.open_in_new, size: 20),
                                const SizedBox(width: 12),
                                const Text('Open in Google Drive'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
                  ],
                ),
          body: GestureDetector(
            onTap: isFullScreen ? _toggleFullScreen : null,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              children: [
                // Main viewer
                Positioned.fill(
                  child: _buildViewer(),
                ),

                // Left arrow
                if (!isFullScreen && _hasPrevious)
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _NavArrow(
                        icon: Icons.chevron_left,
                        onTap: _goToPrevious,
                      ),
                    ),
                  ),

                // Right arrow
                if (!isFullScreen && _hasNext)
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _NavArrow(
                        icon: Icons.chevron_right,
                        onTap: _goToNext,
                      ),
                    ),
                  ),

                // PDF page indicator (bottom)
                if (!isFullScreen && _isPdf && _pdfTotalPages > 0)
                  Positioned(
                    bottom: 24,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(160),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          '$_pdfPage / $_pdfTotalPages',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Full-screen exit hint (tap to exit)
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

  String get _fileTypeLabel {
    if (_isPdf) return 'PDF';
    if (_isImage) return _extension.toUpperCase();
    if (_isOffice) return _extension.toUpperCase();
    return _extension.isNotEmpty ? _extension.toUpperCase() : 'File';
  }

  Widget _buildViewer() {
    if (_isPdf) {
      return PdfViewerWidget(
        key: ValueKey<String>(_currentFile.link),
        file: _currentFile,
        controller: _pdfController,
        onPageChanged: (page, total) {
          if (mounted) {
            setState(() {
              _pdfPage = page;
              _pdfTotalPages = total;
            });
          }
        },
      );
    }

    if (_isImage) {
      return ImageViewerWidget(
        key: ValueKey<String>(_currentFile.link),
        file: _currentFile,
      );
    }

    if (_isOffice) {
      return DocViewerWidget(
        key: ValueKey<String>(_currentFile.link),
        file: _currentFile,
      );
    }

    // Unsupported file type — show fallback
    return FallbackView(file: _currentFile);
  }
}

/// Semi-transparent circular arrow for next/previous navigation.
class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrow({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(100),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.accentBlue,
          size: 28,
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF111221),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111221),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
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
      ),
      body: _buildViewer(),
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

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _maxCacheSizeBytes = 200 * 1024 * 1024; // 200 MB

/// Extracts the Google Drive file ID from a link URL.
///
/// Handles formats:
///   - https://drive.google.com/file/d/FILE_ID/...
///   - https://drive.google.com/open?id=FILE_ID
///   - https://drive.usercontent.google.com/download?id=FILE_ID
///   - ?id=FILE_ID in any URL
String? extractDriveFileId(String url) {
  // /d/FILE_ID/
  final dashMatch = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(url);
  if (dashMatch != null) return dashMatch.group(1);

  // ?id=FILE_ID
  final idMatch = RegExp(r'[?&]id=([a-zA-Z0-9_-]+)').firstMatch(url);
  if (idMatch != null) return idMatch.group(1);

  return null;
}

class FileCacheService {
  Directory? _cacheDir;

  Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    _cacheDir = await getTemporaryDirectory();
    return _cacheDir!;
  }

  /// Initializes the cache: checks size, evicts oldest files if over threshold.
  Future<void> init() async {
    final dir = await _getCacheDir();
    await _evictIfNeeded(dir);
  }

  /// Returns a cached file if available, otherwise downloads it.
  ///
  /// [fileId] is used as the cache key.
  /// [downloadUrl] is the URL to fetch from if not cached.
  Future<File> getOrDownload({
    required String fileId,
    required String downloadUrl,
  }) async {
    final dir = await _getCacheDir();
    final cachedFile = File('${dir.path}/$fileId');

    if (await cachedFile.exists()) {
      // Touch to update access time for LRU eviction
      await cachedFile.setLastModified(DateTime.now());
      return cachedFile;
    }

    final response = await http.get(Uri.parse(downloadUrl));
    if (response.statusCode != 200) {
      throw FileCacheException(
        'Download failed with status ${response.statusCode}',
      );
    }

    await cachedFile.writeAsBytes(response.bodyBytes, flush: true);
    return cachedFile;
  }

  Future<void> _evictIfNeeded(Directory dir) async {
    if (!dir.existsSync()) return;

    final files = dir.listSync().whereType<File>().toList();
    int totalSize = 0;
    for (final f in files) {
      totalSize += f.lengthSync();
    }

    if (totalSize <= _maxCacheSizeBytes) return;

    // Sort by modification time (oldest first) — simple LRU
    files.sort((a, b) {
      final aTime = a.lastModifiedSync();
      final bTime = b.lastModifiedSync();
      return aTime.compareTo(bTime);
    });

    for (final f in files) {
      if (totalSize <= _maxCacheSizeBytes) break;
      final size = f.lengthSync();
      f.deleteSync();
      totalSize -= size;
    }
  }
}

class FileCacheException implements Exception {
  final String message;
  const FileCacheException(this.message);
  @override
  String toString() => 'FileCacheException: $message';
}

final fileCacheServiceProvider = Provider<FileCacheService>((ref) {
  final service = FileCacheService();
  service.init();
  return service;
});

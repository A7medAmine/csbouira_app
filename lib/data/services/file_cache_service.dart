import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'http_download.dart';

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
  final http.Client _client;
  Directory? _cacheDir;

  FileCacheService({http.Client? client}) : _client = client ?? http.Client();

  /// Dedicated subfolder of the temp dir. Eviction only ever deletes files in
  /// here, never other temp files (picked/scanned files being uploaded, the
  /// downloaded update APK, ...).
  Future<Directory> _getCacheDir() async {
    if (_cacheDir != null) return _cacheDir!;
    final temp = await getTemporaryDirectory();
    final dir = Directory('${temp.path}/file_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    _cacheDir = dir;
    return dir;
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

    try {
      await downloadToFile(_client, Uri.parse(downloadUrl), cachedFile);
    } on HttpException catch (e) {
      throw FileCacheException(e.message);
    }
    return cachedFile;
  }

  Future<void> _evictIfNeeded(Directory dir) async {
    if (!await dir.exists()) return;

    final entries = <(File, int, DateTime)>[];
    int totalSize = 0;
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final stat = await entity.stat();
      entries.add((entity, stat.size, stat.modified));
      totalSize += stat.size;
    }

    if (totalSize <= _maxCacheSizeBytes) return;

    // Oldest first — simple LRU (reads touch the modified time).
    entries.sort((a, b) => a.$3.compareTo(b.$3));

    for (final (file, size, _) in entries) {
      if (totalSize <= _maxCacheSizeBytes) break;
      try {
        await file.delete();
        totalSize -= size;
      } catch (e) {
        debugPrint('Error in FileCacheService._evictIfNeeded: $e');
      }
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

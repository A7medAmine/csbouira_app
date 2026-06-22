import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';
import '../models/downloaded_file.dart';
import '../models/drive_node.dart';
import 'file_cache_service.dart';

class DownloadService {
  final http.Client _client;
  SharedPreferences? _prefs;
  static const _storageKey = 'downloaded_files';

  DownloadService({http.Client? client}) : _client = client ?? http.Client();

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<Directory> _getDownloadsDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/downloads');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<DownloadedFile> downloadFile(DriveFile file) async {
    final fileId = extractDriveFileId(file.link);
    if (fileId == null) {
      throw DownloadException('Could not extract file ID from link.');
    }

    final downloadUrl = file.downloadLink ??
        'https://drive.usercontent.google.com/download?id=$fileId';

    final safeName = file.name.replaceAll(RegExp(r'[^\w\-\. ]'), '_');
    final downloadsDir = await _getDownloadsDir();
    final localFile = File('${downloadsDir.path}/${fileId}_$safeName');

    if (await localFile.exists()) {
      final existing = await _findByPath(localFile.path);
      if (existing != null) return existing;
    }

    final response = await _client.get(Uri.parse(downloadUrl));
    if (response.statusCode != 200) {
      throw DownloadException(
        'Download failed with status ${response.statusCode}',
      );
    }

    await localFile.writeAsBytes(response.bodyBytes, flush: true);

    final downloaded = DownloadedFile(
      fileName: file.name,
      localPath: localFile.path,
      driveLink: file.link,
      downloadedAt: DateTime.now(),
      fileSize: response.bodyBytes.length,
    );

    await _saveRecord(downloaded);
    return downloaded;
  }

  Future<List<DownloadedFile>> getAll() async {
    final prefs = await _preferences;
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => DownloadedFile.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
  }

  Future<void> deleteDownload(String localPath) async {
    final file = File(localPath);
    if (await file.exists()) {
      await file.delete();
    }
    final prefs = await _preferences;
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    list.removeWhere((e) => e['localPath'] == localPath);
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  Future<DownloadedFile?> _findByPath(String localPath) async {
    final all = await getAll();
    try {
      return all.firstWhere((d) => d.localPath == localPath);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveRecord(DownloadedFile file) async {
    final prefs = await _preferences;
    final raw = prefs.getString(_storageKey);
    final list = (raw != null && raw.isNotEmpty)
        ? (jsonDecode(raw) as List).cast<Map<String, dynamic>>()
        : <Map<String, dynamic>>[];
    list.add(file.toJson());
    await prefs.setString(_storageKey, jsonEncode(list));
  }

  Future<OpenResult> openFile(String localPath) async {
    return OpenFilex.open(localPath);
  }
}

class DownloadException implements Exception {
  final String message;
  const DownloadException(this.message);
  @override
  String toString() => 'DownloadException: $message';
}

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

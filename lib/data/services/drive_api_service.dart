import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/drive_node.dart';
import '../../core/constants.dart';

class DriveApiException implements Exception {
  final String message;
  final String? path;
  final int? statusCode;

  const DriveApiException(this.message, {this.path, this.statusCode});

  @override
  String toString() => 'DriveApiException: $message${path != null ? ' (path: $path)' : ''}';
}

class DriveApiService {
  final http.Client _client;
  final Map<String, DriveNode> _cache = {};

  DriveApiService({http.Client? client}) : _client = client ?? http.Client();

  String get _baseUrl => ApiConstants.driveBaseUrl;

  String _buildPath(List<String> segments) {
    if (segments.isEmpty) return '';
    return segments.join('>subfolders>');
  }

  Future<Map<String, dynamic>> _getJson(Map<String, String?> queryParams) async {
    final params = <String, String>{};
    for (final e in queryParams.entries) {
      if (e.value != null && e.value!.isNotEmpty) {
        params[e.key] = e.value!;
      }
    }

    final uri = Uri.parse(_baseUrl).replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await _client.get(uri);

    if (response.statusCode == 404) {
      throw DriveApiException('Not found', path: params['path'], statusCode: 404);
    }
    if (response.statusCode != 200) {
      throw DriveApiException(
        'Server error: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final body = jsonDecode(response.body);
    if (body is Map && body.containsKey('error')) {
      throw DriveApiException(
        body['error'] as String,
        path: body['path'] as String?,
      );
    }

    return body as Map<String, dynamic>;
  }

  DriveNode _fetchAndCache(String path, DriveNode node) {
    _cache[path] = node;
    return node;
  }

  /// Full tree: years + _fileCounts + _onlineResources.
  Future<DriveRootData> getFullTree() async {
    final json = await _getJson({});
    final root = DriveRootData.fromFullTree(json);
    for (final entry in root.years.entries) {
      _cache[entry.key] = entry.value;
    }
    return root;
  }

  /// File counts per year.
  Future<Map<String, int>> getFileCounts() async {
    final json = await _getJson({'path': '_fileCounts'});
    return json.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  /// Online resources grouped by year / subject.
  Future<Map<String, Map<String, List<OnlineResource>>>> getOnlineResources() async {
    final json = await _getJson({'path': '_onlineResources'});
    return json.map((yearKey, subjectsRaw) {
      final subjects = subjectsRaw as Map<String, dynamic>;
      return MapEntry(
        yearKey,
        subjects.map((subj, resourcesRaw) {
          final list = (resourcesRaw as List)
              .map((r) => OnlineResource.fromJson(r as Map<String, dynamic>))
              .toList();
          return MapEntry(subj, list);
        }),
      );
    });
  }

  /// A single year's node (semesters + optional Books & Exercices).
  Future<DriveNode> getYear(String year) async {
    if (_cache.containsKey(year)) return _cache[year]!;
    final json = await _getJson({'year': year});
    final node = DriveNode.fromJson(json);
    return _fetchAndCache(year, node);
  }

  /// Navigate into a path of [segments] joined with `>subfolders>`.
  /// Example: `getPath(['Licence 1', 'S02', 'Analyse 2', 'Cours'])`
  Future<DriveNode> getPath(List<String> segments) async {
    final path = _buildPath(segments);
    if (_cache.containsKey(path)) return _cache[path]!;
    final json = await _getJson({'path': path});
    final node = DriveNode.fromJson(json);
    return _fetchAndCache(path, node);
  }

  /// Get the files array from a folder path.
  Future<List<DriveFile>> getFiles(List<String> folderPath) async {
    final path = '${_buildPath(folderPath)}>files';
    if (_cache.containsKey(path)) {
      return _cache[path]!.files;
    }
    final response = await _client.get(
      Uri.parse(_baseUrl).replace(queryParameters: {'path': path}),
    );
    if (response.statusCode != 200) {
      throw DriveApiException('Failed to fetch files', path: path, statusCode: response.statusCode);
    }
    final body = jsonDecode(response.body);
    if (body is Map && body.containsKey('error')) {
      throw DriveApiException(body['error'] as String, path: body['path'] as String?);
    }
    final files = (body as List)
        .map((e) => DriveFile.fromJson(e as Map<String, dynamic>))
        .toList();
    return files;
  }

  /// Get a single file by index from a folder path.
  Future<DriveFile> getFileAt(List<String> folderPath, int index) async {
    final path = '${_buildPath(folderPath)}>files>$index';
    final response = await _client.get(
      Uri.parse(_baseUrl).replace(queryParameters: {'path': path}),
    );
    if (response.statusCode != 200) {
      throw DriveApiException('Failed to fetch file at index $index', path: path);
    }
    final body = jsonDecode(response.body);
    if (body is Map && body.containsKey('error')) {
      throw DriveApiException(body['error'] as String, path: body['path'] as String?);
    }
    return DriveFile.fromJson(body as Map<String, dynamic>);
  }

  /// Navigate through the cached tree given a list of path segments.
  /// Does NOT make API calls — returns null if the path is not cached.
  DriveNode? getCachedNode(List<String> segments) {
    if (segments.isEmpty) return null;

    DriveNode? current = _cache[segments.first];
    if (current == null) return null;

    for (int i = 1; i < segments.length; i++) {
      final child = current!.subfolders[segments[i]];
      if (child == null) return null;
      current = child;
    }
    return current;
  }

  void clearCache() => _cache.clear();
}

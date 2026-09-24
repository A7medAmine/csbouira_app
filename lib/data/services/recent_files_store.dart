import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A file the user opened in the previewer.
class RecentFile {
  final String fileId;
  final String name;

  /// Folder path segments, when known (used to show the module name).
  final List<String> folderPath;
  final DateTime viewedAt;

  const RecentFile({
    required this.fileId,
    required this.name,
    required this.folderPath,
    required this.viewedAt,
  });

  /// Module name for a subtitle, or the year when the path is short.
  String get subtitle {
    final isBook = folderPath.length > 1 && folderPath[1] == 'Books & Exercices';
    final moduleIndex = isBook ? 3 : 2;
    if (folderPath.length > moduleIndex) return folderPath[moduleIndex];
    return folderPath.isNotEmpty ? folderPath.first : '';
  }

  Map<String, dynamic> toJson() => {
        'fileId': fileId,
        'name': name,
        'folderPath': folderPath,
        'viewedAt': viewedAt.toIso8601String(),
      };

  factory RecentFile.fromJson(Map<String, dynamic> json) => RecentFile(
        fileId: json['fileId'] as String,
        name: json['name'] as String? ?? '',
        folderPath: (json['folderPath'] as List?)?.cast<String>() ?? const [],
        viewedAt: DateTime.tryParse(json['viewedAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}

/// Most-recently-opened files, newest first, kept in SharedPreferences.
class RecentFilesStore {
  static const _key = 'recent_files';
  static const maxEntries = 20;

  Future<List<RecentFile>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => RecentFile.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  /// Moves [file] to the top of the list and returns the new list.
  Future<List<RecentFile>> add(RecentFile file) async {
    final items = await getAll()
      ..removeWhere((f) => f.fileId == file.fileId)
      ..insert(0, file);
    if (items.length > maxEntries) items.removeRange(maxEntries, items.length);
    await _save(items);
    return items;
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _save(List<RecentFile> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }
}

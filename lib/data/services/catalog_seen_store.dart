import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Remembers when each catalogue file was first seen on this device, so the
/// app can show "what's new" without the Drive API exposing upload dates.
///
/// Stored as JSON in the app support directory (the map holds thousands of
/// IDs, too big for SharedPreferences). Used from both the UI and the
/// background checker.
class CatalogSeenStore {
  static const _fileName = 'catalog_seen.json';

  final Future<Directory> Function() _directory;
  Future<void> _pending = Future.value();

  CatalogSeenStore({Future<Directory> Function()? directory})
      : _directory = directory ?? getApplicationSupportDirectory;

  Future<File> get _file async => File('${(await _directory()).path}/$_fileName');

  /// Loads the `fileId -> first seen (ms since epoch)` map. Files from the
  /// very first sync are stored with 0, meaning "already there".
  Future<Map<String, int>> load() async {
    final file = await _file;
    if (!await file.exists()) return {};
    try {
      final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final seen = json['seen'] as Map<String, dynamic>? ?? {};
      return seen.map((k, v) => MapEntry(k, (v as num).toInt()));
    } on FormatException {
      return {};
    }
  }

  /// Records [currentIds] and returns the ones never seen before.
  ///
  /// The first call on a device only builds the baseline and returns an
  /// empty set, so a fresh install does not report 5000 "new" files.
  /// IDs that disappeared from the catalogue are dropped.
  Future<Set<String>> record(Set<String> currentIds, {DateTime? now}) {
    final result = _pending.then((_) => _record(currentIds, now ?? DateTime.now()));
    _pending = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<Set<String>> _record(Set<String> currentIds, DateTime now) async {
    final file = await _file;
    final isFirstRun = !await file.exists();
    final seen = await load();
    final stamp = isFirstRun ? 0 : now.millisecondsSinceEpoch;

    final added = <String>{};
    for (final id in currentIds) {
      if (!seen.containsKey(id)) {
        seen[id] = stamp;
        if (!isFirstRun) added.add(id);
      }
    }
    seen.removeWhere((id, _) => !currentIds.contains(id));

    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(jsonEncode({'v': 1, 'seen': seen}), flush: true);
    await tmp.rename(file.path);
    return added;
  }
}

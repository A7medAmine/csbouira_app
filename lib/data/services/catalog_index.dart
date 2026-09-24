import '../../core/text_search.dart';
import '../models/catalog_file.dart';
import '../models/drive_node.dart';
import 'file_cache_service.dart' show extractDriveFileId;

const _booksFolder = 'Books & Exercices';

/// A flat, searchable list of every file in the Drive tree.
///
/// Built once from [DriveRootData]; lookups by file ID are O(1).
class CatalogIndex {
  final List<CatalogFile> files;
  final Map<String, CatalogFile> _byId;

  CatalogIndex._(this.files, this._byId);

  factory CatalogIndex.build(DriveRootData root) {
    final files = <CatalogFile>[];
    final byId = <String, CatalogFile>{};

    void walk(DriveNode node, List<String> path) {
      for (final file in node.files) {
        final id = extractDriveFileId(file.link);
        if (id == null) continue;
        final entry = _entryFor(file, id, path);
        files.add(entry);
        byId.putIfAbsent(id, () => entry);
      }
      for (final sub in node.subfolders.entries) {
        walk(sub.value, [...path, sub.key]);
      }
    }

    for (final year in root.years.entries) {
      walk(year.value, [year.key]);
    }
    return CatalogIndex._(files, byId);
  }

  static CatalogFile _entryFor(DriveFile file, String id, List<String> path) {
    final isBook = path.length > 1 && path[1] == _booksFolder;
    // Regular layout:  year / semester / module / category / ...
    // Books layout:    year / Books & Exercices / semester / module / ...
    final offset = isBook ? 1 : 0;
    String at(int i) => i < path.length ? path[i] : '';
    return CatalogFile(
      file: file,
      id: id,
      folderPath: List.unmodifiable(path),
      year: at(0),
      semester: at(1 + offset),
      module: at(2 + offset),
      category: isBook
          ? ResourceCategory.book
          : categoryFromFolder(at(3)),
      isCorrection: looksLikeCorrection(file.name),
      normalizedName: normalizeForSearch(file.name),
      normalizedContext: normalizeForSearch(
        path.skip(2 + offset).join(' '),
      ),
    );
  }

  CatalogFile? byId(String id) => _byId[id];

  Set<String> get ids => _byId.keys.toSet();

  /// All files in the same folder as [entry], in display order, for the
  /// previewer's next/previous arrows.
  List<CatalogFile> siblingsOf(CatalogFile entry) {
    final key = entry.folderPath.join('\x00');
    return files.where((f) => f.folderPath.join('\x00') == key).toList();
  }

  /// Files ranked by how well their name (and module) matches [query].
  List<CatalogFile> search(
    String query, {
    String? year,
    String? semester,
    String? module,
    ResourceCategory? category,
    int limit = 200,
  }) {
    final q = normalizeForSearch(query);
    if (q.isEmpty) return const [];
    final scored = <(CatalogFile, int)>[];
    for (final f in files) {
      if (year != null && f.year != year) continue;
      if (semester != null && f.semester != semester) continue;
      if (module != null && f.module != module) continue;
      if (category != null && f.category != category) continue;
      var score = matchScore(q, f.normalizedName);
      if (score == 0) {
        // "analyse exam" should find exam files of the Analyse module.
        score =
            matchScore(q, '${f.normalizedName} ${f.normalizedContext}') ~/ 2;
      }
      if (score > 0) scored.add((f, score));
    }
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    return scored.take(limit).map((e) => e.$1).toList();
  }
}

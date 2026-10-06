import 'package:flutter/material.dart';
import 'models/drive_node.dart';

class YearInfo {
  final String name;
  final String level;
  final String? badge;
  final IconData? icon;
  final int colSpan;

  const YearInfo({
    required this.name,
    required this.level,
    this.badge,
    this.icon,
    this.colSpan = 1,
  });
}

const kYears = [
  YearInfo(name: 'Licence 1', level: 'Bachelor', colSpan: 1),
  YearInfo(name: 'Licence 2', level: 'Bachelor', colSpan: 1),
  YearInfo(name: 'Licence 3 SI', level: 'Bachelor Final Year', badge: 'CORE', colSpan: 2),
  YearInfo(name: 'Master 1 GSI', level: 'Master', colSpan: 1),
  YearInfo(name: 'Master 1 ISIL', level: 'Master', colSpan: 1),
  YearInfo(name: 'Master 1 IA', level: 'Master', badge: 'NEW', icon: Icons.psychology, colSpan: 2),
  YearInfo(name: 'Master 2 GSI', level: 'Master', colSpan: 1),
  YearInfo(name: 'Master 2 ISIL', level: 'Master', colSpan: 1),
  YearInfo(name: 'Master 2 IA', level: 'Master', colSpan: 1),
];

const kSemesters = {
  'Licence 1': ['S01', 'S02'],
  'Licence 2': ['S03', 'S04'],
  'Licence 3 SI': ['S05', 'S06'],
  'Master 1 GSI': ['S07', 'S08'],
  'Master 1 ISIL': ['S07', 'S08'],
  'Master 1 IA': ['S07', 'S08'],
  'Master 2 GSI': ['S09'],
  'Master 2 ISIL': ['S09'],
  'Master 2 IA': ['S09'],
};

const kFolderTypes = ['Cours', 'Exams', 'Résumé', 'TDs & TPs', 'Tests'];

/// Separator between Drive folder names in an API path.
const kDrivePathSep = '>subfolders>';

const kBooksFolder = 'Books & Exercices';

final _promoPattern = RegExp(r'^\d{2}(\d{2}|XX)-\d{4}$');

/// True for an academic-year folder (`2024-2025`, or `20XX-2024` for the
/// archive) that sits between a year and its semesters.
bool isPromoFolder(String name) => _promoPattern.hasMatch(name);

/// True for the archive promo folder (`20XX-2024`).
bool isArchivePromo(String name) => name.contains('XX');

/// A semester id is the Drive path from the year to the semester folder:
/// `S05` for most years, `2024-2025>subfolders>S1` when the year is split
/// into promos. Joining it with [kDrivePathSep] yields a valid API path.
List<String> semesterSegments(String semester) =>
    semester.isEmpty ? const [] : semester.split(kDrivePathSep);

/// The semester folder name without its promo (`S1`).
String semesterName(String semester) => semesterSegments(semester).last;

/// The promo folder of [semester], or null when the year has none.
String? semesterPromo(String semester) {
  final segments = semesterSegments(semester);
  return segments.length > 1 ? segments.first : null;
}

/// Expands compound semester ids inside [segments] into raw folder names.
List<String> rawDriveSegments(List<String> segments) =>
    [for (final s in segments) ...s.split(kDrivePathSep)];

/// Raw Drive folder names split into year, semester id and what follows
/// (module, category folder, ...).
class DrivePathParts {
  final String year;
  final String semester;
  final List<String> rest;

  const DrivePathParts(this.year, this.semester, this.rest);

  factory DrivePathParts.parse(List<String> segments) {
    final raw = rawDriveSegments(segments);
    if (raw.isEmpty) return const DrivePathParts('', '', []);
    if (raw.length > 2 && isPromoFolder(raw[1])) {
      return DrivePathParts(
        raw[0],
        '${raw[1]}$kDrivePathSep${raw[2]}',
        raw.sublist(3),
      );
    }
    return DrivePathParts(
      raw[0],
      raw.length > 1 ? raw[1] : '',
      raw.length > 2 ? raw.sublist(2) : const [],
    );
  }

  String get module => rest.isNotEmpty ? rest.first : '';
}

/// Semesters of a year node keyed by semester id, promo folders expanded
/// (newest promo first, archive last). Skips Books & Exercices, and with
/// [skipEmptyPromos] the semesters of promos that have no files yet.
Map<String, DriveNode> semesterNodesOf(
  DriveNode yearNode, {
  bool skipEmptyPromos = false,
}) {
  final direct = <String, DriveNode>{};
  final promos = <MapEntry<String, DriveNode>>[];
  for (final entry in yearNode.subfolders.entries) {
    if (entry.key == kBooksFolder) continue;
    if (isPromoFolder(entry.key)) {
      if (skipEmptyPromos && entry.value.totalFiles == 0) continue;
      promos.add(entry);
    } else {
      direct[entry.key] = entry.value;
    }
  }
  int rank(String promo) => isArchivePromo(promo) ? 0 : 1;
  promos.sort((a, b) {
    final byRank = rank(b.key).compareTo(rank(a.key));
    return byRank != 0 ? byRank : b.key.compareTo(a.key);
  });
  return {
    ...direct,
    for (final promo in promos)
      for (final sem in promo.value.subfolders.entries)
        '${promo.key}$kDrivePathSep${sem.key}': sem.value,
  };
}

/// Display name of a semester id: `S05`, `S1 · 2024-2025` or
/// `S01 · <archiveLabel>`.
String semesterLabel(String semester, String archiveLabel) {
  final promo = semesterPromo(semester);
  final name = semesterName(semester);
  if (promo == null) return name;
  return '$name · ${isArchivePromo(promo) ? archiveLabel : promo}';
}

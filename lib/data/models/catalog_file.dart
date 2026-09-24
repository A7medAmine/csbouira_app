import '../../core/text_search.dart';
import 'drive_node.dart';

/// What kind of material a file is, taken from the category folder it lives
/// in (`Cours`, `Exams`, `Tests`, `Résumé`, `TDs & TPs`).
enum ResourceCategory { course, exam, test, summary, tdTp, book, other }

ResourceCategory categoryFromFolder(String folderName) {
  final n = normalizeForSearch(folderName);
  if (n.startsWith('cours')) return ResourceCategory.course;
  if (n.startsWith('exam')) return ResourceCategory.exam;
  if (n.startsWith('test')) return ResourceCategory.test;
  if (n.startsWith('resume')) return ResourceCategory.summary;
  if (n.startsWith('td') || n.startsWith('tp')) return ResourceCategory.tdTp;
  return ResourceCategory.other;
}

final _correctionPattern = RegExp(r'\b(corrig\w*|correction\w*|solutions?|sol)\b');

/// True if a file name looks like an answer key ("Corrigé", "Solution", …).
bool looksLikeCorrection(String fileName) =>
    _correctionPattern.hasMatch(normalizeForSearch(fileName));

/// One file of the catalogue together with where it lives.
class CatalogFile {
  final DriveFile file;

  /// Drive file ID, used as a stable key (deep links, "what's new").
  final String id;

  /// Path segments of the folder that directly contains the file, starting
  /// with the year (for example `['Licence 1', 'S01', 'Analyse 1', 'Cours']`).
  final List<String> folderPath;

  final String year;
  final String semester;
  final String module;
  final ResourceCategory category;
  final bool isCorrection;

  /// [file.name] run through [normalizeForSearch].
  final String normalizedName;

  /// Normalized module and folder names, searched when the name alone
  /// doesn't match.
  final String normalizedContext;

  const CatalogFile({
    required this.file,
    required this.id,
    required this.folderPath,
    required this.year,
    required this.semester,
    required this.module,
    required this.category,
    required this.isCorrection,
    required this.normalizedName,
    required this.normalizedContext,
  });

  String get name => file.name;

  /// `year>semester>module`, the key used to follow a module.
  String get moduleKey => moduleKeyOf(year, semester, module);
}

String moduleKeyOf(String year, String semester, String module) =>
    '$year>$semester>$module';

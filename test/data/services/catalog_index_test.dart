import 'package:flutter_test/flutter_test.dart';
import 'package:csbouira_app/data/models/catalog_file.dart';
import 'package:csbouira_app/data/models/drive_node.dart';
import 'package:csbouira_app/data/services/catalog_index.dart';
import 'package:csbouira_app/data/services/new_files_checker.dart';

import '../../support/catalog_fixture.dart';

void main() {
  late CatalogIndex index;

  setUp(() => index = CatalogIndex.build(sampleRoot()));

  group('CatalogIndex.build', () {
    test('indexes files in nested folders and books', () {
      expect(index.files, hasLength(7));
      expect(index.byId('cours0000001'), isNotNull);
      expect(index.byId('book00000001'), isNotNull);
    });

    test('reads year, semester, module and category from the path', () {
      final exam = index.byId('exam00000001')!;
      expect(exam.year, 'Licence 1');
      expect(exam.semester, 'S01');
      expect(exam.module, 'Analyse 1');
      expect(exam.category, ResourceCategory.exam);
      expect(exam.folderPath, ['Licence 1', 'S01', 'Analyse 1', 'Exams']);
      expect(exam.moduleKey, 'Licence 1>S01>Analyse 1');
    });

    test('handles the Books & Exercices layout', () {
      final book = index.byId('book00000001')!;
      expect(book.category, ResourceCategory.book);
      expect(book.semester, 'S01');
      expect(book.module, 'Algorithme');
    });

    test('maps every category folder', () {
      expect(index.byId('cours0000001')!.category, ResourceCategory.course);
      expect(index.byId('test00000001')!.category, ResourceCategory.test);
      expect(index.byId('tdtp00000001')!.category, ResourceCategory.tdTp);
      expect(index.byId('resu00000001')!.category, ResourceCategory.summary);
    });

    test('flags corrections', () {
      expect(index.byId('exam00000002')!.isCorrection, isTrue);
      expect(index.byId('book00000001')!.isCorrection, isTrue);
      expect(index.byId('exam00000001')!.isCorrection, isFalse);
    });

    test('skips files without a Drive ID', () {
      final root = DriveRootData(
        fileCounts: const {},
        onlineResources: const {},
        years: {
          'Licence 1': folder(files: [
            const DriveFile(name: 'broken.pdf', link: 'https://example.com/x'),
            driveFile('ok.pdf', 'okfile000001'),
          ]),
        },
      );
      expect(CatalogIndex.build(root).files.map((f) => f.id), ['okfile000001']);
    });
  });

  group('siblingsOf', () {
    test('returns the files of the same folder in order', () {
      final siblings = index.siblingsOf(index.byId('exam00000002')!);
      expect(siblings.map((f) => f.id), ['exam00000001', 'exam00000002']);
    });
  });

  group('search', () {
    test('finds files by name, ignoring accents', () {
      final results = index.search('resume algorithmique');
      expect(results.first.id, 'resu00000001');
    });

    test('falls back to module and folder names', () {
      final results = index.search('analyse exams');
      expect(results.map((f) => f.id), containsAll(['exam00000001', 'exam00000002']));
    });

    test('applies filters', () {
      final results = index.search('exam', category: ResourceCategory.exam);
      expect(results.every((f) => f.category == ResourceCategory.exam), isTrue);
      expect(index.search('exam', year: 'Master 1 IA'), isEmpty);
    });

    test('returns nothing for a blank query', () {
      expect(index.search('   '), isEmpty);
    });
  });

  group('newFilesInFollowedModules', () {
    test('groups new files of followed modules only', () {
      final result = newFilesInFollowedModules(
        index,
        {'exam00000001', 'resu00000001', 'unknown00001'},
        {'Licence 1>S01>Analyse 1'},
      );
      expect(result.keys, ['Licence 1>S01>Analyse 1']);
      expect(result.values.single.single.id, 'exam00000001');
    });
  });
}

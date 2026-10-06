import 'package:flutter_test/flutter_test.dart';
import 'package:csbouira_app/data/models/catalog_file.dart';
import 'package:csbouira_app/data/models/drive_node.dart';
import 'package:csbouira_app/data/navigation_data.dart';
import 'package:csbouira_app/data/services/catalog_index.dart';

import '../support/catalog_fixture.dart';

void main() {
  group('promo folders', () {
    test('recognises academic years and the archive', () {
      expect(isPromoFolder('2024-2025'), isTrue);
      expect(isPromoFolder('20XX-2024'), isTrue);
      expect(isPromoFolder('S01'), isFalse);
      expect(isPromoFolder(kBooksFolder), isFalse);
      expect(isArchivePromo('20XX-2024'), isTrue);
      expect(isArchivePromo('2024-2025'), isFalse);
    });

    test('semester ids round-trip through their segments', () {
      const id = '2024-2025>subfolders>S1';
      expect(semesterSegments(id), ['2024-2025', 'S1']);
      expect(semesterName(id), 'S1');
      expect(semesterPromo(id), '2024-2025');
      expect(semesterPromo('S05'), isNull);
      expect(semesterLabel(id, 'Archive'), 'S1 · 2024-2025');
      expect(semesterLabel('20XX-2024>subfolders>S01', 'Archive'),
          'S01 · Archive');
      expect(semesterLabel('S05', 'Archive'), 'S05');
    });

    test('DrivePathParts folds the promo into the semester', () {
      final promo = DrivePathParts.parse(
        ['Licence 1', '2024-2025', 'S1', 'Analyse 1', 'Cours'],
      );
      expect(promo.year, 'Licence 1');
      expect(promo.semester, '2024-2025>subfolders>S1');
      expect(promo.module, 'Analyse 1');
      expect(promo.rest, ['Analyse 1', 'Cours']);

      final plain = DrivePathParts.parse(['Licence 3 SI', 'S05', 'IHM']);
      expect(plain.semester, 'S05');
      expect(plain.module, 'IHM');

      // Compound ids inside the list are expanded first.
      final compound = DrivePathParts.parse(
        ['Licence 1', '2024-2025>subfolders>S1', 'Analyse 1'],
      );
      expect(compound.semester, '2024-2025>subfolders>S1');
      expect(compound.module, 'Analyse 1');
    });
  });

  group('semesterNodesOf', () {
    final year = folder(subfolders: {
      '20XX-2024': folder(subfolders: {
        'S01': folder(files: [driveFile('a.pdf', 'archive00001')]),
      }),
      '2026-2027': folder(subfolders: {'S03': folder()}),
      '2024-2025': folder(subfolders: {
        'S1': folder(files: [driveFile('b.pdf', 'current00001')]),
        'S2': folder(),
      }),
      kBooksFolder: folder(),
    });

    test('expands promos newest first, archive last, skipping books', () {
      expect(semesterNodesOf(year).keys, [
        '2026-2027>subfolders>S03',
        '2024-2025>subfolders>S1',
        '2024-2025>subfolders>S2',
        '20XX-2024>subfolders>S01',
      ]);
    });

    test('can hide promos without files', () {
      expect(semesterNodesOf(year, skipEmptyPromos: true).keys, [
        '2024-2025>subfolders>S1',
        '2024-2025>subfolders>S2',
        '20XX-2024>subfolders>S01',
      ]);
    });

    test('keeps years without promos as they are', () {
      final plain = folder(subfolders: {'S05': folder(), 'S06': folder()});
      expect(semesterNodesOf(plain).keys, ['S05', 'S06']);
    });
  });

  test('CatalogIndex reads the promo layout', () {
    final root = DriveRootData(
      fileCounts: const {},
      onlineResources: const {},
      years: {
        'Licence 1': folder(subfolders: {
          '2024-2025': folder(subfolders: {
            'S1': folder(subfolders: {
              '1. ASD 1': folder(subfolders: {
                'EMD': folder(files: [driveFile('emd.pdf', 'emdfile00001')]),
              }),
            }),
          }),
        }),
      },
    );
    final file = CatalogIndex.build(root).byId('emdfile00001')!;
    expect(file.semester, '2024-2025>subfolders>S1');
    expect(file.module, '1. ASD 1');
    expect(file.category, ResourceCategory.exam);
    expect(file.folderPath, ['Licence 1', '2024-2025', 'S1', '1. ASD 1', 'EMD']);
  });
}

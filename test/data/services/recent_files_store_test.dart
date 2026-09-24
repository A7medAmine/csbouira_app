import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csbouira_app/data/services/followed_modules_store.dart';
import 'package:csbouira_app/data/services/recent_files_store.dart';

RecentFile recent(String id, {List<String> path = const []}) => RecentFile(
      fileId: id,
      name: '$id.pdf',
      folderPath: path,
      viewedAt: DateTime(2026, 9, 1),
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('RecentFilesStore', () {
    test('adds newest first and de-duplicates', () async {
      final store = RecentFilesStore();
      await store.add(recent('a'));
      await store.add(recent('b'));
      final items = await store.add(recent('a'));
      expect(items.map((f) => f.fileId), ['a', 'b']);
      expect((await store.getAll()).map((f) => f.fileId), ['a', 'b']);
    });

    test('keeps at most maxEntries', () async {
      final store = RecentFilesStore();
      for (var i = 0; i < RecentFilesStore.maxEntries + 5; i++) {
        await store.add(recent('f$i'));
      }
      final items = await store.getAll();
      expect(items, hasLength(RecentFilesStore.maxEntries));
      expect(items.first.fileId, 'f${RecentFilesStore.maxEntries + 4}');
    });

    test('survives corrupt data', () async {
      SharedPreferences.setMockInitialValues({'recent_files': 'not json'});
      expect(await RecentFilesStore().getAll(), isEmpty);
    });

    test('clear empties the list', () async {
      final store = RecentFilesStore();
      await store.add(recent('a'));
      await store.clear();
      expect(await store.getAll(), isEmpty);
    });
  });

  group('RecentFile.subtitle', () {
    test('uses the module name', () {
      expect(recent('a', path: ['Licence 1', 'S01', 'Analyse 1', 'Exams']).subtitle,
          'Analyse 1');
      expect(
        recent('a', path: ['Licence 1', 'Books & Exercices', 'S01', 'Algorithme'])
            .subtitle,
        'Algorithme',
      );
    });

    test('falls back to the year, then nothing', () {
      expect(recent('a', path: ['Licence 1', 'S01']).subtitle, 'Licence 1');
      expect(recent('a').subtitle, '');
    });
  });

  group('FollowedModulesStore', () {
    test('saves and loads module keys', () async {
      final store = FollowedModulesStore();
      expect(await store.getAll(), isEmpty);
      await store.save({'Licence 1>S01>Analyse 1', 'Licence 2>S03>BDD'});
      expect(await store.getAll(),
          {'Licence 1>S01>Analyse 1', 'Licence 2>S03>BDD'});
    });
  });
}

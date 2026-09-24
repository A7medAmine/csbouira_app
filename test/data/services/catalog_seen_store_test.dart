import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:csbouira_app/data/services/catalog_seen_store.dart';

void main() {
  late Directory dir;
  late CatalogSeenStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('seen_store_test');
    store = CatalogSeenStore(directory: () async => dir);
  });

  tearDown(() => dir.delete(recursive: true));

  test('first sync builds a baseline and reports nothing new', () async {
    final added = await store.record({'a', 'b'});
    expect(added, isEmpty);
    expect(await store.load(), {'a': 0, 'b': 0});
  });

  test('later syncs report and timestamp new IDs', () async {
    await store.record({'a'});
    final now = DateTime(2026, 9, 1);
    final added = await store.record({'a', 'b'}, now: now);
    expect(added, {'b'});
    final seen = await store.load();
    expect(seen['a'], 0);
    expect(seen['b'], now.millisecondsSinceEpoch);
  });

  test('keeps the first-seen time on later syncs', () async {
    await store.record({'a'});
    final first = DateTime(2026, 9, 1);
    await store.record({'a', 'b'}, now: first);
    await store.record({'a', 'b'}, now: DateTime(2026, 9, 5));
    expect((await store.load())['b'], first.millisecondsSinceEpoch);
  });

  test('drops IDs that left the catalogue', () async {
    await store.record({'a', 'b'});
    await store.record({'a'});
    expect((await store.load()).keys, ['a']);
  });

  test('serializes concurrent writes', () async {
    await store.record({'a'});
    final results = await Future.wait([
      store.record({'a', 'b'}),
      store.record({'a', 'b', 'c'}),
    ]);
    expect(results[0], {'b'});
    expect(results[1], {'c'});
  });

  test('treats a corrupt file as empty', () async {
    await File('${dir.path}/catalog_seen.json').writeAsString('{not json');
    expect(await store.load(), isEmpty);
  });
}

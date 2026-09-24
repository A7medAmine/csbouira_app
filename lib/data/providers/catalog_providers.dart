import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/catalog_file.dart';
import '../services/catalog_index.dart';
import '../services/catalog_seen_store.dart';
import '../services/followed_modules_store.dart';
import '../services/home_widget_service.dart';
import '../services/new_files_checker.dart';
import '../services/notification_service.dart';
import '../services/recent_files_store.dart';
import 'drive_providers.dart';

/// Flat index of every file; rebuilt when the Drive tree is refreshed.
final catalogIndexProvider = FutureProvider<CatalogIndex>((ref) async {
  final root = await ref.watch(driveRootDataProvider.future);
  // Normalizing ~5k file names takes a noticeable moment on phones; keep it
  // off the UI thread.
  return compute(CatalogIndex.build, root);
});

final catalogSeenStoreProvider = Provider<CatalogSeenStore>((ref) {
  ref.keepAlive();
  return CatalogSeenStore();
});

/// A file that appeared in the catalogue recently.
class NewCatalogFile {
  final CatalogFile file;
  final DateTime firstSeen;
  const NewCatalogFile(this.file, this.firstSeen);
}

/// How long a file stays in the "what's new" feed.
const whatsNewWindow = Duration(days: 14);

/// Files first seen on this device within [whatsNewWindow], newest first.
final whatsNewProvider = FutureProvider<List<NewCatalogFile>>((ref) async {
  final index = await ref.watch(catalogIndexProvider.future);
  final store = ref.read(catalogSeenStoreProvider);
  await store.record(index.ids);
  final seen = await store.load();
  final cutoff =
      DateTime.now().subtract(whatsNewWindow).millisecondsSinceEpoch;

  final result = <NewCatalogFile>[];
  final added = <String>{};
  for (final file in index.files) {
    final at = seen[file.id] ?? 0;
    if (at < cutoff || !added.add(file.id)) continue;
    result.add(NewCatalogFile(file, DateTime.fromMillisecondsSinceEpoch(at)));
  }
  result.sort((a, b) => b.firstSeen.compareTo(a.firstSeen));
  return result;
});

// ── Followed modules ──────────────────────────────────────────────────────

final followedModulesProvider =
    AsyncNotifierProvider<FollowedModulesNotifier, Set<String>>(
  FollowedModulesNotifier.new,
);

class FollowedModulesNotifier extends AsyncNotifier<Set<String>> {
  final _store = FollowedModulesStore();

  @override
  Future<Set<String>> build() async {
    final modules = await _store.getAll();
    await NewFilesScheduler.sync(enabled: modules.isNotEmpty);
    return modules;
  }

  /// Follows or unfollows [moduleKey]. Returns true when it is now followed.
  ///
  /// The first follow asks for the notification permission; following still
  /// works without it (new files show up in the "what's new" feed).
  Future<bool> toggle(String moduleKey) async {
    final current = {...(state.valueOrNull ?? await future)};
    final nowFollowed = current.add(moduleKey);
    if (!nowFollowed) current.remove(moduleKey);
    state = AsyncData(current);
    await _store.save(current);
    if (nowFollowed && current.length == 1) {
      await NotificationService.requestPermission();
    }
    await NewFilesScheduler.sync(enabled: current.isNotEmpty);
    return nowFollowed;
  }
}

// ── Recent files ──────────────────────────────────────────────────────────

final recentFilesProvider =
    AsyncNotifierProvider<RecentFilesNotifier, List<RecentFile>>(
  RecentFilesNotifier.new,
);

class RecentFilesNotifier extends AsyncNotifier<List<RecentFile>> {
  final _store = RecentFilesStore();

  @override
  Future<List<RecentFile>> build() async {
    final items = await _store.getAll();
    // Keeps the home screen widget in sync after app updates.
    HomeWidgetService.updateRecentFiles(items);
    return items;
  }

  Future<void> add(RecentFile file) async {
    final items = await _store.add(file);
    state = AsyncData(items);
    await HomeWidgetService.updateRecentFiles(items);
  }

  Future<void> clear() async {
    await _store.clear();
    state = const AsyncData([]);
    await HomeWidgetService.updateRecentFiles(const []);
  }
}

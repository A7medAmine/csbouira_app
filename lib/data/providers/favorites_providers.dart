import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_favorites_cache.dart';
import 'auth_providers.dart';

class FavoriteItem {
  final String itemType;
  final String itemPath;
  final String displayName;
  final String? resourceType;
  final String? folderPath;
  final DateTime createdAt;

  List<String> get pathSegments => itemPath.split('>subfolders>');

  const FavoriteItem({
    required this.itemType,
    required this.itemPath,
    required this.displayName,
    this.resourceType,
    this.folderPath,
    required this.createdAt,
  });

  factory FavoriteItem.fromLocal(LocalFavoriteItem item) {
    return FavoriteItem(
      itemType: item.itemType,
      itemPath: item.itemPath,
      displayName: item.displayName,
      resourceType: item.resourceType,
      folderPath: item.folderPath,
      createdAt: item.createdAt,
    );
  }
}

class FavoritesNotifier extends AsyncNotifier<List<FavoriteItem>> {
  @override
  Future<List<FavoriteItem>> build() async {
    final repo = ref.watch(favoritesRepositoryProvider);
    final items = await repo.getAll();
    return items.map(FavoriteItem.fromLocal).toList();
  }

  /// Optimistically adds [item]. Returns false (and rolls back) on failure.
  Future<bool> add(FavoriteItem item) async {
    final previousState = state;
    state = AsyncData([item, ...(state.valueOrNull ?? [])]);
    try {
      final repo = ref.read(favoritesRepositoryProvider);
      await repo.addFavorite(
        item.itemType,
        item.itemPath,
        item.displayName,
        resourceType: item.resourceType,
        folderPath: item.folderPath,
      );
      return true;
    } catch (e) {
      debugPrint('Error in FavoritesNotifier.add: $e');
      state = previousState;
      return false;
    }
  }

  /// Optimistically removes an item. Returns false (and rolls back) on failure.
  Future<bool> remove(String itemType, String itemPath) async {
    final previousState = state;
    final items = state.valueOrNull ?? [];
    state = AsyncData(
      items
          .where((e) => e.itemType != itemType || e.itemPath != itemPath)
          .toList(),
    );
    try {
      final repo = ref.read(favoritesRepositoryProvider);
      await repo.removeFavorite(itemType, itemPath);
      return true;
    } catch (e) {
      debugPrint('Error in FavoritesNotifier.remove: $e');
      state = previousState;
      return false;
    }
  }

  Future<bool> toggleFile(String fileLink, String displayName) async {
    final items = state.valueOrNull ?? [];
    final exists = items.any((e) => e.itemType == 'file' && e.itemPath == fileLink);
    if (exists) {
      return remove('file', fileLink);
    }
    return add(FavoriteItem(
      itemType: 'file',
      itemPath: fileLink,
      displayName: displayName,
      createdAt: DateTime.now(),
    ));
  }
}

final favoritesListProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<FavoriteItem>>(
  FavoritesNotifier.new,
);

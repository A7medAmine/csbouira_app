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

  factory FavoriteItem.fromRemote(Map<String, dynamic> map) {
    final path = map['item_path'] as String;
    return FavoriteItem(
      itemType: map['item_type'] as String,
      itemPath: path,
      displayName:
          map['display_name'] as String? ?? path.split('>subfolders>').last,
      resourceType: map['resource_type'] as String?,
      folderPath: map['folder_path'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class FavoritesNotifier extends AsyncNotifier<List<FavoriteItem>> {
  @override
  Future<List<FavoriteItem>> build() async {
    final repo = ref.watch(favoritesRepositoryProvider);
    final raw = await repo.getAll();
    if (raw.isEmpty) return [];
    if (raw.first is LocalFavoriteItem) {
      return (raw as List<LocalFavoriteItem>)
          .map(FavoriteItem.fromLocal)
          .toList();
    }
    return (raw as List<Map<String, dynamic>>)
        .map(FavoriteItem.fromRemote)
        .toList();
  }

  Future<void> add(FavoriteItem item) async {
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
    } catch (_) {
      state = previousState;
    }
  }

  Future<void> remove(String itemType, String itemPath) async {
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
    } catch (_) {
      state = previousState;
    }
  }

  Future<void> toggleFile(String fileLink, String displayName) async {
    final items = state.valueOrNull ?? [];
    final exists = items.any((e) => e.itemType == 'file' && e.itemPath == fileLink);
    if (exists) {
      await remove('file', fileLink);
    } else {
      await add(FavoriteItem(
        itemType: 'file',
        itemPath: fileLink,
        displayName: displayName,
        createdAt: DateTime.now(),
      ));
    }
  }
}

final favoritesListProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<FavoriteItem>>(
  FavoritesNotifier.new,
);

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_favorites_cache.dart';
import 'auth_providers.dart';

class FavoriteItem {
  final String itemType;
  final String itemPath;
  final String displayName;
  final String? resourceType;
  final DateTime createdAt;

  List<String> get pathSegments => itemPath.split('>subfolders>');

  const FavoriteItem({
    required this.itemType,
    required this.itemPath,
    required this.displayName,
    this.resourceType,
    required this.createdAt,
  });

  factory FavoriteItem.fromLocal(LocalFavoriteItem item) {
    return FavoriteItem(
      itemType: item.itemType,
      itemPath: item.itemPath,
      displayName: item.displayName,
      resourceType: item.resourceType,
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
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

final favoritesListProvider = FutureProvider<List<FavoriteItem>>((ref) async {
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
});

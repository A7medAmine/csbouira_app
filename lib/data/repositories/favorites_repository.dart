import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/local_favorites_cache.dart';

/// Reads and writes favorites for the current session.
///
/// - Guest ([userId] is null): favorites live only in [_guestCache].
/// - Signed in: Supabase is the source of truth. [_accountCache] is an
///   offline mirror for that user only; the guest list is never touched.
///
/// Writes for signed-in users throw on failure so callers can roll back
/// their optimistic UI instead of silently diverging from the server.
class FavoritesRepository {
  final LocalFavoritesCache _guestCache;
  final SupabaseClient _supabase;
  final String? _userId;
  final LocalFavoritesCache? _accountCache;

  FavoritesRepository({
    required LocalFavoritesCache guestCache,
    required SupabaseClient supabase,
    required String? userId,
  })  : _guestCache = guestCache,
        _supabase = supabase,
        _userId = userId,
        _accountCache =
            userId != null ? LocalFavoritesCache.forAccount(userId) : null;

  Future<void> addFavorite(
      String itemType, String itemPath, String displayName, {String? resourceType, String? folderPath}) async {
    final userId = _userId;
    if (userId == null) {
      await _guestCache.addFavorite(itemType, itemPath, displayName,
          resourceType: resourceType, folderPath: folderPath);
      return;
    }
    await _supabase.from('favorites').upsert(
      {
        'user_id': userId,
        'item_type': itemType,
        'item_path': itemPath,
        'display_name': displayName,
        if (resourceType != null) 'resource_type': resourceType,
        if (folderPath != null) 'folder_path': folderPath,
      },
      onConflict: 'user_id, item_type, item_path',
      ignoreDuplicates: true,
    );
    await _accountCache!.addFavorite(itemType, itemPath, displayName,
        resourceType: resourceType, folderPath: folderPath);
  }

  Future<void> removeFavorite(String itemType, String itemPath) async {
    final userId = _userId;
    if (userId == null) {
      await _guestCache.removeFavorite(itemType, itemPath);
      return;
    }
    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('item_type', itemType)
        .eq('item_path', itemPath);
    await _accountCache!.removeFavorite(itemType, itemPath);
  }

  Future<bool> isFavorite(String itemType, String itemPath) async {
    final userId = _userId;
    if (userId == null) return _guestCache.isFavorite(itemType, itemPath);
    try {
      final result = await _supabase
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('item_type', itemType)
          .eq('item_path', itemPath)
          .maybeSingle();
      return result != null;
    } catch (_) {
      return _accountCache!.isFavorite(itemType, itemPath);
    }
  }

  Future<List<LocalFavoriteItem>> getAll() async {
    final userId = _userId;
    if (userId == null) return _guestCache.getAll();
    try {
      final result = await _supabase
          .from('favorites')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final items = result.map((map) {
        return LocalFavoriteItem(
          itemType: map['item_type'] as String,
          itemPath: map['item_path'] as String,
          displayName: map['display_name'] as String? ??
              (map['item_path'] as String).split('>subfolders>').last,
          resourceType: map['resource_type'] as String?,
          folderPath: map['folder_path'] as String?,
          createdAt: DateTime.parse(map['created_at'] as String),
        );
      }).toList();
      await _accountCache!.replaceAll(items);
      return items;
    } catch (e) {
      debugPrint('Error in FavoritesRepository.getAll: $e');
      return _accountCache!.getAll();
    }
  }
}

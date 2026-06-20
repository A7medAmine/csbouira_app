import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_favorites_cache.dart';

class GuestMergeService {
  final LocalFavoritesCache _localCache;
  final SupabaseClient _supabase;

  GuestMergeService({
    required LocalFavoritesCache localCache,
    required SupabaseClient supabase,
  })  : _localCache = localCache,
        _supabase = supabase;

  Future<void> mergeGuestDataIntoAccount(String userId) async {
    try {
      final localFavorites = await _localCache.getAll();
      for (final fav in localFavorites) {
        try {
          await _supabase.from('favorites').upsert(
            {
              'user_id': userId,
              'item_type': fav.itemType,
              'item_path': fav.itemPath,
              'display_name': fav.displayName,
              if (fav.resourceType != null) 'resource_type': fav.resourceType,
            },
            onConflict: 'user_id, item_type, item_path',
          );
        } catch (e) {
          debugPrint('GuestMergeService: failed to merge favorite: $e');
        }
      }
      if (localFavorites.isNotEmpty) {
        await _localCache.clear();
      }
    } catch (e) {
      debugPrint('GuestMergeService: merge failed: $e');
    }
  }
}

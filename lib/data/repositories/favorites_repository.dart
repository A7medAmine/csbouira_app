import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/local_favorites_cache.dart';
import '../services/auth_service.dart';

class FavoritesRepository {
  final LocalFavoritesCache _local;
  final AuthService _authService;
  final SupabaseClient _supabase;

  FavoritesRepository({
    required LocalFavoritesCache local,
    required AuthService authService,
    required SupabaseClient supabase,
  })  : _local = local,
        _authService = authService,
        _supabase = supabase;

  bool get _isLoggedIn => _authService.currentUser != null;
  String? get _userId => _authService.currentUser?.id;

  Future<void> addFavorite(
      String itemType, String itemPath, String displayName) async {
    if (_isLoggedIn) {
      await _supabase.from('favorites').insert({
        'user_id': _userId,
        'item_type': itemType,
        'item_path': itemPath,
      });
    } else {
      await _local.addFavorite(itemType, itemPath, displayName);
    }
  }

  Future<void> removeFavorite(String itemType, String itemPath) async {
    if (_isLoggedIn) {
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', _userId!)
          .eq('item_type', itemType)
          .eq('item_path', itemPath);
    } else {
      await _local.removeFavorite(itemType, itemPath);
    }
  }

  Future<bool> isFavorite(String itemType, String itemPath) async {
    if (_isLoggedIn) {
      final result = await _supabase
          .from('favorites')
          .select('id')
          .eq('user_id', _userId!)
          .eq('item_type', itemType)
          .eq('item_path', itemPath)
          .maybeSingle();
      return result != null;
    }
    return _local.isFavorite(itemType, itemPath);
  }

  Future<List<dynamic>> getAll() async {
    if (_isLoggedIn) {
      final result = await _supabase
          .from('favorites')
          .select('*')
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);
      return result;
    }
    return _local.getAll();
  }
}

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
      String itemType, String itemPath, String displayName, {String? resourceType, String? folderPath}) async {
    if (_isLoggedIn) {
      await _supabase.from('favorites').insert({
        'user_id': _userId,
        'item_type': itemType,
        'item_path': itemPath,
        'display_name': displayName,
        if (resourceType != null) 'resource_type': resourceType,
        if (folderPath != null) 'folder_path': folderPath,
      });
    } else {
      await _local.addFavorite(itemType, itemPath, displayName,
          resourceType: resourceType, folderPath: folderPath);
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

  /// Toggle a module favorite.
  Future<void> favoriteModule(String modulePath, String displayName) async {
    if (await isFavorite('module', modulePath)) {
      await removeFavorite('module', modulePath);
    } else {
      await addFavorite('module', modulePath, displayName);
    }
  }

  /// Toggle a file favorite using its unique link as the identifier.
  Future<void> favoriteFile(String fileLink, String displayName) async {
    if (await isFavorite('file', fileLink)) {
      await removeFavorite('file', fileLink);
    } else {
      await addFavorite('file', fileLink, displayName);
    }
  }

  /// Toggle an online resource favorite using its URL as the identifier.
  Future<void> favoriteOnlineResource(String url, String displayName, {String? resourceType}) async {
    if (await isFavorite('online_resource', url)) {
      await removeFavorite('online_resource', url);
    } else {
      await addFavorite('online_resource', url, displayName, resourceType: resourceType);
    }
  }
}

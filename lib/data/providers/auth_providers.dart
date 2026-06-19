import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../services/local_favorites_cache.dart';
import '../services/local_profile_cache.dart';
import '../services/guest_merge_service.dart';
import '../repositories/favorites_repository.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return AuthService(supabase);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull?.session?.user;
});

final profileProvider = FutureProvider.family<Map<String, dynamic>?, String>(
    (ref, userId) async {
  final supabase = ref.watch(supabaseProvider);
  final result = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .maybeSingle();
  return result;
});

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn.instance;
});

final localFavoritesCacheProvider = Provider<LocalFavoritesCache>((ref) {
  return LocalFavoritesCache();
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final local = ref.watch(localFavoritesCacheProvider);
  final authService = ref.watch(authServiceProvider);
  final supabase = ref.watch(supabaseProvider);
  return FavoritesRepository(
    local: local,
    authService: authService,
    supabase: supabase,
  );
});

final localProfileCacheProvider = Provider<LocalProfileCache>((ref) {
  return LocalProfileCache();
});

final guestMergeServiceProvider = Provider<GuestMergeService>((ref) {
  final localCache = ref.watch(localFavoritesCacheProvider);
  final supabase = ref.watch(supabaseProvider);
  return GuestMergeService(
    localCache: localCache,
    supabase: supabase,
  );
});

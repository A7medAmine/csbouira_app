import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';
import '../services/local_profile_cache.dart';

final uploadCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    final cache = LocalProfileCache();
    return cache.getUploadCount();
  }
  final supabase = ref.watch(supabaseProvider);
  // Server-side count instead of downloading every row.
  return supabase.from('uploads').count().eq('user_id', user.id);
});

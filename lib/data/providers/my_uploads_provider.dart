import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_profile_cache.dart';
import 'auth_providers.dart';

final myUploadsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    final cache = LocalProfileCache();
    return cache.getUploadHistory();
  }
  final supabase = ref.watch(supabaseProvider);
  final result = await supabase
      .from('uploads')
      .select()
      .eq('user_id', user.id)
      .order('created_at', ascending: false);
  return result;
});

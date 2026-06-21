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
  final result = await supabase.from('uploads').select('id');
  return result.length;
});

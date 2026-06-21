import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_providers.dart';

final myUploadsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final supabase = ref.watch(supabaseProvider);
  final result = await supabase
      .from('uploads')
      .select()
      .order('created_at', ascending: false);
  return result;
});

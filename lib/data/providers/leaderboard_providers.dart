import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';
import 'auth_providers.dart';

final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return LeaderboardService(supabase);
});

final topContributorsProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getTopContributors();
});

final currentUserRankProvider = FutureProvider<({int rank, int count})?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final service = ref.watch(leaderboardServiceProvider);
  return service.getCurrentUserRank(user.id);
});

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardService {
  final SupabaseClient _supabase;

  LeaderboardService(this._supabase);

  Future<List<LeaderboardEntry>> getTopContributors({int limit = 20}) async {
    final result = await _supabase.rpc('get_leaderboard', params: {
      'limit_count': limit,
    });
    final list = result as List;
    return list.map((e) => LeaderboardEntry.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<({int rank, int count})?> getCurrentUserRank(String userId) async {
    final result = await _supabase.rpc('get_user_rank', params: {
      'p_user_id': userId,
    });
    final list = result as List;
    if (list.isEmpty) return null;
    final row = list.first as Map<String, dynamic>;
    return (
      rank: (row['user_rank'] as num).toInt(),
      count: (row['upload_count'] as num).toInt(),
    );
  }
}

class LeaderboardEntry {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final int uploadCount;
  final int rank;

  const LeaderboardEntry({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.uploadCount,
    required this.rank,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['user_id'] as String,
      fullName: map['full_name'] as String,
      avatarUrl: map['avatar_url'] as String?,
      uploadCount: (map['upload_count'] as num).toInt(),
      rank: (map['rank'] as num).toInt(),
    );
  }
}

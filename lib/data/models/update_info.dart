class UpdateInfo {
  final String latestVersion;
  final String downloadUrl;
  final String? releaseNotes;

  const UpdateInfo({
    required this.latestVersion,
    required this.downloadUrl,
    this.releaseNotes,
  });
}

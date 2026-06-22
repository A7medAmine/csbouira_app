class DownloadedFile {
  final String fileName;
  final String localPath;
  final String driveLink;
  final DateTime downloadedAt;
  final int? fileSize;

  const DownloadedFile({
    required this.fileName,
    required this.localPath,
    required this.driveLink,
    required this.downloadedAt,
    this.fileSize,
  });

  factory DownloadedFile.fromJson(Map<String, dynamic> json) {
    return DownloadedFile(
      fileName: json['fileName'] as String? ?? '',
      localPath: json['localPath'] as String? ?? '',
      driveLink: json['driveLink'] as String? ?? '',
      downloadedAt: DateTime.parse(json['downloadedAt'] as String),
      fileSize: json['fileSize'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'localPath': localPath,
    'driveLink': driveLink,
    'downloadedAt': downloadedAt.toIso8601String(),
    if (fileSize != null) 'fileSize': fileSize,
  };
}

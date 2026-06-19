class DriveFile {
  final String name;
  final String link;
  final String? previewLink;
  final String? downloadLink;

  const DriveFile({
    required this.name,
    required this.link,
    this.previewLink,
    this.downloadLink,
  });

  factory DriveFile.fromJson(Map<String, dynamic> json) {
    return DriveFile(
      name: json['name'] as String? ?? '',
      link: json['link'] as String? ?? '',
      previewLink: json['previewLink'] as String?,
      downloadLink: json['downloadLink'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'link': link,
    if (previewLink != null) 'previewLink': previewLink,
    if (downloadLink != null) 'downloadLink': downloadLink,
  };
}

class DriveNode {
  final String link;
  final Map<String, DriveNode> subfolders;
  final List<DriveFile> files;

  /// True if the folder name from the API carried the literal ` (empty)` suffix.
  final bool isEmpty;

  int get totalFiles {
    int count = files.length;
    for (final node in subfolders.values) {
      count += node.totalFiles;
    }
    return count;
  }

  const DriveNode({
    required this.link,
    required this.subfolders,
    required this.files,
    this.isEmpty = false,
  });

  factory DriveNode.fromJson(Map<String, dynamic> json) {
    final rawLink = json['link'] as String? ?? '';

    Map<String, DriveNode> parsedSubfolders = {};
    if (json['subfolders'] is Map) {
      final raw = json['subfolders'] as Map<String, dynamic>;
      for (final entry in raw.entries) {
        String displayName = entry.key;
        final bool isEmpty = displayName.endsWith(' (empty)');
        if (isEmpty) {
          displayName = displayName.substring(0, displayName.length - 8);
        }
        final node = DriveNode.fromJson(entry.value as Map<String, dynamic>);
        parsedSubfolders[displayName] = DriveNode(
          link: node.link,
          subfolders: node.subfolders,
          files: node.files,
          isEmpty: isEmpty,
        );
      }
    }

    List<DriveFile> parsedFiles = [];
    if (json['files'] is List) {
      parsedFiles = (json['files'] as List)
          .map((e) => DriveFile.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return DriveNode(
      link: rawLink,
      subfolders: parsedSubfolders,
      files: parsedFiles,
    );
  }

  Map<String, dynamic> toJson() => {
    'link': link,
    'subfolders': subfolders.map((k, v) => MapEntry(k, v.toJson())),
    'files': files.map((f) => f.toJson()).toList(),
  };
}

class DriveRootData {
  final Map<String, DriveNode> years;
  final Map<String, int> fileCounts;
  final Map<String, Map<String, List<OnlineResource>>> onlineResources;

  const DriveRootData({
    required this.years,
    required this.fileCounts,
    required this.onlineResources,
  });

  static DriveRootData _normalize(dynamic json) {
    final map = json as Map<String, dynamic>;
    final years = <String, DriveNode>{};
    Map<String, int> fileCounts = {};
    Map<String, Map<String, List<OnlineResource>>> onlineResources = {};

    for (final entry in map.entries) {
      if (entry.key == '_fileCounts') {
        final fc = entry.value as Map<String, dynamic>;
        fileCounts = fc.map((k, v) => MapEntry(k, (v as num).toInt()));
      } else if (entry.key == '_onlineResources') {
        final or = entry.value as Map<String, dynamic>;
        onlineResources = or.map((yearKey, subjectsRaw) {
          final subjects = subjectsRaw as Map<String, dynamic>;
          return MapEntry(
            yearKey,
            subjects.map((subj, resourcesRaw) {
              final list = (resourcesRaw as List)
                  .map((r) => OnlineResource.fromJson(r as Map<String, dynamic>))
                  .toList();
              return MapEntry(subj, list);
            }),
          );
        });
      } else {
        years[entry.key] = DriveNode.fromJson(entry.value as Map<String, dynamic>);
      }
    }

    return DriveRootData(
      years: years,
      fileCounts: fileCounts,
      onlineResources: onlineResources,
    );
  }

  factory DriveRootData.fromFullTree(Map<String, dynamic> json) => _normalize(json);

  factory DriveRootData.fromFileCounts(Map<String, dynamic> json) {
    final fileCounts = json.map((k, v) => MapEntry(k, (v as num).toInt()));
    return DriveRootData(
      years: {},
      fileCounts: fileCounts,
      onlineResources: {},
    );
  }
}

class OnlineResource {
  final String name;
  final String url;
  final String type;
  final String language;

  const OnlineResource({
    required this.name,
    required this.url,
    required this.type,
    required this.language,
  });

  factory OnlineResource.fromJson(Map<String, dynamic> json) {
    return OnlineResource(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      type: json['type'] as String? ?? '',
      language: json['language'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
    'type': type,
    'language': language,
  };
}

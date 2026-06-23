class ShareFileData {
  final String grade;
  final String semester;
  final String module;
  final String folder;
  final int fileIndex;
  final String? subpath;

  const ShareFileData({
    required this.grade,
    required this.semester,
    required this.module,
    required this.folder,
    required this.fileIndex,
    this.subpath,
  });

  List<String> toPathSegments() {
    final segments = <String>[grade];
    if (semester.isNotEmpty) segments.add(semester);
    if (module.isNotEmpty) segments.add(module);
    segments.add(folder);
    if (subpath != null && subpath!.isNotEmpty) {
      segments.addAll(subpath!.split('>'));
    }
    return segments;
  }
}

String encodeFileShareData({
  required String grade,
  required String semester,
  required String module,
  required String folder,
  required int fileIndex,
  String? subpath,
}) {
  final queryParams = <String, String>{
    'grade': grade,
    'semester': semester,
    'module': module,
    'folder': folder,
    'fileIndex': fileIndex.toString(),
  };
  if (subpath != null && subpath.isNotEmpty) {
    queryParams['sub'] = subpath;
  }
  final uri = Uri(
    scheme: 'csbouira-share',
    host: 'file',
    queryParameters: queryParams,
  );
  return uri.toString();
}

ShareFileData? parseFileShareData(String scannedText) {
  final uri = Uri.tryParse(scannedText);
  if (uri == null) return null;
  if (uri.scheme != 'csbouira-share') return null;
  if (uri.host != 'file') return null;

  final params = uri.queryParameters;
  final grade = params['grade'];
  final semester = params['semester'];
  final module = params['module'];
  final folder = params['folder'];
  final fileIndexStr = params['fileIndex'];
  final subpath = params['sub'];

  if (grade == null ||
      semester == null ||
      module == null ||
      folder == null ||
      fileIndexStr == null) {
    return null;
  }

  final fileIndex = int.tryParse(fileIndexStr);
  if (fileIndex == null) return null;

  return ShareFileData(
    grade: grade,
    semester: semester,
    module: module,
    folder: folder,
    fileIndex: fileIndex,
    subpath: subpath,
  );
}

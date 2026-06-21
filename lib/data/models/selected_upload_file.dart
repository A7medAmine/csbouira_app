import 'dart:typed_data';

class SelectedUploadFile {
  final Uint8List bytes;
  final String fileName;
  final String mimeType;

  const SelectedUploadFile({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });

  int get sizeInBytes => bytes.length;

  String get formattedSize {
    if (bytes.length < 1024) return '${bytes.length} B';
    if (bytes.length < 1024 * 1024) {
      return '${(bytes.length / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes.length / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

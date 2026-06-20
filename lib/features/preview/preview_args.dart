import '../../data/models/drive_node.dart';

/// Arguments passed to the PreviewScreen via GoRouter's `extra`.
class PreviewArgs {
  /// All files in the folder, in display order.
  final List<DriveFile> files;

  /// Index of the tapped file within [files].
  final int initialIndex;

  const PreviewArgs({
    required this.files,
    required this.initialIndex,
  });
}

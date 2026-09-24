import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/catalog_file.dart';
import '../../data/services/catalog_index.dart';
import 'preview_args.dart';

/// Opens [entry] in the previewer, with the other files of its folder
/// reachable through the next/previous arrows.
void openCatalogFile(
  BuildContext context,
  CatalogIndex index,
  CatalogFile entry, {
  bool replace = false,
}) {
  final siblings = index.siblingsOf(entry);
  final initial = siblings.indexWhere((f) => f.id == entry.id);
  final args = PreviewArgs(
    files: siblings.map((f) => f.file).toList(),
    initialIndex: initial < 0 ? 0 : initial,
    folderPath: entry.folderPath,
  );
  if (replace) {
    context.pushReplacement('/preview', extra: args);
  } else {
    context.push('/preview', extra: args);
  }
}

import 'package:flutter/material.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';

import '../data/models/catalog_file.dart';

String _extension(String name) {
  final dot = name.lastIndexOf('.');
  return dot < 0 ? '' : name.substring(dot + 1).toLowerCase();
}

/// Icon for a file, chosen from its extension.
IconData fileIconFor(String name) {
  switch (_extension(name)) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'doc':
    case 'docx':
      return Icons.description;
    case 'ppt':
    case 'pptx':
      return Icons.slideshow;
    case 'xls':
    case 'xlsx':
      return Icons.table_chart;
    case 'zip':
    case 'rar':
      return Icons.folder_zip;
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'webp':
      return Icons.image;
    case 'mp4':
    case 'avi':
    case 'mkv':
      return Icons.play_circle;
    default:
      return Icons.insert_drive_file;
  }
}

/// Accent color for a file icon, chosen from its extension.
Color fileIconColorFor(String name, ThemeData theme) {
  switch (_extension(name)) {
    case 'pdf':
      return theme.colorScheme.error;
    case 'doc':
    case 'docx':
      return const Color(0xFF448AFF);
    case 'ppt':
    case 'pptx':
      return const Color(0xFFFF7043);
    case 'xls':
    case 'xlsx':
      return const Color(0xFF66BB6A);
    default:
      return theme.colorScheme.primary;
  }
}

String categoryLabel(AppLocalizations l10n, ResourceCategory category) =>
    switch (category) {
      ResourceCategory.course => l10n.categoryCourse,
      ResourceCategory.exam => l10n.categoryExam,
      ResourceCategory.test => l10n.categoryTest,
      ResourceCategory.summary => l10n.categorySummary,
      ResourceCategory.tdTp => l10n.categoryTdTp,
      ResourceCategory.book => l10n.categoryBook,
      ResourceCategory.other => l10n.categoryOther,
    };

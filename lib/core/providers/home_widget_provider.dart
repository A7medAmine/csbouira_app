import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/navigation_data.dart';
import '../../data/providers/catalog_providers.dart';
import '../../data/providers/favorites_providers.dart';
import '../../data/services/file_cache_service.dart' show extractDriveFileId;
import '../../data/services/home_widget_service.dart';
import '../../data/services/recent_files_store.dart';
import '../../l10n/app_localizations.dart';
import '../deep_links.dart';
import 'locale_provider.dart';

final widgetSourceProvider =
    StateNotifierProvider<WidgetSourceNotifier, WidgetSource>((ref) {
  return WidgetSourceNotifier()..load();
});

/// Whether the Android home screen widget lists recent files or favorites.
/// Recent files by default.
class WidgetSourceNotifier extends StateNotifier<WidgetSource> {
  WidgetSourceNotifier() : super(WidgetSource.recent);

  Future<void> load() async {
    final source = await HomeWidgetService.getSource();
    if (mounted) state = source;
  }

  Future<void> set(WidgetSource source) async {
    // Saved before the state change so the widget redraw that follows
    // already reads the new title.
    await HomeWidgetService.setSource(source);
    if (mounted) state = source;
  }
}

/// Keeps the home screen widget in sync with the chosen source. Watched by
/// the app root so it lives as long as the app.
final homeWidgetSyncProvider = Provider<void>((ref) {
  final source = ref.watch(widgetSourceProvider);
  final l10n = lookupAppLocalizations(ref.watch(localeProvider));
  final List<WidgetRow>? rows = switch (source) {
    WidgetSource.recent =>
      ref.watch(recentFilesProvider).valueOrNull?.map(_recentRow).toList(),
    WidgetSource.favorites => ref
        .watch(favoritesListProvider)
        .valueOrNull
        ?.map((f) => _favoriteRow(f, l10n))
        .nonNulls
        .toList(),
  };
  // Still loading (or failed): keep what the widget shows now.
  if (rows == null) return;
  HomeWidgetService.updateItems(rows);
});

WidgetRow _recentRow(RecentFile f) => WidgetRow(
      link: fileDeepLink(f.fileId),
      name: f.name,
      subtitle: f.subtitle,
    );

WidgetRow? _favoriteRow(FavoriteItem f, AppLocalizations l10n) {
  switch (f.itemType) {
    case 'file':
      final id = extractDriveFileId(f.itemPath);
      if (id == null) return null;
      final folder = f.folderPath?.split('>') ?? const <String>[];
      return WidgetRow(
        link: fileDeepLink(id),
        name: f.displayName,
        subtitle: RecentFile(
          fileId: id,
          name: f.displayName,
          folderPath: folder,
          viewedAt: f.createdAt,
        ).subtitle,
      );
    case 'year':
      return WidgetRow(
        link: browseDeepLink(f.itemPath),
        name: f.displayName,
        subtitle: (kSemesters[f.itemPath] ?? const []).join(' · '),
        kind: WidgetRowKind.folder,
      );
    case 'semester':
      final parts = DrivePathParts.parse(f.pathSegments);
      if (parts.semester.isEmpty) return null;
      return WidgetRow(
        link: browseDeepLink(parts.year, semester: parts.semester),
        name: semesterLabel(parts.semester, l10n.promoArchive),
        subtitle: parts.year,
        kind: WidgetRowKind.folder,
      );
    case 'module':
      final parts = DrivePathParts.parse(f.pathSegments);
      if (parts.module.isEmpty) return null;
      return WidgetRow(
        link: browseDeepLink(
          parts.year,
          semester: parts.semester,
          module: parts.module,
        ),
        name: f.displayName,
        subtitle:
            '${parts.year} · ${semesterLabel(parts.semester, l10n.promoArchive)}',
        kind: WidgetRowKind.folder,
      );
    case 'online_resource':
      final uri = Uri.tryParse(f.itemPath);
      if (uri == null || !uri.hasScheme) return null;
      return WidgetRow(
        link: f.itemPath,
        name: f.displayName,
        subtitle: uri.host,
        kind: WidgetRowKind.link,
      );
  }
  return null;
}

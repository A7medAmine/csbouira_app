import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/providers/locale_provider.dart' show localeOverrideKey;
import '../../l10n/app_localizations.dart';
import '../models/catalog_file.dart';
import 'catalog_index.dart';
import 'catalog_seen_store.dart';
import 'drive_api_service.dart';
import 'followed_modules_store.dart';
import 'notification_service.dart';

/// New files grouped by the followed module they belong to.
Map<String, List<CatalogFile>> newFilesInFollowedModules(
  CatalogIndex index,
  Set<String> newIds,
  Set<String> followed,
) {
  final result = <String, List<CatalogFile>>{};
  for (final id in newIds) {
    final file = index.byId(id);
    if (file == null || !followed.contains(file.moduleKey)) continue;
    result.putIfAbsent(file.moduleKey, () => []).add(file);
  }
  return result;
}

/// Entry point of the background isolate started by workmanager.
@pragma('vm:entry-point')
void newFilesCallbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    try {
      await runNewFilesCheck();
      return true;
    } catch (e) {
      debugPrint('New files check failed: $e');
      // Returning false lets WorkManager retry with backoff.
      return false;
    }
  });
}

/// Fetches the catalogue, records it as seen and posts one notification
/// summarising new files in followed modules.
Future<void> runNewFilesCheck() async {
  final followed = await FollowedModulesStore().getAll();
  if (followed.isEmpty) return;

  final root = await DriveApiService().getFullTree();
  final index = CatalogIndex.build(root);
  final added = await CatalogSeenStore().record(index.ids);
  final byModule = newFilesInFollowedModules(index, added, followed);
  if (byModule.isEmpty) return;

  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(localeOverrideKey) ??
      PlatformDispatcher.instance.locale.languageCode;
  final l10n = lookupAppLocalizations(
    Locale(const ['ar', 'fr'].contains(code) ? code : 'en'),
  );

  final total = byModule.values.fold<int>(0, (sum, list) => sum + list.length);
  final lines = byModule.values
      .map((files) => l10n.newFilesNotificationLine(files.first.module, files.length))
      .join('\n');

  await NotificationService.init(handleTaps: false);
  await NotificationService.showNewFiles(
    channelName: l10n.newFilesChannelName,
    title: l10n.newFilesNotificationTitle(total),
    body: lines,
  );
}

/// Registers or cancels the periodic background check.
class NewFilesScheduler {
  NewFilesScheduler._();

  static const _uniqueName = 'new-files-check';
  static bool _initialized = false;

  static Future<void> sync({required bool enabled}) async {
    if (!Platform.isAndroid) return;
    try {
      if (!_initialized) {
        await Workmanager().initialize(newFilesCallbackDispatcher);
        _initialized = true;
      }
      if (enabled) {
        await Workmanager().registerPeriodicTask(
          _uniqueName,
          _uniqueName,
          frequency: const Duration(hours: 6),
          existingWorkPolicy: ExistingWorkPolicy.keep,
          constraints: Constraints(networkType: NetworkType.connected),
        );
      } else {
        await Workmanager().cancelByUniqueName(_uniqueName);
      }
    } catch (e) {
      debugPrint('Could not schedule new files check: $e');
    }
  }
}

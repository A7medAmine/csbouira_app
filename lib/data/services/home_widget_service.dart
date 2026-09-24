import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import 'recent_files_store.dart';

/// Pushes the recent files list to the Android home screen widget
/// (`RecentFilesWidgetProvider.kt`). Each row opens `csbouira://file/<id>`.
class HomeWidgetService {
  HomeWidgetService._();

  static const _dataKey = 'recent_files';
  static const _showCatKey = 'show_cat';
  static const _provider =
      'com.csbouira.csbouira_app.RecentFilesWidgetProvider';
  static const maxItems = 4;

  static Future<void> updateRecentFiles(List<RecentFile> files) async {
    if (!Platform.isAndroid) return;
    final rows =
        files
            .take(maxItems)
            .map(
              (f) => {'id': f.fileId, 'name': f.name, 'subtitle': f.subtitle},
            )
            .toList();
    try {
      await HomeWidget.saveWidgetData<String>(_dataKey, jsonEncode(rows));
      await HomeWidget.updateWidget(qualifiedAndroidName: _provider);
    } catch (e) {
      debugPrint('Home widget update failed: $e');
    }
  }

  /// Whether the blinking cat peeks over the widget's bottom edge. Stored in
  /// the widget's own preferences so the Kotlin provider can read it.
  static Future<bool> isCatEnabled() async {
    if (!Platform.isAndroid) return false;
    try {
      return await HomeWidget.getWidgetData<bool>(
            _showCatKey,
            defaultValue: true,
          ) ??
          true;
    } catch (e) {
      debugPrint('Home widget read failed: $e');
      return true;
    }
  }

  static Future<void> setCatEnabled(bool enabled) async {
    if (!Platform.isAndroid) return;
    try {
      await HomeWidget.saveWidgetData<bool>(_showCatKey, enabled);
      await HomeWidget.updateWidget(qualifiedAndroidName: _provider);
    } catch (e) {
      debugPrint('Home widget update failed: $e');
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

/// What the home screen widget lists.
enum WidgetSource { recent, favorites }

/// Kind of a widget row; picks the row icon on the Kotlin side.
enum WidgetRowKind { file, folder, link }

/// One row of the home screen widget. [link] is opened when the row is
/// tapped: a `csbouira://` deep link, or an https URL for online resources.
class WidgetRow {
  final String link;
  final String name;
  final String subtitle;
  final WidgetRowKind kind;

  const WidgetRow({
    required this.link,
    required this.name,
    required this.subtitle,
    this.kind = WidgetRowKind.file,
  });

  Map<String, dynamic> toJson() => {
        'link': link,
        'name': name,
        'subtitle': subtitle,
        'kind': kind.name,
      };
}

/// Pushes rows to the Android home screen widget
/// (`RecentFilesWidgetProvider.kt`), either recent files or favorites
/// depending on [WidgetSource].
class HomeWidgetService {
  HomeWidgetService._();

  static const _dataKey = 'widget_items';
  static const _sourceKey = 'widget_source';
  static const _showCatKey = 'show_cat';
  static const _provider =
      'com.csbouira.csbouira_app.RecentFilesWidgetProvider';
  static const maxItems = 4;

  static Future<void> updateItems(List<WidgetRow> rows) async {
    if (!Platform.isAndroid) return;
    final data = rows.take(maxItems).map((r) => r.toJson()).toList();
    try {
      await HomeWidget.saveWidgetData<String>(_dataKey, jsonEncode(data));
      await HomeWidget.updateWidget(qualifiedAndroidName: _provider);
    } catch (e) {
      debugPrint('Home widget update failed: $e');
    }
  }

  /// Stored in the widget's own preferences so the Kotlin provider can pick
  /// the matching title and empty message.
  static Future<WidgetSource> getSource() async {
    if (!Platform.isAndroid) return WidgetSource.recent;
    try {
      final name = await HomeWidget.getWidgetData<String>(_sourceKey);
      return WidgetSource.values.firstWhere(
        (s) => s.name == name,
        orElse: () => WidgetSource.recent,
      );
    } catch (e) {
      debugPrint('Home widget read failed: $e');
      return WidgetSource.recent;
    }
  }

  static Future<void> setSource(WidgetSource source) async {
    if (!Platform.isAndroid) return;
    try {
      await HomeWidget.saveWidgetData<String>(_sourceKey, source.name);
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

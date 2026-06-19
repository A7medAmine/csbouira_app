import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentlyViewedCache {
  static const _key = 'recently_viewed';
  static const _maxEntries = 20;

  Future<List<RecentlyViewedItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => RecentlyViewedItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addItem(RecentlyViewedItem item) async {
    final items = await getAll();
    items.removeWhere((f) => f.path == item.path);
    items.insert(0, item);
    if (items.length > _maxEntries) {
      items.removeRange(_maxEntries, items.length);
    }
    await _save(items);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> _save(List<RecentlyViewedItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }
}

class RecentlyViewedItem {
  final String path;
  final String displayName;
  final String itemType; // 'year', 'semester', 'module', 'folder', 'file'
  final DateTime viewedAt;

  RecentlyViewedItem({
    required this.path,
    required this.displayName,
    required this.itemType,
    DateTime? viewedAt,
  }) : viewedAt = viewedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'path': path,
        'displayName': displayName,
        'itemType': itemType,
        'viewedAt': viewedAt.toIso8601String(),
      };

  factory RecentlyViewedItem.fromJson(Map<String, dynamic> json) =>
      RecentlyViewedItem(
        path: json['path'] as String,
        displayName: json['displayName'] as String,
        itemType: json['itemType'] as String,
        viewedAt: DateTime.parse(json['viewedAt'] as String),
      );
}

final recentlyViewedCacheProvider = Provider<RecentlyViewedCache>((ref) {
  return RecentlyViewedCache();
});

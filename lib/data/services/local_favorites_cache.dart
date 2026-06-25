import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalFavoritesCache {
  static const _key = 'local_favorites';

  Future<List<LocalFavoriteItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => LocalFavoriteItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addFavorite(
      String itemType, String itemPath, String displayName, {String? resourceType, String? folderPath}) async {
    final items = await getAll();
    items.removeWhere((f) => f.itemPath == itemPath && f.itemType == itemType);
    items.insert(
      0,
      LocalFavoriteItem(
        itemType: itemType,
        itemPath: itemPath,
        displayName: displayName,
        resourceType: resourceType,
        folderPath: folderPath,
      ),
    );
    await _save(items);
  }

  Future<void> removeFavorite(String itemType, String itemPath) async {
    final items = await getAll();
    items.removeWhere((f) => f.itemPath == itemPath && f.itemType == itemType);
    await _save(items);
  }

  Future<bool> isFavorite(String itemType, String itemPath) async {
    final items = await getAll();
    return items.any((f) => f.itemPath == itemPath && f.itemType == itemType);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<void> replaceAll(List<LocalFavoriteItem> items) async {
    await _save(items);
  }

  Future<void> _save(List<LocalFavoriteItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }
}

class LocalFavoriteItem {
  final String itemType;
  final String itemPath;
  final String displayName;
  final String? resourceType;
  final String? folderPath;
  final DateTime createdAt;

  LocalFavoriteItem({
    required this.itemType,
    required this.itemPath,
    required this.displayName,
    this.resourceType,
    this.folderPath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'itemType': itemType,
        'itemPath': itemPath,
        'displayName': displayName,
        if (resourceType != null) 'resourceType': resourceType,
        if (folderPath != null) 'folderPath': folderPath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LocalFavoriteItem.fromJson(Map<String, dynamic> json) =>
      LocalFavoriteItem(
        itemType: json['itemType'] as String,
        itemPath: json['itemPath'] as String,
        displayName: json['displayName'] as String,
        resourceType: json['resourceType'] as String?,
        folderPath: json['folderPath'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

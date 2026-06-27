import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/update_info.dart';

class UpdateService {
  static const _repoApiUrl =
      'https://api.github.com/repos/A7medAmine/csbouira_app/releases/latest';
  static const _prefsKey = 'update_last_check_ts';
  static const _throttleHours = 12;

  /// Checks for a newer app version from GitHub Releases.
  /// Throttled to once per [_throttleHours] hours via shared_preferences.
  /// Returns `null` if no update is available, the throttle hasn't expired,
  /// or the API call fails.
  Future<UpdateInfo?> checkForUpdate() async {
    if (!Platform.isAndroid) return null;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(
        Uri.parse(_repoApiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final latestTag = json['tag_name'] as String?;
      if (latestTag == null) return null;

      final latestVersion = latestTag.replaceFirst(RegExp(r'^v'), '');

      // Save throttle timestamp right after successful API call,
      // not just when an update is found. This prevents hitting
      // the API on every launch when there's no update.
      await _saveLastCheck();

      final assets = json['assets'] as List?;
      if (assets == null || assets.isEmpty) return null;

      Map<String, dynamic>? apkAsset;
      for (final a in assets) {
        final name = a['name'] as String? ?? '';
        if (name.endsWith('.apk')) {
          apkAsset = a as Map<String, dynamic>;
          break;
        }
      }
      if (apkAsset == null) return null;

      final downloadUrl = apkAsset['browser_download_url'] as String?;
      if (downloadUrl == null) return null;

      if (!_isNewer(latestVersion, currentVersion)) return null;

      final releaseNotes = json['body'] as String?;

      return UpdateInfo(
        latestVersion: latestVersion,
        downloadUrl: downloadUrl,
        releaseNotes: releaseNotes,
      );
    } catch (_) {
      return null;
    }
  }

  /// Uses [pub_semver] for correct semantic version comparison.
  /// Naive string comparison would incorrectly rank "1.10.0" as older than
  /// "1.9.0" because "1.1" sorts after "1.9" lexicographically.
  bool _isNewer(String latest, String current) {
    try {
      final latestVer = Version.parse(latest);
      final currentVer = Version.parse(current);
      return latestVer > currentVer;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isThrottled() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getInt(_prefsKey) ?? 0;
    if (lastCheck == 0) return false;
    final elapsed = DateTime.now().millisecondsSinceEpoch - lastCheck;
    return elapsed < _throttleHours * 3600000;
  }

  Future<void> _saveLastCheck() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _prefsKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}

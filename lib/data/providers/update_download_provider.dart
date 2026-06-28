import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pub_semver/pub_semver.dart';

enum UpdateDownloadStatus {
  idle,
  downloading,
  completed,
  error,
}

class UpdateDownloadState {
  final UpdateDownloadStatus status;
  final double progress;
  final String? filePath;
  final String? error;

  const UpdateDownloadState({
    this.status = UpdateDownloadStatus.idle,
    this.progress = 0.0,
    this.filePath,
    this.error,
  });

  UpdateDownloadState copyWith({
    UpdateDownloadStatus? status,
    double? progress,
    String? filePath,
    String? error,
  }) {
    return UpdateDownloadState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      filePath: filePath ?? this.filePath,
      error: error ?? this.error,
    );
  }
}

class UpdateDownloadNotifier extends StateNotifier<UpdateDownloadState> {
  UpdateDownloadNotifier() : super(const UpdateDownloadState());

  static const _downloadedVersionKey = 'downloaded_update_version';

  /// Check if there is an update downloaded in the background that hasn't been installed yet.
  Future<void> checkUninstalledUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloadedVersion = prefs.getString(_downloadedVersionKey);
      if (downloadedVersion == null) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final latestVer = Version.parse(downloadedVersion);
      final currentVer = Version.parse(currentVersion);

      if (latestVer > currentVer) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/csbouira_update.apk';
        final file = File(filePath);
        if (await file.exists()) {
          state = UpdateDownloadState(
            status: UpdateDownloadStatus.completed,
            filePath: filePath,
            progress: 1.0,
          );
        } else {
          await prefs.remove(_downloadedVersionKey);
        }
      } else {
        // App is already updated to the downloaded version (or newer), clean up
        await prefs.remove(_downloadedVersionKey);
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/csbouira_update.apk');
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error in UpdateDownloadNotifier.checkUninstalledUpdate: $e');
    }
  }

  Future<void> startDownload(String downloadUrl, String latestVersion) async {
    if (state.status == UpdateDownloadStatus.downloading) return;

    state = const UpdateDownloadState(status: UpdateDownloadStatus.downloading);

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(downloadUrl));
      request.followRedirects = true;
      request.maxRedirects = 5;
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Download failed: Status ${response.statusCode}');
      }

      final totalBytes = response.contentLength ?? -1;
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/csbouira_update.apk';
      final file = File(filePath);

      final sink = file.openWrite();
      int received = 0;

      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (totalBytes > 0) {
          state = state.copyWith(progress: received / totalBytes);
        }
      }
      await sink.flush();
      await sink.close();
      client.close();

      // Save downloaded version info to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_downloadedVersionKey, latestVersion);

      state = state.copyWith(
        status: UpdateDownloadStatus.completed,
        filePath: filePath,
        progress: 1.0,
      );

      // Trigger standard Android installer
      await installUpdate();
    } catch (e) {
      state = state.copyWith(
        status: UpdateDownloadStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> installUpdate() async {
    if (state.filePath != null) {
      await OpenFilex.open(state.filePath!);
    }
  }

  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_downloadedVersionKey);
      if (state.filePath != null) {
        final file = File(state.filePath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error in UpdateDownloadNotifier.reset: $e');
    }
    state = const UpdateDownloadState();
  }
}

final updateDownloadProvider =
    StateNotifierProvider<UpdateDownloadNotifier, UpdateDownloadState>((ref) {
  return UpdateDownloadNotifier();
});

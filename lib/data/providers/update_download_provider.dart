import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> startDownload(String downloadUrl) async {
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

  void reset() {
    state = const UpdateDownloadState();
  }
}

final updateDownloadProvider =
    StateNotifierProvider<UpdateDownloadNotifier, UpdateDownloadState>((ref) {
  return UpdateDownloadNotifier();
});

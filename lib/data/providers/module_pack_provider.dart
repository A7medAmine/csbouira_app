import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/drive_node.dart';
import '../services/download_service.dart';
import 'downloads_providers.dart';

enum ModulePackStatus { idle, running, done, cancelled }

/// Progress of an "download the whole module" job.
class ModulePackState {
  final ModulePackStatus status;

  /// What is being downloaded, e.g. "Analyse 1 · Exams".
  final String label;

  /// `year>semester>module` of the job, so the module screen can show it.
  final String? moduleKey;
  final int total;
  final int completed;
  final int failed;

  const ModulePackState({
    this.status = ModulePackStatus.idle,
    this.label = '',
    this.moduleKey,
    this.total = 0,
    this.completed = 0,
    this.failed = 0,
  });

  bool get isRunning => status == ModulePackStatus.running;
  double get progress => total == 0 ? 0 : (completed + failed) / total;

  ModulePackState copyWith({
    ModulePackStatus? status,
    int? completed,
    int? failed,
  }) =>
      ModulePackState(
        status: status ?? this.status,
        label: label,
        moduleKey: moduleKey,
        total: total,
        completed: completed ?? this.completed,
        failed: failed ?? this.failed,
      );
}

final modulePackProvider =
    StateNotifierProvider<ModulePackNotifier, ModulePackState>((ref) {
  return ModulePackNotifier(ref);
});

/// Downloads a list of files one after another for offline use. Files that
/// are already downloaded are skipped by [DownloadService.downloadFile].
class ModulePackNotifier extends StateNotifier<ModulePackState> {
  final Ref _ref;
  bool _cancelRequested = false;

  ModulePackNotifier(this._ref) : super(const ModulePackState());

  /// Starts a job. Ignored while another job is running.
  Future<void> start({
    required String label,
    required String moduleKey,
    required List<DriveFile> files,
  }) async {
    if (state.isRunning || files.isEmpty) return;
    _cancelRequested = false;
    state = ModulePackState(
      status: ModulePackStatus.running,
      label: label,
      moduleKey: moduleKey,
      total: files.length,
    );

    final service = _ref.read(downloadServiceProvider);
    for (final file in files) {
      if (_cancelRequested || !mounted) break;
      try {
        await service.downloadFile(file);
        if (!mounted) return;
        state = state.copyWith(completed: state.completed + 1);
      } catch (_) {
        if (!mounted) return;
        state = state.copyWith(failed: state.failed + 1);
      }
    }
    if (!mounted) return;
    state = state.copyWith(
      status: _cancelRequested
          ? ModulePackStatus.cancelled
          : ModulePackStatus.done,
    );
    _ref.invalidate(downloadsListProvider);
  }

  /// Stops after the file currently downloading.
  void cancel() => _cancelRequested = true;

  /// Hides a finished job's banner.
  void dismiss() {
    if (!state.isRunning) state = const ModulePackState();
  }
}

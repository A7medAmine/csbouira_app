import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/upload_result.dart';

class UploadFormState {
  final bool isUploading;
  final bool uploadSuccess;
  final UploadResult? error;
  final double progress;

  const UploadFormState({
    this.isUploading = false,
    this.uploadSuccess = false,
    this.error,
    this.progress = 0.0,
  });

  UploadFormState copyWith({
    bool? isUploading,
    bool? uploadSuccess,
    UploadResult? error,
    double? progress,
  }) {
    return UploadFormState(
      isUploading: isUploading ?? this.isUploading,
      uploadSuccess: uploadSuccess ?? this.uploadSuccess,
      error: error ?? this.error,
      progress: progress ?? this.progress,
    );
  }
}

class UploadStateNotifier extends StateNotifier<UploadFormState> {
  UploadStateNotifier() : super(const UploadFormState());

  void setUploading() {
    state = state.copyWith(
      isUploading: true,
      error: null,
      uploadSuccess: false,
      progress: 0.0,
    );
  }

  void setProgress(double progress) {
    state = state.copyWith(progress: progress);
  }

  void setSuccess() {
    state = state.copyWith(
      isUploading: false,
      uploadSuccess: true,
      progress: 1.0,
    );
  }

  void setError(UploadResult error) {
    state = state.copyWith(
      isUploading: false,
      error: error,
      progress: 0.0,
    );
  }

  void reset() {
    state = const UploadFormState();
  }
}

final uploadStateProvider =
    StateNotifierProvider<UploadStateNotifier, UploadFormState>((ref) {
  return UploadStateNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/upload_result.dart';

class UploadFormState {
  final bool isUploading;
  final bool uploadSuccess;
  final UploadResult? error;

  const UploadFormState({
    this.isUploading = false,
    this.uploadSuccess = false,
    this.error,
  });

  UploadFormState copyWith({
    bool? isUploading,
    bool? uploadSuccess,
    UploadResult? error,
  }) {
    return UploadFormState(
      isUploading: isUploading ?? this.isUploading,
      uploadSuccess: uploadSuccess ?? this.uploadSuccess,
      error: error ?? this.error,
    );
  }
}

class UploadStateNotifier extends StateNotifier<UploadFormState> {
  UploadStateNotifier() : super(const UploadFormState());

  void setUploading() {
    state = state.copyWith(isUploading: true, error: null);
  }

  void setSuccess() {
    state = state.copyWith(isUploading: false, uploadSuccess: true);
  }

  void setError(UploadResult error) {
    state = state.copyWith(isUploading: false, error: error);
  }

  void reset() {
    state = const UploadFormState();
  }
}

final uploadStateProvider =
    StateNotifierProvider<UploadStateNotifier, UploadFormState>((ref) {
  return UploadStateNotifier();
});

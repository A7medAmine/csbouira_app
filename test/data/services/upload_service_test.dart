import 'package:flutter_test/flutter_test.dart';
import 'package:csbouira_app/data/services/upload_service.dart' show CancelToken;
import 'package:csbouira_app/data/providers/upload_state_provider.dart';
import 'package:csbouira_app/data/models/upload_result.dart';

void main() {
  group('CancelToken', () {
    test('starts not cancelled', () {
      final token = CancelToken();
      expect(token.isCancelled, isFalse);
    });

    test('isCancelled returns true after cancel()', () {
      final token = CancelToken();
      token.cancel();
      expect(token.isCancelled, isTrue);
    });

    test('multiple cancels are idempotent', () {
      final token = CancelToken();
      token.cancel();
      token.cancel();
      expect(token.isCancelled, isTrue);
    });
  });

  group('UploadFormState', () {
    test('initial state', () {
      const state = UploadFormState();
      expect(state.isUploading, isFalse);
      expect(state.uploadSuccess, isFalse);
      expect(state.error, isNull);
      expect(state.progress, equals(0.0));
    });

    test('setUploading resets error, sets progress to 0', () {
      const state = UploadFormState();
      final updated = state.copyWith(isUploading: true, progress: 0.0);
      expect(updated.isUploading, isTrue);
      expect(updated.uploadSuccess, isFalse);
      expect(updated.progress, equals(0.0));
    });

    test('setProgress updates progress value', () {
      const state = UploadFormState();
      final updated = state.copyWith(progress: 0.5);
      expect(updated.progress, equals(0.5));
    });

    test('setSuccess sets uploadSuccess and progress 1.0', () {
      final state = UploadFormState(isUploading: true, progress: 0.7);
      final updated = state.copyWith(
        isUploading: false,
        uploadSuccess: true,
        progress: 1.0,
      );
      expect(updated.isUploading, isFalse);
      expect(updated.uploadSuccess, isTrue);
      expect(updated.progress, equals(1.0));
    });

    test('setError resets progress', () {
      final state = UploadFormState(isUploading: true, progress: 0.8);
      final error = UploadResult(
        success: false,
        message: 'fail',
        errorType: UploadErrorType.timeout,
      );
      final updated = state.copyWith(
        isUploading: false,
        error: error,
        progress: 0.0,
      );
      expect(updated.isUploading, isFalse);
      expect(updated.error, equals(error));
      expect(updated.progress, equals(0.0));
    });
  });

  group('UploadFormState transitions via StateNotifier', () {
    test('full lifecycle: idle → uploading → success', () {
      final notifier = UploadStateNotifier();

      expect(notifier.state.isUploading, isFalse);
      expect(notifier.state.progress, equals(0.0));

      notifier.setUploading();
      expect(notifier.state.isUploading, isTrue);
      expect(notifier.state.progress, equals(0.0));

      notifier.setProgress(0.5);
      expect(notifier.state.progress, equals(0.5));

      notifier.setProgress(0.9);
      expect(notifier.state.progress, equals(0.9));

      notifier.setSuccess();
      expect(notifier.state.isUploading, isFalse);
      expect(notifier.state.uploadSuccess, isTrue);
      expect(notifier.state.progress, equals(1.0));
    });

    test('full lifecycle: idle → uploading → error', () {
      final notifier = UploadStateNotifier();

      notifier.setUploading();
      expect(notifier.state.isUploading, isTrue);

      notifier.setProgress(0.4);
      expect(notifier.state.progress, equals(0.4));

      const error = UploadResult(
        success: false,
        message: 'fail',
        errorType: UploadErrorType.timeout,
      );
      notifier.setError(error);
      expect(notifier.state.isUploading, isFalse);
      expect(notifier.state.error?.message, equals('fail'));
      expect(notifier.state.error?.errorType, equals(UploadErrorType.timeout));
      expect(notifier.state.progress, equals(0.0));
    });

    test('reset clears everything', () {
      final notifier = UploadStateNotifier();

      notifier.setUploading();
      notifier.setProgress(0.5);
      notifier.reset();

      expect(notifier.state.isUploading, isFalse);
      expect(notifier.state.uploadSuccess, isFalse);
      expect(notifier.state.error, isNull);
      expect(notifier.state.progress, equals(0.0));
    });
  });
}

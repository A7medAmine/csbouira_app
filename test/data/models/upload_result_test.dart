import 'package:flutter_test/flutter_test.dart';
import 'package:csbouira_app/data/models/upload_result.dart';

void main() {
  group('UploadErrorType', () {
    test('offline error is retryable', () {
      final result = UploadResult(
        success: false,
        errorType: UploadErrorType.offline,
      );
      expect(result.isRetryable, isTrue);
    });

    test('timeout error is retryable', () {
      final result = UploadResult(
        success: false,
        errorType: UploadErrorType.timeout,
      );
      expect(result.isRetryable, isTrue);
    });

    test('serverError is retryable', () {
      final result = UploadResult(
        success: false,
        errorType: UploadErrorType.serverError,
      );
      expect(result.isRetryable, isTrue);
    });

    test('cancelled error is NOT retryable', () {
      final result = UploadResult(
        success: false,
        errorType: UploadErrorType.cancelled,
      );
      expect(result.isRetryable, isFalse);
    });

    test('unknown error is retryable', () {
      final result = UploadResult(
        success: false,
        errorType: UploadErrorType.unknown,
      );
      expect(result.isRetryable, isTrue);
    });

    test('successful result is not retryable even with error type', () {
      final result = UploadResult(
        success: true,
        errorType: UploadErrorType.timeout,
      );
      expect(result.isRetryable, isFalse);
    });
  });

  group('UploadResult.success', () {
    test('creates success result', () {
      const result = UploadResult(success: true);
      expect(result.success, isTrue);
      expect(result.message, isNull);
      expect(result.errorType, isNull);
    });

    test('creates failure result with message', () {
      const result = UploadResult(
        success: false,
        message: 'Network error',
        errorType: UploadErrorType.offline,
      );
      expect(result.success, isFalse);
      expect(result.message, equals('Network error'));
      expect(result.errorType, equals(UploadErrorType.offline));
    });
  });
}

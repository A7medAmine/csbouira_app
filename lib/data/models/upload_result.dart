enum UploadErrorType {
  offline,
  timeout,
  serverError,
  cancelled,
  unknown,
}

class UploadResult {
  final bool success;
  final String? message;
  final UploadErrorType? errorType;

  const UploadResult({
    required this.success,
    this.message,
    this.errorType,
  });

  bool get isRetryable =>
      !success &&
      errorType != null &&
      errorType != UploadErrorType.cancelled;
}

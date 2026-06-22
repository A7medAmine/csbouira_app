import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../core/constants.dart';
import '../models/upload_result.dart';

/// Cancellation token that also force-closes the underlying [HttpClient]
/// so in-flight network I/O is aborted immediately.
class CancelToken {
  bool _cancelled = false;
  HttpClient? _client;

  /// Abort the upload and tear down the active connection.
  void cancel() {
    debugPrint('\x1B[31m[UPLOAD] CancelToken.cancel() invoked\x1B[0m');
    _cancelled = true;
    final client = _client;
    _client = null;
    try {
      client?.close(force: true);
    } catch (_) {
      // ignore close errors during abort
    }
  }

  bool get isCancelled => _cancelled;

  /// Attach the active [HttpClient] so [cancel] can close it.
  void _attach(HttpClient client) => _client = client;

  /// Detach the client (called after the request completes/fails).
  void _detach() => _client = null;
}

class UploadPayload {
  final String fullName;
  final String email;
  final String fileType;
  final String moduleName;
  final String grade;
  final String semester;
  final String fileName;
  final String fileData;
  final String mimeType;

  const UploadPayload({
    required this.fullName,
    required this.email,
    required this.fileType,
    required this.moduleName,
    required this.grade,
    required this.semester,
    required this.fileName,
    required this.fileData,
    required this.mimeType,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'email': email,
    'fileType': fileType,
    'moduleName': moduleName,
    'grade': grade,
    'semester': semester,
    'fileName': fileName,
    'fileData': fileData,
    'mimeType': mimeType,
  };
}

class UploadService {
  /// Uploads a resource with improved resilience:
  /// - Connect / idle / overall timeouts
  /// - Retry with exponential backoff + jitter for transient failures
  /// - Progress callback (0.0 – 1.0)
  /// - Cancellation support via [cancelToken] (aborts in-flight I/O)
  /// - Safe resource cleanup via try/finally
  Future<UploadResult> uploadResource({
    required String fullName,
    required String email,
    required String fileType,
    required String moduleName,
    required String grade,
    required String semester,
    required String fileName,
    required Uint8List fileBytes,
    required String mimeType,
    bool isScan = false,
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    // --- size check ---------------------------------------------------------
    if (!isScan) {
      final fileSize = fileBytes.length;
      if (fileSize > UploadConstants.maxFileSizeBytes) {
        debugPrint(
          '\x1B[31m[UPLOAD] File too large: ${fileSize}B > '
          '${UploadConstants.maxFileSizeBytes}B\x1B[0m',
        );
        return const UploadResult(
          success: false,
          message: 'File exceeds 15MB limit.',
          errorType: UploadErrorType.unknown,
        );
      }
    }

    // --- build payload ------------------------------------------------------
    final payload = UploadPayload(
      fullName: fullName,
      email: email,
      fileType: fileType,
      moduleName: moduleName,
      grade: grade,
      semester: semester,
      fileName: fileName,
      fileData: base64Encode(fileBytes),
      mimeType: mimeType,
    );

    final body = jsonEncode(payload.toJson());
    final bodyBytes = utf8.encode(body);

    debugPrint(
      '\x1B[31m[UPLOAD] Payload built, body size: ${bodyBytes.length}B\x1B[0m',
    );

    onProgress?.call(0.0);

    // --- retry loop ---------------------------------------------------------
    for (int attempt = 0; attempt <= UploadConstants.maxRetries; attempt++) {
      debugPrint(
        '\x1B[31m[UPLOAD] --- Attempt ${attempt + 1}/'
        '${UploadConstants.maxRetries + 1} ---\x1B[0m',
      );

      if (_isCancelled(cancelToken)) {
        debugPrint('\x1B[31m[UPLOAD] Cancelled before attempt\x1B[0m');
        return const UploadResult(
          success: false,
          message: 'Upload cancelled.',
          errorType: UploadErrorType.cancelled,
        );
      }

      HttpClient? httpClient;
      try {
        httpClient = _createHttpClient();
        cancelToken?._attach(httpClient);
        onProgress?.call(0.05);

        final result = await _sendRequest(
          httpClient: httpClient,
          bodyBytes: bodyBytes,
          onProgress: onProgress,
          cancelToken: cancelToken,
        );

        cancelToken?._detach();

        if (result.success || !result.isRetryable) {
          debugPrint(
            '\x1B[31m[UPLOAD] Result: success=${result.success} '
            'errorType=${result.errorType}\x1B[0m',
          );
          return result;
        }

        debugPrint(
          '\x1B[31m[UPLOAD] Transient failure (attempt ${attempt + 1}), '
          'will retry\x1B[0m',
        );
      } on CancelledException {
        debugPrint('\x1B[31m[UPLOAD] CancelledException caught\x1B[0m');
        cancelToken?._detach();
        return const UploadResult(
          success: false,
          message: 'Upload cancelled.',
          errorType: UploadErrorType.cancelled,
        );
      } catch (e) {
        cancelToken?._detach();

        if (_isCancelled(cancelToken)) {
          debugPrint(
            '\x1B[31m[UPLOAD] Cancelled after exception: $e\x1B[0m',
          );
          return const UploadResult(
            success: false,
            message: 'Upload cancelled.',
            errorType: UploadErrorType.cancelled,
          );
        }

        debugPrint(
          '\x1B[31m[UPLOAD] Exception on attempt ${attempt + 1}: $e '
          '(${e.runtimeType})\x1B[0m',
        );

        if (attempt == UploadConstants.maxRetries) {
          return UploadResult(
            success: false,
            message: _classifyErrorMessage(e),
            errorType: _classifyErrorType(e),
          );
        }

        if (!_isRetryable(e)) {
          return UploadResult(
            success: false,
            message: _classifyErrorMessage(e),
            errorType: _classifyErrorType(e),
          );
        }
      } finally {
        httpClient?.close();
        cancelToken?._detach();
      }

      // Backoff — do NOT reset progress so the bar stays smooth.
      final delay = _computeBackoff(attempt);
      debugPrint(
        '\x1B[31m[UPLOAD] Backoff ${delay.inMilliseconds}ms before retry\x1B[0m',
      );
      await Future.delayed(delay);
    }

    debugPrint('\x1B[31m[UPLOAD] All attempts exhausted\x1B[0m');
    return const UploadResult(
      success: false,
      message: 'Upload failed after multiple attempts.',
      errorType: UploadErrorType.unknown,
    );
  }

  // --------------------------------------------------------------------------
  // Internal helpers
  // --------------------------------------------------------------------------

  HttpClient _createHttpClient() {
    final client = HttpClient();
    client.userAgent = null;
    client.connectionTimeout = UploadConstants.connectionTimeout;
    client.idleTimeout = UploadConstants.idleTimeout;
    return client;
  }

  /// Sends the request with proper redirect handling.
  ///
  /// **Redirect strategy** (matches Google Apps Script behaviour):
  /// - Initial request: **POST** with JSON body
  /// - Redirect (301/302/303): **GET** without body (the backend
  ///   has already buffered the payload and only needs the auth
  ///   handshake on the redirect URL)
  /// - Redirect (307/308): **GET** (body is NOT resent — the initial
  ///   POST already reached the handler before the redirect)
  Future<UploadResult> _sendRequest({
    required HttpClient httpClient,
    required List<int> bodyBytes,
    required void Function(double)? onProgress,
    required CancelToken? cancelToken,
  }) async {
    const chunkSize = 8192;
    final totalBytes = bodyBytes.length;

    var currentUri = Uri.parse(ApiConstants.uploadUrl);
    bool isRedirect = false;

    for (int redirectCount = 0; redirectCount < 5; redirectCount++) {
      if (_isCancelled(cancelToken)) throw CancelledException();

      debugPrint(
        '\x1B[31m[UPLOAD] ${isRedirect ? "GET" : "POST"} → $currentUri'
        '${isRedirect ? "" : "  (${totalBytes}B body)"}\x1B[0m',
      );

      final request = isRedirect
          ? await httpClient
              .getUrl(currentUri)
              .timeout(UploadConstants.connectionTimeout)
          : await httpClient
              .postUrl(currentUri)
              .timeout(UploadConstants.connectionTimeout);

      if (!isRedirect) {
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        request.contentLength = totalBytes;

        onProgress?.call(0.1);

        // Write body in chunks and report progress.
        int bytesWritten = 0;
        for (int offset = 0; offset < totalBytes; offset += chunkSize) {
          if (_isCancelled(cancelToken)) {
            try {
              request.close();
            } catch (_) {}
            throw CancelledException();
          }
          final end = (offset + chunkSize).clamp(0, totalBytes);
          request.add(bodyBytes.sublist(offset, end));
          bytesWritten += end - offset;
          onProgress?.call(0.1 + 0.15 * (bytesWritten / totalBytes));
        }

        onProgress?.call(0.25);
      } else {
        onProgress?.call(0.65);
      }

      // --- network I/O with simulated progress -----------------------------
      // body.write() is buffered in memory; the actual network send happens
      // inside close().  We use a periodic timer so the bar doesn't freeze.
      var simulated = isRedirect ? 0.68 : 0.25;
      final simTarget = isRedirect ? 0.78 : 0.60;
      Timer? simTimer;
      if (onProgress != null) {
        simTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
          simulated = (simulated + 0.025).clamp(0.0, simTarget);
          onProgress(simulated);
        });
      }

      HttpClientResponse response;
      try {
        response = await request.close().timeout(
          UploadConstants.overallTimeout,
          onTimeout: () => throw TimeoutException(
            'Upload took too long (no response received).',
          ),
        );
      } finally {
        simTimer?.cancel();
      }

      debugPrint(
        '\x1B[31m[UPLOAD] Response: ${response.statusCode}'
        ' ${response.reasonPhrase}\x1B[0m',
      );

      onProgress?.call(isRedirect ? 0.8 : 0.6);

      // --- redirect handling -----------------------------------------------
      if (_isRedirectStatusCode(response.statusCode)) {
        final location = response.headers.value(HttpHeaders.locationHeader);
        debugPrint(
          '\x1B[31m[UPLOAD] Redirect ${response.statusCode} → '
          '${location ?? "(no Location header)"}\x1B[0m',
        );
        if (location == null) {
          final respBody = await _readResponseWithSimulatedProgress(
            response, onProgress, 0.6, 0.65,
          );
          onProgress?.call(1.0);
          return _processResponse(response.statusCode, respBody);
        }
        await response.drain();
        currentUri = Uri.parse(location);
        isRedirect = true;
        continue;
      }

      // --- non-redirect: read body and return -------------------------------
      final responseBody = await _readResponseWithSimulatedProgress(
        response, onProgress, 0.6, 0.65,
      );

      debugPrint(
        '\x1B[31m[UPLOAD] Response body (first 200 chars): '
        '${responseBody.length > 200 ? "${responseBody.substring(0, 200)}…" : responseBody}\x1B[0m',
      );

      onProgress?.call(1.0);
      return _processResponse(response.statusCode, responseBody);
    }

    debugPrint('\x1B[31m[UPLOAD] Too many redirects\x1B[0m');
    return const UploadResult(
      success: false,
      message: 'Too many redirects. Try again.',
      errorType: UploadErrorType.serverError,
    );
  }

  /// Reads the response body while slowly advancing progress so the bar
  /// doesn't appear stuck during a slow response download.
  Future<String> _readResponseWithSimulatedProgress(
    HttpClientResponse response,
    void Function(double)? onProgress,
    double from,
    double to,
  ) async {
    if (onProgress == null) {
      return response.transform(utf8.decoder).join().timeout(
        UploadConstants.overallTimeout,
        onTimeout: () => throw TimeoutException(
          'Reading server response timed out.',
        ),
      );
    }

    var simulated = from;
    final timer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      simulated = (simulated + 0.008).clamp(from, to);
      onProgress(simulated);
    });

    try {
      final body = await response.transform(utf8.decoder).join().timeout(
        UploadConstants.overallTimeout,
        onTimeout: () => throw TimeoutException(
          'Reading server response timed out.',
        ),
      );
      onProgress(to);
      return body;
    } finally {
      timer.cancel();
    }
  }

  // --------------------------------------------------------------------------
  // Response processing
  // --------------------------------------------------------------------------

  UploadResult _processResponse(int statusCode, String responseBody) {
    if (statusCode == 200) {
      try {
        final responseJson = jsonDecode(responseBody);
        if (responseJson is Map && responseJson['error'] == true) {
          debugPrint(
            '\x1B[31m[UPLOAD] Server returned error=true: '
            '${responseJson['message']}\x1B[0m',
          );
          return UploadResult(
            success: false,
            message: responseJson['message'] as String? ?? 'Upload failed.',
            errorType: UploadErrorType.serverError,
          );
        }
      } catch (_) {
        debugPrint(
          '\x1B[31m[UPLOAD] Could not parse 200 response JSON\x1B[0m',
        );
      }
      debugPrint('\x1B[31m[UPLOAD] ✅ Upload successful\x1B[0m');
      return const UploadResult(success: true);
    }

    debugPrint(
      '\x1B[31m[UPLOAD] Non-200 status: $statusCode\x1B[0m',
    );
    return UploadResult(
      success: false,
      message: statusCode >= 500
          ? 'Server error ($statusCode). Try again.'
          : 'Client error ($statusCode).',
      errorType: UploadErrorType.serverError,
    );
  }

  // --------------------------------------------------------------------------
  // Redirect helpers
  // --------------------------------------------------------------------------

  static bool _isRedirectStatusCode(int code) =>
      code == 301 || code == 302 || code == 303 ||
      code == 307 || code == 308;

  // --------------------------------------------------------------------------
  // Error classification
  // --------------------------------------------------------------------------

  bool _isRetryable(Object error) {
    if (error is TimeoutException) return true;
    if (error is SocketException) return true;
    if (error is HttpException) return true;
    if (error is HandshakeException) return true;
    return false;
  }

  String _classifyErrorMessage(Object error) {
    if (error is SocketException) {
      return 'No internet connection. Check your Wi‑Fi and try again.';
    }
    if (error is HandshakeException) {
      return 'Secure connection failed. Check your network.';
    }
    if (error is HttpException) {
      return 'Server communication error. Try again.';
    }
    if (error is TimeoutException) {
      return 'Request timed out. Try again on a stronger connection.';
    }
    return 'Network error. Check your connection.';
  }

  UploadErrorType _classifyErrorType(Object error) {
    if (error is SocketException) return UploadErrorType.offline;
    if (error is HandshakeException) return UploadErrorType.offline;
    if (error is TimeoutException) return UploadErrorType.timeout;
    if (error is HttpException) return UploadErrorType.serverError;
    return UploadErrorType.unknown;
  }

  // --------------------------------------------------------------------------
  // Backoff
  // --------------------------------------------------------------------------

  Duration _computeBackoff(int attempt) {
    final base = UploadConstants.retryBaseDelay.inMilliseconds;
    final max = UploadConstants.retryMaxDelay.inMilliseconds;
    final exp = min(base * (1 << attempt), max);
    final jitter = Random().nextInt(1000);
    return Duration(milliseconds: exp + jitter);
  }

  // --------------------------------------------------------------------------
  // Cancellation helpers
  // --------------------------------------------------------------------------

  static bool _isCancelled(CancelToken? token) =>
      token != null && token.isCancelled;
}

class CancelledException implements Exception {
  @override
  String toString() => 'CancelledException';
}

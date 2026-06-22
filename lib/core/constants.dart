class ApiConstants {
  ApiConstants._();

  static const String driveBaseUrl = 'https://api.csbouira.xyz/api/drive';
  static const String uploadUrl =
      'https://script.google.com/macros/s/AKfycbxMikLNPWYBEWjYJ7FSLJAHV_dZ_5E6aSGarqtm7kubMsjzXFHXnW4s-eEM2RtFOaF3/exec';
}

class EnvKeys {
  EnvKeys._();

  static const String supabaseUrl = 'SUPABASE_URL';
  static const String supabaseAnonKey = 'SUPABASE_ANON_KEY';
}

class UploadConstants {
  UploadConstants._();

  static const int maxFileSizeBytes = 15 * 1024 * 1024; // 15 MB

  /// Maximum time to establish a TCP connection.
  static const Duration connectionTimeout = Duration(seconds: 30);

  /// Maximum idle time between data packets during send/receive.
  static const Duration idleTimeout = Duration(seconds: 60);

  /// Maximum wall-clock time for the entire upload (connect + send + response).
  static const Duration overallTimeout = Duration(seconds: 120);

  /// Number of retry attempts for transient failures.
  static const int maxRetries = 3;

  /// Base delay for exponential backoff (doubles each attempt).
  static const Duration retryBaseDelay = Duration(seconds: 2);

  /// Maximum cap for backoff delay (jitter is added on top).
  static const Duration retryMaxDelay = Duration(seconds: 30);
}

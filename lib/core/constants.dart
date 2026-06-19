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
}

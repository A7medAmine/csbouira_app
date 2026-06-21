import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../models/upload_result.dart';

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
  }) async {
    if (!isScan) {
      final fileSize = fileBytes.length;
      if (fileSize > UploadConstants.maxFileSizeBytes) {
        return UploadResult(
          success: false,
          message: 'File exceeds ${UploadConstants.maxFileSizeBytes ~/ (1024 * 1024)}MB limit.',
        );
      }
    }

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

    try {
      final httpClient = HttpClient();
      httpClient.userAgent = null;
      httpClient.connectionTimeout = const Duration(seconds: 30);

      Future<http.Response> doRequest(Uri url, {bool isRedirect = false}) async {
        final request = isRedirect
            ? await httpClient.getUrl(url)
            : await httpClient.postUrl(url);

        if (!isRedirect) {
          request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
          request.write(body);
        }

        final response = await request.close();

        if (response.statusCode == 301 ||
            response.statusCode == 302 ||
            response.statusCode == 303) {
          final location = response.headers.value(HttpHeaders.locationHeader);
          if (location != null) {
            return doRequest(Uri.parse(location), isRedirect: true);
          }
        }

        final responseBody = await response.transform(utf8.decoder).join();
        return http.Response(responseBody, response.statusCode);
      }

      final response = await doRequest(Uri.parse(ApiConstants.uploadUrl));
      httpClient.close();

      if (response.statusCode == 200) {
        try {
          final responseJson = jsonDecode(response.body);
          if (responseJson is Map && responseJson['error'] == true) {
            return UploadResult(
              success: false,
              message: responseJson['message'] as String? ?? 'Upload failed.',
            );
          }
        } catch (_) {}
        return UploadResult(success: true);
      }

      return UploadResult(
        success: false,
        message: 'Server error (${response.statusCode}). Try again.',
      );
    } catch (e) {
      return UploadResult(
        success: false,
        message: 'Network error. Check your connection.',
      );
    }
  }
}

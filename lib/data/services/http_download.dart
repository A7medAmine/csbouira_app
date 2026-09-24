import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';

/// Streams [url] into [dest] and returns the number of bytes written.
///
/// - Never holds the whole file in memory.
/// - Writes to `<dest>.part` and renames on success, so an interrupted
///   download never leaves a truncated file that looks complete.
/// - Times out if the connection stalls.
/// - With [rejectHtml], fails when the server answers with a web page
///   (e.g. Google Drive's "can't scan this file for viruses" page for large
///   files) instead of silently saving that page as the file.
Future<int> downloadToFile(
  http.Client client,
  Uri url,
  File dest, {
  bool rejectHtml = true,
}) async {
  final response = await client
      .send(http.Request('GET', url))
      .timeout(NetworkConstants.apiTimeout);

  if (response.statusCode != 200) {
    await response.stream.drain<void>();
    throw HttpException(
      'Download failed with status ${response.statusCode}',
      uri: url,
    );
  }

  final contentType = response.headers['content-type'] ?? '';
  if (rejectHtml && contentType.startsWith('text/html')) {
    await response.stream.drain<void>();
    throw HttpException(
      'Server returned a web page instead of the file',
      uri: url,
    );
  }

  final part = File('${dest.path}.part');
  final sink = part.openWrite();
  var bytes = 0;
  try {
    await for (final chunk
        in response.stream.timeout(NetworkConstants.downloadIdleTimeout)) {
      sink.add(chunk);
      bytes += chunk.length;
    }
    await sink.flush();
    await sink.close();
  } catch (_) {
    await sink.close();
    if (await part.exists()) await part.delete();
    rethrow;
  }

  if (await dest.exists()) await dest.delete();
  await part.rename(dest.path);
  return bytes;
}

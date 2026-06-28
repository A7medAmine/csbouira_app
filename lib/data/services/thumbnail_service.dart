import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ThumbnailService {
  final http.Client _client;

  ThumbnailService({http.Client? client}) : _client = client ?? http.Client();

  String? extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host == 'youtu.be') {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }

    if (uri.host.contains('youtube.com') || uri.host.contains('youtube.')) {
      if (uri.path == '/watch') return uri.queryParameters['v'];
      if (uri.path.startsWith('/embed/') && uri.pathSegments.length > 1) {
        return uri.pathSegments[1];
      }
    }

    return null;
  }

  String? extractPlaylistId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtube.com')) {
      return uri.queryParameters['list'];
    }
    return null;
  }

  bool isYoutubeUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.host.contains('youtube.com') || uri.host == 'youtu.be');
  }

  Future<String?> getThumbnailUrl(String url) async {
    final videoId = extractVideoId(url);
    if (videoId != null && videoId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }

    if (!isYoutubeUrl(url)) return null;

    try {
      final response = await _client.get(
        Uri.parse(
          'https://www.youtube.com/oembed?url=${Uri.encodeComponent(url)}&format=json',
        ),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final thumb = data['thumbnail_url'] as String?;
        if (thumb != null && thumb.isNotEmpty) return thumb;
      }
    } catch (e) {
      debugPrint('Error in ThumbnailService.getThumbnailUrl: $e');
    }

    try {
      final avatar = await _getChannelAvatar(url);
      if (avatar != null) return avatar;
    } catch (e) {
      debugPrint('Error in ThumbnailService.getThumbnailUrl (avatar): $e');
    }

    return null;
  }

  Future<String?> _getChannelAvatar(String url) async {
    final response = await _client.get(
      Uri.parse(url),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    );
    if (response.statusCode != 200) return null;

    final body = response.body;
    final reg = RegExp(
      r'<meta\s+property="og:image"\s+content="([^"]+)"',
      caseSensitive: false,
    );
    final match = reg.firstMatch(body);
    if (match == null) return null;

    final imgUrl = match.group(1);
    if (imgUrl == null || imgUrl.isEmpty) return null;

    return imgUrl;
  }

  void dispose() => _client.close();
}

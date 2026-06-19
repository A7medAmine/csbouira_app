import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/thumbnail_service.dart';

final thumbnailServiceProvider = Provider<ThumbnailService>((ref) {
  final service = ThumbnailService();
  ref.onDispose(() => service.dispose());
  return service;
});

final resourceThumbnailProvider = FutureProvider.family<String?, String>((ref, url) {
  final service = ref.read(thumbnailServiceProvider);
  return service.getThumbnailUrl(url);
});

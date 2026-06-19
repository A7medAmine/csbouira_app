import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/drive_node.dart';
import '../services/drive_api_service.dart';

final driveApiServiceProvider = Provider<DriveApiService>((ref) {
  ref.keepAlive();
  final service = DriveApiService();
  ref.onDispose(() => service.clearCache());
  return service;
});

final driveRootDataProvider = FutureProvider<DriveRootData>((ref) {
  ref.keepAlive();
  return ref.read(driveApiServiceProvider).getFullTree();
});

final fileCountsProvider = FutureProvider<Map<String, int>>((ref) {
  ref.keepAlive();
  return ref.read(driveApiServiceProvider).getFileCounts();
});

final onlineResourcesProvider = FutureProvider<Map<String, Map<String, List<OnlineResource>>>>((ref) {
  ref.keepAlive();
  return ref.read(driveApiServiceProvider).getOnlineResources();
});

String drivePathKey(List<String> segments) => segments.join('\x00');

final driveNodeProvider = FutureProvider.family<DriveNode?, String>((ref, key) {
  final api = ref.read(driveApiServiceProvider);
  final segments = key.split('\x00');
  final cached = api.getCachedNode(segments);
  if (cached != null) return cached;
  return api.getPath(segments);
});

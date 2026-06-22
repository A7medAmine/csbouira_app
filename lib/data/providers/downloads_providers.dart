import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/downloaded_file.dart';
import '../services/download_service.dart';

final downloadsListProvider = FutureProvider<List<DownloadedFile>>((ref) async {
  final service = ref.watch(downloadServiceProvider);
  return service.getAll();
});

final downloadsCountProvider = FutureProvider<int>((ref) async {
  final list = await ref.watch(downloadsListProvider.future);
  return list.length;
});

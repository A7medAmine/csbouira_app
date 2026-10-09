import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../models/drive_node.dart';
import 'file_cache_service.dart';

/// An installed AI app that can receive a file.
class AiApp {
  final String packageName;
  final String label;
  final Uint8List? icon;

  const AiApp({required this.packageName, required this.label, this.icon});
}

/// Sends a catalogue file, or one page of a PDF, to an AI chat app with a
/// prompt. Direct app buttons are Android only (`MainActivity.kt`); other
/// platforms use the system share sheet.
class AiShareService {
  static const _channel = MethodChannel('csbouira_app/ai_share');

  /// AI apps offered as direct buttons, in display order. Must match the
  /// `<queries>` list in AndroidManifest.xml.
  static const knownPackages = [
    'com.openai.chatgpt',
    'com.google.android.apps.bard',
    'com.anthropic.claude',
    'com.microsoft.copilot',
    'ai.perplexity.app.android',
    'com.deepseek.chat',
    'ai.x.grok',
    'ai.mistral.chat',
  ];

  final FileCacheService _cache;

  AiShareService(this._cache);

  static String mimeTypeOf(String fileName) =>
      lookupMimeType(fileName) ?? 'application/octet-stream';

  /// Installed AI apps that accept [mimeType].
  Future<List<AiApp>> installedApps(String mimeType) async {
    if (!Platform.isAndroid) return const [];
    try {
      final apps = await _channel.invokeListMethod<Map>('queryApps', {
        'packages': knownPackages,
        'mimeType': mimeType,
      });
      return [
        for (final app in apps ?? const <Map>[])
          AiApp(
            packageName: app['package'] as String,
            label: app['label'] as String,
            icon: app['icon'] as Uint8List?,
          ),
      ];
    } on PlatformException catch (e) {
      debugPrint('AiShareService.installedApps: $e');
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }

  /// Copies [file] into the share folder under its real name, or only [page]
  /// (1-based) of it when given. Files from the previous share are removed.
  Future<File> prepare(DriveFile file, {int? page}) async {
    final downloadUrl = file.downloadLink ?? file.link;
    final fileId = extractDriveFileId(downloadUrl);
    if (fileId == null) throw const FileCacheException('No Drive file ID');
    final source = await _cache.getOrDownload(
      fileId: fileId,
      downloadUrl: downloadUrl,
    );

    final dir = await _shareDir();
    final name = _safeFileName(file.name);
    if (page == null) return source.copy('${dir.path}/$name');

    final bytes = await compute(extractPdfPage, (
      await source.readAsBytes(),
      page,
    ));
    final out = File('${dir.path}/${pageFileName(name, page)}');
    await out.writeAsBytes(bytes);
    return out;
  }

  /// Opens [packageName] with [file] and [text]. Throws a
  /// [PlatformException] when the app can't take it.
  Future<void> shareToApp(
    String packageName,
    File file,
    String mimeType,
    String text,
  ) =>
      _channel.invokeMethod('shareToApp', {
        'package': packageName,
        'path': file.path,
        'mimeType': mimeType,
        'text': text,
      });

  Future<void> shareWithChooser(File file, String mimeType, String text) =>
      SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        text: text,
      ));

  /// `<temp>/ai_share`, emptied. Shared through `AiShareFileProvider`, see
  /// `res/xml/ai_share_paths.xml`.
  Future<Directory> _shareDir() async {
    final temp = await getTemporaryDirectory();
    final dir = Directory('${temp.path}/ai_share');
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
    return dir;
  }
}

String _safeFileName(String name) {
  final safe = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  return safe.isEmpty ? 'file' : safe;
}

/// `Course.pdf` → `Course (p. 5).pdf`.
String pageFileName(String name, int page) {
  final dot = name.toLowerCase().endsWith('.pdf') ? name.length - 4 : -1;
  final base = dot == -1 ? name : name.substring(0, dot);
  return '$base (p. $page).pdf';
}

/// Builds a one-page PDF from page `args.$2` (1-based) of the PDF in
/// `args.$1`. Top level so it can run in an isolate.
Uint8List extractPdfPage((Uint8List, int) args) {
  final (bytes, page) = args;
  final source = PdfDocument(inputBytes: bytes);
  try {
    final sourcePage = source.pages[page - 1];
    final size = sourcePage.size;
    final out = PdfDocument();
    try {
      out.pageSettings
        ..margins.all = 0
        ..orientation = size.width > size.height
            ? PdfPageOrientation.landscape
            : PdfPageOrientation.portrait
        ..size = size
        ..rotate = sourcePage.rotation;
      out.pages.add().graphics.drawPdfTemplate(
            sourcePage.createTemplate(),
            Offset.zero,
            size,
          );
      return Uint8List.fromList(out.saveSync());
    } finally {
      out.dispose();
    }
  } finally {
    source.dispose();
  }
}

final aiShareServiceProvider = Provider<AiShareService>((ref) {
  return AiShareService(ref.watch(fileCacheServiceProvider));
});

/// Installed AI apps accepting a MIME type.
final installedAiAppsProvider =
    FutureProvider.autoDispose.family<List<AiApp>, String>((ref, mimeType) {
  return ref.watch(aiShareServiceProvider).installedApps(mimeType);
});

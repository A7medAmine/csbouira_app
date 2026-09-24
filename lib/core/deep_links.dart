import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Links the app understands:
///
/// * `csbouira://file/<driveFileId>` opens a file in the previewer.
/// * `csbouira://new` opens the "what's new" feed.
sealed class AppLink {
  const AppLink();
}

class FileLink extends AppLink {
  final String fileId;
  const FileLink(this.fileId);

  @override
  bool operator ==(Object other) => other is FileLink && other.fileId == fileId;

  @override
  int get hashCode => fileId.hashCode;
}

class WhatsNewLink extends AppLink {
  const WhatsNewLink();

  @override
  bool operator ==(Object other) => other is WhatsNewLink;

  @override
  int get hashCode => 0;
}

const appLinkScheme = 'csbouira';

final _driveId = RegExp(r'^[A-Za-z0-9_-]{10,}$');

String fileDeepLink(String fileId) => '$appLinkScheme://file/$fileId';

AppLink? parseAppLink(Uri uri) {
  if (uri.scheme != appLinkScheme) return null;
  switch (uri.host) {
    case 'file':
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.length != 1 || !_driveId.hasMatch(segments.first)) {
        return null;
      }
      return FileLink(segments.first);
    case 'new':
      return const WhatsNewLink();
  }
  return null;
}

/// The in-app route that handles [link].
String routeForLink(AppLink link) => switch (link) {
      FileLink(:final fileId) => '/open/file/$fileId',
      WhatsNewLink() => '/whats-new',
    };

/// Receives links from Android (intent data set by the system, the home
/// screen widget or a QR code scanned with the camera app) and hands them to
/// the router once the app is ready.
///
/// Flutter's built-in deep linking is disabled in the manifest because it
/// drops the URI host (`file`), which our links need.
class DeepLinkService {
  DeepLinkService._();
  static final instance = DeepLinkService._();

  static const _channel = MethodChannel('csbouira_app/deep_links');

  void Function(String route)? _navigate;
  String? _pendingRoute;
  bool _started = false;

  /// Starts listening. Safe to call more than once.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onLink' && call.arguments is String) {
        handleUri(Uri.tryParse(call.arguments as String));
      }
    });
    try {
      final initial = await _channel.invokeMethod<String>('getInitialLink');
      if (initial != null) handleUri(Uri.tryParse(initial));
    } on MissingPluginException {
      // iOS and tests: no native side.
    } on PlatformException catch (e) {
      debugPrint('Deep link init failed: $e');
    }
  }

  /// Routes [uri] now if the app is ready, or once [attach] is called.
  void handleUri(Uri? uri) {
    if (uri == null) return;
    final link = parseAppLink(uri);
    if (link == null) return;
    final route = routeForLink(link);
    final navigate = _navigate;
    if (navigate != null) {
      navigate(route);
    } else {
      _pendingRoute = route;
    }
  }

  /// Called once the home screen is shown. Replays a link that arrived
  /// during startup.
  void attach(void Function(String route) navigate) {
    _navigate = navigate;
    final pending = _pendingRoute;
    _pendingRoute = null;
    if (pending != null) navigate(pending);
  }
}

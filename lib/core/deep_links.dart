import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Links the app understands:
///
/// * `csbouira://file/<driveFileId>` opens a file in the previewer.
/// * `csbouira://new` opens the "what's new" feed.
/// * `csbouira://browse/<year>[/<semester>[/<module>]]` opens a year,
///   semester or module page (used by favorites on the home screen widget).
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

class BrowseLink extends AppLink {
  final String year;
  final String? semester;
  final String? module;

  const BrowseLink(this.year, {this.semester, this.module});

  @override
  bool operator ==(Object other) =>
      other is BrowseLink &&
      other.year == year &&
      other.semester == semester &&
      other.module == module;

  @override
  int get hashCode => Object.hash(year, semester, module);
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

/// Link to a year page, or a semester or module page when those are given.
/// [semester] is a semester id, so it may contain a promo folder.
String browseDeepLink(String year, {String? semester, String? module}) => Uri(
      scheme: appLinkScheme,
      host: 'browse',
      pathSegments: [
        year,
        if (semester != null) semester,
        if (semester != null && module != null) module,
      ],
    ).toString();

AppLink? parseAppLink(Uri uri) {
  if (uri.scheme != appLinkScheme) return null;
  switch (uri.host) {
    case 'file':
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.length != 1 || !_driveId.hasMatch(segments.first)) {
        return null;
      }
      return FileLink(segments.first);
    case 'browse':
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isEmpty || segments.length > 3) return null;
      return BrowseLink(
        segments[0],
        semester: segments.length > 1 ? segments[1] : null,
        module: segments.length > 2 ? segments[2] : null,
      );
    case 'new':
      return const WhatsNewLink();
  }
  return null;
}

/// The in-app route that handles [link].
String routeForLink(AppLink link) => switch (link) {
      FileLink(:final fileId) => '/open/file/$fileId',
      BrowseLink(:final year, :final semester, :final module) => [
          '/year/${Uri.encodeComponent(year)}',
          if (semester != null) 'semester/${Uri.encodeComponent(semester)}',
          if (module != null) 'module/${Uri.encodeComponent(module)}',
        ].join('/'),
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

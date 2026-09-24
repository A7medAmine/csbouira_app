import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _enabledKey = 'crash_reports_enabled';

String? get _dsn {
  final dsn = dotenv.env['SENTRY_DSN']?.trim();
  return (dsn == null || dsn.isEmpty) ? null : dsn;
}

/// Whether this build can send crash reports at all (a DSN is configured).
bool get crashReportingAvailable => _dsn != null;

/// Runs [app], wrapped in Sentry when a DSN is configured and the user has
/// not turned crash reports off. Never sends names, emails or IP addresses.
Future<void> runWithCrashReporting(Widget app) async {
  final dsn = _dsn;
  final prefs = await SharedPreferences.getInstance();
  final enabled = prefs.getBool(_enabledKey) ?? true;
  if (dsn == null || !enabled) {
    runApp(app);
    return;
  }
  final info = await PackageInfo.fromPlatform();
  await SentryFlutter.init(
    (options) {
      options
        ..dsn = dsn
        ..release = 'csbouira_app@${info.version}+${info.buildNumber}'
        ..sendDefaultPii = false
        ..tracesSampleRate = 0;
    },
    appRunner: () => runApp(app),
  );
}

final crashReportsEnabledProvider =
    StateNotifierProvider<CrashReportsNotifier, bool>((ref) {
  return CrashReportsNotifier()..load();
});

class CrashReportsNotifier extends StateNotifier<bool> {
  CrashReportsNotifier() : super(true);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) state = prefs.getBool(_enabledKey) ?? true;
  }

  /// Turning reports off stops Sentry right away; turning them on takes
  /// effect the next time the app starts.
  Future<void> set(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
    if (!enabled) await Sentry.close();
  }
}

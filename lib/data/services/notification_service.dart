import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../core/deep_links.dart';

/// Local notifications for "new files in a module you follow".
///
/// Tapping a notification opens its payload, an app link such as
/// `csbouira://new`, through [DeepLinkService].
class NotificationService {
  NotificationService._();

  static const _channelId = 'new_files';
  static const _newFilesId = 1001;

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Sets up the plugin. [handleTaps] is false in the background isolate,
  /// which only posts notifications.
  static Future<void> init({bool handleTaps = true}) async {
    if (_initialized || !Platform.isAndroid) return;
    _initialized = true;
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: handleTaps ? _onTap : null,
    );
    if (!handleTaps) return;
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final response = launch?.notificationResponse;
    if ((launch?.didNotificationLaunchApp ?? false) && response != null) {
      _onTap(response);
    }
  }

  static void _onTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;
    DeepLinkService.instance.handleUri(Uri.tryParse(payload));
  }

  /// Asks for the Android 13+ notification permission. Returns whether
  /// notifications are allowed.
  static Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return false;
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    try {
      return await android?.requestNotificationsPermission() ?? false;
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      return false;
    }
  }

  static Future<void> showNewFiles({
    required String channelName,
    required String title,
    required String body,
  }) async {
    if (!Platform.isAndroid) return;
    await _plugin.show(
      _newFilesId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          channelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      payload: '$appLinkScheme://new',
    );
  }
}

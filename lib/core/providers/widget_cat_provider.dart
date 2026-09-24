import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/home_widget_service.dart';

final widgetCatEnabledProvider = StateNotifierProvider<WidgetCatNotifier, bool>(
  (ref) {
    return WidgetCatNotifier()..load();
  },
);

/// Shows or hides the blinking cat on the Android home screen widget.
/// On by default.
class WidgetCatNotifier extends StateNotifier<bool> {
  WidgetCatNotifier() : super(true);

  Future<void> load() async {
    final enabled = await HomeWidgetService.isCatEnabled();
    if (mounted) state = enabled;
  }

  Future<void> set(bool enabled) async {
    state = enabled;
    await HomeWidgetService.setCatEnabled(enabled);
  }
}

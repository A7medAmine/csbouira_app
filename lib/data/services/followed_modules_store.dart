import 'package:shared_preferences/shared_preferences.dart';

/// Modules the user follows, as `year>semester>module` keys (see
/// `moduleKeyOf`). Kept on the device only; read by the background checker.
class FollowedModulesStore {
  static const _key = 'followed_modules';

  Future<Set<String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? const []).toSet();
  }

  Future<void> save(Set<String> modules) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, modules.toList()..sort());
  }
}

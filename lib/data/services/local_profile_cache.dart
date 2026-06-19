import 'package:shared_preferences/shared_preferences.dart';

class LocalProfileCache {
  static const _keyName = 'guest_profile_name';
  static const _keyEmail = 'guest_profile_email';
  static const _keyAvatar = 'guest_profile_avatar';

  Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName) ?? '';
  }

  Future<void> setName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
  }

  Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? '';
  }

  Future<void> setEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
  }

  Future<String?> getAvatarBase64() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAvatar);
  }

  Future<void> setAvatarBase64(String? base64) async {
    final prefs = await SharedPreferences.getInstance();
    if (base64 != null) {
      await prefs.setString(_keyAvatar, base64);
    } else {
      await prefs.remove(_keyAvatar);
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyName);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyAvatar);
  }
}

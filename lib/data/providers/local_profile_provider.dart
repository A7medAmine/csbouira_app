import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProfile {
  final String name;
  final String email;
  final Uint8List? avatarBytes;

  const LocalProfile({
    this.name = 'Guest',
    this.email = '',
    this.avatarBytes,
  });

  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  LocalProfile copyWith({
    String? name,
    String? email,
    Uint8List? avatarBytes,
    bool clearAvatar = false,
  }) {
    return LocalProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      avatarBytes: clearAvatar ? null : (avatarBytes ?? this.avatarBytes),
    );
  }
}

final localProfileProvider = StateNotifierProvider<LocalProfileNotifier, LocalProfile>(
  (ref) => LocalProfileNotifier(),
);

class LocalProfileNotifier extends StateNotifier<LocalProfile> {
  LocalProfileNotifier() : super(const LocalProfile()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('profile_name') ?? 'Guest';
    final email = prefs.getString('profile_email') ?? '';
    final avatarStr = prefs.getString('profile_avatar');
    Uint8List? avatarBytes;
    if (avatarStr != null && avatarStr.isNotEmpty) {
      try {
        avatarBytes = base64Decode(avatarStr);
      } catch (_) {}
    }
    state = LocalProfile(name: name, email: email, avatarBytes: avatarBytes);
  }

  Future<void> updateName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', name);
    state = state.copyWith(name: name);
  }

  Future<void> updateEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_email', email);
    state = state.copyWith(email: email);
  }

  Future<void> pickAvatar(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_avatar', base64Encode(bytes));
    state = state.copyWith(avatarBytes: bytes);
  }

  Future<void> removeAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_avatar');
    state = state.copyWith(clearAvatar: true);
  }
}

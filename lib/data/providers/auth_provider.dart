import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { unauthenticated, authenticated, guest }

class AuthState {
  final AuthStatus status;
  final String? email;

  const AuthState({this.status = AuthStatus.unauthenticated, this.email});

  bool get isLoggedIn => status == AuthStatus.authenticated || status == AuthStatus.guest;

  AuthState copyWith({AuthStatus? status, String? email}) {
    return AuthState(
      status: status ?? this.status,
      email: email ?? this.email,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('auth_email');
    final guest = prefs.getBool('auth_guest') ?? false;
    if (guest) {
      state = const AuthState(status: AuthStatus.guest);
    } else if (email != null) {
      state = AuthState(status: AuthStatus.authenticated, email: email);
    }
  }

  Future<void> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_email', email);
    await prefs.setBool('auth_guest', false);
    state = AuthState(status: AuthStatus.authenticated, email: email);
  }

  Future<void> signup(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_email', email);
    await prefs.setBool('auth_guest', false);
    state = AuthState(status: AuthStatus.authenticated, email: email);
  }

  Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_guest', true);
    await prefs.remove('auth_email');
    state = const AuthState(status: AuthStatus.guest);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_email');
    await prefs.remove('auth_guest');
    state = const AuthState();
  }
}

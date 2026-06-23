import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  User? get currentUser => _supabase.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<AuthResponse> signUpWithEmail(String email, String password, {Map<String, dynamic>? data}) {
    return _supabase.auth.signUp(email: email, password: password, data: data);
  }

  Future<AuthResponse> signInWithEmail(String email, String password) {
    return _supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signInWithGoogle({
    required String idToken,
    String? accessToken,
  }) {
    return _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> signOut() => _supabase.auth.signOut();

  /// Sends a password reset email with a 6-digit recovery token.
  Future<void> sendPasswordResetOtp(String email) {
    return _supabase.auth.resetPasswordForEmail(email);
  }

  /// Verifies the 6-digit recovery token received via email.
  /// On success, creates a session in recovery mode so [updatePassword] can be called.
  Future<AuthResponse> verifyRecoveryOtp({
    required String email,
    required String token,
  }) {
    return _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery,
    );
  }

  /// Updates the current user's password (must be called after [verifyRecoveryOtp]).
  Future<void> updatePassword(String newPassword) {
    return _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> updateProfile(Map<String, dynamic> data) {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    return _supabase.from('profiles').update(data).eq('id', user.id);
  }

  /// Sends a 6-digit OTP to the user's email for action confirmation.
  Future<void> sendActionOtp(String email) {
    return _supabase.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
    );
  }

  /// Verifies an action confirmation OTP sent to the user's email.
  Future<AuthResponse> verifyActionOtp({
    required String email,
    required String token,
  }) {
    return _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.magiclink,
    );
  }

  /// Updates the current user's email in Supabase Auth.
  Future<void> updateEmail(String newEmail) {
    return _supabase.auth.updateUser(UserAttributes(email: newEmail));
  }
}

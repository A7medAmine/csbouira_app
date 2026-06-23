import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/favorites_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isSignup = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  bool _googleLoading = false;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _nameError;
  String? _generalError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
      _confirmError = null;
      _nameError = null;
      _generalError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final authService = ref.read(authServiceProvider);

      if (_isSignup) {
        final name = _fullNameController.text.trim();
        final response = await authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
          data: {'full_name': name},
        );

        if (response.user == null) {
          setState(() => _generalError = 'Signup failed. Please try again.');
          return;
        }

        final userId = response.user!.id;
        final supabase = ref.read(supabaseProvider);

        await supabase.from('profiles').insert({
          'id': userId,
          'full_name': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
        });

        if (await _promptMergeIfNeeded(userId)) {
          final mergeService = ref.read(guestMergeServiceProvider);
          await mergeService.mergeGuestDataIntoAccount(userId);
          ref.invalidate(favoritesListProvider);
        }
      } else {
        await authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );

        final user = authService.currentUser;
        if (user != null) {
          if (await _promptMergeIfNeeded(user.id)) {
            final mergeService = ref.read(guestMergeServiceProvider);
            await mergeService.mergeGuestDataIntoAccount(user.id);
            ref.invalidate(favoritesListProvider);
          }
        }
      }

      if (mounted) context.go('/');
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('already registered') || msg.contains('email')) {
        setState(() => _emailError = e.message);
      } else if (msg.contains('password')) {
        setState(() => _passwordError = e.message);
      } else {
        setState(() => _generalError = e.message);
      }
    } catch (e) {
      setState(() => _generalError = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    debugPrint('\x1B[31m[GoogleSignIn] Starting Google Sign-In flow...\x1B[0m');
    setState(() {
      _googleLoading = true;
      _generalError = null;
    });

    try {
      final googleSignIn = ref.read(googleSignInProvider);
      debugPrint('\x1B[31m[GoogleSignIn] Calling authenticate()...\x1B[0m');
      final account = await googleSignIn.authenticate();

      debugPrint('\x1B[31m[GoogleSignIn] authenticate() succeeded. Account email: ${account.email}\x1B[0m');
      final auth = account.authentication;
      debugPrint('\x1B[31m[GoogleSignIn] idToken present: ${auth.idToken != null} (length: ${auth.idToken?.length ?? 0})\x1B[0m');

      if (auth.idToken == null) {
        debugPrint('\x1B[31m[GoogleSignIn] FATAL: idToken is null after successful authenticate()\x1B[0m');
        setState(() {
          _generalError = 'Google Sign-In failed: ID token is null. Check Google Cloud Console configuration.';
          _googleLoading = false;
        });
        return;
      }

      final authService = ref.read(authServiceProvider);
      debugPrint('\x1B[31m[GoogleSignIn] Calling supabase.auth.signInWithIdToken()...\x1B[0m');
      final response = await authService.signInWithGoogle(
        idToken: auth.idToken!,
      );

      debugPrint('\x1B[31m[GoogleSignIn] signInWithIdToken response — user: ${response.user?.id}, session: ${response.session?.accessToken != null}\x1B[0m');

      final user = authService.currentUser;
      debugPrint('\x1B[31m[GoogleSignIn] currentUser after signIn: ${user?.id ?? 'null'}\x1B[0m');

      if (user != null) {
        debugPrint('\x1B[31m[GoogleSignIn] Upserting profile row...\x1B[0m');
        final supabase = ref.read(supabaseProvider);
        final meta = user.userMetadata;
        try {
          final googlePhotoUrl = account.photoUrl;
          debugPrint('\x1B[31m[GoogleSignIn] account.photoUrl: $googlePhotoUrl\x1B[0m');
          await supabase.from('profiles').upsert({
            'id': user.id,
            'full_name': meta?['full_name'] ?? account.displayName ?? user.email ?? 'User',
            'email': user.email ?? '',
            'avatar_url': meta?['avatar_url'] ?? meta?['picture'] ?? googlePhotoUrl,
          }, onConflict: 'id');
        } catch (e) {
          debugPrint('\x1B[31m[GoogleSignIn] Profile upsert failed: $e\x1B[0m');
        }

        if (await _promptMergeIfNeeded(user.id)) {
          debugPrint('\x1B[31m[GoogleSignIn] Merging guest data for user ${user.id}...\x1B[0m');
          final mergeService = ref.read(guestMergeServiceProvider);
          await mergeService.mergeGuestDataIntoAccount(user.id);
          ref.invalidate(favoritesListProvider);
          debugPrint('\x1B[31m[GoogleSignIn] Guest merge complete.\x1B[0m');
        }
      }

      debugPrint('\x1B[31m[GoogleSignIn] Navigating to home.\x1B[0m');
      if (mounted) context.go('/');
    } on GoogleSignInException catch (e) {
      debugPrint('\x1B[31m[GoogleSignIn] GoogleSignInException — code: ${e.code}, description: ${e.description}\x1B[0m');
      setState(() => _generalError = 'Google Sign-In failed\n${e.code}:\n${e.description}');
    } on AuthException catch (e) {
      debugPrint('\x1B[31m[GoogleSignIn] Supabase AuthException: ${e.message}\x1B[0m');
      setState(() => _generalError = 'Supabase rejected the login:\n${e.message}');
    } catch (e, stack) {
      debugPrint('\x1B[31m[GoogleSignIn] Unexpected error: $e\x1B[0m');
      debugPrint('\x1B[31m[GoogleSignIn] Stack: $stack\x1B[0m');
      setState(() => _generalError = 'Google Sign-In failed:\n$e');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<bool> _promptMergeIfNeeded(String userId) async {
    final localCache = ref.read(localFavoritesCacheProvider);
    final localFavorites = await localCache.getAll();
    if (localFavorites.isEmpty) return false;

    if (!mounted) return false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Row(
            children: [
              Icon(Icons.favorite, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Merge Favorites',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'We found ${localFavorites.length} item${localFavorites.length == 1 ? '' : 's'} saved in your local favorites. Would you like to add them to your account?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Skip',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'Merge',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (_passwordController.text != value) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _Header(theme: theme),
                  const SizedBox(height: AppSpacing.stackLg),
                  _AuthCard(
                    theme: theme,
                    isSignup: _isSignup,
                    onToggle: (v) => setState(() {
                      _isSignup = v;
                      _emailError = null;
                      _passwordError = null;
                      _confirmError = null;
                      _nameError = null;
                      _generalError = null;
                    }),
                    formKey: _formKey,
                    fullNameController: _fullNameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    obscurePassword: _obscurePassword,
                    obscureConfirm: _obscureConfirm,
                    onTogglePassword: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onToggleConfirm: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    emailError: _emailError,
                    passwordError: _passwordError,
                    confirmError: _confirmError,
                    nameError: _nameError,
                    generalError: _generalError,
                    loading: _loading,
                    googleLoading: _googleLoading,
                    validateEmail: _validateEmail,
                    validatePassword: _validatePassword,
                    validateConfirmPassword: _validateConfirmPassword,
                    onSubmit: _submit,
                    onGoogleSignIn: _signInWithGoogle,
                  ),
                  const SizedBox(height: AppSpacing.stackLg),
                  _Footer(theme: theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ThemeData theme;

  const _Header({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Image.asset(
            'images/csb-hero-logo_org.png',
            width: 64,
            height: 64,
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Text(
          'CS Bouira',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'The Academic Resource Hub for Computer Science',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _AuthCard extends StatelessWidget {
  final ThemeData theme;
  final bool isSignup;
  final ValueChanged<bool> onToggle;
  final GlobalKey<FormState> formKey;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;
  final String? nameError;
  final String? generalError;
  final bool loading;
  final bool googleLoading;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final String? Function(String?) validateConfirmPassword;
  final VoidCallback onSubmit;
  final VoidCallback onGoogleSignIn;

  const _AuthCard({
    required this.theme,
    required this.isSignup,
    required this.onToggle,
    required this.formKey,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    this.emailError,
    this.passwordError,
    this.confirmError,
    this.nameError,
    this.generalError,
    required this.loading,
    required this.googleLoading,
    required this.validateEmail,
    required this.validatePassword,
    required this.validateConfirmPassword,
    required this.onSubmit,
    required this.onGoogleSignIn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.stackLg),
      decoration: BoxDecoration(
        color: const Color(0xFF15151F).withAlpha(204),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: const Color(0xFF1A1A26)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SegmentedToggle(
              theme: theme,
              isSignup: isSignup,
              onToggle: onToggle,
            ),
            if (generalError != null) ...[
              const SizedBox(height: AppSpacing.stackSm),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withAlpha(26),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: theme.colorScheme.error.withAlpha(77),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: theme.colorScheme.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        generalError!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.stackMd),
            if (isSignup) ...[
              _InputField(
                theme: theme,
                label: 'Full Name',
                icon: Icons.person_outline,
                controller: fullNameController,
                errorText: nameError,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Full name is required' : null,
              ),
              const SizedBox(height: AppSpacing.stackMd),
            ],
            _InputField(
              theme: theme,
              label: 'Email Address',
              icon: Icons.mail_outline,
              controller: emailController,
              errorText: emailError,
              validator: (v) {
                final err = validateEmail(v);
                return err;
              },
            ),
            const SizedBox(height: AppSpacing.stackMd),
            _InputField(
              theme: theme,
              label: 'Password',
              icon: Icons.lock_outline,
              controller: passwordController,
              errorText: passwordError,
              obscure: obscurePassword,
              suffix: IconButton(
                icon: Icon(
                  obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: theme.colorScheme.outline,
                  size: 20,
                ),
                onPressed: onTogglePassword,
              ),
              validator: isSignup ? (v) {
                final err = validatePassword(v);
                return err;
              } : (v) =>
                  v == null || v.isEmpty ? 'Password is required' : null,
            ),
            if (!isSignup)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot password?',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            if (isSignup) ...[
              const SizedBox(height: AppSpacing.stackMd),
              _InputField(
                theme: theme,
                label: 'Confirm Password',
                icon: Icons.lock_outline,
                controller: confirmPasswordController,
                errorText: confirmError,
                obscure: obscureConfirm,
                suffix: IconButton(
                  icon: Icon(
                    obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: theme.colorScheme.outline,
                    size: 20,
                  ),
                  onPressed: onToggleConfirm,
                ),
                validator: isSignup ? validateConfirmPassword : null,
              ),
            ],
            const SizedBox(height: AppSpacing.stackMd),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  elevation: 0,
                  shadowColor: theme.colorScheme.primaryContainer.withAlpha(38),
                ),
                child: loading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      )
                    : Text(
                        isSignup ? 'Sign Up' : 'Log In',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            Row(
              children: [
                Expanded(
                    child: Divider(
                        color: theme.colorScheme.outlineVariant.withAlpha(77))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'OR',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline.withAlpha(153),
                    ),
                  ),
                ),
                Expanded(
                    child: Divider(
                        color: theme.colorScheme.outlineVariant.withAlpha(77))),
              ],
            ),
            const SizedBox(height: AppSpacing.stackMd),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: googleLoading ? null : onGoogleSignIn,
                icon: googleLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black54,
                        ),
                      )
                    : Image.asset('images/Google.png', width: 20, height: 20),
                label: Text(
                  'Continue with Google',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  disabledBackgroundColor: Colors.white70,
                  disabledForegroundColor: Colors.black38,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  final ThemeData theme;
  final bool isSignup;
  final ValueChanged<bool> onToggle;

  const _SegmentedToggle({
    required this.theme,
    required this.isSignup,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !isSignup
                      ? theme.colorScheme.primaryContainer.withAlpha(51)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md - 2),
                ),
                child: Text(
                  'Log In',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: !isSignup
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: !isSignup ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSignup
                      ? theme.colorScheme.primaryContainer.withAlpha(51)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md - 2),
                ),
                child: Text(
                  'Sign Up',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSignup
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSignup ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String? errorText;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _InputField({
    required this.theme,
    required this.label,
    required this.icon,
    required this.controller,
    this.errorText,
    this.obscure = false,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: theme.colorScheme.outline, size: 20),
            suffixIcon: suffix,
            errorText: errorText,
            hintText: null,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainer,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.stackMd,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withAlpha(77),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: theme.colorScheme.outlineVariant.withAlpha(77),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: theme.colorScheme.primaryContainer,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final ThemeData theme;

  const _Footer({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'By continuing you agree to our Terms of Service and Privacy Policy.',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withAlpha(153),
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user, size: 18, color: theme.colorScheme.outline.withAlpha(102)),
            const SizedBox(width: AppSpacing.stackSm),
            Icon(Icons.security, size: 18, color: theme.colorScheme.outline.withAlpha(102)),
            const SizedBox(width: AppSpacing.stackSm),
            Icon(Icons.school, size: 18, color: theme.colorScheme.outline.withAlpha(102)),
          ],
        ),
      ],
    );
  }
}

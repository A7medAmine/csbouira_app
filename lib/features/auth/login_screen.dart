import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isSignup = false;
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    if (_isSignup) {
      ref.read(authProvider.notifier).signup(email, password);
    } else {
      ref.read(authProvider.notifier).login(email, password);
    }
    if (mounted) context.pop();
  }

  void _continueAsGuest() {
    ref.read(authProvider.notifier).continueAsGuest();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  // ── Logo Header ─────────────────────────────────
                  const SizedBox(height: 32),
                  _LogoHeader(theme: theme),
                  const SizedBox(height: AppSpacing.stackLg),

                  // ── Auth Card ───────────────────────────────────
                  _AuthCard(
                    theme: theme,
                    isSignup: _isSignup,
                    obscurePassword: _obscurePassword,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onToggle: () => setState(() => _isSignup = !_isSignup),
                    onToggleVisibility: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    onSubmit: _submit,
                    onGuest: _continueAsGuest,
                  ),

                  const SizedBox(height: AppSpacing.stackLg),

                  // ── Footer ──────────────────────────────────────
                  _AuthFooter(theme: theme),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logo Header ────────────────────────────────────────────────────────────

class _LogoHeader extends StatelessWidget {
  final ThemeData theme;

  const _LogoHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(77),
                blurRadius: 24,
              ),
            ],
          ),
          child: Icon(
            Icons.terminal,
            color: theme.colorScheme.onPrimaryContainer,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Text(
          'CS Bouira',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.stackSm),
        Text(
          'The Academic Resource Hub for Computer Science',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withAlpha(204),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Auth Card ──────────────────────────────────────────────────────────────

class _AuthCard extends StatelessWidget {
  final ThemeData theme;
  final bool isSignup;
  final bool obscurePassword;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onToggle;
  final VoidCallback onToggleVisibility;
  final VoidCallback onSubmit;
  final VoidCallback onGuest;

  const _AuthCard({
    required this.theme,
    required this.isSignup,
    required this.obscurePassword,
    required this.emailController,
    required this.passwordController,
    required this.onToggle,
    required this.onToggleVisibility,
    required this.onSubmit,
    required this.onGuest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackLg),
      decoration: BoxDecoration(
        color: const Color(0xFF15151F).withAlpha(204),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: const Color(0xFF1A1A26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(102),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Segmented Toggle ─────────────────────────────────---
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isSignup ? onToggle : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !isSignup
                            ? theme.colorScheme.primaryContainer.withAlpha(51)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        'Log In',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: !isSignup
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: !isSignup ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: !isSignup ? onToggle : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSignup
                            ? theme.colorScheme.primaryContainer.withAlpha(51)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        'Sign Up',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isSignup
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: isSignup ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.stackLg),

          // ── Email Field ─────────────────────────────────────────
          _EmailField(
            theme: theme,
            controller: emailController,
          ),

          const SizedBox(height: AppSpacing.stackMd),

          // ── Password Field ──────────────────────────────────────
          _PasswordField(
            theme: theme,
            controller: passwordController,
            obscurePassword: obscurePassword,
            onToggleVisibility: onToggleVisibility,
          ),

          const SizedBox(height: AppSpacing.stackSm),

          // ── Action Buttons ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.stackSm),
            child: Column(
              children: [
                GestureDetector(
                  onTap: onSubmit,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primaryContainer.withAlpha(38),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Text(
                      isSignup ? 'Sign Up' : 'Log In',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.stackMd),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: theme.colorScheme.outlineVariant.withAlpha(77),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackMd),
                      child: Text(
                        'OR',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.outline.withAlpha(153),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: theme.colorScheme.outlineVariant.withAlpha(77),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                GestureDetector(
                  onTap: onGuest,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withAlpha(77),
                      ),
                    ),
                    child: Text(
                      'Continue as Guest',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Email Field ────────────────────────────────────────────────────────────

class _EmailField extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController controller;

  const _EmailField({required this.theme, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            'Email Address',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(77),
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.mail_outline,
                color: theme.colorScheme.outline,
                size: 20,
              ),
              hintText: 'student@univ-bouira.dz',
              hintStyle: TextStyle(
                color: theme.colorScheme.outline.withAlpha(128),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            cursorColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

// ── Password Field ─────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final ThemeData theme;
  final TextEditingController controller;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;

  const _PasswordField({
    required this.theme,
    required this.controller,
    required this.obscurePassword,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Forgot?',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(77),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscurePassword,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.lock_outline,
                color: theme.colorScheme.outline,
                size: 20,
              ),
              suffixIcon: GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: theme.colorScheme.outline,
                  size: 20,
                ),
              ),
              hintText: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
              hintStyle: TextStyle(
                color: theme.colorScheme.outline.withAlpha(128),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
            ),
            cursorColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

// ── Auth Footer ────────────────────────────────────────────────────────────

class _AuthFooter extends StatelessWidget {
  final ThemeData theme;

  const _AuthFooter({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'By continuing you agree to our ',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withAlpha(153),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {},
              child: Text(
                'Terms of Service',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primaryFixedDim,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' and ',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(153),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Privacy Policy',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primaryFixedDim,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              '.',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withAlpha(153),
              ),
            ),
          ],
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

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/providers/auth_providers.dart';

enum _ResetStep { email, otp, newPassword }

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  _ResetStep _step = _ResetStep.email;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _error;
  String _email = '';
  bool _hasMinChars = false;
  bool _hasNumber = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Enter your email address');
      return;
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final profile = await supabase
          .from('profiles')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (profile == null) {
        if (mounted) {
          setState(() => _error = 'This email is not registered.');
        }
        return;
      }

      final authService = ref.read(authServiceProvider);
      await authService.sendPasswordResetOtp(email);

      setState(() {
        _email = email;
        _step = _ResetStep.otp;
        _error = null;
      });
      _otpFocusNodes[0].requestFocus();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _otpCode =>
      _otpControllers.map((c) => c.text).join();

  Future<void> _verifyOtp() async {
    final code = _otpCode;
    if (code.length < 6) {
      setState(() => _error = 'Enter the full 6-digit code');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.verifyRecoveryOtp(email: _email, token: code);

      setState(() {
        _step = _ResetStep.newPassword;
      });
    } on AuthException {
      if (mounted) {
        setState(
            () => _error = 'Invalid code. Please check and try again.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onOtpChanged(String value, int index) {
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length > 1) {
      for (var i = 0; i < 6; i++) {
        _otpControllers[i].text = i < digitsOnly.length ? digitsOnly[i] : '';
      }
      final last = (digitsOnly.length < 6 ? digitsOnly.length : 6) - 1;
      _otpFocusNodes[last].unfocus();
      return;
    }
    if (digitsOnly.isEmpty) {
      if (index > 0) {
        _otpFocusNodes[index - 1].requestFocus();
      }
      return;
    }
    if (index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
  }

  Future<void> _pasteOtp() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null) return;
    final digitsOnly = data!.text!.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) return;
    for (var i = 0; i < 6; i++) {
      _otpControllers[i].text = i < digitsOnly.length ? digitsOnly[i] : '';
    }
    final last = (digitsOnly.length < 6 ? digitsOnly.length : 6) - 1;
    _otpFocusNodes[last].unfocus();
  }

  void _onPasswordChanged(String value) {
    setState(() {
      _hasMinChars = value.length >= 8;
      _hasNumber = RegExp(r'\d').hasMatch(value);
    });
  }

  Future<void> _updatePassword() async {
    final password = _passwordController.text;
    if (!_hasMinChars) {
      setState(() => _error = 'Password must be at least 8 characters');
      return;
    }
    if (!_hasNumber) {
      setState(() => _error = 'Password must contain a number');
      return;
    }
    if (password != _confirmPasswordController.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.updatePassword(password);
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _appBarTitle() {
    switch (_step) {
      case _ResetStep.email:
        return 'Reset Password';
      case _ResetStep.otp:
        return 'Verification';
      case _ResetStep.newPassword:
        return 'New Password';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () {
            if (_step == _ResetStep.email) {
              context.pop();
            } else {
              setState(() {
                _step = _ResetStep.email;
                _error = null;
              });
            }
          },
        ),
        title: Text(
          _appBarTitle(),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative blurred circles (Stitch design)
            Positioned(
              top: -MediaQuery.of(context).size.height * 0.1,
              right: -MediaQuery.of(context).size.width * 0.3,
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(128),
                ),
              ),
            ),
            Positioned(
              bottom: -MediaQuery.of(context).size.height * 0.1,
              left: -MediaQuery.of(context).size.width * 0.3,
              child: Container(
                width: 256,
                height: 256,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(26),
                  borderRadius: BorderRadius.circular(128),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: _step == _ResetStep.otp
                      ? _buildOtpLayout(theme)
                      : _step == _ResetStep.newPassword
                          ? _buildNewPasswordLayout(theme)
                          : _GlassCard(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _StepHeader(
                                  step: _step,
                                  email: _email,
                                  theme: theme),
                              const SizedBox(height: AppSpacing.stackLg),
                              _buildStepContent(theme),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpLayout(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated icon in glass card (Stitch design)
        SizedBox(
          height: 192,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse ring
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, child) => Container(
                  width: 192 + _pulseController.value * 20,
                  height: 192 + _pulseController.value * 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary
                          .withAlpha((0.2 * (1 - _pulseController.value) * 255)
                              .round()),
                      width: 2,
                    ),
                  ),
                ),
              ),
              // Icon glass card
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl * 1.5),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: const Color(0xFF15151F).withAlpha(204),
                      borderRadius:
                          BorderRadius.circular(AppRadius.xl * 1.5),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withAlpha(77),
                      ),
                    ),
                    child: Icon(
                      Icons.mark_email_read,
                      color: theme.colorScheme.primary,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.stackLg),
        // Title
        Text(
          'Verify your email',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        // Subtitle with email
        Text.rich(
          TextSpan(
            text: 'Enter the 6-digit code sent to ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            children: [
              TextSpan(
                text: _email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.stackLg),
        // OTP input grid (Stitch design: individual boxes)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index < 5 ? 8 : 0,
              ),
              child: SizedBox(
                width: 48,
                height: 56,
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainer,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color:
                            theme.colorScheme.outlineVariant.withAlpha(77),
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color:
                            theme.colorScheme.outlineVariant.withAlpha(77),
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (v) => _onOtpChanged(v, index),
                  onTapOutside: (_) => _otpFocusNodes[index].unfocus(),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.stackSm),
        // Paste button
        Center(
          child: TextButton.icon(
            onPressed: _pasteOtp,
            icon: Icon(Icons.content_paste, size: 16),
            label: Text(
              'Paste code',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.stackSm),
        // Error message
        if (_error != null) ...[
          _errorBanner(theme),
          const SizedBox(height: AppSpacing.stackMd),
        ],
        // Resend
        TextButton(
          onPressed: _loading ? null : _sendOtp,
          child: Text(
            'Resend Code',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.stackLg),
        // Verify Code button (Stitch design: specific blue + icon)
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _loading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A6FFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              shadowColor: const Color(0xFF1A6FFF).withAlpha(38),
              elevation: 8,
            ),
            child: _loading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Verify Code',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    if (_error != null) {
      return Column(
        children: [
          _errorBanner(theme),
          const SizedBox(height: AppSpacing.stackMd),
          _stepWidget(theme),
        ],
      );
    }
    return _stepWidget(theme);
  }

  Widget _errorBanner(ThemeData theme) {
    return Container(
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
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepWidget(ThemeData theme) {
    switch (_step) {
      case _ResetStep.email:
        return _buildEmailStep(theme);
      case _ResetStep.otp:
        return const SizedBox.shrink();
      case _ResetStep.newPassword:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmailStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Email Address',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.mail_outline,
                    color: theme.colorScheme.outline, size: 20),
                hintText: 'student@univ-bouira.dz',
                hintStyle: TextStyle(
                  color: theme.colorScheme.outline.withAlpha(128),
                ),
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
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outlineVariant.withAlpha(77),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primaryContainer,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackMd),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _sendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: _loading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  )
                : Text(
                    'Send Code',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPasswordLayout(ThemeData theme) {
    return Column(
      children: [
        // Headline
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Create New Password',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Your new password must be different from previous used passwords.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.stackLg),
        // Glass card form
        _GlassCard(
          child: Column(
            children: [
              // New Password
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'New Password',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline,
                          color: theme.colorScheme.outline, size: 20),
                      hintText: 'Enter new password',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.outline.withAlpha(128),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: theme.colorScheme.outline,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.stackMd,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant
                              .withAlpha(77),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant
                              .withAlpha(77),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primaryContainer,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: _onPasswordChanged,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.stackMd),
              // Confirm Password
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'Confirm New Password',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline,
                          color: theme.colorScheme.outline, size: 20),
                      hintText: 'Repeat new password',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.outline.withAlpha(128),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: theme.colorScheme.outline,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.stackMd,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant
                              .withAlpha(77),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant
                              .withAlpha(77),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primaryContainer,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.stackMd),
              // Password requirements
              _RequirementRow(
                theme: theme,
                met: _hasMinChars,
                label: 'At least 8 characters',
              ),
              const SizedBox(height: 12),
              _RequirementRow(
                theme: theme,
                met: _hasNumber,
                label: 'Contains a number',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        // Error
        if (_error != null) ...[
          _errorBanner(theme),
          const SizedBox(height: AppSpacing.stackMd),
        ],
        // Update Password button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _loading ? null : _updatePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A6FFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              shadowColor: const Color(0xFF1A6FFF).withAlpha(38),
              elevation: 8,
            ),
            child: _loading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Update Password',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.stackLg),
        // lock_reset illustration
        SizedBox(
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.primaryContainer.withAlpha(51),
                    borderRadius: BorderRadius.circular(80),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(80),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF15151F).withAlpha(204),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Icon(
                      Icons.lock_reset,
                      color: theme.colorScheme.primary.withAlpha(153),
                      size: 56,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shared components matching Stitch design ────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.stackLg),
          decoration: BoxDecoration(
            color: const Color(0xFF15151F).withAlpha(204),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: const Color(0xFF1A1A26)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final ThemeData theme;
  final bool met;
  final String label;

  const _RequirementRow({
    required this.theme,
    required this.met,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.circle_outlined,
          size: 18,
          color: met
              ? const Color(0xFF4CAF50)
              : theme.colorScheme.onSurfaceVariant.withAlpha(128),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: met
                ? const Color(0xFF4CAF50)
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  final _ResetStep step;
  final String email;
  final ThemeData theme;

  const _StepHeader({
    required this.step,
    required this.email,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Icon(
            step == _ResetStep.newPassword
                ? Icons.lock_outline
                : Icons.lock_reset,
            color: theme.colorScheme.onPrimaryContainer,
            size: 32,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          step == _ResetStep.email
              ? 'Forgot Password?'
              : 'New Password',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          step == _ResetStep.email
              ? 'Enter your email and we\'ll send you a 6-digit code.'
              : 'Choose a new password for your account.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

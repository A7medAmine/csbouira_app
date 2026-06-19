import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/providers/auth_providers.dart';
import '../../shared/widgets/avatar_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return _GuestProfileShell(theme: theme, ref: ref);
    }

    return _LoggedInProfileShell(theme: theme, ref: ref, user: user);
  }
}

// ── Shared widgets ──────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final ThemeData theme;

  const _StatsGrid({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GlassCard(
            child: Column(
              children: [
                Text(
                  '0',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'UPLOADS',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.stackMd),
        Expanded(
          child: _GlassCard(
            child: Column(
              children: [
                Text(
                  '0',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'FAVORITES',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: const Color(0x0D15151F),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: const Color(0xFF1A1A26).withAlpha(128),
        ),
      ),
      child: child,
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.theme,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.stackMd),
        decoration: BoxDecoration(
          color: const Color(0x0D15151F),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: const Color(0xFF1A1A26).withAlpha(128),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.stackMd),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.outline,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Guest profile ───────────────────────────────────────────────────────────

class _GuestProfileShell extends ConsumerStatefulWidget {
  final ThemeData theme;
  final WidgetRef ref;

  const _GuestProfileShell({required this.theme, required this.ref});

  @override
  ConsumerState<_GuestProfileShell> createState() =>
      _GuestProfileShellState();
}

class _GuestProfileShellState extends ConsumerState<_GuestProfileShell> {
  String _name = '';
  String _email = '';
  String? _avatarBase64;

  @override
  void initState() {
    super.initState();
    _loadGuestProfile();
  }

  Future<void> _loadGuestProfile() async {
    final cache = ref.read(localProfileCacheProvider);
    final name = await cache.getName();
    final email = await cache.getEmail();
    final avatar = await cache.getAvatarBase64();
    if (mounted) {
      setState(() {
        _name = name;
        _email = email;
        _avatarBase64 = avatar;
      });
    }
  }

  Future<void> _editAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 256,
      maxHeight: 256,
    );
    if (file == null) return;
    final bytes = await File(file.path).readAsBytes();
    final b64 = base64Encode(bytes);
    final cache = ref.read(localProfileCacheProvider);
    await cache.setAvatarBase64(b64);
    if (mounted) {
      setState(() => _avatarBase64 = b64);
      ref.invalidate(guestProfileProvider);
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _name);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Edit Name',
          style: widget.theme.textTheme.headlineMedium?.copyWith(
            color: widget.theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: widget.theme.textTheme.bodyMedium?.copyWith(
            color: widget.theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(
              color: widget.theme.colorScheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: widget.theme.colorScheme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: widget.theme.textTheme.labelMedium?.copyWith(
                color: widget.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(
              'Save',
              style: widget.theme.textTheme.labelMedium?.copyWith(
                color: widget.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final cache = ref.read(localProfileCacheProvider);
      await cache.setName(result);
      if (mounted) {
        setState(() => _name = result);
        ref.invalidate(guestProfileProvider);
      }
    }
  }

  Future<void> _editEmail() async {
    final controller = TextEditingController(text: _email);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: widget.theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Edit Email',
          style: widget.theme.textTheme.headlineMedium?.copyWith(
            color: widget.theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          style: widget.theme.textTheme.bodyMedium?.copyWith(
            color: widget.theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: TextStyle(
              color: widget.theme.colorScheme.onSurfaceVariant,
            ),
            filled: true,
            fillColor: widget.theme.colorScheme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: widget.theme.textTheme.labelMedium?.copyWith(
                color: widget.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(
              'Save',
              style: widget.theme.textTheme.labelMedium?.copyWith(
                color: widget.theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final cache = ref.read(localProfileCacheProvider);
      await cache.setEmail(result);
      if (mounted) {
        setState(() => _email = result);
        ref.invalidate(guestProfileProvider);
      }
    }
  }

  String _initials(String name) {
    if (name.isEmpty) return 'G';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Profile',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginMobile,
              24,
              AppSpacing.marginMobile,
              32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  AvatarWidget(
                    size: 96,
                    initials: _initials(_name),
                    avatarBase64: _avatarBase64,
                    onEdit: _editAvatar,
                    showEditButton: true,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(38),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  GestureDetector(
                    onTap: _editName,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _name.isNotEmpty ? _name : 'Guest',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.edit,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _editEmail,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _email.isNotEmpty ? _email : 'Add your email',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _email.isNotEmpty
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSurfaceVariant
                                    .withAlpha(153),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit,
                          color: theme.colorScheme.primary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withAlpha(77),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'GUEST',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackLg),
                  _StatsGrid(theme: theme),
                  const SizedBox(height: AppSpacing.stackLg),
                  _SettingsRow(
                    theme: theme,
                    icon: Icons.upload_file,
                    label: 'My Uploads',
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  _SettingsRow(
                    theme: theme,
                    icon: Icons.favorite,
                    label: 'Favorites',
                    onTap: () => context.push('/favorites'),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  _SettingsRow(
                    theme: theme,
                    icon: Icons.info_outline,
                    label: 'About CS Bouira',
                    onTap: () => context.push('/about'),
                  ),
                  const SizedBox(height: AppSpacing.stackLg),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.push('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor:
                            theme.colorScheme.onPrimaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'Log In or Sign Up',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Logged-in profile ───────────────────────────────────────────────────────

class _LoggedInProfileShell extends ConsumerWidget {
  final ThemeData theme;
  final WidgetRef ref;
  final User user;

  const _LoggedInProfileShell({
    required this.theme,
    required this.ref,
    required this.user,
  });

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(user.id));
    final profile = profileAsync.asData?.value;

    final meta = user.userMetadata;
    final fullName = (profile?['full_name'] as String?) ??
        meta?['full_name'] as String? ??
        meta?['name'] as String? ??
        user.email ??
        'User';
    final email = (profile?['email'] as String?) ?? user.email ?? '';
    final avatarUrl = (profile?['avatar_url'] as String?) ??
        meta?['avatar_url'] as String? ??
        meta?['picture'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Profile',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginMobile,
              24,
              AppSpacing.marginMobile,
              32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  AvatarWidget(
                    size: 96,
                    initials: _initials(fullName),
                    avatarUrl: avatarUrl,
                    onEdit: () {},
                    showEditButton: false,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withAlpha(38),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.stackMd),
                  Text(
                    fullName,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.stackLg),
                  _StatsGrid(theme: theme),
                  const SizedBox(height: AppSpacing.stackLg),
                  _SettingsRow(
                    theme: theme,
                    icon: Icons.upload_file,
                    label: 'My Uploads',
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  _SettingsRow(
                    theme: theme,
                    icon: Icons.favorite,
                    label: 'Favorites',
                    onTap: () => context.push('/favorites'),
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                  _SettingsRow(
                    theme: theme,
                    icon: Icons.info_outline,
                    label: 'About CS Bouira',
                    onTap: () => context.push('/about'),
                  ),
                  const SizedBox(height: AppSpacing.stackLg),
                  _LogOutButton(theme: theme, ref: ref),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  final ThemeData theme;
  final WidgetRef ref;

  const _LogOutButton({required this.theme, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: theme.colorScheme.surfaceContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            title: Text(
              'Log Out',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to log out?',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  'Log Out',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          final authService = ref.read(authServiceProvider);
          await authService.signOut();
          try {
            await GoogleSignIn.instance.signOut();
          } catch (_) {}
          if (context.mounted) {
            context.go('/');
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.stackMd),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: theme.colorScheme.error.withAlpha(77),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout,
              color: theme.colorScheme.error,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.stackSm),
            Text(
              'Log Out',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

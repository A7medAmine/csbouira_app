import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/providers/local_profile_provider.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/upload_fab.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final profile = ref.watch(localProfileProvider);

    if (!auth.isLoggedIn) {
      return _buildUnauthenticated(context, theme, ref);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(
                left: AppSpacing.marginMobile,
                right: AppSpacing.marginMobile,
                top: 0,
                bottom: 140,
              ),
              children: [
                const SizedBox(height: 8),

                _AppBar(theme: theme),
                const SizedBox(height: 16),

                _ProfileHeader(profile: profile, theme: theme, ref: ref),
                const SizedBox(height: AppSpacing.stackLg),

                Row(
                  children: [
                    Expanded(
                      child: _StatCard(value: '12', label: 'Uploads', theme: theme),
                    ),
                    const SizedBox(width: AppSpacing.stackMd),
                    Expanded(
                      child: _StatCard(value: '0', label: 'Favorites', theme: theme),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.stackLg),
                _SettingsSection(theme: theme),
                const SizedBox(height: AppSpacing.stackLg),
                _DangerZone(theme: theme, ref: ref),
              ],
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomNav(currentLocation: '/profile'),
            ),
            const UploadFab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUnauthenticated(BuildContext context, ThemeData theme, WidgetRef ref) {
    final profile = ref.watch(localProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(
                left: AppSpacing.marginMobile,
                right: AppSpacing.marginMobile,
                top: 0,
                bottom: 140,
              ),
              children: [
                const SizedBox(height: 8),
                _AppBar(theme: theme),

                // ── Login Prompt ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline,
                          size: 40,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.stackMd),
                      Text(
                        'Sign in to your account',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.stackSm),
                      Text(
                        'Access your uploads, favorites, and more.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.stackLg),
                      GestureDetector(
                        onTap: () => context.push('/login'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primaryContainer.withAlpha(51),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Text(
                            'Log In',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      // ── Local profile info if exists ────────────
                      if (profile.name != 'Guest' || profile.email.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.stackLg),
                        Divider(color: theme.colorScheme.outlineVariant.withAlpha(51)),
                        const SizedBox(height: AppSpacing.stackMd),
                        Text(
                          'Local Profile',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.stackSm),
                        _LocalProfilePreview(profile: profile, theme: theme),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomNav(currentLocation: '/profile'),
            ),
            const UploadFab(),
          ],
        ),
      ),
    );
  }
}

// ── AppBar ─────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final ThemeData theme;

  const _AppBar({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const _IconButton(icon: Icons.arrow_back),
          ),
          Text(
            'Profile',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const _IconButton(icon: Icons.more_vert),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  const _IconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Icon(icon, color: theme.colorScheme.primary, size: 24),
    );
  }
}

// ── Profile Header ─────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final LocalProfile profile;
  final ThemeData theme;
  final WidgetRef ref;

  const _ProfileHeader({
    required this.profile,
    required this.theme,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Avatar(profile: profile, theme: theme, ref: ref),
        const SizedBox(height: AppSpacing.stackMd),
        GestureDetector(
          onTap: () => _editName(context, ref),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.name,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(width: AppSpacing.stackSm),
              Icon(Icons.edit, size: 18, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _editEmail(context, ref),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                profile.email,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (profile.email.isEmpty)
                Text(
                  'Add email',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              const SizedBox(width: AppSpacing.stackSm),
              Icon(Icons.edit, size: 16, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }

  void _editName(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: ref.read(localProfileProvider).name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1d1e2e),
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(localProfileProvider.notifier).updateName(controller.text.trim());
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editEmail(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: ref.read(localProfileProvider).email);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1d1e2e),
        title: const Text('Edit Email'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter your email',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(localProfileProvider.notifier).updateEmail(controller.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final LocalProfile profile;
  final ThemeData theme;
  final WidgetRef ref;

  const _Avatar({
    required this.profile,
    required this.theme,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.stackSm),
      child: GestureDetector(
        onTap: () => _showAvatarPicker(context, ref),
        child: Stack(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: profile.avatarBytes != null
                    ? Colors.transparent
                    : theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primaryContainer.withAlpha(77),
                    blurRadius: 20,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: profile.avatarBytes != null
                  ? ClipOval(
                      child: Image.memory(
                        profile.avatarBytes!,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        profile.initials,
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
            ),
            Positioned(
              bottom: 4,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.edit,
                  size: 18,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1d1e2e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white70),
                title: const Text('Take Photo', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(localProfileProvider.notifier).pickAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white70),
                title: const Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(localProfileProvider.notifier).pickAvatar(ImageSource.gallery);
                },
              ),
              if (profile.avatarBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref.read(localProfileProvider.notifier).removeAvatar();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Local Profile Preview (for unauthenticated) ─────────────────────────────

class _LocalProfilePreview extends StatelessWidget {
  final LocalProfile profile;
  final ThemeData theme;

  const _LocalProfilePreview({required this.profile, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: const Color(0xFF15151F).withAlpha(179),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFF1A1A26).withAlpha(128)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                profile.initials,
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.stackMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (profile.email.isNotEmpty)
                  Text(
                    profile.email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

// ── Stat Card ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final ThemeData theme;

  const _StatCard({required this.value, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151F).withAlpha(179),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: const Color(0xFF1A1A26).withAlpha(128)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Section ───────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  final ThemeData theme;
  const _SettingsSection({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingsRow(
          icon: Icons.upload_file,
          label: 'My Uploads',
          onTap: () {},
          theme: theme,
        ),
        const SizedBox(height: AppSpacing.stackSm),
        _SettingsRow(
          icon: Icons.favorite,
          label: 'Favorites',
          onTap: () => context.push('/favorites'),
          theme: theme,
        ),
        const SizedBox(height: AppSpacing.stackSm),
        _SettingsRow(
          icon: Icons.info_outline,
          label: 'About CS Bouira',
          onTap: () {},
          theme: theme,
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final ThemeData theme;

  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.stackMd, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF15151F).withAlpha(179),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: const Color(0xFF1A1A26).withAlpha(128)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Center(
                child: Icon(icon, color: theme.colorScheme.primary, size: 24),
              ),
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
            Icon(Icons.chevron_right, color: theme.colorScheme.outline),
          ],
        ),
      ),
    );
  }
}

// ── Danger Zone ────────────────────────────────────────────────────────────

class _DangerZone extends StatelessWidget {
  final ThemeData theme;
  final WidgetRef ref;

  const _DangerZone({required this.theme, required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ref.read(authProvider.notifier).logout();
        context.pushReplacement('/login');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: theme.colorScheme.error.withAlpha(77)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: theme.colorScheme.error, size: 24),
            const SizedBox(width: AppSpacing.stackSm),
            Text(
              'Log Out',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

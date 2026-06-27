import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/update_service.dart';
import '../home/widgets/update_dialog.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  bool _checking = false;

  Future<void> _checkUpdate() async {
    setState(() => _checking = true);
    try {
      final service = UpdateService();
      // Manual checks bypass throttle
      final info = await service.checkForUpdate();
      if (!mounted) return;
      if (info != null) {
        showUpdateDialog(context, info);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.aboutNoUpdate),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.updateDialogError),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _checking = false);
      }
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.aboutTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.stackMd),
                Center(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        child: Image.asset(
                          'images/csb-hero-logo_org.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.stackMd),
                      Text(
                        'CS Bouira',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          final version = snapshot.data?.version ?? '1.0.0';
                          return Text(
                            '${AppLocalizations.of(context)!.aboutVersion} $version',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _checking
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.of(context)!.aboutCheckingUpdate,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            )
                          : TextButton.icon(
                              onPressed: _checkUpdate,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: Text(
                                AppLocalizations.of(context)!.aboutCheckUpdate,
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.stackLg),
                _SectionCard(
                  theme: theme,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.aboutDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(230),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                _SectionCard(
                  theme: theme,
                  title: AppLocalizations.of(context)!.aboutFeatures,
                  children: [
                    _FeatureRow(theme: theme, text: AppLocalizations.of(context)!.aboutFeatureBrowseResources),
                    _FeatureRow(theme: theme, text: AppLocalizations.of(context)!.aboutFeatureSearch),
                    _FeatureRow(theme: theme, text: AppLocalizations.of(context)!.aboutFeatureDownload),
                    _FeatureRow(theme: theme, text: AppLocalizations.of(context)!.aboutFeatureUpload),
                    _FeatureRow(theme: theme, text: AppLocalizations.of(context)!.aboutFeatureBookmarks),
                    _FeatureRow(theme: theme, text: AppLocalizations.of(context)!.aboutFeatureQrCode),
                    _FeatureRow(theme: theme, text: AppLocalizations.of(context)!.aboutFeatureOffline),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                _SectionCard(
                  theme: theme,
                  title: AppLocalizations.of(context)!.aboutCreator,
                  children: [
                    GestureDetector(
                      onTap: () => _launchUrl('https://github.com/zedsalim'),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CachedNetworkImage(
                              imageUrl: 'https://github.com/zedsalim.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 48,
                                height: 48,
                                color: theme.colorScheme.surfaceContainer,
                                child: Icon(Icons.person, color: theme.colorScheme.primary),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 48,
                                height: 48,
                                color: theme.colorScheme.surfaceContainer,
                                child: Icon(Icons.person, color: theme.colorScheme.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.stackMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Salim Zed',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppLocalizations.of(context)!.aboutCreatorSalimZedDesc,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    GestureDetector(
                      onTap: () => _launchUrl('https://github.com/A7medAmine'),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: CachedNetworkImage(
                              imageUrl: 'https://github.com/A7medAmine.png',
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(
                                width: 48,
                                height: 48,
                                color: theme.colorScheme.surfaceContainer,
                                child: Icon(Icons.person, color: theme.colorScheme.primary),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                width: 48,
                                height: 48,
                                color: theme.colorScheme.surfaceContainer,
                                child: Icon(Icons.person, color: theme.colorScheme.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.stackMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ahmed Amine',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppLocalizations.of(context)!.aboutCreatorAhmedAmineDesc,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                _SectionCard(
                  theme: theme,
                  title: AppLocalizations.of(context)!.aboutSourceCode,
                  children: [
                    GestureDetector(
                      onTap: () => _launchUrl('https://github.com/A7medAmine/csbouira_app'),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: FaIcon(FontAwesomeIcons.github, color: theme.colorScheme.primary, size: 24),
                          ),
                          const SizedBox(width: AppSpacing.stackMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.aboutSourceCodeGithub,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'github.com/A7medAmine/csbouira_app',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: theme.colorScheme.outline),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _launchUrl('https://github.com/A7medAmine/csbouira_app/issues/new'),
                        icon: FaIcon(FontAwesomeIcons.bug, size: 16),
                        label: Text(AppLocalizations.of(context)!.aboutSourceCodeReportIssue),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary.withAlpha(77)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                _SectionCard(
                  theme: theme,
                  title: AppLocalizations.of(context)!.aboutContact,
                  children: [
                    GestureDetector(
                      onTap: () => _launchUrl('mailto:support@csbouira.dz'),
                      child: _FeatureRow(theme: theme, icon: Icons.mail_outline, text: 'support@csbouira.dz'),
                    ),
                    const SizedBox(height: AppSpacing.stackSm),
                    GestureDetector(
                      onTap: () => _launchUrl('https://csbouira.xyz/'),
                      child: _FeatureRow(theme: theme, icon: Icons.language, text: 'csbouira.xyz'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                _SectionCard(
                  theme: theme,
                  title: AppLocalizations.of(context)!.aboutLicense,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.aboutLicenseText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(179),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackLg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }
}

class _SectionCard extends StatelessWidget {
  final ThemeData theme;
  final String? title;
  final List<Widget> children;

  const _SectionCard({required this.theme, this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.stackMd),
      decoration: BoxDecoration(
        color: const Color(0xFF15151F).withAlpha(179),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: const Color(0xFF1A1A26).withAlpha(128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final ThemeData theme;
  final IconData? icon;
  final String text;

  const _FeatureRow({required this.theme, this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon ?? Icons.check_circle_outline,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.stackSm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(204),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

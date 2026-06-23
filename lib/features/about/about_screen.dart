import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'About',
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
                      Text(
                        'v1.0.0',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
                      'CS Bouira is the ultimate academic resource hub for Computer Science students at the University of Bouira. Access a comprehensive collection of course materials, lecture notes, exercises, exams, and study resources organized by year, semester, and module — all in one place.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(230),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                _SectionCard(
                  theme: theme,
                  title: 'Features',
                  children: [
                    _FeatureRow(theme: theme, text: 'Browse resources by year, semester, and module'),
                    _FeatureRow(theme: theme, text: 'Search across all course materials'),
                    _FeatureRow(theme: theme, text: 'Download and preview PDFs, documents, and images'),
                    _FeatureRow(theme: theme, text: 'Upload and share academic resources'),
                    _FeatureRow(theme: theme, text: 'Bookmark favorites for quick access'),
                    _FeatureRow(theme: theme, text: 'QR code scanner for instant resource links'),
                    _FeatureRow(theme: theme, text: 'Offline access to downloaded materials'),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                _SectionCard(
                  theme: theme,
                  title: 'Creator',
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
                                  'Original creator of CS Bouira website & API',
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
                                  'Android app developer',
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
                  title: 'Source Code',
                  children: [
                    GestureDetector(
                      onTap: () => _launchUrl('https://github.com/A7medAmine/csbouira_app'),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainer,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(Icons.code, color: theme.colorScheme.primary, size: 24),
                          ),
                          const SizedBox(width: AppSpacing.stackMd),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GitHub Repository',
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
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                _SectionCard(
                  theme: theme,
                  title: 'Contact',
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
                  title: 'License',
                  children: [
                    Text(
                      'This application is released under the MIT License.\n\nCopyright © 2026 Ahmed Amine. All rights reserved.\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files, to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software.',
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

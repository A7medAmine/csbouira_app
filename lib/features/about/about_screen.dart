import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primaryContainer.withAlpha(77),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: Icon(Icons.terminal, color: theme.colorScheme.onPrimaryContainer, size: 48),
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
                      'The Academic Resource Hub for Computer Science students at the University of Bouira.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(230),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.stackMd),
                    Text(
                      'CS Bouira provides a centralized platform for accessing course materials, lecture notes, exercises, exams, and other academic resources across all years and semesters of the Computer Science program.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(204),
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
                    _FeatureRow(theme: theme, text: 'Download and preview documents'),
                    _FeatureRow(theme: theme, text: 'Upload and share resources'),
                    _FeatureRow(theme: theme, text: 'Bookmark favorites for quick access'),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackMd),
                _SectionCard(
                  theme: theme,
                  title: 'Contact',
                  children: [
                    _FeatureRow(theme: theme, icon: Icons.mail_outline, text: 'support@csbouira.dz'),
                    const SizedBox(height: AppSpacing.stackSm),
                    _FeatureRow(theme: theme, icon: Icons.language, text: 'www.csbouira.dz'),
                  ],
                ),
                const SizedBox(height: AppSpacing.stackLg),
                Center(
                  child: Text(
                    'Built with Flutter & Supabase',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(153),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.stackMd),
              ],
            ),
          ),
        ),
      ),
    );
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

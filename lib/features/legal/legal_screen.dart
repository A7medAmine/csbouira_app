import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:csbouira_app/core/theme/app_spacing.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';
import '../../core/theme/app_surfaces.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String assetPath;

  const LegalScreen({super.key, required this.title, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: context.surfaces.page,
      appBar: AppBar(
        backgroundColor: context.surfaces.page,
        title: Text(title),
      ),
      body: FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(assetPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.failedToLoadData,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return Markdown(
            data: snapshot.data ?? '',
            styleSheet: MarkdownStyleSheet(
              h1: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              h2: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              h3: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              p: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
              listBullet: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              strong: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              a: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
              horizontalRuleDecoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withAlpha(51),
                  ),
                ),
              ),
              tableBorder: TableBorder.all(
                color: theme.colorScheme.outlineVariant.withAlpha(77),
              ),
              tableHead: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              tableBody: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              code: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontFamily: 'JetBrainsMono',
              ),
              codeblockDecoration: BoxDecoration(
                color: context.surfaces.card,
                borderRadius: BorderRadius.circular(8),
              ),
              blockquoteDecoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
          );
        },
      ),
    );
  }
}

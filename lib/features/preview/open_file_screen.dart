import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';

import '../../data/providers/catalog_providers.dart';
import '../../shared/widgets/fetch_error_widget.dart';
import 'open_catalog_file.dart';

/// Target of `csbouira://file/<id>` links: finds the file in the catalogue
/// and replaces itself with the previewer.
class OpenFileScreen extends ConsumerStatefulWidget {
  final String fileId;

  const OpenFileScreen({super.key, required this.fileId});

  @override
  ConsumerState<OpenFileScreen> createState() => _OpenFileScreenState();
}

class _OpenFileScreenState extends ConsumerState<OpenFileScreen> {
  bool _opened = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final indexAsync = ref.watch(catalogIndexProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: indexAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => FetchErrorWidget(error: e),
        data: (index) {
          final entry = index.byId(widget.fileId);
          if (entry != null) {
            if (!_opened) {
              _opened = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) openCatalogFile(context, index, entry, replace: true);
              });
            }
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.link_off, size: 56, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text(
                    l10n.linkFileNotFound,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => context.go('/'),
                    child: Text(l10n.linkGoHome),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

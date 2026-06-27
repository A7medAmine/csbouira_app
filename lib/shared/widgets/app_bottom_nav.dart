import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';

class AppBottomNav extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppBottomNav({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    Widget navItem(IconData icon, String label, int index) {
      final isActive = navigationShell.currentIndex == index;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primaryContainer.withAlpha(51)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: 24,
              ),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsetsDirectional.only(
        start: 8,
        end: 8,
        top: 12,
        bottom: 16 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(51),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          navItem(Icons.home, l10n.bottomNavHome, 0),
          navItem(Icons.search, l10n.bottomNavSearch, 1),
          navItem(Icons.favorite, l10n.bottomNavFavs, 2),
          navItem(Icons.cloud_upload, l10n.bottomNavUpload, 3),
          navItem(Icons.person, l10n.bottomNavProfile, 4),
        ],
      ),
    );
  }
}

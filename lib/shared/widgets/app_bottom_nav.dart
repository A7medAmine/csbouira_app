import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomNav extends StatelessWidget {
  final String currentLocation;

  const AppBottomNav({super.key, required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    bool isActive(String path) {
      if (path == '/') return currentLocation == '/';
      return currentLocation.startsWith(path);
    }

    return Container(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 12,
        bottom: 16,
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
          _NavItem(
            icon: Icons.home,
            label: 'Home',
            isActive: isActive('/'),
            onTap: () => context.go('/'),
          ),
          _NavItem(
            icon: Icons.search,
            label: 'Search',
            isActive: isActive('/search'),
            onTap: () => context.push('/search'),
          ),
          const SizedBox(width: 64),
          _NavItem(
            icon: Icons.favorite,
            label: 'Favs',
            isActive: isActive('/favorites'),
            onTap: () => context.push('/favorites'),
          ),
          _NavItem(
            icon: Icons.person,
            label: 'Profile',
            isActive: isActive('/profile'),
            onTap: () => context.push('/profile'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
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
}

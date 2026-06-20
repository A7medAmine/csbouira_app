import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/drive_node.dart';
import '../../shared/widgets/favorite_star.dart';

class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extra = GoRouterState.of(context).extra;
    final DriveFile? file =
        extra is DriveFile ? extra : null;

    return Scaffold(
      backgroundColor: const Color(0xFF111221),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111221),
        title: Text(
          file?.name ?? 'Preview',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          if (file != null)
            FavoriteStar(
              itemType: 'file',
              itemPath: file.link,
              displayName: file.name,
            ),
          IconButton(
            icon: Icon(
              Icons.download,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Preview',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

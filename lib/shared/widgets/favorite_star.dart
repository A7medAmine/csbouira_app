import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/favorites_providers.dart';

class FavoriteStar extends ConsumerStatefulWidget {
  final String itemType;
  final String itemPath;
  final String displayName;
  final String? resourceType;
  final String? folderPath;
  final double size;

  const FavoriteStar({
    super.key,
    required this.itemType,
    required this.itemPath,
    required this.displayName,
    this.resourceType,
    this.folderPath,
    this.size = 22,
  });

  @override
  ConsumerState<FavoriteStar> createState() => _FavoriteStarState();
}

class _FavoriteStarState extends ConsumerState<FavoriteStar> {
  bool? _isFavorited;

  @override
  void initState() {
    super.initState();
    _loadFromState();
  }

  void _loadFromState() {
    final list = ref.read(favoritesListProvider).valueOrNull;
    if (list == null) return;
    final found = list.any(
      (e) => e.itemType == widget.itemType && e.itemPath == widget.itemPath,
    );
    if (mounted) setState(() => _isFavorited = found);
  }

  Future<void> _toggle() async {
    if (_isFavorited == null) return;
    final wasFavorited = _isFavorited!;
    setState(() => _isFavorited = !wasFavorited);
    try {
      if (wasFavorited) {
        await ref.read(favoritesListProvider.notifier).remove(
          widget.itemType,
          widget.itemPath,
        );
      } else {
        await ref.read(favoritesListProvider.notifier).add(FavoriteItem(
          itemType: widget.itemType,
          itemPath: widget.itemPath,
          displayName: widget.displayName,
          resourceType: widget.resourceType,
          folderPath: widget.folderPath,
          createdAt: DateTime.now(),
        ));
      }
    } catch (_) {
      if (mounted) setState(() => _isFavorited = wasFavorited);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(favoritesListProvider, (_, __) => _loadFromState());

    final theme = Theme.of(context);
    final isFav = _isFavorited ?? false;
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Icon(
          isFav ? Icons.star : Icons.star_border,
          key: ValueKey<bool>(isFav),
          color: isFav ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          size: widget.size,
        ),
      ),
    );
  }
}

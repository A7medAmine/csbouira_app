import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/auth_providers.dart';
import '../../data/providers/favorites_providers.dart';

class FavoriteStar extends ConsumerStatefulWidget {
  final String itemType;
  final String itemPath;
  final String displayName;
  final String? resourceType;
  final double size;

  const FavoriteStar({
    super.key,
    required this.itemType,
    required this.itemPath,
    required this.displayName,
    this.resourceType,
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
    _loadState();
  }

  Future<void> _loadState() async {
    final repo = ref.read(favoritesRepositoryProvider);
    try {
      final result = await repo.isFavorite(widget.itemType, widget.itemPath);
      if (mounted) setState(() => _isFavorited = result);
    } catch (_) {
      if (mounted) setState(() => _isFavorited = false);
    }
  }

  Future<void> _toggle() async {
    if (_isFavorited == null) return;
    final repo = ref.read(favoritesRepositoryProvider);
    final wasFavorited = _isFavorited!;
    setState(() => _isFavorited = !wasFavorited);
    try {
      if (wasFavorited) {
        await repo.removeFavorite(widget.itemType, widget.itemPath);
      } else {
        await repo.addFavorite(widget.itemType, widget.itemPath, widget.displayName,
            resourceType: widget.resourceType);
      }
      ref.invalidate(favoritesListProvider);
    } catch (_) {
      if (mounted) setState(() => _isFavorited = wasFavorited);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(favoritesListProvider, (_, __) => _loadState());

    final theme = Theme.of(context);
    final isFav = _isFavorited ?? false;
    return GestureDetector(
      onTap: _toggle,
      child: Icon(
        isFav ? Icons.star : Icons.star_border,
        color: isFav ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        size: widget.size,
      ),
    );
  }
}

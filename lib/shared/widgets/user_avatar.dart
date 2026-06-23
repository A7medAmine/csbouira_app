import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

String userInitials(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  return name[0].toUpperCase();
}

class UserAvatar extends StatelessWidget {
  final double size;
  final String? avatarUrl;
  final String fullName;

  const UserAvatar({
    super.key,
    required this.size,
    this.avatarUrl,
    required this.fullName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = userInitials(fullName);

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: CachedNetworkImage(
          imageUrl: avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _InitialsCircle(
            theme: theme,
            initials: initials,
            size: size,
          ),
          placeholder: (_, __) => CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      );
    }

    return _InitialsCircle(theme: theme, initials: initials, size: size);
  }
}

class _InitialsCircle extends StatelessWidget {
  final ThemeData theme;
  final String initials;
  final double size;

  const _InitialsCircle({
    required this.theme,
    required this.initials,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          initials,
          style: theme.textTheme.displayLarge?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }
}

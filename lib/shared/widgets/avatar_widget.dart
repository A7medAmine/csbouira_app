import 'dart:convert';
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final double size;
  final String? avatarUrl;
  final String? avatarBase64;
  final String initials;
  final bool showEditButton;
  final VoidCallback? onEdit;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;

  const AvatarWidget({
    super.key,
    required this.size,
    this.avatarUrl,
    this.avatarBase64,
    required this.initials,
    this.showEditButton = false,
    this.onEdit,
    this.backgroundColor,
    this.boxShadow,
  });

  Widget _buildAvatar(ThemeData theme) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _InitialsCircle(theme: theme, initials: initials, size: size),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            );
          },
        ),
      );
    }
    if (avatarBase64 != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.memory(
          base64Decode(avatarBase64!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _InitialsCircle(theme: theme, initials: initials, size: size),
        ),
      );
    }
    return _InitialsCircle(theme: theme, initials: initials, size: size);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(size / 2),
            boxShadow: boxShadow,
          ),
          child: _buildAvatar(theme),
        ),
        if (showEditButton && onEdit != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0D0D14),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.edit,
                  color: theme.colorScheme.onPrimary,
                  size: size * 0.2,
                ),
              ),
            ),
          ),
      ],
    );
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
    return Center(
      child: Text(
        initials,
        style: theme.textTheme.displayLarge?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}

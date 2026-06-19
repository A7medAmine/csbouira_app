import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UploadFab extends StatelessWidget {
  final double bottom;

  const UploadFab({super.key, this.bottom = 35});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: IgnorePointer(
        ignoring: false,
        child: Center(
          child: GestureDetector(
            onTap: () => context.push('/upload'),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primaryContainer.withAlpha(102),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.add,
                color: theme.colorScheme.onPrimaryContainer,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

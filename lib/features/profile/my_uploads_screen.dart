import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/providers/my_uploads_provider.dart';

class MyUploadsScreen extends ConsumerWidget {
  const MyUploadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final uploadsAsync = ref.watch(myUploadsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Uploads',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: uploadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            'Failed to load uploads.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        data: (uploads) {
          if (uploads.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(102),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No uploads yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your uploaded resources will appear here.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withAlpha(153),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginMobile,
              AppSpacing.stackSm,
              AppSpacing.marginMobile,
              32,
            ),
            itemCount: uploads.length,
            itemBuilder: (context, index) {
              final item = uploads[index];
              final fileName = item['file_name'] as String? ?? '';
              final moduleName = item['module_name'] as String? ?? '';
              final grade = item['grade'] as String? ?? '';
              final semester = item['semester'] as String? ?? '';
              final fileType = item['file_type'] as String? ?? '';
              final createdAt = item['created_at'] as String? ?? '';

              final date = createdAt.isNotEmpty
                  ? createdAt.substring(0, 10)
                  : '';

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.stackSm),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.stackMd),
                  decoration: BoxDecoration(
                    color: const Color(0x0D15151F),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: const Color(0xFF1A1A26).withAlpha(128),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer.withAlpha(51),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              fileType == 'Cours' || fileType == 'Summary'
                                  ? Icons.article
                                  : fileType == 'TP' || fileType == 'TD'
                                      ? Icons.assignment
                                      : fileType == 'Exam' || fileType == 'Test'
                                          ? Icons.quiz
                                          : Icons.insert_drive_file,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.stackSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  moduleName,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  fileName,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.stackSm),
                      Row(
                        children: [
                          _Tag(theme: theme, label: grade),
                          const SizedBox(width: 6),
                          _Tag(theme: theme, label: semester),
                          const SizedBox(width: 6),
                          _Tag(theme: theme, label: fileType),
                          if (date.isNotEmpty) ...[
                            const Spacer(),
                            Text(
                              date,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant.withAlpha(153),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final ThemeData theme;
  final String label;

  const _Tag({required this.theme, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(51),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontSize: 10,
        ),
      ),
    );
  }
}

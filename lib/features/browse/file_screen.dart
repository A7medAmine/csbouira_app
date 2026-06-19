import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/drive_node.dart';
import '../../data/providers/drive_providers.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/upload_fab.dart';

class FileScreen extends StatefulWidget {
  final String year;
  final String semester;
  final String module;
  final String folder;
  final String subpath;

  const FileScreen({
    super.key,
    required this.year,
    required this.semester,
    required this.module,
    required this.folder,
    this.subpath = '',
  });

  @override
  State<FileScreen> createState() => _FileScreenState();
}

enum _SortMode { nameAsc, nameDesc, type }

class _FileScreenState extends State<FileScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';
  bool _isGridView = false;
  _SortMode _sortMode = _SortMode.nameAsc;

  List<String> get _segments {
    final parts = <String>[widget.year];
    if (widget.semester.isNotEmpty) parts.add(widget.semester);
    if (widget.module.isNotEmpty) parts.add(widget.module);
    parts.add(widget.folder);
    if (widget.subpath.isNotEmpty) {
      parts.addAll(widget.subpath.split('>'));
    }
    return parts;
  }

  String _buildSubpath(String subfolderName) {
    if (widget.subpath.isEmpty) return subfolderName;
    return '${widget.subpath}>$subfolderName';
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1D1E2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sort by',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _SortOption(
                label: 'Name (A-Z)',
                isSelected: _sortMode == _SortMode.nameAsc,
                onTap: () {
                  setState(() => _sortMode = _SortMode.nameAsc);
                  Navigator.pop(ctx);
                },
              ),
              _SortOption(
                label: 'Name (Z-A)',
                isSelected: _sortMode == _SortMode.nameDesc,
                onTap: () {
                  setState(() => _sortMode = _SortMode.nameDesc);
                  Navigator.pop(ctx);
                },
              ),
              _SortOption(
                label: 'Type',
                isSelected: _sortMode == _SortMode.type,
                onTap: () {
                  setState(() => _sortMode = _SortMode.type);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<MapEntry<String, DriveNode>> _sortSubfolders(
    List<MapEntry<String, DriveNode>> entries,
  ) {
    switch (_sortMode) {
      case _SortMode.nameDesc:
        return List.from(entries)..sort((a, b) => b.key.compareTo(a.key));
      case _SortMode.type:
        return List.from(entries)
          ..sort((a, b) => a.key.compareTo(b.key));
      case _SortMode.nameAsc:
        return List.from(entries)..sort((a, b) => a.key.compareTo(b.key));
    }
  }

  List<DriveFile> _sortFiles(List<DriveFile> files) {
    switch (_sortMode) {
      case _SortMode.nameDesc:
        return List.from(files)
          ..sort((a, b) => b.name.compareTo(a.name));
      case _SortMode.type:
        return List.from(files)
          ..sort(
            (a, b) => a.name
                .split('.')
                .last
                .compareTo(b.name.split('.').last),
          );
      case _SortMode.nameAsc:
        return List.from(files)
          ..sort((a, b) => a.name.compareTo(b.name));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocation = GoRouterState.of(context).uri.toString();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: SafeArea(
        child: Stack(
          children: [
            Consumer(
              builder: (context, ref, _) {
                final nodeAsync = ref.watch(
                  driveNodeProvider(drivePathKey(_segments)),
                );

                return nodeAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) =>
                      Center(child: Text('Failed to load: $err')),
                  data: (node) {
                    if (node == null) {
                      return Center(
                        child: Text(
                          'Folder not found',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    final query = _searchQuery.toLowerCase();

                    final subfolders = query.isEmpty
                        ? _sortSubfolders(
                            node.subfolders.entries.toList(),
                          )
                        : _sortSubfolders(
                            node.subfolders.entries
                                .where(
                                  (e) =>
                                      e.key.toLowerCase().contains(query),
                                )
                                .toList(),
                          );
                    final files = query.isEmpty
                        ? _sortFiles(node.files)
                        : _sortFiles(
                            node.files
                                .where(
                                  (f) =>
                                      f.name.toLowerCase().contains(query),
                                )
                                .toList(),
                          );

                    final hasContent =
                        subfolders.isNotEmpty || files.isNotEmpty;

                    return Column(
                      children: [
                        _Header(
                          year: widget.year,
                          module: widget.module,
                          folder: widget.folder,
                          theme: theme,
                        ),

                        _SearchBar(
                          controller: _searchController,
                          onChanged: (v) =>
                              setState(() => _searchQuery = v),
                          onFilterTap: _showFilterSheet,
                          theme: theme,
                        ),

                        Expanded(
                          child: !hasContent
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        query.isNotEmpty
                                            ? Icons.search_off
                                            : Icons.folder_off,
                                        size: 64,
                                        color: theme.colorScheme
                                            .onSurfaceVariant,
                                      ),
                                      const SizedBox(
                                          height: AppSpacing.stackMd),
                                      Text(
                                        query.isNotEmpty
                                            ? 'No matching files or folders'
                                            : 'No files available',
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                          color: theme.colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView(
                                  padding: const EdgeInsets.only(
                                    left: AppSpacing.marginMobile,
                                    right: AppSpacing.marginMobile,
                                    top: AppSpacing.stackLg,
                                    bottom: 160,
                                  ),
                                  children: [
                                    if (subfolders.isNotEmpty) ...[
                                      _SectionHeader(
                                        title: 'Subfolders',
                                        count:
                                            '${subfolders.length} items',
                                        theme: theme,
                                      ),
                                      const SizedBox(
                                          height: AppSpacing.stackMd),
                                      ...subfolders.map(
                                        (entry) => _FolderCard(
                                          name: entry.key,
                                          node: entry.value,
                                          theme: theme,
                                          onTap: entry.value.isEmpty
                                              ? null
                                              : () {
                                                  final newSub =
                                                      _buildSubpath(
                                                          entry.key);
                                                  if (widget.semester
                                                      .isEmpty) {
                                                    context.push(
                                                      '/year/${Uri.encodeComponent(widget.year)}'
                                                      '/books'
                                                      '?sub=${Uri.encodeComponent(newSub)}',
                                                    );
                                                  } else {
                                                    context.push(
                                                      '/year/${Uri.encodeComponent(widget.year)}'
                                                      '/semester/${Uri.encodeComponent(widget.semester)}'
                                                      '/module/${Uri.encodeComponent(widget.module)}'
                                                      '/folder/${Uri.encodeComponent(widget.folder)}'
                                                      '?sub=${Uri.encodeComponent(newSub)}',
                                                    );
                                                  }
                                                },
                                        ),
                                      ),
                                      if (files.isNotEmpty)
                                        const SizedBox(
                                            height: AppSpacing.stackLg),
                                    ],
                                    if (files.isNotEmpty) ...[
                                      _SectionHeader(
                                        title: 'Files',
                                        theme: theme,
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _ViewToggleButton(
                                              icon: Icons.grid_view,
                                              isActive: _isGridView,
                                              theme: theme,
                                              onTap: () => setState(
                                                  () => _isGridView = true),
                                            ),
                                            _ViewToggleButton(
                                              icon: Icons.list,
                                              isActive: !_isGridView,
                                              theme: theme,
                                              onTap: () => setState(
                                                  () => _isGridView = false),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                          height: AppSpacing.stackMd),
                                      if (_isGridView)
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: files.map((file) {
                                            final ext = file.name
                                                .split('.')
                                                .last
                                                .toLowerCase();
                                            final (icon, color, _) =
                                                _fileTypeInfo(
                                                    ext, theme);
                                            return GestureDetector(
                                              onTap: () {
                                                if (file.link.isNotEmpty) {
                                                  context.push('/preview');
                                                }
                                              },
                                              child: Container(
                                                width: (MediaQuery.of(
                                                            context)
                                                        .size
                                                        .width -
                                                    44) /
                                                    2,
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: theme
                                                      .colorScheme.surface
                                                      .withAlpha(204),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12),
                                                  border: Border.all(
                                                    color: theme
                                                        .colorScheme
                                                        .outlineVariant
                                                        .withAlpha(26),
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: 48,
                                                      height: 48,
                                                      decoration:
                                                          BoxDecoration(
                                                        color: color
                                                            .withAlpha(51),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Icon(
                                                        icon,
                                                        color: color,
                                                        size: 24,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height: 12),
                                                    Text(
                                                      file.name,
                                                      style: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: theme
                                                            .colorScheme
                                                            .onSurface,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow
                                                              .ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        )
                                      else
                                        ...files.map(
                                        (file) => _FileCard(
                                          file: file,
                                          theme: theme,
                                          onTap: () {
                                            if (file.link.isNotEmpty) {
                                              context.push('/preview');
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AppBottomNav(currentLocation: currentLocation),
            ),

            const UploadFab(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String year;
  final String module;
  final String folder;
  final ThemeData theme;

  const _Header({
    required this.year,
    required this.module,
    required this.folder,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.stackMd,
        AppSpacing.marginMobile,
        AppSpacing.stackMd,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(200),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(30),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Breadcrumb
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _BreadcrumbItem(label: 'Drive', theme: theme),
                      _BreadcrumbChevron(theme: theme),
                      _BreadcrumbItem(label: year, theme: theme),
                      _BreadcrumbChevron(theme: theme),
                      _BreadcrumbItem(
                        label: folder,
                        theme: theme,
                        isActive: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Title
                Text(
                  module.isNotEmpty ? '$module / $folder' : folder,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.more_vert,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreadcrumbItem extends StatelessWidget {
  final String label;
  final ThemeData theme;
  final bool isActive;

  const _BreadcrumbItem({
    required this.label,
    required this.theme,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.labelMedium?.copyWith(
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _BreadcrumbChevron extends StatelessWidget {
  final ThemeData theme;

  const _BreadcrumbChevron({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        Icons.chevron_right,
        size: 14,
        color: theme.colorScheme.outline,
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;
  final ThemeData theme;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        AppSpacing.stackMd,
        AppSpacing.marginMobile,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withAlpha(51),
                ),
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  hintText: 'Search files and folders...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(128),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withAlpha(51),
                ),
              ),
              child: Icon(
                Icons.filter_list,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? count;
  final ThemeData theme;
  final Widget? trailing;

  const _SectionHeader({
    required this.title,
    this.count,
    required this.theme,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 8),
              Text(
                count!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isActive,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 20,
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final String name;
  final DriveNode node;
  final ThemeData theme;
  final VoidCallback? onTap;

  const _FolderCard({
    required this.name,
    required this.node,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fileCount = node.totalFiles;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.stackMd),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: node.isEmpty
                  ? theme.colorScheme.outlineVariant.withAlpha(26)
                  : theme.colorScheme.outlineVariant.withAlpha(26),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  node.isEmpty ? Icons.folder_off : Icons.folder,
                  color: node.isEmpty
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: node.isEmpty
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (!node.isEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '$fileCount files',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!node.isEmpty)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.outline,
                ),
              if (node.isEmpty)
                Text(
                  'Empty',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  final DriveFile file;
  final ThemeData theme;
  final VoidCallback onTap;

  const _FileCard({
    required this.file,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = file.name.split('.').last.toLowerCase();
    final (icon, color, showBadge) = _fileTypeInfo(ext, theme);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.stackSm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withAlpha(204),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withAlpha(26),
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  if (showBadge)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'PDF',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ext.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.more_vert,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

(IconData, Color, bool) _fileTypeInfo(String ext, ThemeData theme) {
  switch (ext) {
    case 'pdf':
      return (Icons.description, Colors.red, true);
    case 'jpg':
    case 'jpeg':
    case 'png':
    case 'gif':
    case 'webp':
      return (Icons.image, Colors.blue, false);
    case 'doc':
    case 'docx':
      return (Icons.description, Colors.blue, false);
    case 'xls':
    case 'xlsx':
      return (Icons.table_chart, Colors.green, false);
    case 'ppt':
    case 'pptx':
      return (Icons.slideshow, Colors.orange, false);
    default:
      return (Icons.insert_drive_file, theme.colorScheme.onSurfaceVariant, false);
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer.withAlpha(51)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

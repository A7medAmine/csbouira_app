import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';

import '../../core/ai_prompt_template.dart';
import '../../core/error_messages.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/drive_node.dart';
import '../../data/navigation_data.dart';
import '../../data/providers/ai_prompts_provider.dart';
import '../../data/services/ai_prompts_store.dart';
import '../../data/services/ai_share_service.dart';
import '../ai_prompts/ai_prompt_texts.dart';
import '../ai_prompts/ai_prompts_screen.dart';

/// Opens the "Ask AI" sheet for [file]. [currentPage] and [totalPages] come
/// from the PDF viewer; with more than one page the user can send only the
/// page being viewed.
Future<void> showAskAiSheet(
  BuildContext context, {
  required DriveFile file,
  List<String>? folderPath,
  int currentPage = 0,
  int totalPages = 0,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _AskAiSheet(
      file: file,
      folderPath: folderPath,
      currentPage: currentPage,
      totalPages: totalPages,
    ),
  );
}

class _AskAiSheet extends ConsumerStatefulWidget {
  final DriveFile file;
  final List<String>? folderPath;
  final int currentPage;
  final int totalPages;

  const _AskAiSheet({
    required this.file,
    required this.folderPath,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  ConsumerState<_AskAiSheet> createState() => _AskAiSheetState();
}

class _AskAiSheetState extends ConsumerState<_AskAiSheet> {
  final _text = TextEditingController();
  String? _promptId;
  bool _pageOnly = false;

  /// True once the user typed in the prompt; scope changes then keep the text.
  bool _edited = false;
  bool _busy = false;

  bool get _canSendPage =>
      widget.totalPages > 1 &&
      widget.currentPage >= 1 &&
      widget.file.name.toLowerCase().endsWith('.pdf');

  String get _mimeType => _pageOnly
      ? 'application/pdf'
      : AiShareService.mimeTypeOf(widget.file.name);

  @override
  void initState() {
    super.initState();
    _pickInitialPrompt();
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _pickInitialPrompt() async {
    final notifier = ref.read(aiPromptsProvider.notifier);
    final prompts = await ref.read(aiPromptsProvider.future);
    final lastUsed = await notifier.lastUsed();
    if (!mounted || prompts.isEmpty) return;
    final prompt = prompts.firstWhere(
      (p) => p.id == lastUsed,
      orElse: () => prompts.first,
    );
    _select(prompt);
  }

  void _select(AiPrompt prompt) {
    setState(() {
      _promptId = prompt.id;
      _edited = false;
      _text.text = _fill(prompt);
    });
  }

  String _fill(AiPrompt prompt) {
    final l10n = AppLocalizations.of(context)!;
    final path = widget.folderPath;
    final module =
        path != null && path.length > 2 ? DrivePathParts.parse(path).module : '';
    return fillAiPrompt(aiPromptBody(prompt, l10n), {
      'file': widget.file.name,
      'module': module,
      'page': _pageOnly ? '${widget.currentPage}' : '',
      'language': l10n.askAiAnswerLanguage,
    });
  }

  void _setPageOnly(bool pageOnly) {
    setState(() => _pageOnly = pageOnly);
    if (_edited) return;
    final prompts = ref.read(aiPromptsProvider).valueOrNull ?? const [];
    for (final p in prompts) {
      if (p.id == _promptId) _select(p);
    }
  }

  /// Prepares the file, copies the prompt (some apps ignore the text that
  /// comes with a file) and hands both to [deliver].
  Future<void> _send(
    Future<void> Function(AiShareService service, File file, String text)
        deliver,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final service = ref.read(aiShareServiceProvider);
    final text = _text.text.trim();
    setState(() => _busy = true);
    try {
      final file = await service.prepare(
        widget.file,
        page: _pageOnly ? widget.currentPage : null,
      );
      await Clipboard.setData(ClipboardData(text: text));
      await deliver(service, file, text);
      if (_promptId != null) {
        ref.read(aiPromptsProvider.notifier).setLastUsed(_promptId!);
      }
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.askAiPasteHint)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(
        content: Text(l10n.askAiFailed(friendlyErrorMessage(e, l10n))),
      ));
    }
  }

  void _sendToApp(AiApp app) {
    final mimeType = _mimeType;
    _send((service, file, text) async {
      try {
        await service.shareToApp(app.packageName, file, mimeType, text);
      } on PlatformException {
        await service.shareWithChooser(file, mimeType, text);
      }
    });
  }

  void _sendWithChooser() {
    final mimeType = _mimeType;
    _send((service, file, text) =>
        service.shareWithChooser(file, mimeType, text));
  }

  Future<void> _copyPrompt() async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(ClipboardData(text: _text.text.trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.askAiPromptCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final prompts = ref.watch(aiPromptsProvider).valueOrNull ?? const [];
    final apps = ref.watch(installedAiAppsProvider(_mimeType));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.stackSm),
                Expanded(
                  child: Text(
                    l10n.askAiTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.file.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (_canSendPage) ...[
              const SizedBox(height: AppSpacing.stackMd),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.description_outlined),
                    label: Text(l10n.askAiScopeFile),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.crop_portrait),
                    label: Text(l10n.askAiScopePage(widget.currentPage)),
                  ),
                ],
                selected: {_pageOnly},
                onSelectionChanged:
                    _busy ? null : (s) => _setPageOnly(s.first),
              ),
            ],
            const SizedBox(height: AppSpacing.stackMd),
            Text(
              l10n.askAiPromptLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.stackSm),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final prompt in prompts) ...[
                    ChoiceChip(
                      label: Text(aiPromptTitle(prompt, l10n)),
                      selected: prompt.id == _promptId,
                      onSelected: _busy ? null : (_) => _select(prompt),
                    ),
                    const SizedBox(width: AppSpacing.stackSm),
                  ],
                  ActionChip(
                    avatar: const Icon(Icons.tune, size: 18),
                    label: Text(l10n.askAiEditPrompts),
                    onPressed: _busy
                        ? null
                        : () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const AiPromptsScreen(),
                            )),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.stackSm),
            TextField(
              controller: _text,
              enabled: !_busy,
              minLines: 3,
              maxLines: 8,
              onChanged: (_) => _edited = true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            Text(
              l10n.askAiSendTo,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.stackSm),
            if (_busy)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackMd),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.askAiPreparing),
                  ],
                ),
              )
            else ...[
              if (Platform.isAndroid &&
                  apps.hasValue &&
                  apps.requireValue.isEmpty) ...[
                Text(
                  l10n.askAiNoApps,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.stackSm),
              ],
              Wrap(
                spacing: AppSpacing.stackSm,
                runSpacing: AppSpacing.stackMd,
                children: [
                  for (final app in apps.valueOrNull ?? const <AiApp>[])
                    _AppTile(
                      label: app.label,
                      icon: app.icon != null
                          ? Image.memory(app.icon!, width: 40, height: 40)
                          : const Icon(Icons.smart_toy_outlined),
                      onTap: () => _sendToApp(app),
                    ),
                  _AppTile(
                    label: l10n.askAiOtherApps,
                    icon: Icon(Icons.share, color: theme.colorScheme.primary),
                    onTap: _sendWithChooser,
                  ),
                  _AppTile(
                    label: l10n.askAiCopyPrompt,
                    icon: Icon(Icons.copy, color: theme.colorScheme.primary),
                    onTap: _copyPrompt,
                  ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.stackSm),
          ],
        ),
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const _AppTile({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox(
        width: 76,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: icon,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

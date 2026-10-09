import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:csbouira_app/l10n/app_localizations.dart';

import '../../core/ai_prompt_template.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_surfaces.dart';
import '../../data/providers/ai_prompts_provider.dart';
import '../../data/services/ai_prompts_store.dart';
import '../../shared/widgets/fetch_error_widget.dart';
import 'ai_prompt_texts.dart';

/// Lists the "Ask AI" prompts and lets the user add, edit and delete them.
class AiPromptsScreen extends ConsumerWidget {
  const AiPromptsScreen({super.key});

  Future<void> _confirmRestore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.aiPromptsRestoreConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.deleteCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.aiPromptsRestoreAction),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(aiPromptsProvider.notifier).restoreDefaults();
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AiPrompt prompt,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(aiPromptsProvider.notifier);
    final index = await notifier.remove(prompt.id);
    if (index == -1) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(l10n.aiPromptDeleted),
        action: SnackBarAction(
          label: l10n.aiPromptUndo,
          onPressed: () => notifier.insert(index, prompt),
        ),
      ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final promptsAsync = ref.watch(aiPromptsProvider);

    return Scaffold(
      backgroundColor: context.surfaces.page,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          l10n.aiPromptsTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<void>(
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: () => _confirmRestore(context, ref),
                child: Text(l10n.aiPromptsRestore),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          AppSpacing.stackSm,
          AppSpacing.marginMobile,
          AppSpacing.stackMd,
        ),
        child: FilledButton.icon(
          onPressed: () => showAiPromptEditor(context),
          icon: const Icon(Icons.add),
          label: Text(l10n.aiPromptsAdd),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
          ),
        ),
      ),
      body: promptsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => FetchErrorWidget(error: err),
        data: (prompts) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.marginMobile,
            0,
            AppSpacing.marginMobile,
            AppSpacing.stackMd,
          ),
          children: [
            Text(
              l10n.aiPromptsIntro,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            if (prompts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackLg),
                child: Text(
                  l10n.aiPromptsEmpty,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            for (final prompt in prompts) ...[
              _PromptCard(
                prompt: prompt,
                onTap: () => showAiPromptEditor(context, prompt: prompt),
                onDelete: () => _delete(context, ref, prompt),
              ),
              const SizedBox(height: AppSpacing.stackSm),
            ],
          ],
        ),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  final AiPrompt prompt;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PromptCard({
    required this.prompt,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Material(
      color: context.surfaces.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: context.surfaces.cardBorder.withAlpha(128)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.stackMd,
            AppSpacing.stackSm,
            0,
            AppSpacing.stackMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.stackSm),
                    Text(
                      aiPromptTitle(prompt, l10n),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      aiPromptBody(prompt, l10n),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: l10n.aiPromptDelete,
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
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

/// Opens the editor for [prompt], or for a new prompt when null.
Future<void> showAiPromptEditor(BuildContext context, {AiPrompt? prompt}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _PromptEditor(prompt: prompt),
  );
}

class _PromptEditor extends ConsumerStatefulWidget {
  final AiPrompt? prompt;

  const _PromptEditor({this.prompt});

  @override
  ConsumerState<_PromptEditor> createState() => _PromptEditorState();
}

class _PromptEditorState extends ConsumerState<_PromptEditor> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _filled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prompt = widget.prompt;
    if (_filled || prompt == null) return;
    final l10n = AppLocalizations.of(context)!;
    _title.text = aiPromptTitle(prompt, l10n);
    _body.text = aiPromptBody(prompt, l10n);
    _filled = true;
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  void _insert(String token) {
    final value = _body.value;
    final selection = value.selection.isValid
        ? value.selection
        : TextSelection.collapsed(offset: value.text.length);
    final text = value.text.replaceRange(selection.start, selection.end, token);
    _body.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: selection.start + token.length),
    );
  }

  Future<void> _save() async {
    final body = _body.text.trim();
    if (body.isEmpty) return;
    var title = _title.text.trim();
    if (title.isEmpty) {
      final firstLine = body.split('\n').first;
      title = firstLine.length > 30 ? '${firstLine.substring(0, 30)}…' : firstLine;
    }
    final notifier = ref.read(aiPromptsProvider.notifier);
    final prompt = widget.prompt;
    if (prompt == null) {
      await notifier.add(title, body);
    } else {
      await notifier.edit(prompt.id, title, body);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.prompt == null ? l10n.aiPromptsAdd : l10n.aiPromptEditTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.aiPromptNameLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            TextField(
              controller: _body,
              minLines: 5,
              maxLines: 12,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.aiPromptBodyLabel,
                alignLabelWithHint: true,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            Text(
              l10n.aiPromptInsertLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.stackSm),
            Wrap(
              spacing: AppSpacing.stackSm,
              runSpacing: AppSpacing.stackSm,
              children: [
                for (final name in aiPromptPlaceholders)
                  ActionChip(
                    label: Text(aiPlaceholderLabel(name, l10n)),
                    tooltip: aiPromptToken(name),
                    onPressed: () {
                      _insert(aiPromptToken(name));
                      setState(() {});
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.stackSm),
            Text(
              l10n.aiPromptPlaceholderHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            FilledButton(
              onPressed: _body.text.trim().isEmpty ? null : _save,
              child: Text(l10n.aiPromptSave),
            ),
          ],
        ),
      ),
    );
  }
}

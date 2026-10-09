import 'package:csbouira_app/l10n/app_localizations.dart';

import '../../core/ai_prompt_template.dart';
import '../../data/services/ai_prompts_store.dart';

/// Name of [prompt], localized for built-in prompts the user hasn't edited.
String aiPromptTitle(AiPrompt prompt, AppLocalizations l10n) =>
    prompt.title ??
    switch (prompt.builtInName) {
      'explain' => l10n.aiPresetExplainTitle,
      'summarize' => l10n.aiPresetSummarizeTitle,
      'quiz' => l10n.aiPresetQuizTitle,
      'solve' => l10n.aiPresetSolveTitle,
      _ => '',
    };

/// Text of [prompt] with its placeholders still in, localized for built-in
/// prompts the user hasn't edited.
String aiPromptBody(AiPrompt prompt, AppLocalizations l10n) {
  if (prompt.body != null) return prompt.body!;
  final instruction = switch (prompt.builtInName) {
    'explain' => l10n.aiPresetExplainBody,
    'summarize' => l10n.aiPresetSummarizeBody,
    'quiz' => l10n.aiPresetQuizBody,
    'solve' => l10n.aiPresetSolveBody,
    _ => '',
  };
  final context = l10n.askAiPromptContext(
    aiPromptToken('module'),
    aiPromptToken('file'),
    aiPromptToken('page'),
    aiPromptToken('language'),
  );
  return '$instruction\n\n$context';
}

/// Chip label for a placeholder in the prompt editor.
String aiPlaceholderLabel(String name, AppLocalizations l10n) => switch (name) {
      'file' => l10n.aiPlaceholderFile,
      'module' => l10n.aiPlaceholderModule,
      'page' => l10n.aiPlaceholderPage,
      'language' => l10n.aiPlaceholderLanguage,
      _ => name,
    };

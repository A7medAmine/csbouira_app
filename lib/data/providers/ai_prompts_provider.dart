import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ai_prompts_store.dart';

final aiPromptsProvider =
    AsyncNotifierProvider<AiPromptsNotifier, List<AiPrompt>>(
  AiPromptsNotifier.new,
);

/// The "Ask AI" prompts, editable from the profile settings.
class AiPromptsNotifier extends AsyncNotifier<List<AiPrompt>> {
  final _store = AiPromptsStore();

  @override
  Future<List<AiPrompt>> build() => _store.getAll();

  Future<List<AiPrompt>> _current() async => state.valueOrNull ?? await future;

  Future<void> _set(List<AiPrompt> prompts) async {
    state = AsyncData(prompts);
    await _store.save(prompts);
  }

  Future<void> add(String title, String body) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _set([...await _current(), AiPrompt(id: id, title: title, body: body)]);
  }

  Future<void> edit(String id, String title, String body) async {
    await _set([
      for (final p in await _current())
        p.id == id ? p.copyWith(title: title, body: body) : p,
    ]);
  }

  /// Removes the prompt and returns its index, for [insert] on undo.
  Future<int> remove(String id) async {
    final prompts = List.of(await _current());
    final index = prompts.indexWhere((p) => p.id == id);
    if (index == -1) return -1;
    prompts.removeAt(index);
    await _set(prompts);
    return index;
  }

  Future<void> insert(int index, AiPrompt prompt) async {
    final prompts = List.of(await _current());
    prompts.insert(index.clamp(0, prompts.length), prompt);
    await _set(prompts);
  }

  Future<void> restoreDefaults() async {
    await _store.reset();
    state = AsyncData(List.of(AiPromptsStore.defaults));
  }

  Future<String?> lastUsed() => _store.getLastUsed();

  Future<void> setLastUsed(String id) => _store.setLastUsed(id);
}

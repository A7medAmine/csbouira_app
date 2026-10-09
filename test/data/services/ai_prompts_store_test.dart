import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csbouira_app/data/services/ai_prompts_store.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts with the built-in prompts', () async {
    final prompts = await AiPromptsStore().getAll();
    expect(prompts.map((p) => p.builtInName),
        ['explain', 'summarize', 'quiz', 'solve']);
    expect(prompts.every((p) => p.title == null && p.body == null), isTrue);
  });

  test('saves edits and custom prompts, reset restores defaults', () async {
    final store = AiPromptsStore();
    final prompts = await store.getAll();
    await store.save([
      prompts.first.copyWith(title: 'Mine', body: 'Explain {file}'),
      const AiPrompt(id: '42', title: 'Custom', body: 'Hi'),
    ]);

    final saved = await store.getAll();
    expect(saved.map((p) => p.id), ['builtin:explain', '42']);
    expect(saved.first.body, 'Explain {file}');
    expect(saved.last.isBuiltIn, isFalse);

    await store.reset();
    expect(await store.getAll(), hasLength(AiPromptsStore.defaults.length));
  });

  test('survives corrupt data', () async {
    SharedPreferences.setMockInitialValues({'ai_prompts': 'not json'});
    expect(await AiPromptsStore().getAll(),
        hasLength(AiPromptsStore.defaults.length));
  });

  test('remembers the last used prompt', () async {
    final store = AiPromptsStore();
    expect(await store.getLastUsed(), isNull);
    await store.setLastUsed('builtin:quiz');
    expect(await store.getLastUsed(), 'builtin:quiz');
  });
}

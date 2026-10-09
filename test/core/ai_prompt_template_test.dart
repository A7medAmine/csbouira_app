import 'package:flutter_test/flutter_test.dart';
import 'package:csbouira_app/core/ai_prompt_template.dart';

void main() {
  group('fillAiPrompt', () {
    const values = {
      'file': 'Cours 3.pdf',
      'module': 'Algo',
      'page': '',
      'language': 'English',
    };

    test('fills placeholders', () {
      expect(
        fillAiPrompt('Explain {file} from {module}. Answer in {language}.', values),
        'Explain Cours 3.pdf from Algo. Answer in English.',
      );
    });

    test('drops lines whose value is empty', () {
      expect(
        fillAiPrompt('Explain this.\n\nFile: {file}\nPage: {page}\nDone.', values),
        'Explain this.\n\nFile: Cours 3.pdf\nDone.',
      );
    });

    test('keeps unknown placeholders and plain braces', () {
      expect(
        fillAiPrompt('Use {unknown} and {} in f(x) = {x}', values),
        'Use {unknown} and {} in f(x) = {x}',
      );
    });

    test('collapses blank lines left by dropped lines and trims', () {
      expect(
        fillAiPrompt('A\n\nPage: {page}\n\n\nB\n', values),
        'A\n\nB',
      );
    });
  });
}

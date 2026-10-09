/// Placeholders an "Ask AI" prompt can use, filled when the prompt is sent.
const aiPromptPlaceholders = ['file', 'module', 'page', 'language'];

String aiPromptToken(String name) => '{$name}';

final _placeholder = RegExp(r'\{(\w+)\}');

/// Fills the `{name}` placeholders of [template] from [values].
///
/// A line that uses a placeholder whose value is empty is left out, so
/// `Page: {page}` disappears when the whole file is sent. Placeholders not in
/// [values] are kept as written.
String fillAiPrompt(String template, Map<String, String> values) {
  final lines = <String>[];
  for (final line in template.split('\n')) {
    var missing = false;
    final filled = line.replaceAllMapped(_placeholder, (m) {
      final value = values[m.group(1)];
      if (value == null) return m.group(0)!;
      if (value.isEmpty) missing = true;
      return value;
    });
    if (!missing) lines.add(filled);
  }
  return lines.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
}

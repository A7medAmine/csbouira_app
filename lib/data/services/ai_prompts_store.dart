import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// A saved "Ask AI" prompt.
///
/// Built-in prompts keep [title] and [body] null until the user edits them,
/// so their text follows the app language.
class AiPrompt {
  final String id;
  final String? title;
  final String? body;

  const AiPrompt({required this.id, this.title, this.body});

  static const builtInPrefix = 'builtin:';

  bool get isBuiltIn => id.startsWith(builtInPrefix);

  /// Name of the built-in prompt (`explain`, `summarize`, ...), or null.
  String? get builtInName =>
      isBuiltIn ? id.substring(builtInPrefix.length) : null;

  AiPrompt copyWith({String? title, String? body}) =>
      AiPrompt(id: id, title: title ?? this.title, body: body ?? this.body);

  Map<String, dynamic> toJson() => {
        'id': id,
        if (title != null) 'title': title,
        if (body != null) 'body': body,
      };

  factory AiPrompt.fromJson(Map<String, dynamic> json) => AiPrompt(
        id: json['id'] as String,
        title: json['title'] as String?,
        body: json['body'] as String?,
      );
}

/// The user's "Ask AI" prompts, kept in SharedPreferences. Until the user
/// changes anything the list is [defaults].
class AiPromptsStore {
  static const _key = 'ai_prompts';
  static const _lastUsedKey = 'ai_prompt_last_used';

  static const defaults = [
    AiPrompt(id: '${AiPrompt.builtInPrefix}explain'),
    AiPrompt(id: '${AiPrompt.builtInPrefix}summarize'),
    AiPrompt(id: '${AiPrompt.builtInPrefix}quiz'),
    AiPrompt(id: '${AiPrompt.builtInPrefix}solve'),
  ];

  Future<List<AiPrompt>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return List.of(defaults);
    try {
      return (jsonDecode(raw) as List)
          .map((e) => AiPrompt.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      return List.of(defaults);
    } on TypeError {
      return List.of(defaults);
    }
  }

  Future<void> save(List<AiPrompt> prompts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(prompts.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<String?> getLastUsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastUsedKey);
  }

  Future<void> setLastUsed(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUsedKey, id);
  }
}

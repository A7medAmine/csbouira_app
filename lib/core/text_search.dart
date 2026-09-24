/// Accent-, case- and typo-tolerant text matching used by search.
///
/// Everything here is pure Dart so it can be unit tested and reused from
/// background isolates.
library;

const _latinFolds = {
  'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a',
  'ç': 'c',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
  'ñ': 'n',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
  'ý': 'y', 'ÿ': 'y',
  'œ': 'oe', 'æ': 'ae',
};

const _arabicFolds = {
  'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا',
  'ة': 'ه',
  'ى': 'ي',
  'ؤ': 'و',
  'ئ': 'ي',
};

/// Arabic diacritics (tashkeel) and tatweel.
final _arabicMarks = RegExp('[ً-ٰٟـ]');

/// Anything that is not a letter or digit becomes a word separator.
final _separators = RegExp(r'[^\p{L}\p{N}]+', unicode: true);

/// Lowercases [input], strips Latin accents and Arabic diacritics, unifies
/// Arabic letter variants and collapses punctuation (`_`, `-`, `.`) into
/// single spaces.
String normalizeForSearch(String input) {
  final lower = input.toLowerCase().replaceAll(_arabicMarks, '');
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_latinFolds[char] ?? _arabicFolds[char] ?? char);
  }
  return buffer.toString().replaceAll(_separators, ' ').trim();
}

/// Splits already-normalized text into words.
List<String> searchTokens(String normalized) =>
    normalized.isEmpty ? const [] : normalized.split(' ');

/// Levenshtein distance, giving up early once it exceeds [max].
int boundedEditDistance(String a, String b, int max) {
  if ((a.length - b.length).abs() > max) return max + 1;
  var previous = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final current = List<int>.filled(b.length + 1, 0)..[0] = i;
    var rowMin = current[0];
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      current[j] = [
        previous[j] + 1,
        current[j - 1] + 1,
        previous[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
      if (current[j] < rowMin) rowMin = current[j];
    }
    if (rowMin > max) return max + 1;
    previous = current;
  }
  return previous[b.length];
}

int _allowedTypos(String token) {
  if (token.length >= 8) return 2;
  if (token.length >= 4) return 1;
  return 0;
}

/// Scores how well [text] matches [query]. Both must already be normalized
/// with [normalizeForSearch]. Returns 0 when there is no match; higher is
/// better.
///
/// Every query word must match some word of [text], either exactly, as a
/// prefix, as a substring, or (for longer words) with a small typo.
int matchScore(String query, String text) {
  final queryTokens = searchTokens(query);
  if (queryTokens.isEmpty) return 0;
  final textTokens = searchTokens(text);
  if (textTokens.isEmpty) return 0;

  var score = 0;
  for (final q in queryTokens) {
    var best = 0;
    for (final t in textTokens) {
      final int s;
      if (t == q) {
        s = 100;
      } else if (t.startsWith(q)) {
        s = 70;
      } else if (q.length >= 3 && t.contains(q)) {
        s = 40;
      } else {
        final typos = _allowedTypos(q);
        if (typos == 0) continue;
        // Compare against prefixes of about the query's length too, so
        // "algoritm" finds "algorithmique" and "corige" finds "corrige".
        var distance = boundedEditDistance(q, t, typos);
        for (var len = q.length - typos; len <= q.length + typos; len++) {
          if (len <= 0 || len >= t.length) continue;
          final d = boundedEditDistance(q, t.substring(0, len), typos);
          if (d < distance) distance = d;
        }
        s = distance <= typos ? 25 - distance * 5 : 0;
      }
      if (s > best) best = s;
      if (best == 100) break;
    }
    if (best == 0) return 0;
    score += best;
  }
  // Whole query appearing verbatim is the strongest signal.
  if (text.contains(query)) score += 50;
  return score;
}
